
clc; close all;
T = 1000;
m = gen_inference_net('s/model', T, 7, 1);

m = m_inference_v3(m);

assert(m.params.compute_terminal_joint > 0);

probs = zeros(length(m.g), T);


for i=1:length(m.g)
if m.g(i).is_terminal
    
    joint = m.g(i).i_forward.joint1 .* m.g(i).i_backward.joint2 .* triu(ones(T));
    joint = joint / sum(joint(:)) * m.g(i).i_final.prob_notnull;
        
    disp(m.g(i).i_final.prob_notnull);
    
    for t=1:T-10
        probs(i,t) = sum(sum(joint(1:t,t+1:end)));
    end
    
end
end

figure(1);
plot(sum(probs));
figure(2);
imagesc(probs');


