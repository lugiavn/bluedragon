function weizmann = load_weizmann_dataset( wz_path )
%LOAD_WEIZMANN_DATASET Summary of this function goes here
%   Detailed explanation goes here


weizmann      = struct;
weizmann.path = wz_path;

weizmann.label_str2id.bend  = 1;
weizmann.label_str2id.jack  = 2;
weizmann.label_str2id.jump  = 3;
weizmann.label_str2id.pjump = 4;
weizmann.label_str2id.run   = 5;
weizmann.label_str2id.run1  = 5;
weizmann.label_str2id.run2  = 5;
weizmann.label_str2id.side  = 6;
weizmann.label_str2id.skip  = 7;
weizmann.label_str2id.skip1 = 7;
weizmann.label_str2id.skip2 = 7;
weizmann.label_str2id.walk  = 8;
weizmann.label_str2id.walk1 = 8;
weizmann.label_str2id.walk2 = 8;
weizmann.label_str2id.wave1 = 9;
weizmann.label_str2id.wave2 = 10;

load([wz_path '\classification_masks.mat'])

samples = fieldnames(aligned_masks);

for i=1:length(samples)
    
    strings = regexp(samples{i}, '_', 'split');
    
    weizmann.samples(i).id                  = i;
    weizmann.samples(i).original_mask       = original_masks.(samples{i});
    weizmann.samples(i).aligned_mask        = aligned_masks.(samples{i});
    weizmann.samples(i).class               = strings{2};
    weizmann.samples(i).subject             = strings{1};
    
end


end

