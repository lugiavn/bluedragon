function detections = cmu_kitchen_run_detectors( detectors, sequence )
%CMU_KITCHEN_RUN_DETECTORS Summary of this function goes here
%   Detailed explanation goes here

    T = 1000;

    for i=1:43
        
        detections{i} = zeros(T, T);

    end
        
    for t1=1:10:T
        for t2=t1:10:T
            
            h = sum(sequence.histograms.MBHx(t1:t2, :), 1)';
            h = h / (0.01 + sum(h));
            
            for e=detectors.examples
               
                s = norm(h - e.histograms{4});
                s = (1 - s) ^ 2;
                
                if s > detections{e.id}(t1, t2) 
                    detections{e.id}(t1, t2) = s; 
                end
            end
            
        end
        
        disp(t1);
    end
end

