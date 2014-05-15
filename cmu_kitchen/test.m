


acc1 = 0;
acc2 = 0;
acc3 = 0;
acc4 = 0;
Z12  = 0;
Z34  = 0;

for i=1:13

    figure(i);
    imagesc(data{i}.p2); colormap gray;
    hold on;
    for l=dataset.examples(i).labels
        
        start = nx_linear_scale_to_range(l.start, 1, dataset.examples(i).video_length, 1, 1000);
        send  = nx_linear_scale_to_range(l.end, 1, dataset.examples(i).video_length, 1, 1000);
        
        plot([start send], [l.id, l.id]);
        
%         for t=round (start): round (send)
        for orin_t = l.start:l.end 
        
            t = round (nx_linear_scale_to_range(orin_t,  1, dataset.examples(i).video_length, 1, 1000));
            
            Z12 = Z12 + 1;
            [~, id] = max(data{i}.p2(:,t));
            if id == l.id
                acc1 = acc1 + 1;
            end
            if 4 == l.id
                acc2 = acc2 + 1;
            end
            
            if l.id == 4
                continue;
            end
            
            Z34 = Z34 + 1;
            temp = data{i}.p2(:,t);
            temp(4) = 0;
            [~, id] = max(data{i}.p2(:,t));
            if id == l.id
                acc3 = acc3 + 1;
            end
            if 26 == l.id
                acc4 = acc4 + 1;
            end
        end
    end
    hold off;
end

disp(acc1 / Z12);
disp(acc2 / Z12);
disp(acc3 / Z34);
disp(acc4 / Z34);


