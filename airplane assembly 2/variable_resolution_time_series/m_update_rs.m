function m = m_update_rs( m , t, create_new_rs)
%M_UPDATE_RS Summary of this function goes here
%   Detailed explanation goes here

if ~exist('create_new_rs')
    create_new_rs = 1;
end

% create rs
if create_new_rs
    m = m_do_create_rs( m , t);
end

% converting
m = m_do_rs_convert( m );

end


%%

function m = m_do_create_rs( m , t)

if exist('t')
    t_energy = nxmakegaussian(m.params.T, t, 1000);
else
    t_energy = zeros(1, m.params.T);
end

old_rs          = m.r_settings.rs;
rs_count        = 0;
m.r_settings.rs = {};

for i=1:length(m.g)

    start_d_full1 = vrts_upsample_probability(m.g(i).i_forward.start_distribution, old_rs{m.g(i).start_rs_id});
    start_d_full3 = vrts_upsample_probability(m.g(i).i_final.start_distribution, old_rs{m.g(i).start_rs_id});
    start_d_full2 = vrts_upsample_likelihood(m.g(i).i_backward.start_likelihood, old_rs{m.g(i).start_rs_id});
    start_d_full2 = start_d_full2 / sum(start_d_full2);
    start_energy  =  ...
        compute_distribution_variancex(start_d_full1) * 1 + ...
        compute_distribution_variancex(start_d_full2) * 1 + ...
        compute_distribution_variancex(start_d_full3) * 1 + t_energy * 10;
    
    
    end_d_full1 = vrts_upsample_probability(m.g(i).i_forward.end_distribution, old_rs{m.g(i).end_rs_id});
    end_d_full3 = vrts_upsample_probability(m.g(i).i_final.end_distribution, old_rs{m.g(i).end_rs_id});
    end_d_full2 = vrts_upsample_likelihood(m.g(i).i_backward.end_likelihood, old_rs{m.g(i).end_rs_id});
    end_d_full2 = end_d_full2 / sum(end_d_full2);
    end_energy  = ...
        compute_distribution_variancex(end_d_full1) * 1 + ...
        compute_distribution_variancex(end_d_full2) * 1 + ...
        compute_distribution_variancex(end_d_full3) * 1 + t_energy * 10;
    
    if isfield(old_rs{m.g(i).start_rs_id}, 'energy')
        start_energy = 0.2 * start_energy + 0.8 * old_rs{m.g(i).start_rs_id}.energy;
        end_energy   = 0.2 * end_energy   + 0.8 * old_rs{m.g(i).end_rs_id}.energy;
    end
    
    
    start_rs = create_resolution_structure_by_energy(start_energy);
    end_rs   = create_resolution_structure_by_energy(end_energy);

    
    m.r_settings.rs{end+1}  = start_rs;
    m.g(i).start_rs_id      = length(m.r_settings.rs);
    m.r_settings.rs{end+1}  = end_rs;
    m.g(i).end_rs_id        = length(m.r_settings.rs);
end


end

%%

function m = m_do_create_rs2( m , t)

if exist('t')
    t_energy = nxmakegaussian(m.params.T, t, 50000);
else
    t_energy = zeros(1, m.params.T);
end

old_rs          = m.r_settings.rs;
m.r_settings.rs = {create_resolution_structure_by_energy(t_energy * 90)};

for i=1:length(m.g)
    m.g(i).start_rs_id      = 1;
    m.g(i).end_rs_id        = 1;
end


end



%%
function m = m_do_rs_convert( m )

m.r_settings.transform_rs           = cell(length(m.r_settings.rs), length(m.r_settings.rs));
m.r_settings.transform_rs_duration  = cell(length(m.grammar.symbols), length(m.r_settings.rs), length(m.r_settings.rs));
m.r_settings.detection_result_rs    = cell(length(m.detection.result), length(m.r_settings.rs), length(m.r_settings.rs));
m.r_settings.start_conditions_rs    = cell(length(m.g), length(m.r_settings.rs));

