

global batch_main_i;
batch_main_i = 212;

while 1

    clear; close all; clc;
    main;
    
    global batch_main_i;
    save(num2str(batch_main_i));
    if batch_main_i >= 220
        break;
    end
    batch_main_i = batch_main_i + 1;
end


%%
clc;
accs = [];

for i=201:220
    load(num2str(i));
    accs(end+1) = segmentation_acc;
end

disp Acc:
disp(accs);
disp MEAN:
disp(mean(accs));








