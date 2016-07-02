clear;clc;
%%
data_root = '/home/aya/dataset/ActivityDataset/data/';
track_root = '/home/aya/dataset/ActivityDataset/tracks/';
save_root = '/home/aya/codes/collective_activity/data_view/Group_given_tracklets/groups/';

load ('../data_bbs_info.mat');
tracklist = dir([track_root '*.dat']);

num_video = length(total_video_bbs);


% for it = 1:num_video
for it = 44
    % init info
    name_track = tracklist(it).name;
    num_frame = total_video_bbs(it).total_frame_num;
    path_video = [data_root total_video_bbs(it).video_name '/'];
    
    tracklet = readTracks([track_root name_track]);
    
    % tracklets matrix
    % show track in spatial-temporal space
    num_person = length(tracklet);
    [coordinary,mat_track] = STTracks(tracklet,num_frame);
    
%     showTracks(path_video,tracklet);

    % generate group-similarity between different people
    d_alpha = 5e-4;
    v_beta = 5e-4;
    p_gamma = 1e-3;
    [map_group,map_distance,map_velocity,map_position] =...
        groupSimi(num_person,coordinary,tracklet,d_alpha,v_beta,p_gamma);
    
    assign_group0 = double(map_group>0.5&map_group<5);
    assign_group1 = double(map_position<0.5&map_position>=0);
    
%     assign_group = assign_group1;
%     save([save_root total_video_bbs(it).video_name],'assign_group');
end

