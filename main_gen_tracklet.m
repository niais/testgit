clc;close all;clear;
%% read info
data_root = '/home/aya/dataset/ActivityDataset/data/';
save_root = '/home/aya/dataset/ActivityDataset/video/frame/';
save_tmp_tracklet = '/home/aya/codes/collective_activity/data_view/tmp_tracklets/';
checkDir(save_root);

seq = dir([data_root 'seq*']);
dir_num = length(seq);
%
load 'data_bbs_info.mat'
CAD_video_info = [];
tmp_video_info = struct(...
    'video_name',[],...
    'total_frame_num',[],...
    'label_frame_num',[],...
    'video_bbs',[],...
    'bbs_distribution',[],...
    'video_tracklets',[]);

for dn = 5
% for dn = 1:dir_num
    imglist = textread([data_root seq(dn).name '/annotations.txt']);
    frame_num = total_video_bbs(dn).label_frame_num;
    video_bbs = total_video_bbs(dn).video_bbs;
    
    id = [];
    curt_id = [];
    id_num = 0;
    id_ct_num = 0;
    
%     video_track = struct('id',0,'bbs',[]);
%     video_track = [];
    video_track_ix = {};
    for i = 1:frame_num
        tmp_bbs_trans = [];
        frame_ix = video_bbs(i).frame;
        tmp_bbs = video_bbs(i).bbs;
        bbs_num = video_bbs(i).bbs_num;
        
        img_name = [data_root seq(dn).name '/frame' num2str(frame_ix,'%.4d') '.jpg'];
        
        im = imread(img_name);
        ts = clock;
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
        %% verification the same person
        if i == 1
            id_num = id_num + bbs_num;
            id_ct_num = bbs_num;
            new_id = 1:bbs_num;
            id = [id curt_id];
            for j = 1:id_num
%                 tmp_track = struct('id',j,'bbs',tmp_bbs(j,:));
%                 video_track = [video_track;tmp_track];
            end
        else
%             if old_bbs_num > bbs_num
%             end
%             tmp_simi = gpuArray(zeros(old_bbs_num,bbs_num));
            
            tmp_simi = gen_sift_simi(old_patchs,new_patchs);
            % get_similarity
%             tmp_simi = (zeros(old_bbs_num,bbs_num));
%             for si = 1:old_bbs_num
%                 for sj = 1:bbs_num
%                     [tmp_simi(si,sj),~] = get_similarity(old_patchs{si},new_patchs{sj}); 
%                 end
%             end

            % UNDO 
            % Assume that same bbs_num means same individuals.
            % TODO
            % Assume that max different number between two near frames is 1 

%             new_id = [];
            new_id = zeros(1,bbs_num);
            var_1 = var(tmp_simi,[],1);
            var_2 = var(tmp_simi,[],2);
            if old_bbs_num > bbs_num        %instance num decrease
                [~,de_ix] = max(tmp_simi,[],1);
                new_id = curt_id(de_ix);
%                 if length(unique(de_ix)) == bbs_num
%                     new_id = curt_id(de_ix);
%                 else
%                     id_appear1 = histc(de_ix,1:old_bbs_num);
%                     id_s1 = find(id_appear1>1);
%                     curt_s1 = find(de_ix == id_s1);
%                     [~,comp_eq_ix1] = max(tmp_simi(id_s1,curt_s1),[],2);
%                     curt_s1(comp_eq_ix1) = 0;
%                     de_ix(curt_s1(curt_s1~=0)) = find(id_appear1==0);
%                     new_id = curt_id(de_ix);
%                 end
                id_ct_num = id_ct_num + bbs_num - old_bbs_num;              
%                 curt_id = sort(curt_id(de_ix(bi))); % TODO
                
                
            elseif old_bbs_num < bbs_num    %instance number increase
                [~,in_ix] = max(tmp_simi,[],2);
                
                for ini = 1:old_bbs_num
                    new_id(in_ix(ini)) = curt_id(ini);
                end
                % add new person id
                for ini = find(new_id==0)
                    id_num = id_num + 1;
                    id = [id id_num];
                    new_id(ini) = id_num;
                end                
                id_ct_num = id_ct_num + bbs_num - old_bbs_num;

%                 curt_id = sort([curt_id id_num]);
                
