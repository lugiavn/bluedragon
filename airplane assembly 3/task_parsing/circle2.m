function h = circle2(x, y, r, colorx)

    if ~exist('colorx')
        colorx = [0 0 0];
    end

    d = r*2;
    px = x-r;
    py = y-r;
    h = rectangle('Position',[px py d d],'Curvature',[1,1], 'EdgeColor', colorx);
    daspect([1,1,1]);

end