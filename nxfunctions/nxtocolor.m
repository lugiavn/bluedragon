function c = nxtocolor(i)
%NXTOCOLOR Summary of this function goes here
%   Detailed explanation goes here

    i = i + 999999999;
    
    colors = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1;
        0 0 0; 0.4 0.4 0.4; 1 0.5 0; 1 0 0.5; 0.5 1 0; 0 1 0.5; 0 0.5 1; 0.5 0 1;
        0.5 0 0; 0 0.5 0; 0 0 0.5; 0.3 1 0.3; 1 0.3 0.3; 0.3 0.3 1];
  
    colors2 = 1 - colors;
    colors3 = [];
    colors  = [colors; colors2; colors3];
    
    c = colors(1 + mod(i,size(colors,1)),:);
end

