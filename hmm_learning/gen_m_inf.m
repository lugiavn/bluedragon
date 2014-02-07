function m = gen_m_inf( s, m )

    % gen inference net
%     m.params.downsample_ratio = max(1, s.length / m.params.downsample_length);
    m = gen_inference_net(m, m.params.T, m.params.downsample_ratio, 1, 1);
    
%     s_length = min(s.length, m.params.downsample_length);
    s_length = round(s.length / m.params.downsample_ratio);
    m.g(m.s).end_likelihood(:) = 0;
    m.g(m.s).end_likelihood(s_length) = 1;
    
    % compute detection
    m.detection.result = compute_raw_detection_score( s, m );
    for i=1:length(m.vdetectors)
        x = m.detection.result{i};
        if size(m.detection.result{i}, 1) > s.length
            x = x(1:s.length,1:s.length);
        end
        x = imresize(x, [s_length s_length], 'bilinear');
        m.detection.result{i} = zeros(m.params.T);
        m.detection.result{i}(1:s_length, 1:s_length) = x;
        
        m.detection.result{i} = m.detection.result{i} / m.vdetectors(i).mean_score;
    end
   
end