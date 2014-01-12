function [s m correct_classification] = perform_inf_n_update_timing( s, m, do_random_obv_ratio )
%PERFORM_INF_N_UPDATE_TIMING Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('do_random_obv_ratio')
        do_random_obv_ratio = 0;
    end;
    

    % change OR
    assert(s.class >= 0 & s.class <= 5);
    %m.grammar.symbols(m.grammar.starting).prule.or_prob(:) = 10e-10;
    %m.grammar.symbols(m.grammar.starting).prule.or_prob(s.class+1) = 1;
    %m.grammar.rules(1).or_prob(:) = 10e-10;
    %m.grammar.rules(1).or_prob(s.class+1) = 1;
   
    % gen inference net
    m = gen_inference_net(m, 250, 1 , 1, 250);
    m.g(m.s).end_likelihood(:) = 0;
    m.g(m.s).end_likelihood(s.length) = 1;
    
    % compute detection for all sequences
    m.detection.result = compute_raw_detection_score( s, m, 1 );
    for i=1:length(m.vdetectors)
%         m.detection.result{i} = m.detection.result{i} / m.vdetectors(i).mean_score;
    end
    
    % obv ratio
    if rand < do_random_obv_ratio
        m = m_change_obv_ratio(m, s, rand);
    end
    
    % perform inference
    m = m_inference_v3(m);
	hold off;
    m_plot_distributions(m, fields(m.grammar.name2id)', {'S'});
    xlim([0 s.length * 1.5]);
	ylim([0 1]);
    pause(0.1);
    
    % update new timings
    for i=1:length(s.train.actions)
        s_id = s.train.actions(i).s_id;
        
        % old
		start_distribution = m.grammar.symbols(s_id).start_distribution / sum(m.grammar.symbols(s_id).start_distribution);
		end_distribution   = m.grammar.symbols(s_id).end_distribution / sum(m.grammar.symbols(s_id).end_distribution);
        new_start = round(sum(start_distribution .* [1:m.params.T]));
        new_end   = round(sum(end_distribution .* [1:m.params.T]));
        
        disp(sprintf('Update %s from %d, %d to %d, %d', m.grammar.symbols(s_id).name, s.train.actions(i).start, s.train.actions(i).end, new_start, new_end));
        s.train.actions(i).start = new_start;
        s.train.actions(i).end = new_end;
        
%         % new
%         for g=m.g
%         if g.id == s_id
%             j = g.i_forward.joint1 *  g.i_backward.joint2;
%             j = j / sum(sum(j));
%             [s.train.actions(i).start s.train.actions(i).end] = find (j == max(j(:)));
%         end
%         end
    end
    
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
    disp(['Classify class ' num2str(class) ' with probability ' num2str(bestP) '. Truth: ' num2str(s.class) ]);
    if class ~= s.class
        correct_classification = 0;
    else
        correct_classification = 1;
    end
end

