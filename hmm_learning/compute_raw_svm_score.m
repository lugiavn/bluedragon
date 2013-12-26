function result = compute_raw_svm_score( s, m )
%COMPUTE_RAW_DETECTION_SCORE Summary of this function goes here
%   Detailed explanation goes here

    matfile = ['./cache/' strrep(s.filename, '.avi', '.svmscores.mat')];
    
    if exist(matfile)
        load(matfile, 'result');
        return;
    end
    
    result = {};
    
    for i=1:length(m.vdetectors)
        result{i} = ones(m.params.T) * (-Inf);
    end
    
    for t1=1:s.length
    for t2=t1:s.length
        
        h = s.i_histograms{4}(:,t2) - s.i_histograms{4}(:,t1);
        h = h + 10e-3;
        h = h / sum(h) * min(1, sum(h) / 100);

        
        % svm
        if 1
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
                result{i}(t1,t2) = v(i);
            end
        end
    end
    end

    save(matfile, 'result');
end

