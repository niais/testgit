function [similarity] = gen_sift_simi(old_patchs,new_patchs)
run '/home/aya/codes/vlfeat-0.9.20/toolbox/vl_setup.m';
old_bbs_num = length(old_patchs);
bbs_num = length(new_patchs);
tmp_simi = zeros(old_bbs_num,bbs_num);
old_tmp = {};
new_tmp = {};
for si = 1:old_bbs_num
    for sj = 1:bbs_num
        im1 = old_patchs{si};
        im2 = new_patchs{sj};
        if numel(im1) > numel(im2)
            tmp1 = im1;
            [m,n,~] = size(im1);
            tmp2 = imresize(im2,[m,n]);
        elseif numel(im1) < numel(im2)
            tmp2 = im2;
            [m,n,~] = size(im2);
            tmp1 = imresize(im1,[m,n]);
        else
            tmp1 = im1;
            tmp2 = im2;
        end
%         for i = 1:3
%         tmp1_sift = vl_covdet(single(rgb2gray(tmp1)),'descriptor','SIFT');
%         tmp2_sift = vl_covdet(single(rgb2gray(tmp2)),'descriptor','SIFT');
        [tmp1f,tmp1d] = vl_sift(single(rgb2gray(tmp1)));
        [tmp2f,tmp2d]  = vl_sift(single(rgb2gray(tmp2)));
        [MATCHES,SCORES] = vl_ubcmatch(tmp1d,tmp2d,0.4);
        scs = sort(SCORES);
        tmp_simi(si,sj) = mean(scs(1:floor(length(scs)/2)))/10000;
%         end
%         old_tmp{si,sj} = tmp1d;
%         new_tmp{si,sj} = tmp2d;
    end
end

% for si = 1:old_bbs_num
%     for sj = 1:bbs_num
%         [MATCHES,SCORES] = vl_ubcmatch(old_tmp{si,sj},new_tmp{si,sj},0.5);
%         tmp_simi(si,sj) = SCORES;
% %         [tmp_simi(si,sj)] = get_simi(old_tmp{si,sj},new_tmp{si,sj});
% 
%     end
% end

similarity = -tmp_simi;
% function [R] = get_simi(im1,im2)
%     for i = 1:3
%       R = corr2(im1,im2);
%     end
%     similarity = sum(R);
    % similarity = max(R);
% end
end