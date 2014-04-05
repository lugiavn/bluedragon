

%% kalman estimation
close all;


T = m.params.T;

% stateNoise = cov([data.examples.velocity]');
% stateNoise = [data.examples.velocity] * [data.examples.velocity]' /  length([data.examples.velocity]);

kalmanEsimations         = struct;
kalmanEsimations(1).mean = [test.positions(:,1); 0; 0];
kalmanEsimations(1).var  = diag([1 1 0.001 0.001])  * 10^0;

% smooth

y = repmat(kalmanEsimations(1).mean(1:2), [1 T]);

model    = ones(1, T);

F        = [1 0 1 0; 0 1 0 1; 0 0 1 0 ; 0 0 0 1];
H        = [1 0 0 0; 0 1 0 0];
Q        = diag([0.1 0.1 0.04 0.04]);
R        = eye(2) * 10^6;

for t=T:-1:1
    
    model(t) = t;
    y(:,t)   = kalmanEsimations(1).mean(1:2);
    F(:,:,t) = F(:,:,1);
    H(:,:,t) = H(:,:,1);
    Q(:,:,t) = Q(:,:,1);
    R(:,:,t) = R(:,:,1);
    
    if t == 1 | t == 20  | t == 60 %  | t == 70   |  t == 90
        y(:,t)   = test.positions(:,t);
        R(:,:,t) = eye(2) * 1;
    end
end

[xsmooth, Vsmooth] = kalman_smoother(y, F, H, Q, R, kalmanEsimations(1).mean, kalmanEsimations(1).var, 'model', model);

for t=1:T
    kalmanEsimations(t).mean = xsmooth(:,t);
    kalmanEsimations(t).var  = Vsmooth(:,:,t);
end

% viz
figure(1); cla;
hold on;
for t=T:-3:1
    
    % plot kalman estimation
%     plot(kalmanEsimations(t).mean(1), kalmanEsimations(t).mean(2), '*r');
    h = plot_gaussian_ellipsoid(kalmanEsimations(t).mean(1:2), kalmanEsimations(t).var(1:2,1:2)', 3);
    if t > 100
        set(h, 'Color', 'yellow');
    end;
    if t == T
        set(h, 'Color', 'red');
    end
    
    % plot truth
    if t < test.length
        plot(test.positions(1,t), test.positions(2,t), '*g');
    end
end
hold off;
pause(1);

%% inference


% run detection
m.detection.result{1} = ones(m.params.T) * 1;
m.detection.result{2} = ones(m.params.T) * 1;

for t1=1:1:m.params.T
for t2=t1:1:m.params.T
    
    if t2 > length(kalmanEsimations)
        continue;
    end
    
    for i=1:2
        d = detectors{i};
        s = 0;
        
        for j=1:length(d.segments)
            t = nx_linear_scale_to_range(j, 1, length(d.segments), t1, t2);
           
            t = round(t);
            
            o = kalmanEsimations(t);
            
            [~, ~, v] = nx_mul_gaussians(d.segments(j).mean', d.segments(j).var, o.mean, o.var);
            
            s = s + max(-100, log(v)) - d.segments(j).expected_score;
            
        end
        
        s = s / 1 / length(d.segments);
        
        if i==1
            s = s - 78.5559;
        else
            s = s - 77.9026;
        end
        
        m.detection.result{i}(t1, t2) = exp(s);
    end


end
end

% plot
figure(1);
imagesc(log(m.detection.result{1}(1:5:end,1:5:end))); colorbar;
figure(2);
imagesc(log(m.detection.result{2}(1:5:end,1:5:end))); colorbar;

% inf
m = m_inference_v3(m);

% plot
figure(3);
m_plot_distributions(m, {'a1', 'a2'}, {'a1', 'a2'});
pause(0.1);

%% sampling predict

% compute joint of each action
j    = {};
j{1} = m.g(2).i_forward.joint1 .* m.g(2).i_backward.joint2;
j{1} = j{1} / sum(j{1}(:)) * m.g(2).i_final.prob_notnull;

j{2} = m.g(3).i_forward.joint1 .* m.g(3).i_backward.joint2;
j{2} = j{2} / sum(j{2}(:)) * m.g(3).i_final.prob_notnull;

% plot
figure(1);
imagesc(j{1}); colorbar;
figure(2);
imagesc(j{2}); colorbar;


%% init structure
ut  = {};
uax = {};
for t=1:length(kalmanEsimations)
    ut{t} = {};
end
for a=1:2
    for s=1:length(detectors{a}.segments)
        uax{a,s} = {};
    end
end

% sample
for i4623=1:2000
    
    % sample action
    a = randi(length(j));
    a = randsample([1 2], 1, true, [sum(j{1}(:)) sum(j{2}(:)) ]);
    
    % sample timing
    i = randsample(length(j{a}(:)), 1,true, j{a}(:));
    t2 = floor(i / size(j{a},1));
    t1 = mod(i, size(j{a},1));
    
    if t2 > length(kalmanEsimations)
        continue;
    end
    
    % uax
    for s=1:length(detectors{a}.segments)
        
        % compute t
        t = nx_linear_scale_to_range(s, 1, length(detectors{a}.segments), t1, t2);
        t = round (t);
        
        % compute gaussian
        g.var  = inv( inv(kalmanEsimations(t).var) + inv(detectors{a}.segments(s).var));
        g.mean = g.var * (inv(kalmanEsimations(t).var) * kalmanEsimations(t).mean + inv(detectors{a}.segments(s).var) * detectors{a}.segments(s).mean');
        
        g.var = (g.var + g.var') / 2;
        
        % save
        uax{a,s}{end+1} = g;
        
        % viz
        if 0
            h = plot_gaussian_ellipsoid(g.mean, g.var, 3);
            set(h,'color','y');
        end
        
    end
    
    % ut
    for t=t1:t2
        
        s = nx_linear_scale_to_range(t, t1, t2 + 0.001, 1, length(detectors{a}.segments));
        
        w(2) = s - floor(s);
        w(1) = 1 - w(2);
        
        s    = floor(s);
        
        % weighted sum of segments gaussian
        A      = [w(1) 0 0 0, w(2) 0 0 0; 
                  0 w(1) 0 0, 0 w(2) 0 0; 
                  0 0 w(1) 0, 0 0 w(2) 0;
                  0 0 0 w(1), 0 0 0 w(2)];
        g2.mean = A * [detectors{a}.segments(s).mean'; detectors{a}.segments(s+1).mean'];
        g2.var  = A * [detectors{a}.segments(s).var zeros(4); zeros(4) detectors{a}.segments(s+1).var] * A';
        g2.var  = w(1) * detectors{a}.segments(s).var + w(2) *  detectors{a}.segments(s+1).var;
        
        % multiplying with observation gaussian
        g.var  = inv( inv(kalmanEsimations(t).var) + inv(g2.var));
        g.mean = g.var * (inv(kalmanEsimations(t).var) * kalmanEsimations(t).mean + inv(g2.var) * g2.mean);
        
        g.var = (g.var + g.var') / 2;
        
        % save
        ut{t}{end+1} = g;
        
        if t == t2
            for tt = t+1:length(ut)
                ut{tt}{end+1} = g;
            end
        end
        
        % viz
        if 0
            h = plot_gaussian_ellipsoid(g.mean, g.var, 3);
            set(h,'color','y');
        end
    end
   
    
    gogo = 1;
end

%% viz t

p = [];
for i=1:200
    for j=1:200
        p(end+1,:) = [i j];
    end
end

ds = {};

for t=1:1:length(ut)
    
    d = zeros(200,200);
    
    for k=1:length(ut{t})
        
        d2 = mvnpdf(p, ut{t}{k}.mean(1:2)', ut{t}{k}.var(1:2,1:2));
        d2 = reshape(d2, 200, 200);
        d = d + d2;
    end
   
    
    d = d / sum(d(:));
    
    ds{end+1} = d;
    
    imagesc(d);
    pause(1);
    
end

%% play
for t=1:length(ds)
    ds{t}(1) = 0.00;
    imagesc(ds{t});
    set(gca,'YDir','normal');
    
    hold on;
    for d=detectors
    d = d{1};
    for i=1:length(d.segments)
%         plot(d.segments(i).mean(1), d.segments(i).mean(2), '*black');
        h = plot_gaussian_ellipsoid(d.segments(i).mean(1:2), d.segments(i).var(1:2,1:2)', 3);
        set(h, 'Color','black')
    end
    end
    if t < test.length
        plot(test.positions(1,t), test.positions(2,t), '*g');
    end
    hold off;
    
    pause(0.1);
end



