

function m = gen_inference_net(model, T, downsample_ratio , uni_start_length, uni_end_length)

if isstr(model)
    load(model);
end

if ~exist('T')
    T = 1000;
end

if ~exist('uni_start_length')
    uni_start_length = 100;
end
if ~exist('uni_end_length')
    uni_end_length = T;
end
if ~exist('downsample_ratio')
    downsample_ratio = 7;
end

disp ==========================================================
disp 'Generate inference network'
disp ==========================================================

m = struct;

if ~exist('model')
    disp 'variable model not found. Please load model first'
    return;
end

m                               = model; clearvars model;
m.params.T                      = T;
m.params.compute_terminal_joint = 1;
m.params.downsample_ratio       = downsample_ratio;
m.params.duration_var_scale     = 5;
m.params.use_start_conditions   = 0;

m.params.fake_dummmy_step_before_terminal = 0;

duration_mean = 30 / m.params.downsample_ratio;
duration_var  = 400 * m.params.duration_var_scale / m.params.downsample_ratio^2;
m.params.trick.fakedummystep    = nxmakegaussian(m.params.T, duration_mean, duration_var);
if 1
    for i=2:m.params.T
        m.params.trick.fakedummystep(i,:) = [0 m.params.trick.fakedummystep(i-1,1:end-1)];
    end
end
m.params.trick.fakedummystep    = NaN;


m.start_conditions              = ones(length(m.grammar.symbols), m.params.T);


%% compute duration mat

for i=1:length(m.grammar.symbols)
    if m.grammar.symbols(i).is_terminal
        
        duration_mean = m.grammar.symbols(i).learntparams.duration_mean / m.params.downsample_ratio;
        duration_var  = m.params.duration_var_scale * m.grammar.symbols(i).learntparams.duration_var / m.params.downsample_ratio^2;
        
        
        [m.grammar.symbols(i).duration_vec, m.grammar.symbols(i).duration_mat] = make_duration_mat(duration_mean, duration_var, m.params.T);
        
        % integral
        m.grammar.symbols(i).duration_mat_integral = zeros(m.params.T + 1);
        m.grammar.symbols(i).duration_mat_integral(2:end,2:end) = cumsum(cumsum(m.grammar.symbols(i).duration_mat, 2));
    end
end


%% roll out

m.g = [];
x   = [m.grammar.starting];
i   = 0;

while 1
    i = i + 1;
    if length(x) < i, break; end;
    
    s = m.grammar.symbols(x(i));
    r = m.grammar.rules(find([m.grammar.rules.left] == x(i)));
    
    m.g(end+1).id        	= x(i);
    m.g(end).is_terminal  	= s.is_terminal;
    m.g(end).detector_id   	= s.detector_id;
    
    if s.is_terminal
        
        m.g(end).log_null_likelihood = log(1);
        
        %m.g(end).obv_duration_likelihood = m.g(end).likelihood .* m.g(end).durationmat;
        m.g(end).obv_duration_likelihood = nan(m.params.T);
        
    else
        
        m.g(end).prule      = r.right; % todo
        m.g(end).prule      = length(x) + [1:length(r.right)];
        m.g(end).andrule    = ~r.or_rule;
        m.g(end).orweights  = r.or_prob;
        
        x = [x r.right];
    end
    

end

%% set up inference struct
for i=1:length(m.g)
    m.g(i).i_forward    = struct;
    m.g(i).i_backward   = struct;
    m.g(i).i_final      = struct;
    m.g(i).start_rs_id	= nan;
    m.g(i).end_rs_id    = nan;
end

%% set up root
m.s =  m.grammar.starting;

m.g(m.s).start_distribution                     = 0 * ones(1, m.params.T) / m.params.T;
m.g(m.s).start_distribution(1:uni_start_length) = 1 / uni_start_length;

m.g(m.s).end_likelihood                             = 0 * ones(1, m.params.T) / m.params.T;
m.g(m.s).end_likelihood(end-uni_end_length+1:end)   = 1 / uni_end_length;

%% set up detection result
for i=unique([m.g.detector_id])
    if i > 0
        m.detection.result{i} = ones(m.params.T);
    end
end;

disp 'Generating inference network is successful'
return;

end













