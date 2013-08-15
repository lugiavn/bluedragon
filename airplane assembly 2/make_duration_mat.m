
function [duration duration_mat] = make_duration_mat(mean, var, T)

duration = nxmakegaussian(T, mean+1, var);

if nargout > 1
    duration_mat  = zeros(T, T);
    for j=1:T
        duration_mat(j,j:end) = duration(1:T-j+1);
        duration_mat(j,j:end) = duration_mat(j,j:end) / sum(duration_mat(j,j:end));
    end
end

end