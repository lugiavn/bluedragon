function m = m_inference_v3( m )
%M_INFERENCE Summary of this function goes here
%   Detailed explanation goes here

    m = compute_null_likelihood(m, m.s);
%     for i=1:length(m.g)
%         m.g(i).or_log_othersnull_likelihood = 0;
%     end;
    
    % compute P(end | start) * P( Z | start, end)
    for i=1:length(m.g)
        if m.g(i).is_terminal
            if isfield(m, 'r_settings')
            	m.g(i).obv_duration_likelihood = ...
                    m.r_settings.transform_rs_duration{m.g(i).id, m.g(i).start_rs_id, m.g(i).end_rs_id} .* ...
                    m.r_settings.detection_result_rs{m.g(i).detector_id, m.g(i).start_rs_id, m.g(i).end_rs_id};
            else
                m.g(i).obv_duration_likelihood = m.grammar.symbols(m.g(i).id).duration_mat .* m.detection.result{m.g(i).detector_id};
            end
        end
    end
    

    % forward phase
    m.g(m.s).i_forward.start_distribution = m.g(m.s).start_distribution;
    if isfield(m, 'r_settings')
        m.g(m.s).i_forward.start_distribution = m.r_settings.start_distribution;
    end
    m = forward_phase(m, m.s);
    
    % backward phase
    m.g(m.s).i_backward.end_likelihood = m.g(m.s).end_likelihood;
    if isfield(m, 'r_settings')
        m.g(m.s).i_backward.end_likelihood = m.r_settings.end_likelihood;
    end
    m = backward_phase(m, m.s);

    % merge forward & backward
    for i=1:length(m.g)
        try
        g = m.g(i);
        
        g.i_final.end_distribution   = g.i_forward.end_distribution .* g.i_backward.end_likelihood;
        g.i_final.start_distribution = g.i_forward.start_distribution .* g.i_backward.start_likelihood;
        g.i_final.end_distribution   = g.i_final.end_distribution / sum(g.i_final.end_distribution);
        g.i_final.start_distribution = g.i_final.start_distribution / sum(g.i_final.start_distribution);
        
        assert(isreal(g.i_final.end_distribution(1)));
        assert(isreal(g.i_final.start_distribution(1)));
        
        m.g(i) = g;
        catch
            disp(sprintf('merge forward & backward fail for g %d', i));
        end
    end
    
    
    % compute happening prob
    m.g(m.s).i_final.prob_notnull = 1;
    m = compute_prob_notnull(m, m.s);

    % compute symbol distribution
    m.grammar.symbols = calculate_symbol_distribution(m, m.grammar.symbols);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = compute_null_likelihood( m, gid )

    m.g(gid).or_log_othersnull_likelihood = NaN;

    if m.g(gid).is_terminal
        return;
    end
    
    log_null_likelihood = 0;
    
    if ~m.g(gid).is_terminal
        
        for i=m.g(gid).prule 
            m = compute_null_likelihood(m,i);
            log_null_likelihood = log_null_likelihood + m.g(i).log_null_likelihood;
        end
        
        
    end

    m.g(gid).log_null_likelihood = log_null_likelihood;
    
    %~~~~~~~~~~~ or
    if ~m.g(gid).andrule
        sum_log_null_likelihood = 0;
        
        for i=1:length(m.g(gid).prule)
            sum_log_null_likelihood = sum_log_null_likelihood + m.g(m.g(gid).prule(i)).log_null_likelihood;
        end
        
        for i=1:length(m.g(gid).prule)
            m.g(m.g(gid).prule(i)).or_orweight = m.g(gid).orweights(i);
            m.g(m.g(gid).prule(i)).or_log_othersnull_likelihood = sum_log_null_likelihood - m.g(m.g(gid).prule(i)).log_null_likelihood;
        end
    end

