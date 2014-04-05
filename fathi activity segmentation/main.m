
% init dataset
clc; clear; close all;

GTEA = struct;


GTEA.testing_ids = [3, 4, 7, 8, 16, 17, 18];


ACTION_NULL_ID = 0;


%% load examples

fileID = fopen('./data/labels.txt');
line   = fgetl(fileID);

GTEA.activity_classes = {};

for i=1:28
    
    GTEA.examples(i).id = i;
    
    data = load(sprintf('data/groundTruthActionLabels_%d.mat',i)); 

    GTEA.examples(i).frameslabels_GT = data.framesGT; % segmentation groundtruth
    
    
    % sequence of actions
    GTEA.examples(i).label.actions = struct;
    j = 0;
    for t=1:length(GTEA.examples(i).frameslabels_GT)
        if t == 1 | GTEA.examples(i).label.actions(j).class ~=  GTEA.examples(i).frameslabels_GT(t)
            j = j + 1;
            GTEA.examples(i).label.actions(j).class = GTEA.examples(i).frameslabels_GT(t);
            GTEA.examples(i).label.actions(j).start = t;
        end
        GTEA.examples(i).label.actions(j).end  = t;
    end
    
    % high level acitivty label
    line = fgetl(fileID);
    words = regexp(line, '\s*', 'split');
    %disp(words);
    GTEA.examples(i).label.class = words{2};
    GTEA.examples(i).label.subject_id = str2num(words{3});
    
    GTEA.activity_classes{end+1} = GTEA.examples(i).label.class;
    
    % info
    if 0
        disp(['Sequence ' num2str(i) ' (' num2str(length(GTEA.examples(i).label.actions)) ' actions)']);
        j = 0;
        for a=GTEA.examples(i).label.actions
            if a.class > 0
                disp([num2str(a.start) '     >     ' num2str(a.end)]);
                j = j + 1;
            end
        end
        disp([ ' (' num2str(j) ' actions)']);
    end
end

fclose(fileID);


GTEA.activity_classes = unique(GTEA.activity_classes);


%% train action duration model


for i=1:length(GTEA.examples)
if ~any(i == GTEA.testing_ids)
for a = GTEA.examples(i).label.actions
    try
        GTEA.training.duration.(['action' num2str(a.class)]).data(end+1) = a.end - a.start + 1;
    catch
        GTEA.training.duration.(['action' num2str(a.class)]).data = a.end - a.start + 1;
    end
end
end
end


% actioname to id
actionnames = fieldnames(GTEA.training.duration);
for i=1:length(actionnames)
    GTEA.name2id.(actionnames{i}) = i;
    GTEA.id2name{i} = actionnames{i};
end

%% construct the grammar & write to file

grammar_str = 'S > ';

for i=1:length(GTEA.activity_classes)
    grammar_str = [grammar_str ' ' GTEA.activity_classes{i} ' or'];
end

grammar_str(end-1:end) = sprintf('\n');


for i=1:length(GTEA.activity_classes)
    grammar_str = [grammar_str GTEA.activity_classes{i} ' > '];
    
    for j=1:length(GTEA.examples)
    if ~any(j == GTEA.testing_ids) & strcmp(GTEA.activity_classes{i}, GTEA.examples(j).label.class)
        grammar_str = [grammar_str ' sequence' num2str(j) ' or'];
    end
    end
    
    
    grammar_str(end-1:end) = sprintf('\n');
end

grammar_str(end-1:end) = sprintf('\n');

for i=1:length(GTEA.examples)
if ~any(i == GTEA.testing_ids) 
    grammar_str = [grammar_str  'sequence' num2str(i) ' > '];
    for a = GTEA.examples(i).label.actions
        grammar_str = [grammar_str ' action' num2str(a.class) ' and'];
    end
    grammar_str(end-2:end) = sprintf('\n');
end
end

actionnames = fieldnames(GTEA.training.duration);
for i=1:length(actionnames)
    duration_data = GTEA.training.duration.(actionnames{i}).data;
    grammar_str = [grammar_str actionnames{i} '  ' num2str(i) ' ' ...
        num2str(mean(duration_data)) ' ' ...
        num2str(max(10, var(duration_data)))];
    grammar_str(end+1) = sprintf('\n');
end

disp(grammar_str);

fileID = fopen('grammar.txt', 'wt');
fprintf(fileID, grammar_str);
fclose(fileID);

clearvars -except GTEA;

%% compute detection mean

