function [ b_model, b_ind, exp_var] = updateEEG(InData, k )



n_chan = size(InData, 2);

%eeg =InData;
eeg = NormDimL2(InData,2) / sqrt(size(InData, 2));

newRef = eye(n_chan);

eeg = eeg*newRef;									% Average reference of data 

%eeg = NormDim(eeg,2);

org_data = eeg;


opt = statset('TolFun',1e-10);
[idx, Center ,~, ~]=kmeans(InData, k, 'Replicates',100, 'MaxIter', 10000, 'Options', opt);

GMModel = fitgmdist(InData,4);

idxMM = cluster(GMModel,InData);
%model   = NormDim(C,2)*newRef;	
model = Center; 
covm    = org_data*model';	

[loading,ind] =  max(abs(covm),[],2);	

%[loading,~] =  min(abs(D),[],2);	 

b_model   = Center;
b_ind     = idx;
b_loading = loading/sqrt(n_chan);

exp_var = sum(b_loading)/sum(std(eeg,1,2));



% From Zuirich group 
X = InData';
[C,N] = size(X);

const1 = sum(sum(X.^2));
A = GMModel.mu';
A = bsxfun(@rdivide,A,sqrt(diag(A*A')));% normalising
    % Step 4
for k = 1:4
    A(:,k) = A(:,k)./sqrt(sum(A(:,k).^2));
end
Z = A'*X;
[~,L] = max(Z.^2);
sig2 = (const1 - sum(sum(A(:,L).*X).^2)) / (N*(C-1));


% Step 10
    % Step 3

sig2_D = const1 / (N*(C-1));
R2 = 1 - sig2/sig2_D;
activations = zeros(size(Z));
for n=1:N; activations(L(n),n) = Z(L(n),n); end % setting to zero
MSE = mean(mean((X-A*activations).^2));


end

