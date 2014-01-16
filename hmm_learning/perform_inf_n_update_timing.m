function [s m correct_classification] = perform_inf_n_update_timing( s, m, do_random_obv_ratio )
%PERFORM_INF_N_UPDATE_TIMING Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('do_random_obv_ratio')
        do_random_obv_ratio = 0;
    end;

    % change OR
    assert(s.class >= 0 & s.class <= 5);
   
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

