function detectors = cmu_kitchen_train_detectors( sequences )
%CMU_KITCHEN_TRAIN_DETECTORS Summary of this function goes here
%   Detailed explanation goes here

    detectors.examples = struct;

    for e=sequences
        for l=e.labels
            try
                detectors.examples(end+1) = l;
            catch
                detectors.examples = l;
            end
            
            for u=2
                
                t1 = round(nx_linear_scale_to_range(l.start, 1, e.video_length, 1, 1000));
                t2 = round(nx_linear_scale_to_range(l.end, 1, e.video_length, 1, 1000));
                
                t33 = round((t1 * 2 + t2) / 3);
                t66 = round((t1 + 2 * t2) / 3);
                
                h = [sum(e.histograms.HOG(t1:t2, :), 1)' 
                     sum(e.histograms.HOG(t1:t33, :), 1)' 
                     sum(e.histograms.HOG(t33:t66, :), 1)' 
                     sum(e.histograms.HOG(t66:t2, :), 1)' ];
                 
                h = h + 0.01;
                h = h / sum(h);
                
                detectors.examples(end).histograms{u} = h;
                
                assert(size(h,1) == 16000);
                assert(size(h,2) == 1);
            end

        end
    end
    

end

