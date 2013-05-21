function label = m_output_label( m, conf_theshold )
%M_OUTPUT_LABEL Summary of this function goes here
%   Detailed explanation goes here

if ~exist('conf_theshold')
    conf_theshold = 0.9;
end

label = struct([]);

queue = [m.s];

while length(queue) > 0
    
    % pop
    g = m.g(queue(1));
    queue(1) = [];
    
    % terminal, push to label
    if g.is_terminal
        
        if g.i_final.prob_notnull >= conf_theshold
            label(end+1).name = m.grammar.symbols(g.id).name;
            [~, label(end).start]  = max(g.i_final.start_distribution);
            [~, label(end).end]    = max(g.i_final.end_distribution);
        end
        
    elseif g.andrule % and rule, add to queue
        
        queue = [g.prule queue];
        
    else % or rule, add to queue the one with highest prob
        
        prob = [];
        for i=g.prule
            prob = [prob m.g(i).i_final.prob_notnull];
        end
        
        [~, maxid] = max(prob);
        queue = [g.prule(maxid) queue];
    end
    
end

end

