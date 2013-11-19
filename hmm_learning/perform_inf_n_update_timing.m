function s = perform_inf_n_update_timing( s, m )
%PERFORM_INF_N_UPDATE_TIMING Summary of this function goes here
%   Detailed explanation goes here

    

    % change OR
    assert(s.class >= 0 & s.class <= 5);
    m.grammar.symbols(m.grammar.starting).prule.or_prob(:) = 10e-10;
    m.grammar.symbols(m.grammar.starting).prule.or_prob(s.class+1) = 1;
    m.grammar.rules(1).or_prob(:) = 10e-10;
    m.grammar.rules(1).or_prob(s.class+1) = 1;
   
    % gen inference net
    m = gen_inference_net(m, 300, 1 , 1, 300);
    m.g(m.s).end_likelihood(:) = 0;
    m.g(m.s).end_likelihood(s.length) = 1;
    
    % compute detection for all sequences
    m.detection.result = compute_raw_detection_score( s, m, 1 );
    
    % perform inference
    m = m_inference_v3(m);
    m_plot_distributions(m, fields(m.grammar.name2id)', {'S'});
    xlim([0 s.length * 1.5]);
    pause(0.1);
    
    % update new timings
    for i=1:length(s.train.actions)
        s_id = s.train.actions(i).s_id;
        new_start = round(sum(m.grammar.symbols(s_id).start_distribution .* [1:m.params.T]));
        new_end   = round(sum(m.grammar.symbols(s_id).end_distribution .* [1:m.params.T]));
        
        disp(sprintf('Update %s from %d, %d to %d, %d', m.grammar.symbols(s_id).name, s.train.actions(i).start, s.train.actions(i).end, new_start, new_end));
        s.train.actions(i).start = new_start;
        s.train.actions(i).end = new_end;
    end
    
end

