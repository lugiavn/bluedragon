function v = m_detector_evaluate( detector, example )
%M_DETECTOR_EVALUATE Summary of this function goes here
%   Detailed explanation goes here

    v = 0;
    
    for i=1:length(detector.segments)
        
        t = round ((i-0.5) / length(detector.segments) * example.length);
        t = max(t, 1);
        
        if t <= size(example.positions, 2)
            data = [example.positions(:,t); example.velocity(:,t)];
            v    = v + max(-1000, log( mvnpdf(data', detector.segments(i).mean, detector.segments(i).var) ));
            v    = v - detector.segments(i).expected_score;
        else
            v    = v + 0;
%             v    = v + detector.segments(i).expected_score;
        end
    end

end

