

% %% read all training sequences info
% clear;
% load d;
% 
% data.training_ids = [];
% data.testing_ids  = [];
% for i=1:length(data.examples)
% %     if data.examples(i).class == 1 | data.examples(i).class == 2
%         if data.examples(i).sequence_id == 8 % 3, 6, 7, 8
%             data.testing_ids(end+1) = i;
%         else
%             data.training_ids(end+1) = i;
%         end
% %     end
% end

%% read the grammar
m.grammar = load_grammar('grammar8.txt');


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

for i_901=1:5
    
    disp(['<<<<<<<<< Round ' num2str(i_901) ' >>>>>>>>>>>>']);
    
    % re-train the model
    do_train

    % inference for each training sequence
    for i_352=data.train_update_ids
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
if 1
    compute_average_detection_score
    save d3;
else
    for i=1:length(m.vdetectors)
        m.vdetectors(i).mean_score = 1;
    end
end
 

%% Now do recognition baby!

CResult = {};

for i=data.testing_ids

    disp(['Inference on sequence ' num2str(i) ', class ' num2str(data.examples(i).class)]);
    class = do_recognition(data.examples(i), m);

    CResult{end+1} = class == data.examples(i).class;
end

disp(CResult);

%%
% Note:
% - For grammar1:
% --- Duration factor makes it worse
% --- Computing average detection score makes it worse
% - For grammar3 sequence 4:
% --- Magnify 2nd primitive detection is better
% --- Duration100 seem beter than Duration10000
% - For grammar3 sequence 6:
% --- Duration1 == Duration100 == Duration10000
% --- ProudAvg Score > 1 > Avg (magnify 2nd primitive) > ProudAvg Score (no magnify)
% - For grammar3 sequence 8:
% --- ProudAvg Score (2) = Avg (2) < 1 (0)
% --- Duration100 (0) > Duration1 (1) & 10000 (1)
% - For grammar3 sequence 2:
% --- (1) same for Duration1,100,10000, and ProdAvg,1
% --- 
% - For grammar4 sequence 2:
% --- (1) > ProdAvg(2)
% --- 
% - For grammar8 sequence 2:
% --- (0): magnify 1 2 3 4 5 5 4 3
% --- (0): prodavg
% --- (0): observation 50%
% - For grammar8 sequence 7:
% --- (2): prodavg, magnify 1 2 3 4 5 5 4 3
% --- (3): no avg
% --- (2): train2
% - For grammar8 sequence 7:
% --- (1): train2






