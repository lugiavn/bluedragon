function obv_duration = nx_create_custom_obv_duration( aname, m )
%NX_CREATE_CUSTOM_OBV_DURATION Summary of this function goes here
%   Detailed explanation goes here

    if strcmp(aname, 'restart')
        
        endpoint = find (m.g(m.s).end_likelihood == 1);
        assert(endpoint > 0);
        
        obv_duration = zeros(m.params.T);
        obv_duration(endpoint,1) = 1;
        
    else
        assert(0);
    end

end

