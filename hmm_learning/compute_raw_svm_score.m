function result = compute_raw_svm_score( s, m )
%COMPUTE_RAW_DETECTION_SCORE Summary of this function goes here
%   Detailed explanation goes here

    matfile = ['./cache/' s.filename '.svmscores.mat'];
    
    if exist(matfile)
        load(matfile, 'result');
        return;
    end
    
    result = {};
    
    s_length = round(s.length / m.params.downsample_ratio);
    s_length = min(50, s_length);
    
    for i=1:length(m.vdetectors)
        result{i} = ones(s_length) * (-Inf);
    end
    
    
    for t1=1:s_length
    for t2=t1:s_length
        h = imresize(s.i_histograms{4}, [size(s.i_histograms{4},1) s_length], 'bilinear');
        h = h(:,t2) - h(:,t1);
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
%                 iii = 1 + 6 * floor( i / 6 - 0.001);
%                 result{i}(t1,t2) = sum(cT(i,iii:iii+5)) / 5;
            end
        end
    end
    end

    save(matfile, 'result');
end

