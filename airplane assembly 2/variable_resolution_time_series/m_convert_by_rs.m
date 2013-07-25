function m = m_convert( m, rs )
%M_CONVERT Summary of this function goes here
%   Detailed explanation goes here


%% create resolution structure

m.r_settings        = struct;
m.r_settings.rs{1}  = rs; 
%m.r_settings.rs{2}  = create_resolution_structure(m.params.T, 200, 1.1, 30);

m.r_settings.transform_rs           = cell(length(m.r_settings.rs), length(m.r_settings.rs));
m.r_settings.transform_rs_duration  = cell(length(m.grammar.symbols), length(m.r_settings.rs), length(m.r_settings.rs));
m.r_settings.detection_result_rs    = cell(length(m.detection.result), length(m.r_settings.rs), length(m.r_settings.rs));
m.r_settings.start_conditions_rs    = cell(length(m.g), length(m.r_settings.rs));

clearvars rs;

%% setup rs id

for i=1:length(m.g)
    m.g(i).start_rs_id = randi([1 length(m.r_settings.rs)]);
    m.g(i).end_rs_id   = randi([1 length(m.r_settings.rs)]);
end



%% converting

for i=1:length(m.r_settings.rs)
    m.r_settings.rs{i} = rs_add_upsampleprobtransform(m.r_settings.rs{i});
end

% convert rs transform
for g=m.g
    if ~g.is_terminal
        if g.andrule
            
            m.r_settings.transform_rs{g.start_rs_id, m.g(g.prule(1)).start_rs_id} = 999;
            
            for i=1:length(g.prule)-1
                m.r_settings.transform_rs{m.g(i).end_rs_id, m.g(i+1).start_rs_id} = 999;
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
for i=1:length(m.r_settings.rs)
    for j=1:length(m.r_settings.rs)
    if m.r_settings.transform_rs{i,j} == 999
        m.r_settings.transform_rs{i,j} = vrts_downsample_mat(...
            eye(m.params.T), ...
            m.r_settings.rs{i},  m.r_settings.rs{j}, ...
            1, 0, 0);
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
    for j=1:length(m.r_settings.rs)
        m.r_settings.start_conditions_rs{k,j} = vrts_downsample_probability(m.start_conditions(k,:), m.r_settings.rs{j});
    end
end

% todo fakedummystep
%m.params.trick.fakedummystep = vrts_downsample_mat(m.params.trick.fakedummystep, m.r_settings.rs{1}, m.r_settings.rs{1}, 1, 0, 0);

% convert S.start_distribution, S.end_likelihood
%m.g(m.s).start_distribution = vrts_downsample_probability(m.g(m.s).start_distribution, m.r_settings.rs{m.g(m.s).start_rs_id});
%m.g(m.s).end_likelihood     = vrts_downsample_likelihood(m.g(m.s).end_likelihood, m.r_settings.rs{m.g(m.s).end_rs_id});
m.r_settings.start_distribution = vrts_downsample_probability(m.g(m.s).start_distribution, m.r_settings.rs{m.g(m.s).start_rs_id});
m.r_settings.end_likelihood     = vrts_downsample_likelihood(m.g(m.s).end_likelihood, m.r_settings.rs{m.g(m.s).end_rs_id});

end

