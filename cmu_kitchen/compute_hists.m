
clear;
load d2;
load dic;

for i=7:length(dataset.examples)
    
    disp(['Run dense trajectory on #' num2str(i)]);
    
    p  = strrep(dataset.examples(i).video_path, '.avi', '.320240.avi');
    
    histograms = nx_run_densetrajectory_n_kmeans(p, dic, 1000);

    dataset.examples(i).histograms = [];
    
    save(['histograms/' num2str(i) '.mat'], 'histograms');
end

save d2;
