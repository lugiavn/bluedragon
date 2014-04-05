
clear; load d;

dense_trajectories = {};

for i=1:length(dataset.examples)
    
    disp(['Run dense trajectory on #' num2str(i)]);
    
    p  = strrep(dataset.examples(1).video_path, '.avi', '.320240.avi');
    dt = nx_run_densetrajectory(p, 1 - 0.005);
    
    dt = dt(randperm(length(dt)));
    disp(size(dt));
    if length(dt) > 10000
        dt = dt(1:10000);
    end
    
    dense_trajectories{end+1} = dt;
end

dic = nx_build_densetrajectory_dic(dense_trajectories);

clearvars -except dic;
save dic;

