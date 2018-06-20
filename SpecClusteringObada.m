function [ Centriods,  D] = SpecClusteringObada ( X, k )
Data = normalizeData(X);
SimGraph = SimGraph_NearestNeighbors(Data, 10,1, 0);
C = SpectralClustering(SimGraph, k, 3);
% convert and restore full size
D = convertClusterVector(C);
Centriods = nan(size(Data,1),k);
X=X';

for iC=1:k
    
   
    %S = X(D==iC, :)'*X(D==iC, :);
    %[eVecs,eVals] = eig(S,'vector');
    %[~,idx] = max(eVals);
    [S,d] = kmeans(X(D==iC, :), 2);
    c1 =sum(S==1);
    c2 = sum(S==2);
    ind =2;
    if c1>=c2
        ind=1;
    end
    %Centriods(:, iC) = eVecs(:,idx);
    Centriods(:, iC) = d(ind, :)';
    Centriods(:, iC) = Centriods(:, iC)./sqrt(sum(Centriods(:, iC).^2));
    %clus_data = mean(X(D==iC, :),1);
    %clus_data =clus_data';
    %clus_data = clus_data./sqrt(sum(clus_data.^2));  

    %Centriods = [Centriods clus_data];
end

end

