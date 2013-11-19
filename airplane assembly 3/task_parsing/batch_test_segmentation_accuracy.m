

global batch_main_i;
global batch_data;
batch_main_i = 1;
batch_data   = {};

while 1

    clear; close all; clc;
    main;
    
    global batch_main_i;
    global batch_data;
    
    batch_main_i = batch_main_i + 1;
    batch_data{end+1} = test.filename;
    batch_data{end+1} = segmentation_acc;
    
    if batch_main_i >= 2
        break;
    end
end


clear; close all; clc;
global batch_main_i;
global batch_data;
save batch_seg


%%

    
names = {};
accs  = [];

for i=1:2:length(batch_data)
    names{end+1} = batch_data{i};
    accs(end+1)  = batch_data{i+1};
end

[a b] = sort(names);

for i=b
    disp([names{i} '            ' num2str(accs(i))]);
end

% s1_1_a1.avi   0.7
% 
% s1_2_c1.avi   0.8
% s1_2_c3       0.9
% s1_2_c4        0.9
% 
% 
% 
% s2_a1_             0.5 0.5
% s2_a2           0.6
% 
% 
% s2_b1       0.7
% 
% s2_c2    0.8 0.6
% 
% s2_b3







