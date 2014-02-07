function [s m correct_classification] = perform_inf_n_update_timing( s, m, do_random_obv_ratio )
%PERFORM_INF_N_UPDATE_TIMING Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('do_random_obv_ratio')
        do_random_obv_ratio = 0;
    end;

    % change OR
    assert(s.class >= 0 & s.class <= 16);
   
    % gen inference net
    m = gen_m_inf( s, m );
%     s_length = min(s.length, m.params.downsample_length);
    s_length = round(s.length / m.params.downsample_ratio);
    
    % obv ratio
    if rand < do_random_obv_ratio
        if rand < 0.9
            m = m_change_obv_ratio(m, s, rand);
        else
            m = m_change_obv_ratio(m, s, 1);
        end
    end
    
    % perform inference
    m = m_inference_v3(m);
    
    % update new timings
    if ~do_random_obv_ratio | 1
    for i=1:length(s.train.actions)
        s_id = s.train.actions(i).s_id;
        
        % old
		start_distribution = m.grammar.symbols(s_id).start_distribution / sum(m.grammar.symbols(s_id).start_distribution);
		end_distribution   = m.grammar.symbols(s_id).end_distribution / sum(m.grammar.symbols(s_id).end_distribution);
        new_start = round(sum(start_distribution .* [1:m.params.T]) * m.params.downsample_ratio);
        new_end   = round(sum(end_distribution .* [1:m.params.T]) * m.params.downsample_ratio);
        new_end   = min(new_end, s.length);
        
        disp(sprintf('Update %s from %d, %d to %d, %d', m.grammar.symbols(s_id).name, s.train.actions(i).start, s.train.actions(i).end, new_start, new_end));
        s.train.actions(i).start = new_start;
        s.train.actions(i).end = new_end;
    end
    end;
    
    % recognition
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
        correct_classification = 0;
    else
        correct_classification = 1;
    end
end

