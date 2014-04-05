
clear;
load d2;
load dic;

for i=6:length(dataset.examples)
    
    disp(['Run dense trajectory on #' num2str(i)]);
    p  = strrep(dataset.examples(1).video_path, '.avi', '.320240.avi');
    dataset.examples(i).histograms = nx_run_densetrajectory_n_kmeans(p, dic, 1000);

    save d2;
end


