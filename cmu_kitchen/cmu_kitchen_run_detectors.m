function detections = cmu_kitchen_run_detectors( detectors, sequence )
%CMU_KITCHEN_RUN_DETECTORS Summary of this function goes here
%   Detailed explanation goes here

    T = 1000;

    for i=1:43
        detections{i} = zeros(T, T);
    end
        
    
    examples = [];
    for e=detectors.examples
        examples(:,end+1) = e.histograms{2};
    end
    
    
    sequence_integral_hist = zeros(4000,1);
    for i=1:size(sequence.histograms.HOG,1)
        sequence_integral_hist(:,end+1) = sequence_integral_hist(:,end) + sequence.histograms.HOG(i,:)';
    end
    
    for t1=1:1:T
        for t2=t1:1:T
            
            h = sequence_integral_hist(:,t2+1) - sequence_integral_hist(:,t1);
            h = h / (0.01 + sum(h));
            h = repmat(h, [1 length(detectors.examples)]);
            s = h - examples;
            s = s .* s;
            s = sum(s, 1);
            s = s .^ 0.5;
            s = (1 - s) .^ 2;
            
            for i=1:length(detectors.examples)
                if s(i) > detections{detectors.examples(i).id}(t1, t2) 
                    detections{detectors.examples(i).id}(t1, t2) = s(i); 
                end
            end
            
        end
        
        disp(t1);
    end
    
%     for t1=1:10:T
%         for t2=t1:10:T
%             
%             h = sum(sequence.histograms.MBHx(t1:t2, :), 1)';
%             h = h / (0.01 + sum(h));
%             
%             for e=detectors.examples
%                
%                 s = norm(h - e.histograms{4});
%                 s = (1 - s) ^ 2;
%                 
%                 if s > detections{e.id}(t1, t2) 
%                     detections{e.id}(t1, t2) = s; 
%                 end
%             end
%             
%         end
%         
%         disp(t1);
%     end
end

