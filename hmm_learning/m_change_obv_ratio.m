function m = m_change_obv_ratio( m, s, obv_ratio )
%M_CHANGE_OBV_RATIO Summary of this function goes here
%   Detailed explanation goes here

    assert(obv_ratio <= 1 & obv_ratio >= 0);
    
    s_length = round(s.length / m.params.downsample_ratio);
    
    % change end likelyhood
    m.g(m.s).end_likelihood(:) = 1;
    m.g(m.s).end_likelihood = m.g(m.s).end_likelihood / sum(m.g(m.s).end_likelihood);

    % change detection result
    for i=1:length(m.vdetectors)
        m.detection.result{i}(:,max(1,round(s_length*obv_ratio)):end) = 1;
        m.detection.result{i}(max(1,round(s_length*obv_ratio)):end,:) = 1;
    end
        

end

