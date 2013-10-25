
% add path the nx & the airplane_inference

clc; clear; close all;

test_set = [3, 4, 7, 8, 16, 17, 18];

ACTION_NULL_ID = 63;

%% load all

sequences = struct;

sequencenum = 28;

gt_labels         = -1 * ones(sequencenum, 2100);
testresult_labels = -1 * ones(sequencenum, 2100);
compare_labels    = -1 * ones(1, 2100);

right_count = 0;
wrong_count = 0;

for i=1:sequencenum
    
    sequences(i).test = 0;
    
    data = load(sprintf('data/groundTruthActionLabels_%d.mat',i)); 
    data.framesGT(data.framesGT == 0) = ACTION_NULL_ID;
    
    gt_labels(i,1:length(data.framesGT)) = data.framesGT;
    
    sequences(i).framesGT = data.framesGT;
    
    if any(test_set == i)
        
        sequences(i).test = 1;
        
        data = load(sprintf('data/resultsActionLabels_%d.mat',i)); 
        data.frames(data.frames == 0) = ACTION_NULL_ID;
        
        testresult_labels(i,1:length(data.frames)) = data.frames;
        
        sequences(i).frames = data.frames;
        
        compare_labels(end+1,:) = gt_labels(i,:);
        compare_labels(end+1,:) = -1;
        compare_labels(end+1,:) = testresult_labels(i,:);
        compare_labels(end+1,:) = -1;
        compare_labels(end+1,:) = -1;
        
        for j=1:length(data.frames)
            if data.frames(j) == gt_labels(i,j)
                right_count = right_count + 1;
            else
                wrong_count = wrong_count + 1;
            end
        end
    end
    
end

disp(['Test result : ' num2str(right_count / (right_count + wrong_count))]);

colors = [0 0 0; rand(1000,3)];
nx_figure(1); imagesc(gt_labels); xlabel('gt labels');
colormap (colors);
nx_figure(2); imagesc(testresult_labels); xlabel('testresult labels');
colormap (colors);
nx_figure(3); imagesc(compare_labels); xlabel('compare labels');
colormap (colors);



%% compute duration
action_num = max(gt_labels);
actions = struct;
actions.durations = [];
    
gt_labels_train = gt_labels';
gt_labels_train(:,test_set) = [];
t = 1;
while t <= size(gt_labels_train,1) * size(gt_labels_train,2)

    if gt_labels_train(t) > 0
        
        action_id = gt_labels_train(t);
        duration  = 0;
        
        
        while gt_labels_train(t + duration) == action_id
            duration = duration + 1;
        end
        
        actions(action_id).id = action_id;
        actions(action_id).durations(end+1) = duration;
        
        t = t + duration - 1;
    end

    t = t + 1;
end


% calculate mean & var
for i=1:length(actions)
    actions(i).duration_mean = mean(actions(i).durations);
    actions(i).duration_var  = var(actions(i).durations);
    
    if actions(i).duration_var <= 0
        actions(i).duration_var  = 1;
    end
end

% print duration
for i=1:length(actions)
    disp(['action ' num2str(i)]);
    disp(actions(i).durations);
end



%% convert to bluedragon label structure
gt_label_sequences = {};

for i=1:sequencenum
    
    sequences(i).str_gt = remove_consecutive_dup( sequences(i).framesGT );
    
    if sequences(i).test
        
        sequences(i).str_test = remove_consecutive_dup( sequences(i).frames );
        
    end
    
end

%% compute detection mean
detection_means = cell(length(actions)-2,1);
for i=1:sequencenum
if sequences(i).test
    
        T = floor(length(sequences(i).framesGT) / 2);
        
        detection_before = load(['data/Matrix_' num2str(i) '_before']);
        detection_before = detection_before.timeSeriesB;
        detection_after  = load(['data/Matrix_' num2str(i) '_after']);
        detection_after  = detection_after.timeSeriesA;
        for j=1:length(actions)-2
            detection_result = ones(T) * 1;
            for thestart=1:T
                detection_result(thestart,:) = detection_result(thestart,:) * detection_before(j, thestart*2);
            end
            for theend=1:T
                detection_result(:,theend) = detection_result(:,theend) * detection_after(j, theend*2);
            end
            
            detection_means{j} = [detection_means{j}; detection_result(:)];
        end
