
%% load
% read_dataset_info;
% clearvars -except dataset
% save d;

%% build dic, need dense trajectories
% build_dic

%% compute hist, need dense trajectories
% compute_hists

clear;
load d2;
for i=1:length(dataset.examples)
    load(['histograms/' num2str(i) '.mat']);
	dataset.examples(i).histograms = histograms;   
end

%% compute hists
for i=1:length(dataset.examples)

    e = dataset.examples(i);
    load(['histograms/' num2str(i) '.mat']);
    e.histograms = histograms;
        
    
    
    for j=1:length(dataset.examples(i).labels)
        
        l = dataset.examples(i).labels(j);
        
        dnames = fields(e.histograms);
        for u=1:length(dnames)
            
            t1 = round(nx_linear_scale_to_range(l.start, 1, e.video_length, 1, 1000));
            t2 = round(nx_linear_scale_to_range(l.end, 1, e.video_length, 1, 1000));
            
            
            h  = sum(e.histograms.(dnames{u})(t1:t2,:), 1);
            
            dataset.examples(i).labels(j).histograms{u} = h';
        end
    end
end

%% compute duration model
durations = {};
for e=dataset.examples
    for l=e.labels
        try
            durations{l.id}(end+1) = l.end - l.start + 1;
        catch
            durations{l.id} = single([l.end - l.start + 1]);
        end
    end
end

dataset.training.durations = durations;

%% compute detections

parfor i=13
    
    training_ids    = 1:length(dataset.examples);
    training_ids(i) = [];
    detectors       = cmu_kitchen_train_detectors(dataset.examples(training_ids));
    detections      = cmu_kitchen_run_detectors(detectors, dataset.examples(i));

    save_detection(i, detections);
    
end


%% compute detection mean

dataset.params.n_power = 100;

compute_detection_means

clearvars -except dataset
save d3 -v7.3

%% inference
clear
load d3;
data = {};

GROUNDTRUTH_GRAMMAR  = 0;
for testing_id = 1:13
    
    data{testing_id}.testing_id = testing_id;
      
    dataset.training_ids = 1:13;
    dataset.training_ids = setdiff(1:length(dataset.examples), testing_id); 
    
    make_cmu_kitchen_grammar 
    pause(10);
    run_testing;
    
    % save
    data{testing_id}    = struct;
    data{testing_id}.p1 = m.frame_symbol_prob(1:T,:)';
    data{testing_id}.p2 = zeros(dataset.primitive_action_num, 1000);
    for i4641=1:dataset.primitive_action_num
        for j51=1:length(m.grammar.symbols)
            if m.grammar.symbols(j51).detector_id == i4641
                data{testing_id}.p2(i4641,:) = m.frame_symbol_prob(1:T,j51)';
            end
        end
    end
   
end

clearvars -except data
save result













