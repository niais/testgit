function [feats] = ExtractFeatsR(input_imgs,net,batch_size)
%% input files spec
N = length(input_imgs);

%%

% iterate over the iamges in batches
feats = zeros(1024, N, 'single');
for b=1:batch_size:N
    % enter images, and dont go out of bounds
    Is = {};
    for i = b:min(N,b+batch_size-1)
        I = input_imgs{i};
        if ndims(I) == 2
            I = cat(3, I, I, I); % handle grayscale edge case. Annoying!
        end
        Is{end+1} = I;
    end
    nb = length(Is);
    
    if (i == N)&(N < (b+batch_size-1))
        for j = (N+1):b+batch_size-1
            Is{end+1} = zeros(1,1,3);
        end
    end
    input_data = prepare_images_batch(Is);

    tic;

    scores = net.forward({input_data});
    scores = squeeze(scores{1});
    tt = toc;

    
    feats(:, b:b+nb-1) = scores(:,1:nb);
%     fprintf('%d/%d = %.2f%% done in %.2fs\n', b, N, 100*(b-1)/N, tt);
end

%% write to file
% fprintf('Finished...\n');
% save_path = '/home/aya/_data/elongated/VOCFeats/';
% if (~exist(feat_path))
%     mkdir(feat_path);
% end
% save([feat_path 'VOC_' file_phase '_feats_hdf5_v1.3.mat'], 'feats', '-v7.3');
% save([feat_path 'VOC_' file_phase '_feats_v1.3.mat'], 'feats');

end

