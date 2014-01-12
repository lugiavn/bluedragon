
clear; clc;
global batch;
batch           = struct;
batch.i         = 1;
batch.loopnum   = 10;
batch.CResults  = {};

while true
    
    clear; clc;
    load d;
    global batch;
    data.training_ids = [];
    data.testing_ids  = [];
    for i=1:length(data.examples)
        if data.examples(i).sequence_id == batch.i
            data.testing_ids(end+1) = i;
        else
            data.training_ids(end+1) = i;
        end
    end
    main2;
    
    % save
    global batch;
    batch.CResults{batch.i} = CResult;
    save d9
    
    % next
    batch.i = batch.i + 1;
    if batch.i > batch.loopnum
        break;
    end
end







