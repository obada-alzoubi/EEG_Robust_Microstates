function data_out = kernelpca_tutorial(data_in,num_dim)
%
% This function does principal component analysis (non-linear) on the given
% data set using the Kernel trick
%
% Data_Out = kernelpca_tutorial(Data_in,Num_Dim)
%
% Data_in - Input data (d (dimensions) X N (# of points)
% Num_Dim - Dimensions of output data. (Num_Dim <= d)
% Data_Out - Output data. (Num_Dim (dimensions) X N (# of points))
%
% Ambarish Jash
% ambarish.jash@colorado.edu
%

%% Checking to ensure output dimensions are lesser than input dimension.
if num_dim > size(data_in,1)
    fprintf('\nDimensions of output data has to be lesser than the dimensions of input data\n');
    fprintf('Closing program\n');
    return
end

%% Using the Gaussian Kernel to construct the Kernel K
% K(x,y) = -exp((x-y)^2/(sigma)^2)
% K is a symmetric Kernel
K = zeros(size(data_in,2),size(data_in,2));
% for row = 1:size(data_in,2)
%     for col = 1:row
%         %temp1 = sum(((data_in(:,row) - data_in(:,col)).^2));
%         %temp2 = sum(((data_in(:,row) + data_in(:,col)).^2));
%         %temp = max([temp1,temp2]);
%         
%         temp = 1-corr(data_in(:,row), data_in(:,col))^2;
%         K(row,col) = exp(-temp/1); % sigma = 1
%     end
% end
G_a = L2_distance(data_in,data_in);
G_b = L2_distance(data_in,-data_in);
G_c = max(G_a, G_b);
%G_c = 1- (corr(data_in)).^2;
K = exp(-G_c/10);
K = K + K'; 
% Dividing the diagonal element by 2 since it has been added to itself
for row = 1:size(data_in,2)
    K(row,row) = K(row,row)/2;
end
% We know that for PCA the data has to be centered. Even if the input data
% set 'X' lets say in centered, there is no gurantee the data when mapped
% in the feature space [phi(x)] is also centered. Since we actually never
% work in the feature space we cannot center the data. To include this
% correction a pseudo centering is done using the Kernel.
one_mat = ones(size(K));
K_center = K - one_mat*K - K*one_mat + one_mat*K*one_mat;
clear K

%% Obtaining the low dimensional projection
% The following equation needs to be satisfied for K
% N*lamda*K*alpha = K*alpha
% Thus lamda's has to be normalized by the number of points
opts.issym=1;                          
opts.disp = 0; 
opts.isreal = 1;
neigs = 30;
[eigvec eigval] = eigs(K_center,[],neigs,'lm',opts);
eig_val = eigval ~= 0;
eig_val = eig_val./size(data_in,2);
% Again 1 = lamda*(alpha.alpha)
% Here '.' indicated dot product
for col = 1:size(eigvec,2)
    eigvec(:,col) = eigvec(:,col)./(sqrt(eig_val(col,col)));
end
[~, index] = sort(eig_val,'descend');
eigvec = eigvec(:,index);

%% Projecting the data in lower dimensions
data_out = zeros(num_dim,size(data_in,2));
for count = 1:num_dim
    data_out(count,:) = eigvec(:,count)'*K_center';
end