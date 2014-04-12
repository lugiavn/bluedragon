

i = 8;

imagesc(data{i}.p); colormap gray;

hold on;

for l=dataset.examples(i).labels
    
    start = nx_linear_scale_to_range(l.start, 1, dataset.examples(i).video_length, 1, 1000);
    send  = nx_linear_scale_to_range(l.end, 1, dataset.examples(i).video_length, 1, 1000);
    
    aid = l.id + 13;
    
    
    for j=1:length(m.grammar.symbols)
        if m.grammar.symbols(j).detector_id == l.id
            aid = j;
        end
    end;
    
    plot([start send], [aid aid]);
end


hold off;