
clear; close all; clc;

%% Load

disp 'Load dataset and compute distance transform'
disp '...'
weizmann = load_weizmann_dataset('D:\myr\datasets\weizmann');
weizmann = resize_masks_and_compute_dt(weizmann);

%play_distance_transform(weizmann);


weizmann.training_ids = nx_randomswap(1:83);
weizmann.testing_ids  = nx_randomswap(84:93);
weizmann.K            = 100; % for k-means

%% duration model
weizmann.durations = cell(10,1);

for i=weizmann.training_ids
    
    id = weizmann.label_str2id.(weizmann.samples(i).class);
    weizmann.durations{id}(end+1) = size(weizmann.samples(i).original_mask, 3);

end

%% k-means
disp 'Perform k-means'
weizmann = perform_kmeans(weizmann, weizmann.K, weizmann.training_ids);

clearvars -except weizmann
save data


%% compute histogram

for i=1:length(weizmann.samples)

    weizmann.samples(i).hist = zeros(1, weizmann.K);
    
    for j=weizmann.samples(i).frameclusterings
        
        weizmann.samples(i).hist(j) = weizmann.samples(i).hist(j) + 1;
    
    end

    weizmann.samples(i).hist = weizmann.samples(i).hist / norm(weizmann.samples(i).hist);
end

% test_nearest_neighbor_classification( weizmann )


%% create long test sequence

weizmann.test = create_test_sequence( weizmann, weizmann.testing_ids);
 

%% compute observation likelihood for test sequence

weizmann.test = perform_detections( weizmann, weizmann.test);


%% save

for i=1:length(weizmann.samples)
    weizmann.samples(i).original_mask = 0;
    weizmann.samples(i).aligned_mask = 0;
    weizmann.samples(i).distance_transform = 0;
end


clearvars -except weizmann
save data

%% Inference
load data;

m = create_m(weizmann);

T  = weizmann.test.T;
Tx = weizmann.test.T + 300;

% detection
for j=1:10
    m.detection.result{j}           = zeros(Tx);
    m.detection.result{j}(1:T,1:T)  = 2 - weizmann.test.x2_distances{j};
    
    m.detection.result{j}(m.detection.result{j} < 10e-5) = 10e-5;
    
    assert(sum(m.detection.result{j}(:)) > 0);
    
    m.detection.result{j} = m.detection.result{j} .^ 2;
    m.detection.result{j} = m.detection.result{j} / mean(m.detection.result{j}(:));
    % m.detection.result{j} = ones(Tx);
    %nx_figure(j);
    %imagesc(m.detection.result{j}); colorbar;
end

    m.detection.result{99} = eye(Tx);

% inference
m = m_inference_v3(m);

% segmentation
m                 = m_compute_frame_prob(m);
[~, segmentation] = max(m.frame_symbol_prob(1:T,:)');
segmentation      = segmentation - 2;
%

nx_figure(112);
imagesc([ weizmann.test.sequence_framelabels ; segmentation]);
segmentation_acc = 1 - sum(weizmann.test.sequence_framelabels ~= segmentation) / T;
disp(['Segmentation accuracy: ' num2str(segmentation_acc)]);

