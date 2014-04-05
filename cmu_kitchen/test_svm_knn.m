

clear;

load d2;

data = struct;

icount = 0;

for e=dataset.examples
    for l=e.labels
    if l.id ~= 4
        icount = icount + 1;
        
        data.examples(icount).class = l.id;
        
        dnames = fields(e.histograms);
        for u=1:length(dnames)
            
            t1 = round(1000 * l.start / e.video_length);
            t2 = round(1000 * l.end / e.video_length);
            
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













