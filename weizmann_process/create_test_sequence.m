function test = create_test_sequence( weizmann, ids )
%CREATE_TEST_SEQUENCE Summary of this function goes here
%   Detailed explanation goes here

test_sequence_frameclustering = [];
test_sequence_framelabels     = [];

for i=ids

    test_sequence_frameclustering = [test_sequence_frameclustering weizmann.samples(i).frameclusterings];
    test_sequence_framelabels     = [test_sequence_framelabels weizmann.label_str2id.(weizmann.samples(i).class) * ones(1,length(weizmann.samples(i).frameclusterings))];

end

test.sequence_frameclustering = test_sequence_frameclustering;
test.sequence_framelabels     = test_sequence_framelabels;
test.T                        = length(test.sequence_framelabels);
 
end

