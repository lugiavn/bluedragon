

%% read all training sequences info
clear;
load d;

data.training_ids = [];
data.testing_ids  = [];
for i=1:length(data.examples)
%     if data.examples(i).class == 1 | data.examples(i).class == 2
        if data.examples(i).sequence_id == 6 % 3, 6, 7, 8
            data.testing_ids(end+1) = i;
        else
            data.training_ids(end+1) = i;
        end
%     end
end

%% read the grammar
m.grammar = load_grammar('grammar4.txt');


%% init training sequences timing

for i=data.training_ids
    s_id = m.grammar.name2id.(['A' num2str(data.examples(i).class)]);
    s    = m.grammar.symbols(s_id);
    for j=1:length(s.prule.right)
        data.examples(i).train.actions(j).s_id  = s.prule.right(j);
        data.examples(i).train.actions(j).start = max(1, ceil(data.examples(i).length * (j-1) / length(s.prule.right)));
        data.examples(i).train.actions(j).end   = ceil(data.examples(i).length * j / length(s.prule.right));
    end
end

save d1;

%% iterate
load d1;

m.final_training = 0;

for i_901=1:10
    
    disp(['<<<<<<<<< Round ' num2str(i_901) ' >>>>>>>>>>>>']);
    
    % re-train the model
    do_train

    % inference for each training sequence
    for i_352=data.training_ids
         disp(['Inference on sequence ' num2str(i_352) ', class ' num2str(data.examples(i_352).class)]);
         data.examples(i_352) = perform_inf_n_update_timing(data.examples(i_352), m);
    end
    
    if mod(i_901, 10) == 3
        save d2;
    end
end

save d2

%% compute average detection score
clear;
load d2;
m.final_training = 1;
do_train;
compute_average_detection_score
save d3

%% Now do recognition baby!
clear;
load d3;
CResult = [];

for i=data.testing_ids

    disp(['Inference on sequence ' num2str(i) ', class ' num2str(data.examples(i).class)]);
    class = do_recognition(data.examples(i), m);

    CResult(end+1) = class == data.examples(i).class;
end

disp(CResult);









