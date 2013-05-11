function [ output_args ] = convert_and_plot( m, nt, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION )
%CONVERT_AND_PLOT Summary of this function goes here
%   Detailed explanation goes here


m.rs = create_resolution_structure(m.params.T, nt, 1.1, 20);
m.params.T = m.rs.T;

%% convert
tic;

for i=1:length(m.g)
    if m.g(i).is_terminal
        m.g(i).durationmat  = vrts_downsample_durationmat_forward(m.g(i).durationmat, m.rs);
        m.g(i).obv_duration_likelihood = nan(m.rs.T);
    end
end

for i=1:length(m.detection.result)
    if ~isempty(m.detection.result{i})
        m.detection.result{i} = vrts_downsample_mat_avg(m.detection.result{i}, m.rs);
    end
end

m.g(m.s).start_distribution = vrts_downsample_probability(m.g(m.s).start_distribution, m.rs);
m.g(m.s).end_likelihood     = vrts_downsample_likelihood(m.g(m.s).end_likelihood, m.rs);

toc;

%% inf
tic
m = m_inference_v3(m);
toc
m_plot_distributions(m, DRAW_START_DISTRIBUTION, DRAW_END_DISTRIBUTION);

end

