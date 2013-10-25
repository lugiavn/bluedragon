
img = zeros(480, 640, 3);

for x=1:640,
    for y=1:480
        
        v = 0;
        
        for i=1:length(data.training.visualdetectors)
            
            v = max(v, mvnpdf([x y], data.training.visualdetectors{i}.mean, data.training.visualdetectors{i}.var));
            
        end
        
        img(y,x,1) = v;
        img(y,x,2) = v;
        img(y,x,3) = v;
        
    end
end

close all; 
img = img / max(img(:));
imshow(img);









