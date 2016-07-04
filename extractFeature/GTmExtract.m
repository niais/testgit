clc;close all;clear;
%% read info
data_root = '/home/aya/dataset/ActivityDataset/data/';
track_root = '/home/aya/dataset/ActivityDataset/tracks/';
save_root = '/home/aya/codes/collective_activity/data_view/extractFeature/provTrackFeats/';
checkDir(save_root);
addpath('/home/aya/codes/collective_activity/data_view/Group_given_tracklets');

load ('../data_bbs_info.mat');
tracklist = dir([track_root '*.dat']);

num_video = length(total_video_bbs);

%% google / caffe spec
use_gpu = 1;

if exist('/home/aya/caffe-recurrent/matlab/+caffe', 'dir')
  addpath('/home/aya/caffe-recurrent/matlab/');
else
  error('Please run this demo from caffe/matlab');
end

% Set caffe mode
if exist('use_gpu', 'var') && use_gpu
  caffe.set_mode_gpu();
  gpu_id = 0;  % we will use the first gpu in this demo
  caffe.set_device(gpu_id);
else
  caffe.set_mode_cpu();
end

% model_def_file = '/home/aya/caffe-master/models/bvlc_googlenet/deploy.prototxt';
model_def_file = 'google_deploy.prototxt';
model_file = '/home/aya/caffe-master/models/bvlc_googlenet/bvlc_googlenet.caffemodel';
batch_size = 10;

phase = 'test'; % run with phase test (so that dropout isn't applied)
net = caffe.Net(model_def_file, model_file, phase);

%% extraction
for dn = 1
% for dn = 1:num_video
    vts = clock;
    name_track = tracklist(dn).name;
    tracklet = readTracks([track_root name_track]);
    
    
    video_name = total_video_bbs(dn).video_name;
%     imglist = textread([data_root video_name '/annotations.txt']);
    frame_num = total_video_bbs(dn).label_frame_num;
%     video_bbs = total_video_bbs(dn).video_bbs;
    
    video_feats = {};
    for i = 1:frame_num
        ts = clock;
        
        tmp_bbs_trans = [];
        frame_ix = video_bbs(i).frame;
        tmp_bbs = video_bbs(i).bbs;
        bbs_num = video_bbs(i).bbs_num;
        
        img_name = [data_root video_name '/frame' num2str(frame_ix,'%.4d') '.jpg'];
        
        im = imread(img_name);

        %% generate image patch to compare
        new_patchs = {};
        [M,N,~] = size(im);
        tmp_bbs_trans(:,1:2) = tmp_bbs(:,1:2);
        tmp_bbs_trans(:,3) = tmp_bbs(:,1)+tmp_bbs(:,3)-1;
        tmp_bbs_trans(:,4) = tmp_bbs(:,2)+tmp_bbs(:,4)-1;
        tmp_bbs_trans(tmp_bbs_trans(:,1)<1,1) = 1;
        tmp_bbs_trans(tmp_bbs_trans(:,2)<1,2) = 1;
        tmp_bbs_trans(tmp_bbs_trans(:,3)>N,3) = N;
        tmp_bbs_trans(tmp_bbs_trans(:,4)>M,4) = M;
        
        for sj = 1:bbs_num
           new_patch_bbs = tmp_bbs_trans(sj,:);
           new_patch_ix = ...
           [{new_patch_bbs(1):new_patch_bbs(3)},...
            {new_patch_bbs(2):new_patch_bbs(4)}];
           new_patchs{end+1} = (im(new_patch_ix{2},new_patch_ix{1},:));
           %
    %                [tmp_simi(si,sj),~] = get_similarity(old_patch,new_patch);  
        end
        feats = ExtractFeatsR(new_patchs,net,10);
        %% check
        if video_bbs(i).bbs_num == size(feats,2)
            video_feats = [video_feats;feats];
        else
            fprintf('feats number is unequal to bbs num ...\n');
            return;
        end
        
        te = clock;
        vte = clock;
        fprintf('%d/%d video %d/%d frame %d boxes cost %.4fs total %.2fs\n',...
            dn,num_video,i,frame_num,bbs_num,etime(te,ts), etime(vte,vts));
    end

    save([save_root 'feats_' video_name '.mat'],'video_feats');

end
        