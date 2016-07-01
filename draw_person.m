function draw_person(boxes,person_id)
N = size(boxes,1);
if N ~= length(person_id)
    fprintf('unequal...\n');
    return;
end

color = 'g';
str = 'NaN';
pad = 7;
for i = 1:N
    xmin = boxes(i,1);
    ymin = boxes(i,2);
    length_x = boxes(i,3);
    length_y = boxes(i,4);
    ac_class = mod(person_id(i),6);
    
    switch ac_class
        case 1
            color = 'w';str = num2str(person_id(i));
        case 2
            color = 'r';str = num2str(person_id(i));
        case 3
            color = 'b';str = num2str(person_id(i));
        case 4
            color = 'y';str = num2str(person_id(i));
        case 5
            color = 'g';str = num2str(person_id(i));
        case 0
            color = 'm';str = num2str(person_id(i));
                 
    end
    rectangle('Position',[xmin,ymin,length_x,length_y],'Edgecolor',color); hold on;   %draw
    text(xmin,ymin+pad,str,'Color',color);hold on;
end
end

