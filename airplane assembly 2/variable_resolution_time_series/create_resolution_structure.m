function rs = create_resolution_structure(T0, center_point, rate, max_cell_size)
%CREATE_RESOLUTION_STRUCTURE Summary of this function goes here
%   Detailed explanation goes here

if ~exist('max_cell_size'),
    max_cell_size = Inf;
end


rs              = struct;
rs.center_point = center_point;
rs.csize        = 1;

% on the left
csize1 = [];
i      = 1;
while sum(csize1) < center_point - 1
    csize1 = [min(max_cell_size, round(1 * rate ^ i)) csize1];
    i = i + 1;
end
if length(csize1) > 0,
    csize1(1) = 0;
    csize1(1) = center_point - 1 - sum(csize1);
end;

% on the right
csize2 = [];
i      = 1;
while sum(csize2) < T0 - center_point
    csize2 = [csize2 min(max_cell_size, round(1 * rate ^ i))];
    i = i + 1;
end
if length(csize2) > 0,
    csize2(end) = 0;
    csize2(end) = T0 - center_point - sum(csize2);
end

% finally
rs.csize = [csize1 1 csize2];

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

