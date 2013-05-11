function m = m_convert( m, rs )
%M_CONVERT Summary of this function goes here
%   Detailed explanation goes here


m.rs        = rs;
m.params.T  = m.rs.T;


for i=1:length(m.g)
    if m.g(i).is_terminal
        m.g(i).obv_duration_likelihood = nan(m.rs.T);
    end
end

for i=1:length(m.grammar.symbols)
    if m.grammar.symbols(i).is_terminal
        m.grammar.symbols(i).duration_mat = vrts_downsample_mat(m.grammar.symbols(i).duration_mat_integral, m.rs, m.rs, 1, 0, 1);
    end
end

for i=1:length(m.detection.result)
    if ~isempty(m.detection.result{i})
        %m.detection.result{i} = vrts_downsample_mat_avg(m.detection.result{i}, rs);
        m.detection.result{i} = vrts_downsample_mat(m.detection.result{i}, m.rs, m.rs, 1, 1, 0);
    end
end

start_conditions   = m.start_conditions;
m.start_conditions = [];
for i=1:size(start_conditions,1)
    m.start_conditions(i,:) = vrts_downsample_probability(start_conditions(i,:), m.rs);
end

m.params.trick.fakedummystep = vrts_downsample_mat(m.params.trick.fakedummystep, m.rs, m.rs, 1, 0, 0);

m.g(m.s).start_distribution = vrts_downsample_probability(m.g(m.s).start_distribution, m.rs);
m.g(m.s).end_likelihood     = vrts_downsample_likelihood(m.g(m.s).end_likelihood, m.rs);


end

