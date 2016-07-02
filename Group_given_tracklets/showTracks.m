function showTracks(imdir, tracks)

imfiles = dir([imdir '*.jpg']);

for i = 1:length(imfiles)
    imshow(imread([imdir imfiles(i).name]));
    
    drawTracks(tracks, i);
    
    drawnow;
end

end



function drawTracks(tracks, frame)

cmap = colormap;

for i = 1:length(tracks)
    if ((tracks(i).ti <= frame) & ...
        (tracks(i).te >= frame))
        idx = frame - tracks(i).ti + 1;

        col = cmap(mod(i*10, 64) + 1, :);
        ttt = tracks(i).bbs(:, idx);
        rectangle('Position', ttt, 'EdgeColor', col, 'LineWidth', 3);
        
        str = num2str(i);
        pad = 7;
        text(ttt(1,1),ttt(2,1)+pad,str,'Color',col);
    end
end

end