for i=1:length(m.r_settings.rs)
    m.r_settings.rs{i} = rs_add_upsampleprobtransform(m.r_settings.rs{i});
end

% convert rs transform
for g=m.g
    if ~g.is_terminal
        if g.andrule
            
            m.r_settings.transform_rs{g.start_rs_id, m.g(g.prule(1)).start_rs_id} = 999;
            
            for i=1:length(g.prule)-1
                m.r_settings.transform_rs{m.g(g.prule(i)).end_rs_id, m.g(g.prule(i+1)).start_rs_id} = 999;
            end
            
            m.r_settings.transform_rs{m.g(g.prule(end)).end_rs_id, g.end_rs_id} = 999;
            
        else
            
            for i=1:length(g.prule)
                m.r_settings.transform_rs{g.start_rs_id, m.g(g.prule(i)).start_rs_id} = 999;
                m.r_settings.transform_rs{m.g(g.prule(i)).end_rs_id, g.end_rs_id} = 999;
            end
            
        end
    end
end

eyecum              = zeros(m.params.T + 1);
eyecum(2:end,2:end) = cumsum(cumsum(eye(m.params.T),2));

for i=1:length(m.r_settings.rs)
    for j=1:length(m.r_settings.rs)
    if m.r_settings.transform_rs{i,j} == 999
        m.r_settings.transform_rs{i,j} = vrts_downsample_mat(...
            eyecum, ...
            m.r_settings.rs{i},  m.r_settings.rs{j}, ...
            1, 0, 1);
    end
    end
end

% convert duration_mat
for g=m.g
    if g.is_terminal && g.start_rs_id >= 1 && g.end_rs_id >= 1
        m.r_settings.transform_rs_duration{g.id, g.start_rs_id, g.end_rs_id} = vrts_downsample_mat(...
            m.grammar.symbols(g.id).duration_mat_integral, ...
            m.r_settings.rs{g.start_rs_id}, m.r_settings.rs{g.end_rs_id}, ...
            1, 0, 1);
    end
end

% convert detection result
for g=m.g
    if g.is_terminal && g.start_rs_id >= 1 && g.end_rs_id >= 1
            m.r_settings.detection_result_rs{g.detector_id, g.start_rs_id, g.end_rs_id} = vrts_downsample_mat(...
                m.detection.result{g.detector_id}, ...
                m.r_settings.rs{g.start_rs_id}, m.r_settings.rs{g.end_rs_id}, ... 
                1, 1, 0);
    end
end

% convert start_condition
for k=1:length(m.g)
    j = m.g(k).start_rs_id;
    m.r_settings.start_conditions_rs{k,j} = vrts_downsample_probability(m.start_conditions(k,:), m.r_settings.rs{j});
end

% todo fakedummystep
%m.params.trick.fakedummystep = vrts_downsample_mat(m.params.trick.fakedummystep, m.r_settings.rs{1}, m.r_settings.rs{1}, 1, 0, 0);

% convert S.start_distribution, S.end_likelihood
%m.g(m.s).start_distribution = vrts_downsample_probability(m.g(m.s).start_distribution, m.r_settings.rs{m.g(m.s).start_rs_id});
%m.g(m.s).end_likelihood     = vrts_downsample_likelihood(m.g(m.s).end_likelihood, m.r_settings.rs{m.g(m.s).end_rs_id});
m.r_settings.start_distribution = vrts_downsample_probability(m.g(m.s).start_distribution, m.r_settings.rs{m.g(m.s).start_rs_id});
m.r_settings.end_likelihood     = vrts_downsample_likelihood(m.g(m.s).end_likelihood, m.r_settings.rs{m.g(m.s).end_rs_id});



end


function v = compute_distribution_variancex(d)

    v = d * 8 + compute_distribution_variance(d) * 3;
    
end























