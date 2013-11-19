

%% set up inference structure
downsample_ratio          = 9;
T                         = round(6000 / downsample_ratio);
m                         = struct;
m.grammar                 = data.grammar;
m                         = gen_inference_net(m, T, downsample_ratio, 120);

% structure for detection result
m.detection = struct;
for i=1:length(data.grammar.symbols)
    s = data.grammar.symbols(i);
    if s.is_terminal
        m.detection.result{s.detector_id} = ones(T);
    end
end

%% process

ms = {};

record_data = nx_record_figures_init(10, 'viz');

vid = VideoReader([data.path '/' test.filename]);

for t=1:99999999
    
    if mod(t, downsample_ratio) ~= floor(downsample_ratio/2)
        continue;
    end
    timestep =  ceil(t / downsample_ratio);
    if timestep > T || t > test.length + 300
        break;
    end
    
    if t <= test.length
        
        % get reaching hand
        hands = test.handsdetections(t,:);
        [ reaching_hand  missing_detections ] = get_reaching_hand( hands );
        
        % run detectors & update detection result
        detections_result = run_detectors( data.training.visualdetectors, missing_detections, reaching_hand );
        
        for i=1:length(data.training.visualdetectors)
            if ~isnan(detections_result(i))
                m.detection.result{i}(timestep,:) = detections_result(i);
            end
        end
    end
    
    % skip timestep
    if mod(timestep, 10) ~= 1
%         continue;
    end
    
    % new inference
    m = m_inference_v3(m);
    
    % viz
    if t <= test.length
        f = read(vid, t);
    end
    viz_inference2;
    pause(0.1);
    record_data = nx_record_figures_process(record_data);
    
    % save
    ms{timestep} = m_extract_small_data(m);
    
end

record_data = nx_record_figures_terminate(record_data);






