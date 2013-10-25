
% show all events
close all
for i=1:length(data.examples)
    vid = VideoReader([data.path '/' data.examples(i).filename]);

    figure(i);
    j = 0;
    for a=data.examples(i).label.actions
        j = j + 1;
        subplot(5, 5, j);
        if a.start < 0
            imshow(0);
            continue;
        end
        
        img = read(vid, a.start);
        imshow(img);

        % draw hands
        hands = data.examples(i).handsdetections(a.start, [1 2]);
        if isnan(hands(1)) | hands(2) < data.examples(i).handsdetections(a.start, [4])
            hands = data.examples(i).handsdetections(a.start, [3 4]);
        end
        if ~isnan(hands(1)) & hands(2) > 300
            hold on;
            rectangle('Position', [hands(1) - 10 hands(2) - 10 20 20], 'EdgeColor', 'r');
            hold off;
        end
    end
end