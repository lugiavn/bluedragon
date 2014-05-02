
read_dataset_info;

%%
e = dataset.examples(randi([1 length(dataset.examples)]));
e = dataset.examples(9); % 3 (9), 5 (13), 9 is wrong
% 3 (9): top video is not synced
% 5 (13): top video is not synced
% 9 ():  top video is not synced

v = VideoReader(e.video_path);
v2 = VideoReader(e.top_video);

for t=5000:5:6000
    f = read(v, t);
    
    if v2.NumberOfFrames >= t
        f2 = read(v2, t);
    end
    
%     figure(1);
    subplot(1, 2, 1);
    imshow(f2);
    subplot(1, 2, 2);
    imshow(f);
    
    
    hold on;
    for l=e.labels
        if l.start <= t && t <= l.end
            rectangle('Position',[1,1,300,50],'Curvature',[0,0], 'FaceColor','w');
            text(20, 20, l.text);
        end
    end
    hold off;
    
    pause(0.1);
end


















