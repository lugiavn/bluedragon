function [classes m] = do_recognition( s, m )
%DO_RECOGNITION Summary of this function goes here
%   Detailed explanation goes here

    % gen inference net
    m = gen_m_inf( s, m );
%     s_length = min(s.length, m.params.downsample_length);
    s_length = round(s.length / m.params.downsample_ratio);
    
    % perform inference
    m = m_inference_v3(m);
    figure(1); clf;
    m_plot_distributions(m, fields(m.grammar.name2id)', {'S'});
    xlim([0 s_length * 2]);
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
    for i=m.classes
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
            
%             for j=1:round(s_length*obv_ratio)
%                 o = [round(s_length*obv_ratio)+1:m.params.T] - j;
%                 o = (round(s_length*obv_ratio) - j) ./ o;
%                 o = o * 0.8;
%                 m.detection.result{i}(j,round(s_length*obv_ratio)+1:end) = (1 - o) * 1 + o * m.detection.result{i}(j,round(s_length*obv_ratio));
%             end
        end
        
        % run inference
        m = m_inference_v3(m);
        
        % classifiy
        class = 0;
        bestP = -1;
        for i=m.classes
            P = sum(m.grammar.symbols(m.grammar.name2id.(['A' num2str(i)])).start_distribution);
            if P > bestP
                class = i;
                bestP = P;
            end
        end
        classes = [class classes];
    end
    
    
end

