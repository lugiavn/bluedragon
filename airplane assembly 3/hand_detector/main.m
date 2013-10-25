clear all; close all; clc;

dataset.path = './../real_dataset2';
files        = dir(dataset.path);


spacemask = imread('spacemask.bmp');
spacemask = im2double(spacemask);
spacemask = spacemask(:,:,1) > 0;

c = imread('hand_nam.bmp');
c = im2double(c);

b = imread('background.bmp');
b = im2double(b);


handsize  = [50 50];
handsize2 = [30 30];

SCORE_THRESHOLD = 3000;

for i=1:length(files)
    
    if length(files(i).name) < 5 | ~strcmp(files(i).name(end-3:end), '.avi')
        continue;
    end

    videofile = [dataset.path '/' files(i).name];

    vid = VideoReader(videofile);

    handpositions = [];

    close all;
    record_data = nx_record_figures_init(30, ['viz_' files(i).name]);
    
    f = zeros(600, 800,3);

    for t=1:1:vid.NumberOfFrames

        f = read(vid,t);
        f = im2double(f);
        %f(101:580,101:740,:) = f2;
        nx_figure(131); subplot(2,2,1); imshow(f);

        [h w ~] = size(f);

        % remove background color
        diff = nxmatch_color(f, b);
        se = strel('disk', 2);
        background_match = nxfilter_mask_by_seed((diff < 0.18) .* spacemask, imerode(diff < 0.05, se) .* spacemask);
        new_spacemask = spacemask .* (1 - background_match);
        
        %
        diff = nxmatch_color(f, c);
        nx_figure(131); subplot(2,2,2); imagesc(diff );
        se = strel('disk', 2);
        handbit = nxfilter_mask_by_seed((diff < 0.25) .* new_spacemask, imerode(diff < 0.1, se) .* new_spacemask);
 
        
        nx_figure(131); subplot(2,2,3); imagesc(-handbit);

        % detect hand
        handp = find(imerode(handbit, se) > 0); handp(end+1) = 1;
        hand.bestscore = -1;
        for r=1:1000
           p1 = handp(randi(length(handp)));
           p2 = handp(randi(length(handp)));

           x1 = floor((p1-1)/h) + 1;
           y1 = mod(p1-1, h)+1;
           x2 = floor((p2-1)/h) + 1;
           y2 = mod(p2-1, h)+1;

           if x1 + handsize(1) > w | x1 - handsize(1) < 1 | y1 + handsize(2) > h | y1 - handsize(2) < 1 | ...
              x2 + handsize(1) > w | x2 - handsize(1) < 1 | y2 + handsize(2) > h | y2 - handsize(2) < 1 
                   continue;
           end

           % score
           score1 = sum(sum(handbit(y1-handsize(2):y1+handsize(2), x1-handsize(1):x1+handsize(1)))) / 1.8 + ...
                    sum(sum(handbit(y1-handsize2(2):y1+handsize2(2), x1-handsize2(1):x1+handsize2(1)))) / 2;
           score2 = sum(sum(handbit(y2-handsize(2):y2+handsize(2), x2-handsize(1):x2+handsize(1)))) / 1.8 + ...
                    sum(sum(handbit(y2-handsize2(2):y2+handsize2(2), x2-handsize2(1):x2+handsize2(1)))) / 2;
           score  = score1 + score2;

           % penalize overlapping of 2 hands
           score = score - 0.8 * rectint([x1-handsize(1) y1-handsize(2) 2*handsize(1) 2*handsize(2)], [x2-handsize(1) y2-handsize(2) 2*handsize(1) 2*handsize(2)]);

           % best
           if score > hand.bestscore
               hand.x1 = x1;
               hand.x2 = x2;
               hand.y1 = y1;
               hand.y2 = y2;
               hand.bestscore = score;
               hand.score1 = score1;
               hand.score2 = score2;
           end
        end
        nx_figure(131); subplot(2,2,2); hold on;
        rectangle('Position', [hand.x1-handsize(1) hand.y1-handsize(2) 2*handsize(1) 2*handsize(2)], 'EdgeColor', 'r');
        rectangle('Position', [hand.x2-handsize(1) hand.y2-handsize(2) 2*handsize(1) 2*handsize(2)], 'EdgeColor', 'b');
        text(hand.x1, hand.y1, num2str(hand.score1));
        text(hand.x2, hand.y2, num2str(hand.score2));
        hold off;

        % thresholding the score
        handpositions(end+1,:) = [nan nan nan nan];
        if hand.score1 > SCORE_THRESHOLD
            handpositions(end, [1 2]) = [hand.x1 hand.y1];
            nx_figure(131); subplot(2,2,1); hold on;
            rectangle('Position', [hand.x1-handsize(1) hand.y1-handsize(2) 2*handsize(1) 2*handsize(2)], 'EdgeColor', 'r');
            hold off;
        end
        if hand.score2 > SCORE_THRESHOLD
            handpositions(end, [3 4]) = [hand.x2 hand.y2];
            nx_figure(131); subplot(2,2,1); hold on;
            rectangle('Position', [hand.x2-handsize(1) hand.y2-handsize(2) 2*handsize(1) 2*handsize(2)], 'EdgeColor', 'r');
            hold off;
        end

        %
        pause(0.01);
        record_data = nx_record_figures_process(record_data);
    end


    record_data = nx_record_figures_terminate(record_data);
    dlmwrite([strrep(files(i).name, 'avi', 'handsdetections') '.txt'], handpositions);
end
