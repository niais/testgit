clc;close all;clear;
%%
data_root = '/home/aya/dataset/ActivityDataset/data/';
save_root = '/home/aya/dataset/ActivityDataset/video/frame/';
checkDir(save_root);

seq = dir([data_root 'seq*']);
dir_num = length(seq);

% for dn = 1:dir_num
for dn = 1:1
    imglist = textread([data_root seq(dn).name '/annotations.txt']);
    frame_num = max(imglist(:,1));
    x = 1:frame_num;
    appear = sum(histc(imglist(:,1),x),2);

    save_img_path = [save_root seq(dn).name];
    checkDir(save_img_path);
    for i = 1:frame_num
        img_name = [data_root seq(dn).name '/frame' num2str(i,'%.4d') '.jpg'];
        ix_end = sum(appear(1:i));
        curt_num = appear(i);
        ix = (ix_end-curt_num+1):ix_end;
        im = imread(img_name);
        [M,N,~]=size(im);
        h = figure(1);clf;
        set(h,'visible','off');
        
        imshow(im);
        if curt_num == 0
            drawPredict(tmp_boxes);
        else
            tmp_boxes = imglist(ix,2:6);
            drawPredict(tmp_boxes);
        end
        % txt=get(gca,'Title');
        % set(txt,'fontsize',16);
        set(gcf,'color','w');
        set(gca,'units','pixels','Visible','off');

        q=get(gca,'position');
        q(1)=1;%设置左边距离值为零
        q(2)=1;%设置右边距离值为零
        set(gca,'position',q);

        frame=getframe(gcf,[0,0,N,M]);
        im_anno=frame2im(frame);

        save_img_name = [save_img_path '/anno_frame' num2str(i,'%.4d') '.jpg'];
        imwrite(im_anno,save_img_name);
        fprintf('saving video %d/%d\t%d/%d\n',dn,dir_num,i,frame_num);
    end
end