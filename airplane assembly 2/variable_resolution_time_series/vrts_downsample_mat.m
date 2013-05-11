function downsampled_mat = vrts_downsample_mat( mat, rs1, rs2, dim1_domean, dim2_domean, mat_is_zeropaded_integral )
%VRTS_DOWNSAMPLE_MAT Summary of this function goes here
%   Detailed explanation goes here
%   Note: this function use integral image trick, which will produce
%   round-off error, which could cause the terminal multiplication
%   outputing very small negative value (instead of 0)

    % compute integral mat
    if ~(exist('mat_is_zeropaded_integral') & mat_is_zeropaded_integral)
        
        mat(2:end+1,2:end+1) = cumsum(cumsum(mat,2));
        mat(1,:)             = 0;
        mat(:,1)             = 0;
        
    end

    % compute
    downsampled_mat = nan(rs1.T, rs2.T);
    for i=1:rs1.T
        for j=1:rs2.T
            downsampled_mat(i,j) = ...
                mat(rs1.end(i)+1, rs2.end(j)+1) + ...
                mat(rs1.start(i), rs2.start(j)) - ...
                mat(rs1.start(i), rs2.end(j)+1) - ...
                mat(rs1.end(i)+1, rs2.start(j));
        end
    end
    
    % do mean
    if dim1_domean
        for i=1:rs1.T
            downsampled_mat(i,:) = downsampled_mat(i,:) / rs1.csize(i);
        end
    end
    if dim2_domean
        for j=1:rs2.T
            downsampled_mat(:,j) = downsampled_mat(:,j) / rs2.csize(j);
        end
    end
end

