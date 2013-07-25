
clear; clc;
close all;

m = gen_inference_net('../s/model');

m.params.use_start_conditions   = 1;
m.start_conditions(:,1:20)     = 0;

rs = create_resolution_structure(m.params.T, 300, 1.1, 30);
rs = create_resolution_structure_by_energy(ones(1,1000) / 10);

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
ylim([0 .1])
nx_figure(2);
m_plot_distributions(new_m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);
ylim([0 .1])

linkaxes([findall(figure(1), 'type', 'axes'); findall(figure(2), 'type', 'axes')]);

%% update r

while 1
    
    pause
    
    tic
    new_m = m_update_rs(new_m);
    disp m_update_rs
    toc
    
    tic
    new_m = m_inference_v3(new_m);
    disp inference_time
    toc
    
    nx_figure(2);
    m_plot_distributions(new_m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);
    ylim([0 .1])
end













