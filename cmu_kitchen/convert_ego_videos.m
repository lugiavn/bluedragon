
read_dataset_info;

for e=dataset.examples(end)

    v = VideoReader(e.video_path);
    w = VideoWriter(strrep(e.video_path, '.avi', '.320240.avi'));
    open(w);
    
    for t=1:v.NumberOfFrames
            
        f = read(v, t);
        f = imresize(f, [240 320]);
%         imshow(f);
        writeVideo(w, f);
    end
    
%     close(v);
    close(w);
end



