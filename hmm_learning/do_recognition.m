function [classes m] = do_recognition( s, m )
%DO_RECOGNITION Summary of this function goes here
%   Detailed explanation goes here

    % gen inference net
    m = gen_inference_net(m, 250, 1 , 1, 250);
    m.g(m.s).end_likelihood(:) = 0;
    m.g(m.s).end_likelihood(round (s.length)) = 1;
    
    % compute detection for all sequences
    m.detection.result = compute_raw_detection_score( s, m );
    for i=1:length(m.vdetectors)
%         
%         x = zeros(250);
%         x(1:60, 1:60) = imresize(m.detection.result{i}, [60 60], 'bilinear');
%         m.detection.result{i} = x;
        
%         m.detection.result{i} = m.detection.result{i} / m.vdetectors(i).mean_score;
%         m.detection.result{i}(round(s.length/2):end,round(s.length/2):end) = 1;
    end
    
    % perform inference
    m = m_inference_v3(m);
    figure(1); clf;
    m_plot_distributions(m, fields(m.grammar.name2id)', {'S'});
    xlim([0 s.length * 1.5]);
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
%             m.detection.result{i}(round(s.length*obv_ratio):end,round(s.length*obv_ratio):end) = 1;
            m.detection.result{i}(:,round(s.length*obv_ratio):end) = 1;
            m.detection.result{i}(round(s.length*obv_ratio):end,:) = 1;
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

