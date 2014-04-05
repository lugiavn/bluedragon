

%% train duration
durations = {};
for i=setdiff(data.training_ids,data.train_update_ids)
    for a=data.examples(i).train.actions
        try
            durations{a.s_id}(end+1) = a.end - a.start + 1;
        catch
            durations{a.s_id} = [];
            durations{a.s_id}(end+1) = a.end - a.start + 1;
        end
    end
end

%% set duration mean & var into the grammar

for i=1:length(m.grammar.symbols)
    if m.grammar.symbols(i).is_terminal
        assert(length(durations{i}) > 0);
        m.grammar.symbols(i).learntparams.duration_mean = mean(durations{i});
        if m.final_training
            m.grammar.symbols(i).learntparams.duration_var  = var(durations{i})  + 100;
        else
            m.grammar.symbols(i).learntparams.duration_var  = var(durations{i})  + 100;
        end
    end
end

%% train detector

try 
	for i=1:length(m.vdetectors)
        m.vdetectors(i).histograms = [];
        m.vdetectors(i).h_id = [];
    end
catch
    m.vdetectors = struct;
    m.vdetectors.histograms = [];
    m.vdetectors.h_id = [];
end

for i=setdiff(data.training_ids,data.train_update_ids)
    
    s = data.examples(i);
    
    for a=s.train.actions
    if m.grammar.symbols(a.s_id).detector_id > 0
        h = a.hist;
        
        d_id = m.grammar.symbols(a.s_id).detector_id;
        m.vdetectors(d_id).x = 0;
        m.vdetectors(d_id).histograms(:,end+1) = h;
        m.vdetectors(d_id).h_id(:,end+1) = a.h_id;
    end
    end
end

try
    for i=1:length(m.vdetectors)
        m.vdetectors(i).lamda = m.vdetectors(i).lamda;
        m.vdetectors(i).derivative = 0;
    end
catch
    for i=1:length(m.vdetectors)
        m.vdetectors(i).mean_score  = 1;
        m.vdetectors(i).lamda       = 2;
        m.vdetectors(i).derivative  = 0;
        m.vdetectors(i).lamda2      = 0;
        m.vdetectors(i).derivative2 = 0;
    end
end

%% train svm
m.svm.model    = struct;
m.svm.examples = struct;
count = 0;
for i=1:length(m.vdetectors)
    for j=1:size(m.vdetectors(i).histograms,2)
        count = count + 1;
        m.svm.examples(count).x     = m.vdetectors(i).histograms(:,j);
        m.svm.examples(count).y     = i;
        m.svm.examples(count).h_id  = m.vdetectors(i).h_id(:,j);
    end
end
% K = nan(count);
% for i=1:count
%     for j=1:count
%         K(i,j) = exp(-chi_square_statistics_fast(m.svm.examples(i).x', m.svm.examples(j).x'));
%     end
% end
K = data.K([m.svm.examples.h_id], [m.svm.examples.h_id]);
y = [];
for i=1:length(m.svm.examples)
    y(end+1) = m.svm.examples(i).y;
end
m.svm.model = svmtrain(y', [[1:length(y)]' K], '-c 1000 -t 4 -q');
