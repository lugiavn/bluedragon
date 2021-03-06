

data.train_update_ids = [];
data.train_update_ids = data.training_ids;

%% train duration
durations = {};
for i=data.training_ids
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
            m.grammar.symbols(i).learntparams.duration_var  = var(durations{i}) * 2 + 10;
        else
            m.grammar.symbols(i).learntparams.duration_var  = var(durations{i}) * 16 + 10000;
        end
    end
end

%% train detector
delete('./cache/*.mat')

try 
	for i=1:length(m.vdetectors)
        m.vdetectors(i).histograms = [];
    end
catch
    m.vdetectors = struct;
    m.vdetectors.histograms = [];
end

for i=data.training_ids
    for a=data.examples(i).train.actions
        
        h = data.examples(i).i_histograms{4}(:,a.end) - data.examples(i).i_histograms{4}(:,a.start);
        h = h + 10e-3;
        h = h / sum(h) * min(1, sum(h) / 100);
        
        
        d_id = m.grammar.symbols(a.s_id).detector_id;
        m.vdetectors(d_id).x = 0;
        m.vdetectors(d_id).histograms(:,end+1) = h;
    end
end

try
    for i=1:length(m.vdetectors)
        m.vdetectors(i).lamda = m.vdetectors(i).lamda;
        m.vdetectors(i).derivative = 0;
    end
catch
    for i=1:length(m.vdetectors)
        m.vdetectors(i).lamda = 2;
        m.vdetectors(i).derivative = 0;
    end
end

%% mean & var of histograms
% for i=1:length(m.vdetectors)
%     m.vdetectors(i).hist_mean = mean(m.vdetectors(i).histograms');
%     m.vdetectors(i).hist_var  = cov(m.vdetectors(i).histograms');
%     
% end

%% train svm
m.svm.model    = struct;
m.svm.examples = struct;
count = 0;
for i=1:length(m.vdetectors)
    for j=1:size(m.vdetectors(i).histograms,2)
        count = count + 1;
        m.svm.examples(count).x = m.vdetectors(i).histograms(:,j);
        m.svm.examples(count).y = i;
    end
end
K = nan(count);
for i=1:count
    for j=1:count
        K(i,j) = exp(-chi_square_statistics_fast(m.svm.examples(i).x', m.svm.examples(j).x'));
    end
end
y = [];
for i=1:length(m.svm.examples)
    y(end+1) = m.svm.examples(i).y;
end
m.svm.model = svmtrain(y', [[1:length(y)]' K], '-c 100 -t 4');









