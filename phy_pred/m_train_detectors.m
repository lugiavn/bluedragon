
function detector = m_train_detectors(examples)

    segment_num = 10; % randi([3, 20]);
    
    detector = struct;

    % duration
    detector.duration.data = [examples.length];
    detector.duration.mean = mean([examples.length]);
    detector.duration.var  = var([examples.length]);
    
    
    % feature
    for i=1:segment_num
        
        data = [];
        
        for e=examples
            t    = round ((i-0.5) / segment_num * e.length);
            t    = nx_linear_scale_to_range(i, 1, segment_num, 1, e.length);
            t    = round (t);
            data = [data [e.positions(:,t); e.velocity(:,t)]];
        end
        
        detector.segments(i).mean = mean(data');
        detector.segments(i).var  = cov(data');
        
        detector.segments(i).expected_score  = -5;
        
    end
end

