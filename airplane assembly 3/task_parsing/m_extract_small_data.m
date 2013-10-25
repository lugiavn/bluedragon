function m = m_extract_small_data( m )
%M_EXTRACT_SMALL_DATA Summary of this function goes here
%   Detailed explanation goes here

    m.g = 0;
    m.detection = 0;
    
    for i=1:length(m.grammar.symbols)
        m.grammar.symbols(i).duration_mat = 0;
        m.grammar.symbols(i).duration_mat_integral = 0;
    end;
end

