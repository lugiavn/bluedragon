function m = m_compute_frame_prob( m )
%M_COMPUTE_FRAME_PROB Summary of this function goes here
%   Detailed explanation goes here



assert(m.params.compute_terminal_joint > 0);
T = m.params.T;
probs = zeros(length(m.g), T);


for i=1:length(m.g)
if m.g(i).is_terminal
    
    joint = m.g(i).i_forward.joint1 .* m.g(i).i_backward.joint2 .* triu(ones(T));
    joint = joint / sum(joint(:)) * m.g(i).i_final.prob_notnull;
        
    %disp(m.g(i).i_final.prob_notnull);
    
    for t=1:T-10
        probs(i,t) = sum(sum(joint(1:t,t+1:end)));
    end
    
end
end

m.frame_prob = probs';

% grammar symbol prob
m.frame_symbol_prob = zeros(T, length(m.grammar.symbols));
for i=1:length(m.g)
if m.g(i).is_terminal
    m.frame_symbol_prob(:,m.g(i).id) = m.frame_symbol_prob(:,m.g(i).id) + m.frame_prob(:,i);
end
end

end

