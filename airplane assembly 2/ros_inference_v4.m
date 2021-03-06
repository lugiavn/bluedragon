
%% load data
addpath(genpath('.'));
clc; clear; close all;
m = gen_inference_net('s/model');

%% const

PORT_NUMBER         = 12341;
BIN_NUM             = 20;

MAX_NAME_LENGTH     = 20; % must match ROS node param

DO_INFERENCE             = 1;
SEND_INFERENCE_TO_ROS    = 1;
DRAW_DISTRIBUTION_FIGURE = 99;
DRAW_START_DISTRIBUTION  = {'Body', 'body1','body2', 'nose_a1', 'nose_a2', 'Wing_AT', 'tail_at1', 'tail_at2', 'tail_at3'};
%DRAW_START_DISTRIBUTION  = {'space', 'body1', 'body2', 'body3', 'body4', 'body5', 'body6'};
%DRAW_START_DISTRIBUTION  = {'Nose_A', 'Wing_AD', 'Tail_AT'};
DRAW_END_DISTRIBUTION    = {'S'};

DRAW_POSITIONS_FIGURE    = 0;
DRAW_DETECTIONS_FIGURE   = 0;

DRAW_CURRENT_ACTION_PROB = 0; % todo


%% open connection

ros_tcp_connection                  = tcpip('localhost', PORT_NUMBER);
ros_tcp_connection.OutputBufferSize = 4 * length(m.grammar.symbols) * m.params.T;
ros_tcp_connection.InputBufferSize  = 4 * length(m.grammar.symbols) * m.params.T;
disp('Try connecting to ROS node....');
while 1
    try
        fopen(ros_tcp_connection)
        disp('Connected');
        break;
    catch e
        pause(1);
    end
end


%%


t               = 0;
nt              = 0;
inference_num   = 0;

detection_raw_result  = ones(length(m.detection.result), m.params.T);
m.start_conditions(:) = 1;

