
clear; close all; clc;

%% load dataset
data = struct;
data.downsample_ratio = 9;

load_dataset;

%viz_start_events;

clearvars -except data;

%% do train

while 1
    data.rand_ids = randperm(length(data.examples));
    
    if strcmp(data.examples(data.rand_ids(1)).model, 'A') & ...
       strcmp(data.examples(data.rand_ids(2)).model, 'B') & ...
       strcmp(data.examples(data.rand_ids(3)).model, 'C') 
   
            break;
    end
end


data.training_ids = data.rand_ids(4:end);

do_training;

% viz_learning
clearvars -except data;

%% Test: online parsing (offline parsing is the last result from online parsing)

test = data.examples(data.rand_ids(randi([1 3]))); % choose a test sequence
% test = data.examples(14); % choose a test sequence

do_online_parsing;
% do_offline_parsing;


