function result = compute_raw_detection_score( s, m, for_learning )
%COMPUTE_RAW_DETECTION_SCORE Summary of this function goes here
%   Detailed explanation goes here

	
    if ~exist('for_learning')
        for_learning = 0;
    end

    result = {};
    
    for i=1:length(m.vdetectors)
        result{i} = zeros(m.params.T);
    end
    for t1=1:s.length
    for t2=t1:s.length
        

        h = s.i_histograms{4}(:,t2) - s.i_histograms{4}(:,t1);
        h = h + 10e-3;
        h = h / sum(h) * min(1, sum(h) / 100);

%         % nearest neighbor
%         for i=1:length(m.vdetectors)
%             
%             distances = chi_square_statistics_fast(h', m.vdetectors(i).histograms');
%             distances = sort(distances);
%             if for_learning
%                 v = distances(2);
%             else
%                 v = distances(1);
%             end
%             v = max(10e-5, 0.4 - v) ^ 2;
%             
%             result{i}(t1,t2) = v;
%         end
        
        % svm
%         if t1 == 1 & t2 == s.length
            K = nan(1, length(m.svm.examples));
            for i=1:length(m.svm.examples)
                K(i) = exp(-chi_square_statistics_fast(h', m.svm.examples(i).x'));
            end
            
            [a b c] = svmpredict(1, [1 K], m.svm.model, '-q');
            cT = nan(length(m.vdetectors));
            h=0;
            for a=1:length(m.vdetectors)
                cT(a,a) = 0;
                for b=a+1:length(m.vdetectors)
                    cT(a,b) = c(h+1);
                    cT(b,a) = -cT(a,b);
                    h = h + 1;
                end;
            end;
            v = mean(cT,2);
            for i=1:length(m.vdetectors)
                result{i}(t1,t2) = exp(v(i) * 1);
%                 result{i}(t1,t2) = (1 / (1 + exp(-v(i))))^5;
                if i > 6 & i <= 12
                    result{i}(t1,t2) = exp(v(i) * 2);
                elseif i > 12 & i <= 18
                    result{i}(t1,t2) = exp(v(i) * 3);
                elseif i > 18 & i <= 24
                    result{i}(t1,t2) = exp(v(i) * 4);
                elseif i > 24 & i <= 30
                    result{i}(t1,t2) = exp(v(i) * 5);
                elseif i > 30 & i <= 36
                    result{i}(t1,t2) = exp(v(i) * 5);
                elseif i > 36 & i <= 42
                    result{i}(t1,t2) = exp(v(i) * 4); 
                elseif i > 42 
                    result{i}(t1,t2) = exp(v(i) * 2);   
                end
            end
%         end
    end
    end

end

