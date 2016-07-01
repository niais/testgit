clc;close all;clear;
%% read info
data_root = '/home/aya/dataset/ActivityDataset/data/';
save_root = '/home/aya/dataset/ActivityDataset/video/frame/';
checkDir(save_root);

seq = dir([data_root 'seq*']);
dir_num = length(seq);

total_video_bbs = [];

%% read annotation
for dn = 10:dir_num
%     tmp_video_bbs = struct(...
%         'video_name','',...
%         'total_frame_num',0,...
%         'label_frame_num',0,...
%         'video_bbs',[]);
    imglist = textread([data_root seq(dn).name '/annotations.txt']);
    [video_bbs,appear] = read_anno(imglist);
    total_fn = length(dir([data_root seq(dn).name '/*.jpg']));
    tmp_video_bbs = struct(...
        'video_name',seq(dn).name,...
        'total_frame_num',total_fn,...
        'label_frame_num',length(video_bbs),...
        'video_bbs',video_bbs,...
        'bbs_distribution',appear);
    
    total_video_bbs = [total_video_bbs; tmp_video_bbs];
%     frame_num = max(imglist(:,1));
%     x = 1:frame_num;
%     appear = sum(histc(imglist(:,1),x),2);
%     frame_ix = double(find(appear~=0));
% 
% %     save_img_path = [save_root seq(dn).name];
% %     checkDir(save_img_path); 
%     video_bbs = [];
%     for i = 1:length(frame_ix)
%         im_ix = frame_ix(i);
%         ix_end = sum(appear(1:im_ix));
%         curt_num = appear(im_ix);
%         ix = (ix_end-curt_num+1):ix_end;
%         
% %         img_name = [data_root seq(dn).name '/frame' num2str(im_ix,'%.4d') '.jpg'];
% %         im = imread(img_name);
% %         [M,N,~]=size(im);
% %         imshow(im);
%         %
%         tmp_bbs = struct('frame',0,'bbs_num',0,'bbs',[]);
%         tmp_bbs.bbs = imglist(ix,2:5);
%         tmp_bbs.frame = im_ix;
%         tmp_bbs.bbs_num = appear(im_ix);
%         video_bbs = [video_bbs; tmp_bbs];
%         %%
% %         track = struct('id', n, 'ti', 0, 'te', 0, 'bbs', []);   
%     end
end
%% generate tracklet
