
clear; clc;
close all;

m = gen_inference_net('../s/model');

rs = create_resolution_structure(m.params.T, 100, 1.1, 30);


%% convert%
tic;
new_m = m_convert_by_rs(m, rs);
disp convert_time
toc;

%% inference

tic
new_m = m_inference_v3(new_m);
disp inference_time
toc

tic
m = m_inference_v3(m);
disp full_inference_time
toc

%% draw
DRAW_START_DISTRIBUTION = {'Body', 'Nose_A', 'Wing_AT', 'tail_at2'};
%DRAW_START_DISTRIBUTION = {'Body', 'wing_at1', 'wing_at2', 'wing_at3', 'tail_at1'};
DRAW_END_DISTRIBUTION   = {'S'};
nx_figure(1);
m_plot_distributions(m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);
nx_figure(2);
m_plot_distributions(new_m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);

