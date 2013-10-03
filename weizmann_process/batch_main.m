

global batch_main_i;
batch_main_i = 5;

while 1

    clear; close all; clc;
    main;
    
    global batch_main_i;
    save(num2str(batch_main_i));
    if batch_main_i >= 20
        break;
    end
    batch_main_i = batch_main_i + 1;
end