end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = forward_phase( m , gid )
    % given g.i_forward.start_distribution 
    % compute g.i_forward.end_distribution
    
    g = m.g(gid);
    
    if ~isreal(g.i_forward.start_distribution(1)) || isnan(g.i_forward.start_distribution(1))
        disp(gid);
        assert(0);
    end
    
    %% intergrate start condition
    if m.params.use_start_conditions,
        
        if isfield(m, 'r_settings')
            g.i_forward.start_distribution  = start_condition_probability_forward(g.i_forward.start_distribution , m.r_settings.start_conditions_rs{gid,g.start_rs_id});
        else
            g.i_forward.start_distribution  = start_condition_probability_forward(g.i_forward.start_distribution , m.start_conditions(g.id,:));
        end
        
        if ~isnan(m.params.trick.fakedummystep(1)) & g.is_terminal
            if size(m.params.trick.fakedummystep, 1) == 1
                g.i_forward.start_distribution = conv(g.i_forward.start_distribution, m.params.trick.fakedummystep);
                g.i_forward.start_distribution = g.i_forward.start_distribution(1:m.params.T);
            else
                g.i_forward.start_distribution = g.i_forward.start_distribution * m.params.trick.fakedummystep;
            end
        end
    end
    
    if g.is_terminal
    %% terminal
        
        p =  g.i_forward.start_distribution * g.obv_duration_likelihood;
        p(p < 0) = 0;
        
        g.i_forward.log_pZ = log(sum(p));
        g.i_forward.end_distribution = p / sum(p);
        
        if m.params.compute_terminal_joint
            g.i_forward.joint1 = repmat(g.i_forward.start_distribution', [1 m.params.T]) .* g.obv_duration_likelihood;
        end
        
        if ~isreal(g.i_forward.log_pZ)
            assert(0);
        end
        
    elseif g.andrule
    %% and rule
    
        current_distribution = g.i_forward.start_distribution;
        current_rs_id        = g.start_rs_id;
        
        g.i_forward.log_pZ   = 0;
        
        for i=g.prule
            m.g(i).i_forward.start_distribution = rs_transform(m, current_distribution, current_rs_id, m.g(i).start_rs_id);
            
            m = forward_phase(m, i);
            
            g.i_forward.log_pZ = g.i_forward.log_pZ + m.g(i).i_forward.log_pZ;
            
            current_distribution = m.g(i).i_forward.end_distribution;
            current_rs_id        = m.g(i).end_rs_id;
        end
        
        
        g.i_forward.end_distribution = rs_transform(m, current_distribution, current_rs_id, g.end_rs_id);
        
    
    else   
    %% or rule 
    
        for i=g.prule
            m.g(i).i_forward.start_distribution = rs_transform(m, g.i_forward.start_distribution, g.start_rs_id, m.g(i).start_rs_id);
            m = forward_phase(m, i);
        end
        
        
        % 
        if isfield(m, 'r_settings')
            g.i_forward.end_distribution = zeros(1, m.r_settings.rs{g.end_rs_id}.T);
        else
            g.i_forward.end_distribution = zeros(1, m.params.T);
        end
        
        for i=g.prule
            g.i_forward.end_distribution = g.i_forward.end_distribution + ...
                m.g(i).or_orweight * ...
                exp(m.g(i).i_forward.log_pZ + m.g(i).or_log_othersnull_likelihood) * ...
                rs_transform(m, m.g(i).i_forward.end_distribution, m.g(i).end_rs_id, g.end_rs_id);
        end
        
        g.i_forward.log_pZ = log(sum(g.i_forward.end_distribution));
        g.i_forward.end_distribution = g.i_forward.end_distribution / sum(g.i_forward.end_distribution);
    end

    % for debug
    if isfield(m, 'r_settings')
        g.i_forward.start_debug = vrts_upsample_probability(g.i_forward.start_distribution, m.r_settings.rs{g.start_rs_id});
        g.i_forward.end_debug   = vrts_upsample_probability(g.i_forward.end_distribution, m.r_settings.rs{g.end_rs_id});
    end
    
    m.g(gid) = g;

end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = backward_phase( m, gid )
    % given g.i_backward.end_likelihood
    % compute g.i_backward.start_likelihood

    g  = m.g(gid);
    
    if ~isreal(g.i_backward.end_likelihood(1))
        assert(0);
    end

    %% terminal
    if g.is_terminal
        
        g.i_backward.start_likelihood = g.i_backward.end_likelihood * g.obv_duration_likelihood';
        
        if m.params.compute_terminal_joint
            %g.i_backward.joint2 = g.obv_duration_likelihood .* repmat(g.i_backward.end_likelihood, [m.params.T 1]);
            g.i_backward.joint2 = repmat(g.i_backward.end_likelihood, [m.params.T 1]);
        end
        
    elseif g.andrule
    %% and rule
    
        current_likelihood = g.i_backward.end_likelihood;
        current_rs_id      = g.end_rs_id;
        
        for i=g.prule(end:-1:1)
            
            m.g(i).i_backward.end_likelihood = rs_transform_likelihood(m, current_likelihood, current_rs_id, m.g(i).end_rs_id);
            m = backward_phase(m, i);
            current_likelihood = m.g(i).i_backward.start_likelihood;
            current_rs_id      = m.g(i).start_rs_id;
            
            % start condition
            if m.params.use_start_conditions,
                if ~isfield(m, 'r_settings')    
                	current_likelihood = start_condition_likelihood_backward(current_likelihood, m.start_conditions(m.g(i).id,:));
                else
                    current_likelihood = start_condition_likelihood_backward(current_likelihood, m.r_settings.start_conditions_rs{m.g(i).id, current_rs_id});
                end
            end
        end
        
        g.i_backward.start_likelihood = rs_transform_likelihood(m, current_likelihood, current_rs_id, g.start_rs_id);
        
    else  %% or rule  
    
        
        for i=g.prule
            
            m.g(i).i_backward.end_likelihood = rs_transform_likelihood(m, g.i_backward.end_likelihood, g.end_rs_id, m.g(i).end_rs_id);
            m = backward_phase(m, i);
            
        end
        
        if isfield(m, 'r_settings')
            g.i_backward.start_likelihood = zeros(1, m.r_settings.rs{g.start_rs_id}.T);
        else
            g.i_backward.start_likelihood = zeros(1, m.params.T);
        end
        
        if ~m.params.use_start_conditions,
            for i=g.prule
                g.i_backward.start_likelihood = g.i_backward.start_likelihood  + ...
                    m.g(i).or_orweight * ...
                    exp(m.g(i).or_log_othersnull_likelihood) * ...
                    rs_transform_likelihood(m, m.g(i).i_backward.start_likelihood, m.g(i).start_rs_id, g.start_rs_id);
            end
        end
        if m.params.use_start_conditions && ~isfield(m, 'r_settings'),
            g.i_backward.start_likelihood = zeros(1, m.params.T);
            for i=g.prule
                g.i_backward.start_likelihood = g.i_backward.start_likelihood  + ...
                    m.g(i).or_orweight * ...
                    exp(m.g(i).or_log_othersnull_likelihood) * ...
                    start_condition_likelihood_backward(m.g(i).i_backward.start_likelihood, m.start_conditions(m.g(i).id,:));
            end
        end
        if m.params.use_start_conditions && isfield(m, 'r_settings'),
            for i=g.prule
                g.i_backward.start_likelihood = g.i_backward.start_likelihood  + ...
                    m.g(i).or_orweight * ...
                    exp(m.g(i).or_log_othersnull_likelihood) * ...
                    rs_transform_likelihood(m, start_condition_likelihood_backward(m.g(i).i_backward.start_likelihood, m.r_settings.start_conditions_rs{m.g(i).id, m.g(i).start_rs_id}), m.g(i).start_rs_id, g.start_rs_id);
                   
            end
        end
    end

    
    %% debug
    if isfield(m, 'r_settings')
        g.i_backward.start_debug = vrts_upsample_likelihood(g.i_backward.start_likelihood, m.r_settings.rs{g.start_rs_id});
        g.i_backward.end_debug   = vrts_upsample_likelihood(g.i_backward.end_likelihood, m.r_settings.rs{g.end_rs_id});
        g.i_backward.start_debug = g.i_backward.start_debug / max(g.i_backward.start_debug);
        g.i_backward.end_debug   = g.i_backward.end_debug / max(g.i_backward.end_debug);
        
        
%         plot(g.i_backward.end_debug);
%         hold on; plot(g.i_backward.start_debug, 'r'); hold off;
    else
%         plot(g.i_backward.end_likelihood / max(g.i_backward.end_likelihood));
%         hold on; plot(g.i_backward.start_likelihood / max(g.i_backward.start_likelihood), 'r'); hold off;
    end
    m.g(gid) = g;

end



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function m = compute_prob_notnull( m, gid )


    if m.g(gid).is_terminal
        return;
        
    elseif m.g(gid).andrule
        
        for i=m.g(gid).prule

            m.g(i).i_final.prob_notnull = m.g(gid).i_final.prob_notnull;
            
            m = compute_prob_notnull(m, i);
            
        end
    
    else
        
        s = [];
        
        for i=m.g(gid).prule
            
            log_notnull = log(m.g(i).or_orweight) + m.g(i).i_forward.log_pZ + m.g(i).or_log_othersnull_likelihood - m.g(gid).i_forward.log_pZ;
            m.g(i).i_final.prob_notnull = m.g(gid).i_final.prob_notnull * exp(log_notnull);
            
            s(end+1) = m.g(i).i_final.prob_notnull * ...
                sum(m.g(i).i_backward.end_likelihood .* m.g(i).i_forward.end_distribution);
            
        end
        
        s = m.g(gid).i_final.prob_notnull * s / sum(s);
        
        for i=m.g(gid).prule
            
            m.g(i).i_final.prob_notnull = s(1);
            s(1) = [];
            
            m = compute_prob_notnull(m, i);
            
        end
        
    end
    
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function symbols = calculate_symbol_distribution(m, symbols)
%CALCULATE_SYMBOL_DISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here


    for i=1:length(symbols) 
        symbols(i).start_distribution = zeros(1, m.params.T); % todo
        symbols(i).end_distribution   = zeros(1, m.params.T); % todo
    end
    
    for g=m.g

        sd = g.i_final.start_distribution * g.i_final.prob_notnull;
        ed = g.i_final.end_distribution * g.i_final.prob_notnull;

        if isfield (m, 'r_settings')
            sd = vrts_upsample_probability(sd,  m.r_settings.rs{g.start_rs_id});
            ed = vrts_upsample_probability(ed,  m.r_settings.rs{g.end_rs_id});
        end

        symbols(g.id).start_distribution = symbols(g.id).start_distribution + sd;
        symbols(g.id).end_distribution   = symbols(g.id).end_distribution + ed;
    end
        

end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function v = rs_transform(m, v, rs_from_id, rs_to_id)

try
    if rs_from_id == rs_to_id
        return;
    elseif ~isnan(rs_from_id) && ~isnan(rs_to_id)
        v = v * m.r_settings.transform_rs{rs_from_id, rs_to_id};
    end
    
catch
    gogo = 1;
end;

end


function v = rs_transform_likelihood(m, v, rs_from_id, rs_to_id)

    if rs_from_id == rs_to_id
        return;
    elseif ~isnan(rs_from_id) && ~isnan(rs_to_id)
        v = v * m.r_settings.transform_rs{rs_to_id, rs_from_id}';
    end
end






























