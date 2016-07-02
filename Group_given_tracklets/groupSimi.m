function [mat_group,map_distance,map_velocity,map_position] ...
    = groupSimi(num_person,coordinary,tracklet,alpha,beta,gamma)
%%
% alpha = 5e-4;
% beta = 5e-4;
map_distance = zeros(num_person,num_person);
map_velocity = zeros(num_person,num_person);
map_position = zeros(num_person,num_person);
% mat_group = zeros(num_person,num_person);
for i = 1:(num_person-1)
    for j = (i+1):num_person
        t1 = [tracklet(i).ti tracklet(i).te];
        t2 = [tracklet(j).ti tracklet(j).te];
        t_cs = max(t1(1),t2(1));
        t_ce = min(t1(2),t2(2));
        x1 = coordinary{i}(:,(t_cs-t1(1)+1):(t_ce-t1(1)+1));
        x2 = coordinary{j}(:,(t_cs-t2(1)+1):(t_ce-t2(1)+1));
        if sum(x1(3,:)-x2(3,:))~=0
            fprintf('the length of tracklets is not equal ...\n');
        end
        
        if (t_ce-t_cs) < 0
            distance = -1/alpha;
            velocity = -1/beta;
            position = -1/gamma;
        else
        [distance,velocity] = gen_relative(t_cs,t_ce,x1(1:2,:),x2(1:2,:));  
        position = norm((x1(1:2,end)-x1(1:2,1))-(x2(1:2,end)-x2(1:2,1)))...
            /(t_ce-t_cs+1);
        end
        map_distance(i,j) = distance;
        map_velocity(i,j) = velocity;
        map_position(i,j) = position;
    end
end
% map_distance = (map_distance + map_distance')/max(max(map_distance));
% map_velocity = (map_velocity + map_velocity')/max(max(map_velocity));
map_distance = (map_distance + map_distance');
map_velocity = (map_velocity + map_velocity');
map_position = (map_position + map_position');
mat_group = exp(-(alpha.*map_distance+beta.*map_velocity));


%% generate relative distance/velocity
function [distance,velocity] = gen_relative(t_cs,t_ce,x1,x2)
    % velocity
    x1_next = [x1(:,2:end) x1(:,end)];
    x2_next = [x2(:,2:end) x2(:,end)];
    v1 = x1_next - x1;
    v2 = x2_next - x2;
    
    % distance
    norm_distance = zeros(1,t_ce-t_cs+1);
    norm_velocity = zeros(1,t_ce-t_cs+1);
    for ii = 1:(t_ce-t_cs+1)
        norm_distance(1,ii) = norm(x1-x2);
        norm_velocity(1,ii) = norm(v1-v2);
    end
    distance = mean(norm_distance);
    velocity = mean(norm_velocity);
        
end

end

