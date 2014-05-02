

clear;

load d3;

data = struct;

icount = 0;

i = 1;
for e=dataset.examples
    
    load(['histograms/' num2str(i) '.mat']); i = i + 1;
    e.histograms = histograms;
        
    for l=e.labels
    if l.id ~= 4 | 1
        icount = icount + 1;
        
        data.examples(icount).class = l.id;
        
        
        dnames = fields(e.histograms);
        for u=1:length(dnames)
            
            t1 = round (nx_linear_scale_to_range(l.start, 1, e.video_length, 1, 1000));
            t2 = round (nx_linear_scale_to_range(l.end, 1, e.video_length, 1, 1000));
            
            h  = sum(e.histograms.(dnames{u})(t1:t2,:), 1);
            
            data.examples(icount).histograms{u} = h';
        end
    end
    end
end

x = randperm(length(data.examples));
data.testing_ids  = x(1:50);
data.training_ids = x(51:end);

clearvars -except data;



% GO TO D:\myr\datasets\activity\UT-Interaction









