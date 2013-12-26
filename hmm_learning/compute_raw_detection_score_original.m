function result = compute_raw_detection_score( s, m, for_learning )
%COMPUTE_RAW_DETECTION_SCORE Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('for_learning')
        for_learning = 0;
    end

    result = compute_raw_svm_score( s, m );
    
    for i=1:length(m.vdetectors)
        
        result{i} = exp(result{i} * m.vdetectors(i).lamda);
        
        
%         if i <= 6
%             result{i} = exp(result{i} * 1);
%         elseif i > 6 & i <= 12
%             result{i} = exp(result{i} * 2);
%         elseif i > 12 & i <= 18
%             result{i} = exp(result{i} * 3);
%         elseif i > 18 & i <= 24
%             result{i} = exp(result{i} * 4);
%         elseif i > 24 & i <= 30
%             result{i} = exp(result{i} * 5);
%         elseif i > 30 & i <= 36
%             result{i} = exp(result{i} * 3);
%         elseif i > 36 & i <= 42
%             result{i} = exp(result{i} * 2);
%         elseif i > 42 
%             result{i} = exp(result{i} * 1);
%         else
%             assert(0);
%         end
    end

end

