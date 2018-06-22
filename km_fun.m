%% K-means

function [CENTS, DAL] = km_fun(F, K, KMI)

CENTS = F( ceil(rand(K,1)*size(F,1)) ,:); 
[~,A_K] = kmeans(F, K,'MaxIter',1000,'Replicates',20);% Cluster Centers
CENTS = A_K;
DAL   = zeros(size(F,1),K+2);                          % Distances and Labels
GEV_max = 0;
for n = 1:KMI
        
   for i = 1:size(F,1)
      for j = 1:K  
        
        DAL(i,j) = 1- abs(corr(F(i,:)', CENTS(j,:)')); 
        %CosTheta = dot(F(i,:)',CENTS(j,:)')/(norm(F(i,:)')*norm(CENTS(j,:)'));
        %DAL(i,j) = acosd(CosTheta);
        %DAL(i,j) = abs(pdist2(F(i,:), CENTS(j,:), 'squaredeuclidean'));
        
      end
      [Distance, CN] = min(DAL(i,1:K));                % 1:K are Distance from Cluster Centers 1:K 
      DAL(i,K+1) = CN;                                 % K+1 is Cluster Label
      DAL(i,K+2) = Distance;                           % K+2 is Minimum Distance
   end
   for i = 1:K
        if true
        % Cluster K Points
        %finding eigenvector with largest value and normalising it
        L= DAL(:,K+1);
        S = F(L==i, :)'*F(L==i, :);
        [eVecs,eVals] = eig(S,'vector');
        [~,idx] = max(abs(eVals));
        CENTS(i,:) = eVecs(:,idx);
        CENTS(i, :) = CENTS(i, :)./sqrt(sum(CENTS(i,:).^2));
        else
            A = (DAL(:,K+1) == i);
            CENTS(i,:) = mean(F(A,:));
        end
      
                  % New Cluster Centers
      if sum(isnan(CENTS(:))) ~= 0                     % If CENTS(i,:) Is Nan Then Replace It With Random Point
         NC = find(isnan(CENTS(:,1)) == 1);            % Find Nan Centers
         for Ind = 1:size(NC,1)
         CENTS(NC(Ind),:) = F(randi(size(F,1)),:);
         end
      end
   end
   
   if mod(n,1)==0
        [KL, KL_nrm, W, CV, GEV] = calc_fitmeas(F',CENTS', DAL(:,K+1));

        if GEV > GEV_max
            GEV_max= GEV;
            fprintf('GEV = %0.3f \n', GEV_max)
        end
    end
    %c=c+1;

end
CENTS=CENTS';
for iK=1:K
CENTS(:,iK) = CENTS(:,iK)./sqrt(sum(CENTS(:,iK).^2));
end
DAL = DAL(:, K+1);
end