for i=GTEA.testing_ids

    downsamplingrate = 3;
    T                = round(length(GTEA.examples(i).frameslabels_GT) / downsamplingrate);
    
    % read raw detection value
    detection_before = load(['data/Matrix_' num2str(i) '_before']);
    detection_before = detection_before.timeSeriesB;
    detection_after  = load(['data/Matrix_' num2str(i) '_after']);
    detection_after  = detection_after.timeSeriesA;
    
    % downsample
    temp1 = [];
    temp2 = [];
    for j=1:size(detection_before, 1)
        temp1(j,:) = imresize(detection_before(j,:), [1 T], 'nearest');
        temp2(j,:) = imresize(detection_after(j,:), [1 T], 'nearest');
    end
    detection_before = temp1;
    detection_after  = temp2;
    assert(size(detection_before, 2) == T);
    

    % compute detection score
    for j=1:size(detection_before, 1)
        
        actionname = ['action' num2str(j)];
        id         = GTEA.name2id.(actionname);
        
        detection_result{i,id} = ones(T) * 1;  
        
        for thestart=1:T
            detection_result{i,id}(thestart,:) = detection_result{i,id}(thestart,:) * detection_before(j, thestart) .^ 10;
        end
        for theend=1:T
            detection_result{i,id}(:,theend) = detection_result{i,id}(:,theend) * detection_after(j, theend) .^ 10;
        end
        
%         detection_result{i,id} = detection_result{i,id} * 1 * 10 - 9;
%         detection_result{i,id} = 1 ./ (1 + exp(-detection_result{i,id}));
%         detection_result{i,id} = exp(10 * detection_result{i,id});
    end

end


for i=1:length(GTEA.id2name)-1
    GTEA.mean_detection_score(i) = 1;
    
    d = [];
    for j=1:size(detection_result, 1)
        if ~isempty(detection_result{j,i})
            d = [d; detection_result{j,i}(:)];
        end
    end
    if ~isempty(d)
        GTEA.mean_detection_score(i) = mean(d);
        GTEA.mean_detection_score(i) = exp(mean(log(d))) * (0.5 + rand / 2);
    end
end

%% construct inference structure

accuracies = [];

colors = [0 0 0; rand(1000,3)];

% for i=GTEA.testing_ids
for i=16
    
    m.grammar        = load_grammar('grammar.txt');
    downsamplingrate = 3;
    T                = round(length(GTEA.examples(i).frameslabels_GT) / downsamplingrate);
    m                = gen_inference_net(m, T, downsamplingrate , 1, 1);

    % read raw detection value
    detection_before = load(['data/Matrix_' num2str(i) '_before']);
    detection_before = detection_before.timeSeriesB;
    detection_after  = load(['data/Matrix_' num2str(i) '_after']);
    detection_after  = detection_after.timeSeriesA;
    
    % downsample
    temp1 = [];
    temp2 = [];
    for j=1:size(detection_before, 1)
        temp1(j,:) = imresize(detection_before(j,:), [1 T], 'nearest');
        temp2(j,:) = imresize(detection_after(j,:), [1 T], 'nearest');
    end
    detection_before = temp1;
    detection_after  = temp2;
    assert(size(detection_before, 2) == T);
    
    % compute detection score
    for j=1:size(detection_before, 1)
        
        actionname = ['action' num2str(j)];
        id         = GTEA.name2id.(actionname);
        
        m.detection.result{id} = ones(T) * 1;  
        
        for thestart=1:T
            m.detection.result{id}(thestart,:) = m.detection.result{id}(thestart,:) * detection_before(j, thestart) .^ 10;
        end
        for theend=1:T
            m.detection.result{id}(:,theend) = m.detection.result{id}(:,theend) * detection_after(j, theend) .^ 10;
        end
        
%         m.detection.result{id} = m.detection.result{id} * 1 * 10 - 9;
%         m.detection.result{id} = 1 ./ (1 + exp(-m.detection.result{id}));
%         m.detection.result{id} = exp(10 * m.detection.result{id});

        m.detection.result{id} = m.detection.result{id} / GTEA.mean_detection_score(id);
        
    end
    
    % perform inference
    m = m_inference_v3(m);
    m = m_compute_frame_prob(m);
    
    % segmentation
    frame_symbol_prob = m.frame_symbol_prob(1:T,:)';
    for i5523=1:length(m.grammar.symbols)
        if ~m.grammar.symbols(i5523).is_terminal
            frame_symbol_prob(i5523,:) = 0;
        end
    end
    [~, segmentation] = max(frame_symbol_prob);
    
    % map label
    segmentation2 = zeros(1, T);
    for t=1:T
        symbol_id = segmentation(t);
        detector_id = m.grammar.symbols(symbol_id).detector_id;
        if isnan(detector_id)
            continue;
        end
        actionname = GTEA.id2name{detector_id};
        segmentation2(t) = str2num(actionname(7:end));
    end
    
    % upsample
    segmentation3 = imresize(segmentation2, [1 length(GTEA.examples(i).frameslabels_GT)], 'nearest');
    
    % compare
    nx_figure(i);
    imagesc([GTEA.examples(i).frameslabels_GT; segmentation3]);
    colormap(colors);
    disp Accuracy
    accuracy = sum([GTEA.examples(i).frameslabels_GT == segmentation3]) / length(segmentation3);
    disp(accuracy);
    accuracies(end+1) = accuracy;
end



disp 'Accuracies:'
disp(accuracies);
disp 'Mean accuracy:'
disp(mean(accuracies));































