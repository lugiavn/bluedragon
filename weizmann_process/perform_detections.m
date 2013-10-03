function test = perform_detections( weizmann, test)
%PERFORM_DETECTIONS Summary of this function goes here
%   Detailed explanation goes here

l2_distances = cell(10,1);
hi_distances = cell(10,1);
x2_distances = cell(10,1);
for i=1:10
    l2_distances{i} = inf(test.T);
    hi_distances{i} = inf(test.T);
    x2_distances{i} = inf(test.T);
end
    
for tstart=1:test.T
    disp(tstart)
    h2 = zeros(1, 100);
    for tend=tstart+1:test.T

        h2(test.sequence_frameclustering(tend-1)) = h2(test.sequence_frameclustering(tend-1)) + 1;
        
%         h = zeros(1, 100);
%         
%         for j = test.sequence_frameclustering(tstart:tend-1)
%             h(j) = h(j) + 1;
%         end
%         
%         disp(norm(h-h2));
        
        h = h2 / norm(h2);
        
        for i=weizmann.training_ids
            
            

            d1 = norm(h - weizmann.samples(i).hist);
            d2 = histogram_intersection(h, weizmann.samples(i).hist);
            d3 = chi_square_statistics(h, weizmann.samples(i).hist);


            classid = weizmann.label_str2id.(weizmann.samples(i).class);
            
            l2_distances{classid}(tstart, tend) = min(d1, l2_distances{classid}(tstart, tend));
            hi_distances{classid}(tstart, tend) = min(d2, hi_distances{classid}(tstart, tend));
            x2_distances{classid}(tstart, tend) = min(d3, x2_distances{classid}(tstart, tend));
        end

    end
end

test.l2_distances = l2_distances;
test.hi_distances = hi_distances;
test.x2_distances = x2_distances;

%% plot observation likelihood
close all;
for i=1:10
   
    nx_figure(i);
    imagesc(-test.x2_distances{i});
    hold on;
    
    t = find(test.sequence_framelabels == i);
    tstart = min(t);
    tend   = max(t);
    
    plot(tend, tstart, '*');
    
    hold off;
end

end

