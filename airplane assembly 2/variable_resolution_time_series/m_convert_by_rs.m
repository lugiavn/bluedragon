function m = m_convert( m, rs )
%M_CONVERT Summary of this function goes here
%   Detailed explanation goes here


%% create resolution structure

m.r_settings        = struct;
m.r_settings.rs{1}  = rs; % resolution structure set
m.r_settings.rs{1}  = rs; %create_resolution_structure(m.params.T, 200, 1.1, 50);
m.r_settings.rs{2}  =  rs; %create_resolution_structure(m.params.T, 500, 1.1, 50);
m.r_settings.rs_num = length(m.r_settings.rs);

m.r_settings.transform_rs = cell(m.r_settings.rs_num, m.r_settings.rs_num);
m.r_settings.transform_rs_duration = cell(length(m.grammar.symbols), m.r_settings.rs_num, m.r_settings.rs_num);
m.r_settings.detection_result_rs = cell(length(m.detection.result), m.r_settings.rs_num, m.r_settings.rs_num);

clearvars rs;

%% setup rs id

for i=1:length(m.g)
    m.g(i).start_rs_id = randi([1 m.r_settings.rs_num]);
    m.g(i).end_rs_id   = randi([1 m.r_settings.rs_num]);
end



%% converting
for i=1:length(m.g)
    if m.g(i).is_terminal
        
        start_rs = m.r_settings.rs{m.g(i).start_rs_id};
        end_rs   = m.r_settings.rs{m.g(i).end_rs_id};
        
        m.g(i).obv_duration_likelihood = nan(start_rs.T, end_rs.T);
    end
end

for i=1:length(m.grammar.symbols)
    if m.grammar.symbols(i).is_terminal
        
        start_rs = m.r_settings.rs{m.g(i).start_rs_id};
        end_rs   = m.r_settings.rs{m.g(i).end_rs_id};
        
        m.grammar.symbols(i).duration_mat = vrts_downsample_mat(m.grammar.symbols(i).duration_mat_integral, start_rs, end_rs, 1, 0, 1);
    end
end

%% compute

for i=1:m.r_settings.rs_num
    for j=1:m.r_settings.rs_num
        m.r_settings.transform_rs{i,j} = vrts_downsample_mat(...
            eye(m.params.T), ...
            m.r_settings.rs{i},  m.r_settings.rs{j}, ...
            1, 0, 0);
    end
end

for i=1:m.r_settings.rs_num
    for j=1:m.r_settings.rs_num
        for k=1:length(m.grammar.symbols)
        if m.grammar.symbols(k).is_terminal
            m.r_settings.transform_rs_duration{k,i,j} = vrts_downsample_mat(...
                m.grammar.symbols(k).duration_mat_integral, ...
                m.r_settings.rs{i}, m.r_settings.rs{j}, ...
                1, 0, 1);
        end
        end
    end
end

for i=1:m.r_settings.rs_num
    for j=1:m.r_settings.rs_num
        for k=1:length(m.detection.result)
        if ~isempty(m.detection.result{k})
            m.r_settings.detection_result_rs{k,i,j} = vrts_downsample_mat(...
                m.detection.result{k}, ...
                m.r_settings.rs{i}, m.r_settings.rs{j}, ... 
                1, 1, 0);
        end
        end
    end
end


%% convert start_condition, fakedummystep, S.start_distribution, S.end_likelihood
%  todo

start_conditions   = m.start_conditions;
m.start_conditions = [];
for i=1:size(start_conditions,1)
    m.start_conditions(i,:) = vrts_downsample_probability(start_conditions(i,:), m.r_settings.rs{1});
end

%m.params.trick.fakedummystep = vrts_downsample_mat(m.params.trick.fakedummystep, m.r_settings.rs{1}, m.r_settings.rs{1}, 1, 0, 0);

m.g(m.s).start_distribution = vrts_downsample_probability(m.g(m.s).start_distribution, m.r_settings.rs{m.g(m.s).start_rs_id});
m.g(m.s).end_likelihood     = vrts_downsample_likelihood(m.g(m.s).end_likelihood, m.r_settings.rs{m.g(m.s).end_rs_id});


end