%                 tmp_track = struct('id',id_num,'bbs',);
%                 video_track = [video_track;tmp_track];
            else
                % equal
                [~,eq_ix1] = max(tmp_simi,[],1);
                [~,eq_ix2] = max(tmp_simi,[],2);
                if length(unique(eq_ix2)) == bbs_num
                    new_id = curt_id(eq_ix2);
                elseif length(unique(eq_ix1)) == bbs_num
                    for ini = 1:old_bbs_num
                        new_id(eq_ix1(ini)) = curt_id(ini);
                    end
                else
                    if length(unique(eq_ix1)) < length(unique(eq_ix2))
                    
                        id_appear = histc(eq_ix2,1:length(eq_ix2));
                        id_s = find(id_appear>1);
                        curt_s = find(eq_ix2 == id_s);
                        [~,comp_eq_ix] = max(tmp_simi(curt_s,id_s),[],1);
                        curt_s(comp_eq_ix) = 0;
                        eq_ix2(curt_s(curt_s~=0)) = 0;
                        
                        new_id = curt_id(de_ix);
                    
                    
                    elseif length(unique(eq_ix1)) > length(unique(eq_ix2))
                        id_appear1 = histc(eq_ix1,1:length(eq_ix1));
                        id_s1 = find(id_appear1>1);
                        curt_s1 = find(eq_ix1 == id_s1);
                        [~,comp_eq_ix1] = max(tmp_simi(id_s1,curt_s1),[],2);
                        curt_s1(comp_eq_ix1) = 0;
                        eq_ix1(curt_s1(curt_s1~=0)) = 0;

                        % threshold
    %                     pre_tmp_simi = tmp_simi.*(tmp_simi>-5);
    %                     de_ix = find(max(pre_tmp_simi,[],1)~=0);
    %                     in_ix = find(max(pre_tmp_simi,[],2)~=0);
                        for ini = 1:length(unique(eq_ix1))
                            new_id(eq_ix1(ini)) = curt_id(ini);
                        end
                    end
%                     new_id(eq_ix2(eq_ix2~=0)) = curt_id(eq_ix1(eq_ix1~=0));
                    
                    if (length(find(new_id~=0))< bbs_num)
                        for indi = find(new_id==0)
                            id_num = id_num + 1;
                            id = [id id_num];
                            new_id(indi) = id_num;
                        end
                    end
                end
            end            
% %             for si = 1:old_bbs_num
% %                old_patch_bbs = old_bbs(si,:);
% %                old_patch_ix = ...
% %                    [{old_patch_bbs(1):(old_patch_bbs(1)+old_patch_bbs(3)-1)},...
% %                     {old_patch_bbs(2):(old_patch_bbs(2)+old_patch_bbs(4)-1)}];
% %                old_patch = old_im(old_patch_ix{2},old_patch_ix{1},:);
% %                for sj = 1:bbs_num
% %                    new_patch_bbs = tmp_bbs(sj,:);
% %                    new_patch_ix = ...
% %                    [{new_patch_bbs(1):(new_patch_bbs(1)+new_patch_bbs(3)-1)},...
% %                     {new_patch_bbs(2):(new_patch_bbs(2)+new_patch_bbs(4)-1)}];
% %                    new_patch = im(new_patch_ix{2},new_patch_ix{1},:);
% %                    %
% %                    [tmp_simi(si,sj),~] = get_similarity(old_patch,new_patch);  
% %                end
% %             end
        end
        video_track_ix = [video_track_ix; new_id];
        te = clock;
        fprintf('%d/%d frame %d boxes cost %.4fs\n',i,frame_num,bbs_num,etime(te,ts));
        old_bbs = tmp_bbs;
        old_bbs_num = bbs_num;
        old_im = im;
        curt_id = new_id;
        old_patchs = new_patchs;

%         [M,N,~]=size(im);
%         imshow(im);bbs_num

%         drawBoxes(tmp_bbs);
    end
    save([save_tmp_tracklet seq(dn).name '.mat'], 'video_track_ix');
%     tmp_video_info.video_name = total_video_bbs(dn).video_name;
%     tmp_video_info.total_frame_num = total_video_bbs(dn).total_frame_num;
%     tmp_video_info.label_frame_num = total_video_bbs(dn).label_frame_num;
%     tmp_video_info.video_bbs = total_video_bbs(dn).video_bbs;
%     tmp_video_info.bbs_distribution = total_video_bbs(dn).bbs_distribution;
%     tmp_video_info.video_tracklets = video_track_ix;

%     CAD_video_info = [CAD_video_info; tmp_video_info];
    
end