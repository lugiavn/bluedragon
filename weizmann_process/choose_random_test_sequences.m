function [ training_ids test_ids ] = choose_random_test_sequences(weizmann, sequence_ids)
%CHOOSE_RANDOM_TEST_SEQUENCES Summary of this function goes here
%   Detailed explanation goes here

training_ids  = sequence_ids;
test_ids      = [];

for i=randperm(10)
    
    j = nx_get_random_elements_from(training_ids);
    while i ~= weizmann.label_str2id.(weizmann.samples(j).class)
        j = nx_get_random_elements_from(training_ids);
    end
    
    test_ids(end+1) = j;
    training_ids(training_ids == j) = [];
    
end


end

