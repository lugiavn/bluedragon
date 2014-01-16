function result = compute_raw_detection_score( s, m, for_learning )
%COMPUTE_RAW_DETECTION_SCORE Summary of this function goes here
%   Detailed explanation goes here

	
    if ~exist('for_learning')
        for_learning = 0;
    end

    result = compute_raw_svm_score( s, m );
    
    for i=1:length(m.vdetectors)
        result{i} = exp(result{i} * m.vdetectors(i).lamda) * exp(0.1 * m.vdetectors(i).lamda2);
    end

end

