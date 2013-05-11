function r = vrts_downsample_durationmat_forward( mat, rs )
%VRTS_DOWNSAMPLE_DURATIONMAT_FORWARD Summary of this function goes here
%   Detailed explanation goes here

    % assert
    

    %
    r = 9999 * ones(rs.T);
    
    for i=1:rs.T
        for j=1:rs.T
            
            % r(i,j) = mean(sum(mat(rs.start(i):rs.end(i),rs.start(j):rs.end(j)), 2)); % slow
            r(i,j) = sum(sum(mat(rs.start(i):rs.end(i),rs.start(j):rs.end(j)))) / rs.csize(i);
            
        end
        
    end
    
    
end

