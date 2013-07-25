function rs = create_resolution_structure_by_energy( energy )
%CREATE_RESOLUTION_STRUCTURE_BY_ENERGY Summary of this function goes here
%   Detailed explanation goes here

rs.energy   = energy;
rs.T0       = length(energy);
rs.csize    = [];

current_energy = 0;
current_csize  = 0;

for i=1:rs.T0

    current_energy = current_energy + energy(i);
    current_csize  = current_csize + 1;

    if i == rs.T0 || current_energy + energy(i+1) > 1

        rs.csize = [rs.csize current_csize];

        current_energy = 0;
        current_csize  = 0;

    end

end

rs.T = length(rs.csize);

% find start point & end point
for i=1:rs.T
    if i == 1,
        rs.start(i) = 1;
    else
        rs.start(i) = rs.end(i-1) + 1;
    end
    
    rs.end(i) = rs.start(i) + rs.csize(i) - 1;
end

end