while t < m.params.T * m.params.downsample_ratio & t < 6000
    
    % exist signal
    if ros_tcp_connection.BytesAvailable == 5
        break;
    end
    
    %------------------------------------------------
    % get new frame data
    %------------------------------------------------
    if ros_tcp_connection.BytesAvailable >= 4 * (2 * 3 + BIN_NUM * 7)
        
        % new frame, update t
        t   = t + 1;
        nt  =  ceil(t / m.params.downsample_ratio);
        
        % read data from ROS
        rosdata    = fread(ros_tcp_connection, 2 * 3 + BIN_NUM * 7, 'float');
        
        % skip frame?
        if mod(t, m.params.downsample_ratio) ~= 0
            continue
        end
        
        % parse data
        frame_info           = struct;
        frame_info.lefthand  = rosdata(1:3);
        frame_info.righthand = rosdata(4:6);
        for b=0:length(m.detection.detectors)-1
            if m.detection.detectors(b+1).exist
                frame_info.bins(b+1).pq = rosdata(6 + b*7 + 1: 6 + b*7 + 7);
                frame_info.bins(b+1).H  = pq2H(frame_info.bins(b+1).pq);
            end
        end
        
        % run detection on new frame
        d = run_action_detections(frame_info, m.detection);
        d(find(isnan(d))) = 1;
        detection_raw_result(:,nt) = d;
        
        % update start condition
        for b=1:length(m.detection.detectors)
            if ~isempty(frame_info.bins(b).H)
                d = norm([-1, -1.3] - [frame_info.bins(b).pq(1), frame_info.bins(b).pq(2)]);
                % disp(d);
                if d > 1
                    for i=1:length(m.grammar.symbols)
                        if m.grammar.symbols(i).detector_id == b,
                            m.start_conditions(i,nt) = 0;
                        end
                    end
                end
            end
        end

        
        continue;
    end
    
    if t <= 0
        continue;
    end
    
    
    
    %------------------------------------------------
    % inference
    %------------------------------------------------
    if DO_INFERENCE
        inference_num = inference_num + 1;
        disp(['Inference num: ' num2str(inference_num)]);
        
        % compute detection result matrix
        for i=1:length(m.detection.result)
            %m.detection.result{i} = triu(repmat(detection_raw_result(i,:)', [1 m.params.T]));
            m.detection.result{i} = repmat(detection_raw_result(i,:)', [1 m.params.T]);
        end
        
        % do inference
        m = m_inference_v3(m);
        
        
        % send to ROS
        if SEND_INFERENCE_TO_ROS
            for i=length(m.grammar.symbols):-1:1
                s = m.grammar.symbols(i);
                name = [s.name '_start'];
                while length(name) < MAX_NAME_LENGTH, name = [name ' ']; end;
                fwrite(ros_tcp_connection, name, 'char');
                fwrite(ros_tcp_connection, s.start_distribution, 'float');

                name = [s.name '_end'];
                while length(name) < MAX_NAME_LENGTH, name = [name ' ']; end;
                fwrite(ros_tcp_connection, name, 'char');
                fwrite(ros_tcp_connection, s.end_distribution, 'float');
            end
        end
        
        % VRTS
        if ~exist('vrts_m')
            vrts_m = m_convert_by_rs(m, create_resolution_structure(m.params.T, nt, 10, 10));
        else
            vrts_m.detection.result = m.detection.result;
            vrts_m.start_conditions = m.start_conditions;
            
%             tic
%             if randi([1 10]) > 1
%             for i=1:1
%                 vrts_m = m_update_rs(vrts_m, nt);
%                 vrts_m = m_inference_v3(vrts_m);
%                 nx_figure(DRAW_DISTRIBUTION_FIGURE + 2);
%                 subplot(2, 2, i);
%                 m_plot_distributions(vrts_m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);
%                 hold on; plot(nt, 0, '*'); hold off;
%             end
%             end
%             toc;
            
            vrts_m = m_update_rs(vrts_m, nt, 1);
        end
        
        tic
        vrts_m = m_inference_v3(vrts_m);
        disp m_inference_v3(vrts_m)
        toc;
        if DRAW_DISTRIBUTION_FIGURE > 0
            nx_figure(DRAW_DISTRIBUTION_FIGURE); subplot(2, 1, 2);
            m_plot_distributions(vrts_m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);
            hold on; plot(nt, 0, '*'); hold off;
            ylim([0 1]);
        end
        
        
        % plot
        if DRAW_DISTRIBUTION_FIGURE > 0
            nx_figure(DRAW_DISTRIBUTION_FIGURE); subplot(2, 1, 1);
            m_plot_distributions(m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);
            hold on; plot(nt, 0, '*'); hold off;
            ylim([0 1]);
        end
        % linkaxes([findall(figure(DRAW_DISTRIBUTION_FIGURE), 'type', 'axes')]);
        pause(1);
    end
    
    
    %------------------------------------------------
    % misc
    %------------------------------------------------
    if DRAW_DETECTIONS_FIGURE
        nx_figure(DRAW_DETECTIONS_FIGURE);
        dnum = sum([m.detection.detectors.exist]);
        i    = 0;
        for d=1:length(m.detection.detectors)
            if m.detection.detectors(d).exist
                i = i + 1;
                subplot(dnum, 1, i);
                dr = detection_raw_result(d,:);
                dr(detection_raw_result(d,:) < 0.1) = 0.1;
                semilogy(dr);
                legend({['Bin ' num2str(d)]});
                
                hold on;
                x = (log(min(100, dr(nt))) - log(0.1)) / (log(100) - log(0.1));
                semilogy(nt, dr(nt), '*r');
                set(gca,'Color', x * [1 0.3 0.3] + (1 - x) * [1 1 1]);
                hold off;
            end
        end
        
    end
    
    if exist('frame_info') & DRAW_POSITIONS_FIGURE
        
        nx_figure(DRAW_POSITIONS_FIGURE);
        cla;
        axis equal;
        xlim([-1.5 0.5])
        ylim([-1.5 0.5])
        hold on;
        plot(frame_info.lefthand(1), frame_info.lefthand(2), '*r');
        plot(frame_info.righthand(1), frame_info.righthand(2), '*r');

        for b=0:length(m.detection.detectors)-1
          if ~isempty(frame_info.bins(b+1).H)
            plot(frame_info.bins(b+1).pq(1), frame_info.bins(b+1).pq(2), '.b');
            text(frame_info.bins(b+1).pq(1), frame_info.bins(b+1).pq(2), num2str(b+1)); 
            
            d = max(norm([frame_info.righthand(1), frame_info.righthand(2)] - [frame_info.bins(b+1).pq(1), frame_info.bins(b+1).pq(2)]), norm([frame_info.lefthand(1), frame_info.lefthand(2)] - [frame_info.bins(b+1).pq(1), frame_info.bins(b+1).pq(2)]));
            if d < 0.7
                plot(frame_info.bins(b+1).pq(1), frame_info.bins(b+1).pq(2), '+g');
            end
          end
        end

        hold off
    end
    
    if ~isempty(findall(0,'Type','Figure'))
        pause(0.1)
    end
    
end



fclose(ros_tcp_connection);
disp 'The End'
disp([num2str(inference_num * 30 / t) ' inferences per second']);
pause(1);




