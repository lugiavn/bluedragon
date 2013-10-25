function detections_result = run_detectors( visualdetectors, missing_detections, reaching_hand , do_raw)
%RUN_DETECTORS Summary of this function goes here
%   Detailed explanation goes here

if ~exist('do_raw')
    do_raw = 0;
end

detections_result = nan(1, length(visualdetectors));

% run detectors & update detection result
for i=1:length(visualdetectors)
if i ~= 333
    
    detector = visualdetectors{i};
    
    if do_raw 
        if ~isnan(reaching_hand(1))
            v = mvnpdf(reaching_hand, detector.mean, detector.var);
        else
            v = nan;
        end
    else

        if missing_detections
            v = 0.2;
        else
            v = 0.01;
        end
        if ~isnan(reaching_hand(1))
            % v = v + 500000 * mvnpdf(reaching_hand, detector.mean, detector.var);
            v = v +  mvnpdf(reaching_hand, detector.mean, detector.var) / visualdetectors{i}.mean_detection_score;
        end
    end
    
    detections_result(i) = v;
end
end

end

