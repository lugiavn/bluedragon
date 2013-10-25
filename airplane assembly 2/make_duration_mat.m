
function [duration duration_mat] = make_duration_mat(mean, var, T)

duration = nxmakegaussian(T, mean+1, var);

disp('[toremove] hard code min in make_duration_mat');
if mean > 10
    min_dur  = 6;
    duration(1:min_dur-1) = duration(1:min_dur-1) * 0.001;
    duration = duration / sum(duration);
    assert(abs(sum(duration) - 1) < 10e-5);
end;

if nargout > 1
    duration_mat  = zeros(T, T);
    for j=1:T
        duration_mat(j,j:end) = duration(1:T-j+1);
        
        if sum(duration_mat(j,j:end)) <= 0
            duration_mat(j,j:end) = 1;
        end
        
        duration_mat(j,j:end) = duration_mat(j,j:end) / sum(duration_mat(j,j:end));
    end
end

end
