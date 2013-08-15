

weizmann      = struct;
weizmann.path = 'D:\myr\datasets\weizman';

load classification_masks

weizmann.training_ids = nx_randomswap(1:83);
weizmann.testing_ids  = nx_randomswap(84:93);
weizmann.K            = 100;

weizmann.label_str2id.bend  = 1;
weizmann.label_str2id.jack  = 2;
weizmann.label_str2id.jump  = 3;
weizmann.label_str2id.pjump = 4;
weizmann.label_str2id.run   = 5;
weizmann.label_str2id.run1  = 5;
weizmann.label_str2id.run2  = 5;
weizmann.label_str2id.side  = 6;
weizmann.label_str2id.skip  = 7;
weizmann.label_str2id.skip1 = 7;
weizmann.label_str2id.skip2 = 7;
weizmann.label_str2id.walk  = 8;
weizmann.label_str2id.walk1 = 8;
weizmann.label_str2id.walk2 = 8;
weizmann.label_str2id.wave1 = 9;
weizmann.label_str2id.wave2 = 10;

%% calculate distance transform

disp 'calculate distance transform'

distance_transforms = struct;

resized_masks = struct;

samples = fieldnames(aligned_masks);

for i=1:length(samples)
    
    for j=1:size(aligned_masks.(samples{i}),3)
    
        resized_masks.(samples{i})(:,:,j)       = imresize(aligned_masks.(samples{i})(:,:,j), [150 100]);
        distance_transforms.(samples{i})(:,:,j) = bwdist(resized_masks.(samples{i})(:,:,j));
        
%         imagesc(distance_transforms.(samples{i})(:,:,j));
%         pause(0.01);
    end
end

weizmann.original_masks = original_masks;
weizmann.aligned_masks  = aligned_masks;
weizmann.resized_masks  = resized_masks;
weizmann.distance_transforms = distance_transforms;

clearvars -except weizmann

%% convert to struct sample

samples = fieldnames(weizmann.aligned_masks);

for i=1:length(samples)
    
    strings = regexp(samples{i}, '_', 'split');
    
    weizmann.samples(i).id = i;
    weizmann.samples(i).original_mask       = weizmann.original_masks.(samples{i});
    weizmann.samples(i).aligned_mask        = weizmann.aligned_masks.(samples{i});
    weizmann.samples(i).distance_transform  = weizmann.distance_transforms.(samples{i});
    weizmann.samples(i).class               = strings{2};
    weizmann.samples(i).subject             = strings{1};
    
end

clearvars -except weizmann
save data;

%% k means

disp 'perform k means'

feature_vectors = [];

for i=weizmann.training_ids
    for j=1:size(weizmann.samples(i).distance_transform,3)
        f = weizmann.samples(i).distance_transform(:,:,j);
        feature_vectors(end+1,:) = f(:)';
    end
end