end
end

for i=1:length(actions)-2
    if length(detection_means{i}) > 0
        detection_means{i} = mean(detection_means{i});
    else
        detection_means{i} = 1;
    end
end

%% TEST
close all;
right_count = 0;
wrong_count = 0;

for i=1:sequencenum
if sequences(i).test
    
    best_mystr = nan;
    best_logPZ = -inf;
    
    for h=1:sequencenum
    if ~sequences(h).test

        % find str
        str = sequences(h).str_gt;

        % setup grammar
        model = struct;
        model.grammar = struct;
        model.grammar.starting = 1;

        model.grammar.symbols(1).name           = 'S';
        model.grammar.symbols(1).is_terminal    = 0;
        model.grammar.symbols(1).rule_id        = 1;

        for j=1:length(actions)
            model.grammar.symbols(j+1).name         = num2str(j);
            model.grammar.symbols(j+1).is_terminal	= 1;
            model.grammar.symbols(j+1).detector_id  = j;

            model.grammar.symbols(j+1).learntparams.duration_mean = actions(j).duration_mean / 2 ;
            model.grammar.symbols(j+1).learntparams.duration_var  = actions(j).duration_var  / 4 ;
        end

        model.grammar.rules(1).id      = 1;
        model.grammar.rules(1).left    = 1;
        model.grammar.rules(1).right   = str + 1;
        model.grammar.rules(1).or_rule = 0;
        model.grammar.rules(1).or_prob = [];

        % gen inference structure
        T = floor(length(sequences(i).framesGT) / 2);
        m = gen_inference_net(model, T, 1, 1, 1);


        % detection
        detection_before = load(['data/Matrix_' num2str(i) '_before']);
        detection_before = detection_before.timeSeriesB;
        detection_after  = load(['data/Matrix_' num2str(i) '_after']);
        detection_after  = detection_after.timeSeriesA;
        for j=1:length(actions)-2
            m.detection.result{j}    = ones(T) * 1;
            for thestart=1:T
                m.detection.result{j}(thestart,:) = m.detection.result{j}(thestart,:) * detection_before(j, thestart*2);
            end
            for theend=1:T
                m.detection.result{j}(:,theend) = m.detection.result{j}(:,theend) * detection_after(j, theend*2);
            end

%             m.detection.result{j} = exp(m.detection.result{j});
%             m.detection.result{j} = m.detection.result{j} - min(m.detection.result{j}(:));
%             m.detection.result{j} = m.detection.result{j} / mean(m.detection.result{j}(:));
            m.detection.result{j} = m.detection.result{j} / detection_means{j};
        end

        % gogogo
        m = m_inference_v3(m);
        nx_figure(131);
%         m_plot_distributions(m, {'12', '17'}, {});

        % segmentation
        my_str = zeros(1, floor(length(sequences(i).frames) / 2));

        for g=m.g(2:end)
            [mymax, maxid] = max(g.i_final.start_distribution);
            my_str(maxid:end) = g.detector_id;
%             maxid = g.i_final.start_distribution .* [1:T];
%             maxid = floor(sum(maxid));
            my_str(maxid:end) = g.detector_id;
        end
        
        % check
        if m.g(1).i_forward.log_pZ > best_logPZ
            disp(['match test ' num2str(i) ' with train ' num2str(h) ', logPZ = ' num2str(m.g(1).i_forward.log_pZ)]);
            best_mystr = my_str;
            best_logPZ = m.g(1).i_forward.log_pZ;
        end


    end
    end
    
    
    
    % plot
    my_str = best_mystr;
    nx_figure(9000+i);
    imagesc([my_str; sequences(i).framesGT([1:T]*2)]);
    colormap (colors);

    for j=1:floor(length(sequences(i).frames) / 2)
        if my_str(j) == sequences(i).framesGT(2*j)
            right_count = right_count + 1;
        else
            wrong_count = wrong_count + 1;
        end
    end
    
    gogogo = 1;
end
end


disp(['Test result : ' num2str(right_count / (right_count + wrong_count))]);
m.g(1).i_forward












