function [coordinary,mat_track] =  STTracks(tracklet,num_frame)
%% 
mat_track = zeros(length(tracklet),num_frame);
coordinary = {};
num_person = length(tracklet);
for im = 1:num_person
    mat_track(im,tracklet(im).ti:tracklet(im).te) = 1;
    axis_z = tracklet(im).ti:tracklet(im).te;
%     tmp_axis = zeros(3,length(axis_z));
    tmp_bbs = tracklet(im).bbs;

    center = [tmp_bbs(1,:)+floor(tmp_bbs(3,:)/2);...
              tmp_bbs(2,:)+floor(tmp_bbs(4,:)/2)];
    tmp_axis = [center;axis_z];
    
    coordinary = [coordinary tmp_axis];
    
%     for i = 1:length(axis_z)
%         plot3(tmp_axis(1,i),tmp_axis(2,i),tmp_axis(3,i),'ro'); hold on;
% %         mesh(tmp_axis);hold on;
%     end
end


% [M,N] = size(mat_track);
% for m = 1:M
%     for n = 1:N
%         if mat_track(m,n) == 1
%             plot(m,n,'x');hold on;
%         end
%     end
% end

end

