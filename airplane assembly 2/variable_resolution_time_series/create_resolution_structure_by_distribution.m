function rs = create_resolution_structure_by_distribution( d, T )
%CREATE_RESOLUTION_STRUCTURE_BY_DISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

d  = d / sum(d);
T0 = length(d);

assert(T <= T0);

rs.csize  = [];
tcum      = 0;
tcumcount = 0;

for i=1:T0

    tcum        = tcum + d(i);
    tcumcount   = tcumcount + 1;

    if  i == T0 || ...
            T - length(rs.csize) == T0 - i + 1 || ...
            tcum + d(i+1)  > (length(rs.csize) + 1) / T + 1e-13
        
        rs.csize        = [rs.csize tcumcount];
        tcumcount       = 0;
            
    end

end

assert(T == length(rs.csize));

% find start point & end point
rs.T0 = T0;
rs.T  = length(rs.csize);

for i=1:rs.T
    if i == 1,
        rs.start(i) = 1;
    else
        rs.start(i) = rs.end(i-1) + 1;
    end
    
    rs.end(i) = rs.start(i) + rs.csize(i) - 1;
end


end

