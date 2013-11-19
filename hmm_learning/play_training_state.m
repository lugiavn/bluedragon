
class = 4;
for i=data.training_ids
    if data.examples(i).class == class

        vid = VideoReader(data.examples(i).path);
        
        for a=data.examples(i).train.actions
            
            for t=a.start:4:a.end
                
                f = read(vid,t);
                imshow(f);
                hold on;
                text(10, 10, num2str(a.s_id));
                hold off;
                pause(0.1);
                
            end
            
        end

    end;
end