feature_vectors = uint8(feature_vectors / 100 * 255);
[C A] = vl_ikmeans(feature_vectors', weizmann.K);

weizmann.C = C;

%% k means classify

for i=1:length(weizmann.samples)
    
    weizmann.samples(i).frameclusterings = [];
    
    for t=1:size(weizmann.samples(i).distance_transform,3)
        f  = weizmann.samples(i).distance_transform(:,:,t);
        f  = f(:);
        f  = uint8(f / 100 * 255);
        weizmann.samples(i).frameclusterings(t) = vl_ikmeanspush(f, weizmann.C);
    end
end


clearvars -except weizmann
save data

%% compute histogram


for i=1:length(weizmann.samples)

    weizmann.samples(i).hist = zeros(1, 100);
    
    for j=weizmann.samples(i).frameclusterings
        
        weizmann.samples(i).hist(j) = weizmann.samples(i).hist(j) + 1;
    
    end

    weizmann.samples(i).hist = weizmann.samples(i).hist / norm(weizmann.samples(i).hist);
end

clearvars -except weizmann
save data


%% nearest neighbor

clc;

for i=weizmann.testing_ids

    class        = 'N/A';
    bestDistance = inf;
    nearestID    = nan;
    distances    = [];

    for k=weizmann.training_ids

        d = norm(weizmann.samples(i).hist - weizmann.samples(k).hist);
        d = histogram_intersection(weizmann.samples(i).hist,weizmann.samples(k).hist);
        distances(end+1) = d;

        if d < bestDistance
            class = weizmann.samples(k).class;
            bestDistance = d;
            nearestID = k;
        end
    end

    disp(['Classify ' num2str(i) ' ' weizmann.samples(i).class ' >>> ' class ', best distance ' num2str(bestDistance) ' with sample ' num2str(nearestID)]);

end

%% create long test sequence

test_sequence_frameclustering = [];
test_sequence_framelabels     = [];

for i=weizmann.testing_ids

    test_sequence_frameclustering = [test_sequence_frameclustering weizmann.samples(i).frameclusterings];
    test_sequence_framelabels     = [test_sequence_framelabels     weizmann.label_str2id.(weizmann.samples(i).class) * ones(1,length(weizmann.samples(i).frameclusterings))];

end

weizmann.test.sequence_frameclustering = test_sequence_frameclustering;
weizmann.test.sequence_framelabels     = test_sequence_framelabels;
weizmann.test.T                        = length(weizmann.test.sequence_framelabels);

clearvars -except weizmann
save data

%% compute observation likelihood for test sequence

observation_eudistances = cell(10,1);

for i=1:10
    observation_eudistances{i} = inf(weizmann.test.T);
end
    
for tstart=1:weizmann.test.T
    disp(tstart)
    for tend=tstart+1:weizmann.test.T

        h = zeros(1, 100);
        
        %for j = weizmann.test.sequence_frameclustering(tstart:tend) % todo
        for j = weizmann.test.sequence_frameclustering(tstart:tend-1)
            h(j) = h(j) + 1;
        end
        
        h = h / norm(h);
        
        for i=weizmann.training_ids
            d = norm(h - weizmann.samples(i).hist);
            classid = weizmann.label_str2id.(weizmann.samples(i).class);
            observation_eudistances{classid}(tstart, tend) = min(d, observation_eudistances{classid}(tstart, tend));
        end

    end
end

weizmann.observation_eudistances = observation_eudistances;
clearvars -except weizmann
save data

%% plot observation likelihood
close all;
for i=1:10
   
    nx_figure(i);
    imagesc(-weizmann.observation_eudistances{i});
    hold on;
    
    t = find(weizmann.test.sequence_framelabels == i);
    tstart = min(t);
    tend   = max(t);
    
    plot(tend, tstart, '*');
    
    hold off;
end

%% learn duration model

weizmann.durations = cell(10,1);

for i=weizmann.training_ids
    
    id = weizmann.label_str2id.(weizmann.samples(i).class);
    weizmann.durations{id}(end+1) = size(weizmann.samples(i).original_mask, 3);

end


clearvars -except weizmann
save data



%% construct grammar
clc;
close all;
load data;

% clear sequences
weizmann.original_masks = 0;
weizmann.aligned_masks  = 0;
weizmann.distance_transforms = 0;
for i=1:length(weizmann.samples)
    weizmann.samples(i).original_mask = 0;
    weizmann.samples(i).aligned_mask = 0;
    weizmann.samples(i).distance_transform = 0;
    
end

% setup grammar
model = struct;
model.grammar = struct;
model.grammar.starting = 1;

model.grammar.symbols(1).name           = 'S';
model.grammar.symbols(1).is_terminal    = 0;
model.grammar.symbols(1).rule_id        = 1;

model.grammar.rules(1).id      = 1;
model.grammar.rules(1).left    = 1;
model.grammar.rules(1).right   = [];
model.grammar.rules(1).or_rule = 0;
model.grammar.rules(1).or_prob = [];

for i=unique(weizmann.test.sequence_framelabels)
    
    model.grammar.symbols(end+1).name      = 'N/A';
    model.grammar.symbols(end).name        = num2str(i);
    model.grammar.symbols(end).is_terminal = 1;
    model.grammar.symbols(end).detector_id = i;
    
    model.grammar.symbols(end).learntparams.duration_mean = mean(weizmann.durations{i});
    model.grammar.symbols(end).learntparams.duration_var  = var(weizmann.durations{i});
    
    model.grammar.rules(1).right(end+1) = length(model.grammar.symbols);
end


% setup grammar
model = struct;
model.grammar = struct;
model.grammar.starting = 1;

model.grammar.symbols(1).name           = 'S';
model.grammar.symbols(1).is_terminal    = 0;
model.grammar.symbols(1).rule_id        = 1;

model.grammar.rules(1).id      = 1;
model.grammar.rules(1).left    = 1;
model.grammar.rules(1).right   = [2 2 2 2 2, 2 2 2 2 2, 2 2 2 2 2];
model.grammar.rules(1).or_rule = 0;
model.grammar.rules(1).or_prob = [];

model.grammar.symbols(2).name           = 'A';
model.grammar.symbols(2).is_terminal    = 0;
model.grammar.symbols(2).rule_id        = 2;

model.grammar.rules(2).id      = 2;
model.grammar.rules(2).left    = 2;
model.grammar.rules(2).right   = [];
model.grammar.rules(2).or_rule = 1;
model.grammar.rules(2).or_prob = ones(10,1) / 10;

for i=unique(weizmann.test.sequence_framelabels)
    
    model.grammar.symbols(end+1).name      = 'N/A';
    model.grammar.symbols(end).name        = num2str(i);
    model.grammar.symbols(end).is_terminal = 1;
    model.grammar.symbols(end).detector_id = i;
    
    model.grammar.symbols(end).learntparams.duration_mean = mean(weizmann.durations{i});
    model.grammar.symbols(end).learntparams.duration_var  = var(weizmann.durations{i});
    
    model.grammar.rules(2).right(end+1) = length(model.grammar.symbols);
end

% empty 
%     model.grammar.symbols(end+1).name      = 'N/A';
%     model.grammar.symbols(end).name        = 'empty';
%     model.grammar.symbols(end).is_terminal = 1;
%     model.grammar.symbols(end).detector_id = 99;
%     
%     model.grammar.symbols(end).learntparams.duration_mean = 0;
%     model.grammar.symbols(end).learntparams.duration_var  = 0;
%     
%     model.grammar.rules(2).right(end+1) = length(model.grammar.symbols);
    
    
% gen inference structure
T  = weizmann.test.T;
Tx = T + 300;
m = gen_inference_net(model, Tx, 1, 1, Tx);

m.g(m.s).end_likelihood(:) = 0;
m.g(m.s).end_likelihood(T) = 1;

% detection
for j=1:10
    m.detection.result{j} = zeros(Tx);
    m.detection.result{j}(1:T,1:T) = 1 - weizmann.observation_eudistances{j};
    m.detection.result{j}(m.detection.result{j} < 10e-5) = 10e-5;
    assert(sum(m.detection.result{j}(:)) > 0);
    m.detection.result{j} = m.detection.result{j} .^ 2;
    m.detection.result{j} = m.detection.result{j} / mean(m.detection.result{j}(:));
    % m.detection.result{j} = ones(Tx);
    nx_figure(j);
    imagesc(m.detection.result{j}); colorbar;
end

    m.detection.result{99} = eye(Tx);
    
% gogogo
m = m_inference_v3(m);

% segmentation
segmentation = zeros(1, weizmann.test.T);
for i=model.grammar.rules(1).right
   t_835 = round(sum(m.g(i).i_final.start_distribution(1:Tx) .* [1:Tx]));
   [~, t_453] = max(m.g(i).i_final.start_distribution(1:T));
   segmentation(t_835:end) = i-1;
end

% segmentation with frame_prob
disp('do compute_frame_prob');
m = m_compute_frame_prob(m);
segmentation2 = zeros(1, weizmann.test.T);
for t=1:weizmann.test.T
    [~, maxid] = max(m.frame_symbol_prob(t,:));
    segmentation2(t) = maxid-2;
end

% plot

nx_figure(95);
m_plot_distributions(m, {'1', '2', '3', '4', '5',    '7', '8', '9', '10'}, {}, 0);
hold on;
for i=1:weizmann.test.T
    plot([i-1 i], [-1 -1]/50, 'linewidth', 20, 'color' , nxtocolor(sum(num2str(segmentation2(i)))));
    plot([i-1 i], [-2 -2]/50, 'linewidth', 20, 'color' , nxtocolor(sum(num2str(weizmann.test.sequence_framelabels(i)))));
end
hold off;

%
disp('done')
nx_figure(112);
imagesc([ weizmann.test.sequence_framelabels ; segmentation; segmentation2]);

disp('Segmentation accuracy')
disp(sum(segmentation == weizmann.test.sequence_framelabels) / weizmann.test.T);
disp(sum(segmentation2 == weizmann.test.sequence_framelabels) / weizmann.test.T);

disp('Log likelihood');
disp(m.g(1).i_forward.log_pZ);














