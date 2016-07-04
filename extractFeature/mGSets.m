clc;close all;clear;
%% read info
data_root = '/home/aya/dataset/ActivityDataset/data/';
sets_root = '/home/aya/codes/collective_activity/data_view/extractFeature/';
save_root = '/home/aya/codes/collective_activity/data_view/extractFeature/traintest/';
checkDir(save_root);

load ('../data_bbs_info.mat'); %total_video_bbs
load ('../Group_given_tracklets/personlet_info.mat'); %'axis_xyz','track_graph'
load([sets_root 'labels/video_labels.mat']); %binary_label,multi_label
num_video = length(total_video_bbs);

size_tracklet = 5;
train_ix = [7 12:24 26 27 30:44];
test_ix = [1:6 8:11 25 28 29];
%% processing
total_sets = {};
for dn = 1
% for dn = 1:num_video
    vts = clock;
    video_name = total_video_bbs(dn).video_name;
    imglist = textread([data_root video_name '/annotations.txt']);
    frame_num = total_video_bbs(dn).label_frame_num;
    video_bbs = total_video_bbs(dn).video_bbs;
    
    load([sets_root 'provTrackFeats/Provfeats_' video_name '.mat']); %video_Provfeats
    
    video_graph = track_graph{dn};
    num_person = size(video_graph,1);
    for i = 1:num_person
        ix_f = find(video_graph(i,:)==1);
        % check length of tracklets
        if size(axis_xyz{dn}{i},2) ~= length(ix_f)
            fprintf('error.\n');
        end
        % check ix_f > size_tracklets
        if length(ix_f) >= size_tracklet
   
        end
        
    end
    
end