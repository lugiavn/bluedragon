function [ output_args ] = convert_and_plot_2( m, nt, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION )
%CONVERT_AND_PLOT Summary of this function goes here
%   Detailed explanation goes here


%% convert
tic;
m = m_convert_by_rs(m, create_resolution_structure(m.params.T, nt, 1.05, 15));
disp convert_time
toc;

%% inf
tic
m = m_inference_v3(m);
disp inf_time
toc
m_plot_distributions(m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);

end

