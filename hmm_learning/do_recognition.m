function [classes m] = do_recognition( s, m )
%DO_RECOGNITION Summary of this function goes here
%   Detailed explanation goes here

    % gen inference net
    m.params.downsample_ratio = 2;
    m = gen_inference_net(m, round(s.length * 2 / m.params.downsample_ratio), m.params.downsample_ratio, 1, 1);
    
    s_length = round(s.length / m.params.downsample_ratio);
    m.g(m.s).end_likelihood(:) = 0;
    m.g(m.s).end_likelihood(s_length) = 1;
    
    % compute detection for all sequences
    m.detection.result = compute_raw_detection_score( s, m );
    for i=1:length(m.vdetectors)
        x = m.detection.result{i};
        if size(m.detection.result{i}, 1) > s.length
            x = x(1:s.length,1:s.length);
        end
        x = imresize(x, [s_length s_length], 'bilinear');
        m.detection.result{i} = zeros(m.params.T);
        m.detection.result{i}(1:s_length, 1:s_length) = x;
    end
    
    % perform inference
    m = m_inference_v3(m);
    figure(1); clf;
    m_plot_distributions(m, fields(m.grammar.name2id)', {'S'});
    xlim([0 s_length * 1.9]);
%     figure(2); clf;
%     for i=1:length(m.detection.result)
%         subplot(length(m.detection.result)/6, 6, i); 
%         imagesc(m.detection.result{i}); colorbar;
%         xlim([0 s.length]); ylim([0 s.length]); 
%     end;
%     pause(2);
    
    
    
    %% recognition
    class = 0;
    bestP = -1;
    for i=0:5
        P = sum(m.grammar.symbols(m.grammar.name2id.(['A' num2str(i)])).start_distribution);
        if P > bestP
            class = i;
            bestP = P;
        end
    end
    disp(['Classify class ' num2str(class) ' with probability ' num2str(bestP) '. Truth: ' num2str(s.class) ]);
    if class ~= s.class
        gogo = 1;
    end
    
    %% do prediction
    classes = class;
    m.g(m.s).end_likelihood(:) = 1;
    m.g(m.s).end_likelihood = m.g(m.s).end_likelihood / sum(m.g(m.s).end_likelihood);
    
    for obv_ratio = [1:-0.1:0.1]
        
        % update detection result
        for i=1:length(m.vdetectors)
            m.detection.result{i}(:,round(s_length*obv_ratio)+1:end) = 1;
            m.detection.result{i}(round(s_length*obv_ratio)+1:end,:) = 1;
            
            for j=1:round(s_length*obv_ratio)
                o = [round(s_length*obv_ratio)+1:m.params.T] - j;
                o = (round(s_length*obv_ratio) - j) ./ o;
                o = o * 0.8;
                m.detection.result{i}(j,round(s_length*obv_ratio)+1:end) = (1 - o) * 1 + o * m.detection.result{i}(j,round(s_length*obv_ratio));
            end
        end
        
        % run inference
        m = m_inference_v3(m);
        
        % classifiy
        class = 0;
        bestP = -1;
        for i=0:5
            P = sum(m.grammar.symbols(m.grammar.name2id.(['A' num2str(i)])).start_distribution);
            if P > bestP
                class = i;
                bestP = P;
            end
        end
        classes = [class classes];
    end
    
    
end

