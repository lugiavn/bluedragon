

%% read all training sequences info
clear;
load d;

data.training_ids = [];
data.testing_ids  = [];
for i=1:length(data.examples)
%     if data.examples(i).class == 1 | data.examples(i).class == 2
        if data.examples(i).sequence_id == 7 % 3, 6, 7, 8
            data.testing_ids(end+1) = i;
        else
            data.training_ids(end+1) = i;
        end
%     end
end

%% read the grammar
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

%% iterate
% load d1;

m.final_training = 0;

for i_901=1:50
    
    disp(['<<<<<<<<< Round ' num2str(i_901) ' >>>>>>>>>>>>']);
    
    % re-train the model
    do_train_v2;
    
    %
    compute_average_detection_score;

    % inference for each training sequence
    for i_423652=1:100
    for i_352=nx_randomswap(data.train_update_ids)
         disp(['Inference on sequence ' num2str(i_352) ', class ' num2str(data.examples(i_352).class)]);
         [data.examples(i_352) newm] = perform_inf_n_update_timing(data.examples(i_352), m);
         
        %
        temp;
        gd_update_params;
    end
    end
    
    %
    figure(99);
    imagesc(reshape([m.vdetectors().lamda], [6 8])); colorbar;
    pause(1);
end

save d2

%% compute average detection score
% clear;
% load d2;

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
detector_scores = {};
for i=data.testing_ids

    disp(['Inference on sequence ' num2str(i) ', class ' num2str(data.examples(i).class)]);
    [class detector_scores{i} newm] = do_recognition(data.examples(i), m);

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

% - For grammar8 sequence 8:
% --- (3): train2 vs (1) : notrain
% - For grammar8 sequence 2:
% --- (1): train2 vs train (0) vs notrain(0)

%%
% for i6435435=1:100

% try update
% for i=1:length(m.vdetectors)
%     m.vdetectors(i).mean_score = log(m.vdetectors(i).mean_score) / m.vdetectors(i).lamda;
%     m.vdetectors(i).lamda = m.vdetectors(i).lamda + 1 * m.vdetectors(i).derivative;
%     m.vdetectors(i).derivative = 0;
%     m.vdetectors(i).mean_score = exp(m.vdetectors(i).mean_score * m.vdetectors(i).lamda);
% end
% 
% 
% % inf
% CResult = {};
% detector_scores = {};
% for i=data.testing_ids
% 
%     disp(['Inference on sequence ' num2str(i) ', class ' num2str(data.examples(i).class)]);
%     [class detector_scores{i} newm] = do_recognition(data.examples(i), m);
% 
%     CResult{end+1} = class == data.examples(i).class;
%     
%     % derivative
%     temp;
% end
% 
% disp(CResult);
% 
% end;


