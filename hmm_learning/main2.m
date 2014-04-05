

% read all training sequences info
clear;
load d;

data.training_ids = [];
data.testing_ids  = [];
for i=1:length(data.examples)
    if data.examples(i).sequence_id == 9 % 3, 6, 7, 8
        data.testing_ids(end+1) = i;
    else
        data.training_ids(end+1) = i;
    end
end

%% change feature
% for i=1:length(data.examples)
%     data.examples(i).i_histograms{4} = data.examples(i).i_histograms{2};
% end

%% read the grammar
m.params.downsample_ratio  = 2.5;
% m.params.downsample_length = 50;
m.params.T                 = 150;
m.classes                  = 0:5;
m.grammar = load_grammar('grammar135.txt');


%% init training sequences timing

for i=data.training_ids
    s_id = m.grammar.name2id.(['A' num2str(data.examples(i).class)]);
    s    = m.grammar.symbols(s_id);
    
    % for restart
    rights = {[]};
    for j=s.prule.right,
        if strcmp(m.grammar.symbols(j).name, 'restart'),
            rights{end+1} = [];
        else
            rights{end}(end+1) = j;
        end
    end;
    segments = [];
    for j=1:length(rights)
        segments = [segments [1:length(rights{j})] / length(rights{j})];
        segments(end+1) = -1;
    end
    
    
    for j=1:length(s.prule.right)
        
        data.examples(i).train.actions(j).s_id  = s.prule.right(j);
        data.examples(i).train.actions(j).start = max(1, ceil(data.examples(i).length * (j-1) / length(s.prule.right)));
        data.examples(i).train.actions(j).end   = ceil(data.examples(i).length * j / length(s.prule.right));
        
        % for restart
        if j == 1,
            data.examples(i).train.actions(j).start  = 1;
        else
            data.examples(i).train.actions(j).start = data.examples(i).train.actions(j-1).end;
        end
        if segments(j) == -1
            data.examples(i).train.actions(j).end = 1;
            
        else
            data.examples(i).train.actions(j).end = round (segments(j) * data.examples(i).length );
        end
    end
    
end

save d1;

%% LEARN
for i_462354=1:5
    crf_learn;
end

save d3;

%% Test
CResult = {};
for i=data.testing_ids

    disp(['Inference on sequence ' num2str(i) ', class ' num2str(data.examples(i).class)]);
    
    s = data.examples(i);
    s = load_i_hist(s, data);
    [class  newm] = do_recognition(s, m);

    CResult{end+1} = class == s.class;
    
end

disp(CResult);












































