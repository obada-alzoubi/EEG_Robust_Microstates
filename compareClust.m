function [A_all,L_all,  KL, KL_nrm, W, CV, GEV ] = compareClust( MapsToUse, Clut_Range, alg )
ClustPar = struct('MinClasses', 4, 'MaxClasses', 8, 'GFPPeaks', true, ...
    'IgnorePolarity', true, 'Algorithm',2, 'MaxMaps', 10000, 'Restarts',10);

for i=6:6
switch i

    case 0 
        A_all = cell(length(Clut_Range), 1);
        L_all = cell(length(Clut_Range), 1);

        for nClusters = Clut_Range
            [b_model,label,~,exp_var] = eeg_kMeans(MapsToUse',...
                nClusters,ClustPar.Restarts,[],'');
            A_all{nClusters-ClustPar.MinClasses+1, 1} = b_model';
            L_all{nClusters-ClustPar.MinClasses+1, 1} = label';

            msinfo.MSMaps(nClusters).Maps = b_model;
            msinfo.MSMaps(nClusters).ExpVar = exp_var;
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';

        end

        %[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);

    case 1



        A_all = cell(length(Clut_Range), 1);
        L_all = cell(length(Clut_Range), 1);

        for nClusters = Clut_Range
            [b_model,label,exp_var] = eeg_computeAAHC(MapsToUse',...
            nClusters,false, ClustPar.IgnorePolarity);
            A_all{nClusters-ClustPar.MinClasses+1, 1}= b_model';
            L_all{nClusters-ClustPar.MinClasses+1, 1}= label';
            msinfo.MSMaps(nClusters).Maps =...
                b_model;
            msinfo.MSMaps(nClusters).ExpVar =...
                exp_var;
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';

        end
        %[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);

    case 2

        opts.b =0;
        A_all = cell(length(Clut_Range), 1);
        L_all = cell(length(Clut_Range), 1);



        for nClusters = Clut_Range
            [b_model,label,Res] = modkmeans(MapsToUse,nClusters,opts);
            b_model = b_model';
            label = label';
            A_all{nClusters-ClustPar.MinClasses+1}=b_model';
            L_all{nClusters-ClustPar.MinClasses+1}=label';
            msinfo.MSMaps(nClusters).Maps = Res.A_all{1}';
            msinfo.MSMaps(nClusters).ExpVar = Res.R2(1);
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
         end
        %[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);

    case 3 %'taahc'

        opts.atom_ratio = 1;
        opts.atom_measure = 'corr';
        opts.verbose = 1;
        opts.determinism = 0;
        opts.polarity = 0;

        % running algorithm
        [A_all, L_all] = raahc(MapsToUse, Clut_Range, opts);
        % Calculate measures of fit


        for nClusters = Clut_Range
            msinfo.MSMaps(nClusters).Maps =...
                A_all{nClusters-ClustPar.MinClasses+1}';
            msinfo.MSMaps(nClusters).ExpVar = nan; % to be implemenated
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
         end

         %[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);

    case 4 %raahc

        opts.atom_ratio = 1;
        opts.atom_measure = 'GEV';
        opts.verbose = 1;
        opts.determinism = 0;
        opts.polarity = 0;

        % running algorithm
        [A_all, L_all] = raahc(MapsToUse, Clut_Range, opts);

        for nClusters = Clut_Range
            msinfo.MSMaps(nClusters).Maps =...
                A_all{nClusters-ClustPar.MinClasses+1}';
            msinfo.MSMaps(nClusters).ExpVar = nan;
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
         end
        %[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);

    case 5 %K-means
        A_all ={};
        L_all ={};
        for nClusters = Clut_Range
            [L_K,A_K] = kmeans(MapsToUse', nClusters);
            A_all{nClusters-ClustPar.MinClasses+1} = A_K';
            L_all{nClusters-ClustPar.MinClasses+1} = L_K';
        end



        for nClusters = Clut_Range
            msinfo.MSMaps(nClusters).Maps = A_all{nClusters-ClustPar.MinClasses+1}';
            msinfo.MSMaps(nClusters).ExpVar = nan; % to be implemenated
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
         end
         %[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);

    case 6
         % running algorithm
        A_all ={};
        L_all ={};
        for nClusters = Clut_Range
            [L_K,A_K] = SpecClustering(MapsToUse', nClusters);
            A_all{nClusters-ClustPar.MinClasses+1} = A_K';
            L_all{nClusters-ClustPar.MinClasses+1} = L_K';
        end



        for nClusters = Clut_Range
            msinfo.MSMaps(nClusters).Maps = A_all{nClusters-ClustPar.MinClasses+1}';
            msinfo.MSMaps(nClusters).ExpVar = nan; % to be implemenated
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
        end
         

        %[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);
    otherwise 
        fprintf('Bad Selection of alg. \n');
end

[KL, KL_nrm, W, CV, GEV] = calc_fitmeas(MapsToUse,A_all, L_all);
fprintf('Alg %d - Val of GEV:  %0.3f \n', i, GEV)
end

end

