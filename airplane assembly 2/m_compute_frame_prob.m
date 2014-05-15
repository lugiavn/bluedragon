function m = m_compute_frame_prob( m )
%M_COMPUTE_FRAME_PROB Summary of this function goes here
%   Detailed explanation goes here



assert(m.params.compute_terminal_joint > 0);
T = m.params.T;

%% compiled grammar symbol prob
probs = nan(length(m.g), T);

for i=1:length(m.g)
if m.g(i).is_terminal
    
    joint = m.g(i).i_forward.joint1 .* m.g(i).i_backward.joint2 .* triu(ones(T));
    
    if sum(joint(:)) <= 0
        assert(m.g(i).i_final.prob_notnull == 0);
    else
        joint = joint / sum(joint(:)) * m.g(i).i_final.prob_notnull;
    end
    
    integral_joint = cumsum(cumsum(joint(:,end:-1:1), 2));
    integral_joint = integral_joint(:,end:-1:1);
    for t=1:T-1
        probs(i,t) = integral_joint(t,t+1);
    end
        
%     for t=1:T
%         probs(i,t) = sum(sum(joint(1:t,t+1:end)));
%     end
    
end
end

m.frame_prob = probs';

%% for composition
m = m_compute_frame_prob_for_composition(m, m.s);


%% original grammar symbol prob
m.frame_symbol_prob = zeros(T, length(m.grammar.symbols));
for i=1:length(m.g)
% if m.g(i).is_terminal
    m.frame_symbol_prob(:,m.g(i).id) = m.frame_symbol_prob(:,m.g(i).id) + m.frame_prob(:,i);
% end
end

end


function m = m_compute_frame_prob_for_composition(m, id)

    if m.g(id).is_terminal
        return;
    end
    
    prob = zeros(1, m.params.T);
    
    for i=m.g(id).prule
        m = m_compute_frame_prob_for_composition(m, i);
        prob = prob + m.frame_prob(:,i)';
    end

    m.frame_prob(:,id) = prob';
end













