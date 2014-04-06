
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

%% compute hists
for i=1:length(dataset.examples)
    for j=1:length(dataset.examples(i).labels)
        
        e = dataset.examples(i);
        l = dataset.examples(i).labels(j);
        
        dnames = fields(e.histograms);
        for u=1:length(dnames)
            
            t1 = round(1000 * l.start / e.video_length);
            t2 = round(1000 * l.end / e.video_length);
            
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

%% gen grammar

grammar_str = 'S > ';

for j=1:length(dataset.examples)
    grammar_str = [grammar_str ' sequence' num2str(j) ' or'];
end


grammar_str(end-1:end) = sprintf('\n');

for i=1:length(dataset.examples)
% if ~any(i == dataset.testing_ids) 
    grammar_str = [grammar_str  'sequence' num2str(i) ' > '];
    for l = dataset.examples(i).labels
        grammar_str = [grammar_str ' action' num2str(l.id) ' and'];
    end
    grammar_str(end-2:end) = sprintf('\n');
% end
end

for i=1:dataset.primitive_action_num
    
    duration_data = dataset.training.durations{i};
    grammar_str = [grammar_str  '  action' num2str(i) ' ' ...
        num2str(mean(duration_data)) ' ' ...
        num2str(max(10, var(duration_data)))];
    grammar_str(end+1) = sprintf('\n');
end


fileID = fopen('grammar.txt', 'wt');
fprintf(fileID, grammar_str);
fclose(fileID);

clearvars -except dataset
save d3 -v7.3


%% compute detection mean

% detectors  = cmu_kitchen_train_detectors(dataset.examples(2:end));
% detections = cmu_kitchen_run_detectors(detectors, dataset.examples(1));
% 
% for i=1:dataset.primitive_action_num
%     
%     detections = [];
%     
%     detections(end+1) = 1;
%     for e=dataset.examples
%         for l=e.labels
%             
%         end
%     end
%     
%     dataset.training.detection_means(i) = exp(mean(log(detections)));
% end


%% inference























