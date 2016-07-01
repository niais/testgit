function drawPredict(boxes)
N = size(boxes,1);
color = 'g';
str = 'NaN';
pad = 7;
for i = 1:N
    xmin = boxes(i,1);
    ymin = boxes(i,2);
    length_x = boxes(i,3);
    length_y = boxes(i,4);
    ac_class = boxes(i,5);
    
    switch ac_class
        case 1
            color = 'w';str = 'NA';
        case 2
            color = 'r';str = 'Cross';
        case 3
            color = 'b';str = 'Wait';
        case 4
            color = 'y';str = 'Queue';
        case 5
            color = 'g';str = 'Walk';
        case 6
            color = 'm';str = 'Talk';
                 
    end
    rectangle('Position',[xmin,ymin,length_x,length_y],'Edgecolor',color); hold on;   %draw
    text(xmin,ymin+pad,str,'Color',color);hold on;
end
end

