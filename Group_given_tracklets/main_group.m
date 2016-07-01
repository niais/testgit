clear;clc;
%%
data_root = '/home/aya/dataset/ActivityDataset/data/';
track_root = '/home/aya/dataset/ActivityDataset/tracks/';
load ('../data_bbs_info.mat');
tracklist = dir([track_root '*.dat']);

num_video = length(total_video_bbs);


% for it = 1:num_video
for it = 1
    % init info
    name_track = tracklist(it).name;
    num_frame = total_video_bbs(it).total_frame_num;
    path_video = [data_root total_video_bbs(it).video_name '/'];
    
    tracklet = readTracks([track_root name_track]);
    % tracklets matrix

    
    % show track in spatial-temporal space

    STTracks(tracklet);
%     showTracks(path_video,tracklet);
end

