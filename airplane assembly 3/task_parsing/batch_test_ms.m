

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
    batch_data{end+1} = {test, ms};
    if batch_main_i >= 100
        break;
    end
end


clear; close all; clc;
global batch_main_i;
global batch_data;
save batch_ms





