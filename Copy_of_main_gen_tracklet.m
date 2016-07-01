clc;close all;clear;
%% read info
data_root = '/home/aya/dataset/ActivityDataset/data/';
save_root = '/home/aya/dataset/ActivityDataset/video/frame/';
checkDir(save_root);

seq = dir([data_root 'seq*']);
dir_num = length(seq);
%
load 'data_bbs_info.mat'

for dn = 1:1
    imglist = textread([data_root seq(dn).name '/annotations.txt']);
    frame_num = total_video_bbs(dn).label_frame_num;
    video_bbs = total_video_bbs(dn).video_bbs;
    
    id = [];
    curt_id = [];
    id_num = 0;
    id_ct_num = 0;
    
%     video_track = struct('id',0,'bbs',[]);
    video_track = [];
    for i = 1:frame_num
        tmp_bbs_trans = [];
        frame_ix = video_bbs(i).frame;
        tmp_bbs = video_bbs(i).bbs;
        bbs_num = video_bbs(i).bbs_num;
        
        img_name = [data_root seq(dn).name '/frame' num2str(frame_ix,'%.4d') '.jpg'];
        
        im = imread(img_name);
        ts = clock;
        %%
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
        %%
        if i == 1
            id_num = id_num + bbs_num;
            curt_id = 1:bbs_num;
            id = [id curt_id];
            for j = 1:id_num
                tmp_track = struct('id',j,'bbs',tmp_bbs(j,:));
                video_track = [video_track;tmp_track];
            end
        else
%             if old_bbs_num > bbs_num
%             end
            tmp_simi = gpuArray(zeros(old_bbs_num,bbs_num));
            for si = 1:old_bbs_num
                for sj = 1:bbs_num
                    [tmp_simi(si,sj),~] = get_similarity(old_patchs{si},new_patchs{sj}); 
                end
            end
            % UNDO 
            % Assume that same bbs_num means same individuals.
            % TODO
            % Assume that max different number between two near frames is 1 

            
            if old_bbs_num > bbs_num %instance num decrease
                [~,de_ix] = max(tmp_simi,[],1);
                for bi = 1:bbs_num
                    video_track(curt_id(de_ix(bi))).bbs =...
                        [video_track(curt_id(de_ix(bi))).bbs;tmp_bbs(bi,:)];
                end
                id_ct_num = id_ct_num - 1;              
                curt_id = sort(curt_id(de_ix(bi))); % TODO
                
                
            elseif old_bbs_num < bbs_num %instance number increase
                [~,in_ix] = max(tmp_simi,[],2);
                for ini = 1:old_bbs_num
                    video_track(curt_id(ini)).bbs =...
                        [video_track(curt_id(ini)).bbs;'old_bbs(in_ix(ini),:)']; % TODO
                end
                id_num = id_num + 1;
                id_ct_num = id_ct_num + 1;
                id = [id id_num];
                curt_id = sort([curt_id id_num]);
                
                tmp_track = struct('id',id_num,'bbs',);
                video_track = [video_track;tmp_track];
            end
%             for si = 1:old_bbs_num
%                old_patch_bbs = old_bbs(si,:);
%                old_patch_ix = ...
%                    [{old_patch_bbs(1):(old_patch_bbs(1)+old_patch_bbs(3)-1)},...
%                     {old_patch_bbs(2):(old_patch_bbs(2)+old_patch_bbs(4)-1)}];
%                old_patch = old_im(old_patch_ix{2},old_patch_ix{1},:);
%                for sj = 1:bbs_num
%                    new_patch_bbs = tmp_bbs(sj,:);
%                    new_patch_ix = ...
%                    [{new_patch_bbs(1):(new_patch_bbs(1)+new_patch_bbs(3)-1)},...
%                     {new_patch_bbs(2):(new_patch_bbs(2)+new_patch_bbs(4)-1)}];
%                    new_patch = im(new_patch_ix{2},new_patch_ix{1},:);
%                    %
%                    [tmp_simi(si,sj),~] = get_similarity(old_patch,new_patch);  
%                end
%             end
        end
        te = clock;
        fprintf('%d/%d frame %d boxes cost %.4fs\n',i,frame_num,bbs_num,etime(te,ts));
        old_bbs = tmp_bbs;
        old_bbs_num = bbs_num;
        old_im = im;
        old_patchs = new_patchs;

%         [M,N,~]=size(im);
%         imshow(im);bbs_num

%         drawBoxes(tmp_bbs);
    end
end