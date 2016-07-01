function [video_bbs,appear] = read_anno(imglist)
%% read anontation

    frame_num = max(imglist(:,1));
    x = 1:frame_num;
    appear = sum(histc(imglist(:,1),x),2);
    frame_ix = double(find(appear~=0));

%     save_img_path = [save_root seq(dn).name];
%     checkDir(save_img_path);
    
    video_bbs = [];
    for i = 1:length(frame_ix)
        im_ix = frame_ix(i);
        ix_end = sum(appear(1:im_ix));
        curt_num = appear(im_ix);
        ix = (ix_end-curt_num+1):ix_end;
        
        %
        tmp_bbs = struct('frame',0,'bbs_num',0,'bbs',[]);
        tmp_bbs.bbs = imglist(ix,2:5);
        tmp_bbs.frame = im_ix;
        tmp_bbs.bbs_num = appear(im_ix);
        video_bbs = [video_bbs; tmp_bbs];      
    end
end

