function [g] = KL_Metric(MapsToUse,L_all,clust_range)
KL_all = zeros(1, clust_range(end));
ssw_all = zeros(1, clust_range(end));
diff = zeros(1, clust_range(end));
g= zeros(1, clust_range(end));

for nc =clust_range
  [indx,ssw,sw,sb]=valid_clusterIndex(MapsToUse',L_all{nc-clust_range(1)+1}); 
  fprintf('KL = %0.2f for number of clusters %d \n', indx(4), nc)
  KL_all(nc)=indx(4);
  ssw_all(nc) =ssw;
end

for nc=clust_range(2:end)
    diff(nc) = (((nc-1)^(2/31))*ssw_all(nc-1) - ((nc)^(2/31))*ssw_all(nc));
end

for nc=clust_range(2:end-1)
    g(nc)= abs(diff(nc)/diff(nc+1));
end
end

