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
            
            detectors.examples(end).histograms{4} = detectors.examples(end).histograms{4} / (0.01 + sum(detectors.examples(end).histograms{4}));
        end
    end
    

end

