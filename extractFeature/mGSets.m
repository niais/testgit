clc;close all;clear;
%% read info
data_root = '/home/aya/dataset/ActivityDataset/data/';
track_root = '/home/aya/dataset/ActivityDataset/tracks/';
sets_root = '/home/aya/codes/collective_activity/data_view/extractFeature/';
save_root = '/home/aya/codes/collective_activity/data_view/extractFeature/traintest/';
checkDir(save_root);

load ('../data_bbs_info.mat'); %total_video_bbs
load ('../Group_given_tracklets/personlet_info.mat'); %'axis_xyz','track_graph'
load([sets_root 'labels/video_labels.mat']); %binary_label,multi_label
num_video = length(total_video_bbs);

size_tracklet = 7;
train_ix = [7 12:24 26 27 30:44];
test_ix = [1:6 8:11 25 28 29];
datasets = {train_ix test_ix};
fappend = {'train','test'};
tracklist = dir([track_root '*.dat']);
%% processing
total_sets = {};

for iii = 1:2
v_feats = {};
v_label = [];    
for dn = datasets{iii}
% for dn = 1:num_video
    vts = clock;
    name_track = tracklist(dn).name;
    tracklet = readTracks([track_root name_track]);
    video_name = total_video_bbs(dn).video_name;
%     imglist = textread([data_root video_name '/annotations.txt']);
    total_frame_num = total_video_bbs(dn).total_frame_num;
    label_frame_num = total_video_bbs(dn).label_frame_num;
    video_bbs = total_video_bbs(dn).video_bbs;
    
    lframe = [video_bbs.frame];
    vall_b_label = zeros(total_frame_num,1);
    vlabel = binary_label{dn};
    
    for li = 1:label_frame_num
        if li < label_frame_num
            vall_b_label(lframe(li):(lframe(li+1)-1)) = vlabel(li);
        else
            vall_b_label(lframe(li):end) = vlabel(li);
        end
            
    end
    load([sets_root 'provTrackFeats/Provfeats_' video_name '.mat']); %video_feats
    
%     video_graph = track_graph{dn};
%     num_person = size(video_graph,1);
    num_person = length(tracklet);

    for i = 1:num_person
        tmp_feats = video_feats{i};
        ix_f = tracklet(i).ti:tracklet(i).te;
        % check length of tracklets
        if size(axis_xyz{dn}{i},2) ~= length(ix_f)
            fprintf('error.\n');
        end
        % check ix_f > size_tracklets
        if length(ix_f) >= size_tracklet
            for jf = 1:length(ix_f)-size_tracklet+1
                ifx = ix_f(jf):(ix_f(jf)+size_tracklet-1);
                v_feats = [v_feats tmp_feats(:,jf:(jf+size_tracklet-1))];
                v_label = [v_label max(vall_b_label(ifx))]; % positive if once appear
            end
        end
    end
    fprintf('%s video %d length %d \n',fappend{iii},dn,length(v_label));
end
save([save_root 'unsort_' fappend{iii} '_s' num2str(size_tracklet) '_tracklets.mat'],'v_feats','v_label','-v7.3');
end