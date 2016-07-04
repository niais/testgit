clc;close all;clear;
%% read info
data_root = '/home/aya/dataset/ActivityDataset/data/';
save_root = '/home/aya/codes/collective_activity/data_view/extractFeature/labels';
checkDir(save_root);

load ('../data_bbs_info.mat');
seq = dir([data_root 'seq*']);
dir_num = length(seq);

multi_label = {};
binary_label = {};
% for dn = 1
for dn = 1:dir_num
    imglist = textread([data_root seq(dn).name '/annotations.txt']);
    bbs_distribution = total_video_bbs(dn).bbs_distribution;
    video_bbs = total_video_bbs(dn).video_bbs;
    
    num_labels = length(video_bbs);
    video_label = [];
    video_b_label = [];
    for i = 1:num_labels
        ix = find(imglist(:,1)==video_bbs(i).frame);
        % check label number
        if length(ix)~=video_bbs(i).bbs_num
            fprintf('unequal...\n');
            return;
        end
        % label
        tmp_labels = imglist(ix,6);
        appear = histc(tmp_labels,1:6);
        [~,frame_label] = max(appear);
        tmp_binary_label = 0;
        % generate binary label
        if sum(frame_label==[3 4]) % stand
            tmp_binary_label = 1;
        elseif sum(frame_label==[2 5 6]) % move
            tmp_binary_label = 0;
        else
            fprintf('NA\n');
        end
        video_label = [video_label; frame_label];
        video_b_label = [video_b_label; tmp_binary_label];
    end
    multi_label{end+1}=video_label;
    binary_label{end+1}=video_b_label;
    fprintf('%d/%d video...\n',dn,dir_num);
end
save('./labels/video_labels.mat','multi_label','binary_label');



