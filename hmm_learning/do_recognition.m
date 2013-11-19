function class = do_recognition( s, m )
%DO_RECOGNITION Summary of this function goes here
%   Detailed explanation goes here

    % gen inference net
    m = gen_inference_net(m, 300, 1 , 1, 300);
    m.g(m.s).end_likelihood(:) = 0;
    m.g(m.s).end_likelihood(s.length) = 1;
    
    % compute detection for all sequences
    m.detection.result = compute_raw_detection_score( s, m );
    for i=1:length(m.vdetectors)
        m.detection.result{i} = m.detection.result{i} / m.vdetectors(i).mean_score;
    end
    
    % perform inference
    m = m_inference_v3(m);
    m_plot_distributions(m, fields(m.grammar.name2id)', {'S'});
    xlim([0 s.length * 1.5]);
    pause(0.1);
    
    % recognition
    class = 0;
    bestP = -1;
    for i=0:5
        P = sum(m.grammar.symbols(m.grammar.name2id.(['A' num2str(i)])).start_distribution);
        if P > bestP
            class = i;
            bestP = P;
        end
    end
    disp(['Classify class ' num2str(class) ' with probability ' num2str(bestP)]);
end
