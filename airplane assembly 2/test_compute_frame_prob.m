
clc; close all;
T = 1000;
m = gen_inference_net('s/model', T, 7, 1);

m = m_inference_v3(m);
m = m_compute_frame_prob(m);

figure(1);
plot(sum(m.frame_prob'));
figure(2);
imagesc(m.frame_prob);


