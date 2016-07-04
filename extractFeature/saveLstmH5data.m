clear;
%%
file_phase = {'train' 'test'};
data_root = '/home/aya/codes/collective_activity/data_view/extractFeature/traintest/';
h5_path = [data_root 'h5_data/'];
checkDir(h5_path,'dir');

fprintf('loading mat file ...\n');
load([data_root 'unsort_test_s5_tracklets.mat']);
load([data_root 'unsort_train_s5_tracklets.mat']);

fprintf('saving hdf5 file ...\n');

data = {train_data test_data};
cont = {train_cont test_cont};
label = {train_label test_label};
fappend = 'lstm_aug_';
data_nums = [length(train_cont) length(test_cont)];
for i = 1:2
    save_path = [h5_path fappend file_phase{i} '_v1.h5'];
    if ~exist(save_path,'file')
        h5create(save_path,'/data',[1024 1 data_nums(i)]);
        h5create(save_path,'/label',[1 data_nums(i)]);
        h5create(save_path,'/cont',[1 data_nums(i)]);
    end
    feats = reshape(double(data{i}),[1024 1 data_nums(i)]);
    h5write(save_path,'/data',feats);
    h5write(save_path,'/label',label{i});
    h5write(save_path,'/cont',cont{i});
end