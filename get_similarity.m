function [similarity,R] = get_similarity(im1,im2)
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
% tmp1 = gpuArray(tmp1);
% tmp2 = gpuArray(tmp2);

for i = 1:3
    R(i) = corr2(tmp1(:,:,i),tmp2(:,:,i));
end
% similarity = sum(R);
similarity = min(R);
end