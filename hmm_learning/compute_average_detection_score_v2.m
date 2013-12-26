
m.params.T = 300;

%% get all examples
svm.examples = struct;
c = 0;
for i=data.training_ids
    for a=data.examples(i).train.actions
        
        h = data.examples(i).i_histograms{4}(:,a.end) - data.examples(i).i_histograms{4}(:,a.start);
        h = h + 10e-3;
        h = h / sum(h) * min(1, sum(h) / 100);
        
        d_id = m.grammar.symbols(a.s_id).detector_id;
        
        c = c + 1;
        svm.examples(c).x = h;
        svm.examples(c).y = d_id;
        svm.examples(c).sequence_id = data.examples(i).sequence_id;
    end
end

%% compute K
K = nan(length(svm.examples));
for i=1:length(svm.examples)
    for j=1:length(svm.examples)
        K(i,j) = exp(-chi_square_statistics_fast(svm.examples(i).x', svm.examples(j).x'));
    end
end

%% for each sequence
results = {};
sequences = unique([data.examples(data.training_ids).sequence_id]);
for sequence_id=sequences
    
    % train
    training_ids = find([svm.examples.sequence_id] ~= sequence_id);
    testing_ids  = find([svm.examples.sequence_id] == sequence_id);
    
    y            = [svm.examples.y];
    y            = y(training_ids);
    
    svm.model = svmtrain(y', [[1:length(y)]' K(training_ids, training_ids)], '-c 100 -t 4');
    
    % test
    m.svm.model = svm.model;
    m.svm.examples = svm.examples(training_ids);
    for i=data.training_ids
        if data.examples(i).sequence_id == sequence_id
            results{end+1} = compute_raw_detection_score(data.examples(i), m, 1);
        end
    end
    
end

%%
for k=1:length(m.vdetectors)

    values = [];
    
    for i=1:length(results)
        values = [values; results{i}{k}(results{i}{k} > 0)];
    end
    
    m.vdetectors(k).mean_score = mean(values);
end

%% svm model
training_ids = 1:length(svm.examples);
y            = [svm.examples.y];
y            = y(training_ids);
m.svm.model = svmtrain(y', [[1:length(y)]' K(training_ids, training_ids)], '-c 100 -t 4');
m.svm.examples = svm.examples(training_ids);

















