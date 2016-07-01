function drawBoxes(boxes,option)
N = size(boxes,1);
if nargin <2
    option = 'r';
end
for i = 1:N
    xmin = boxes(i,1);
    ymin = boxes(i,2);
    length_x = boxes(i,3);
    length_y = boxes(i,4);
    rectangle('Position',[xmin,ymin,length_x,length_y],'Edgecolor',option); hold on;   %draw
end
end

