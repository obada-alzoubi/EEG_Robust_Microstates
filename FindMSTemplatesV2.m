

function [EEG] = FindMSTemplatesV2(EEG, Param, iSubj)

ClustPar = Param.ClustPars;
DataList = Param.DataList;

if nargin < 2
    ClustPar = [];
end


FieldNames = {'MinClasses','MaxClasses','GFPPeaks','IgnorePolarity','MaxMaps','Restarts', 'Algorithm'};

iscomplete = all(isfield(ClustPar,FieldNames));


if ~iscomplete
    % Throw in the defaults where necessary and confirm
    ClustPar = UpdateFitParameters(ClustPar, struct('MinClasses',3,'MaxClasses',6,'GFPPeaks',true,'IgnorePolarity',true,'MaxMaps',1000,'Restarts',5', 'Algorithm',0),FieldNames);
    
    ClustPar.Algorithm        = structout.Algorithm;
    ClustPar.MaxMaps        = str2double(structout.Max_Maps);
    ClustPar.GFPPeaks       = structout.GFP_Peaks;
    ClustPar.IgnorePolarity = structout.Ignore_Polarity;
    ClustPar.MinClasses     = str2double(structout.Min_Classes);
    ClustPar.MaxClasses     = str2double(structout.Max_Classes);
    ClustPar.Restarts       = str2double(structout.Restarts);
    
end

% Distribute the random sampling across segments
nSegments = EEG.trials;
if ~isinf(ClustPar.MaxMaps)
    MapsPerSegment = hist(ceil(nSegments * rand(ClustPar.MaxMaps,1)),nSegments);
else
    MapsPerSegment = inf(nSegments,1);
end

MapsToUse = [];

%EEG.data = EEG.data ./ mean(std(EEG.data,0,2));
data_raw = EEG.data;
%EEG.data = normc(EEG.data);
for s = 1:nSegments
    
    if ClustPar.GFPPeaks == 1
        gfp = std(data_raw(:,:,s),1,1);
        % Obada Modified this to use MATLAB biultin function to find
        % peaks:
        %gfP_smoothed = smoothdata(gfp, 'gaussian',3);
        gfP_smoothed = gfp;
        x = 1:EEG.pnts;

        [pk, IsGFPPeak] = findpeaks(gfP_smoothed,x, 'MinPeakDistance',...
            2);
        f1= figure;
        plot(gfP_smoothed)
        hold on 
        scatter(IsGFPPeak, pk, 'r')
        hold off
        saveas(f1, fullfile(DataList{iSubj, 4},...
            sprintf('%s_GFP_peaks.png', EEG.setname)));
        close all;
        
        if numel(IsGFPPeak) > MapsPerSegment(s) && MapsPerSegment(s) > 0
            idx = randperm(numel(IsGFPPeak));
            IsGFPPeak = IsGFPPeak(idx(1:MapsPerSegment(s)));
        end
        MapsToUse = [MapsToUse EEG.data(:,IsGFPPeak,s)];
        
    else
        
        if (size(EEG.data,2) > ClustPar.MaxMaps) && MapsPerSegment(s) > 0
            idx = randperm(size(EEG.data,2));
            MapsToUse = [MapsToUse EEG.data(:,idx(1:MapsPerSegment(s)),s)];
        else
            MapsToUse = [MapsToUse EEG.data(:,:,s)];
        end
    end
    
end

% Paramter specefic for each algorithms
p = randperm(size(MapsToUse,2));
MapsToUse = double(MapsToUse);
MapsToUse = MapsToUse(:, p); % Randmoize smaples 
if ClustPar.IgnorePolarity == true
    flags = '';
else
    flags = 'p';
end

Clut_Range = ClustPar.MinClasses:ClustPar.MaxClasses;

% Select algorithm
%[sM,cl, centers] = expSOM(MapsToUse,EEG.setname);
Alg_name = '';
switch ClustPar.Algorithm
    
    case 0
        A_all = cell(length(Clut_Range), 1);
        L_all = cell(length(Clut_Range), 1);
        
        for nClusters = Clut_Range
            [b_model,label,~,exp_var] = eeg_kMeans(MapsToUse',...
                nClusters,ClustPar.Restarts,[],flags);
            A_all{nClusters-ClustPar.MinClasses+1, 1} = b_model';
            L_all{nClusters-ClustPar.MinClasses+1, 1} = label';
            
            msinfo.MSMaps(nClusters).Maps = b_model;
            msinfo.MSMaps(nClusters).ExpVar = exp_var;
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
            
        end
        
        Alg_name = 'eeg_kmeans';
        
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
        Alg_name ='AAHC';
        
    case 2
        
        opts.b =1;
        opts.fitmeas ='GEV';
        opts.optimised =1;
        opts.MS_Temp = Param.MS_Temp;
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
        Alg_name ='modkmeans';
        
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
        
        Alg_name = 'raahc_corr';
        
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
        Alg_name = 'raahc_GEV';
        
        
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
        Alg_name = 'kmeans';
        
    case 6
        % running algorithm
        % running algorithm
        A_all ={};
        L_all ={};
        for nClusters = Clut_Range
            [L_K,A_K] = SpecClustering(MapsToUse, nClusters);
            L_all{nClusters-ClustPar.MinClasses+1} = A_K;
            A_all{nClusters-ClustPar.MinClasses+1} = L_K;
        end
        
        
        
        for nClusters = Clut_Range
            msinfo.MSMaps(nClusters).Maps = A_all{nClusters-ClustPar.MinClasses+1}';
            msinfo.MSMaps(nClusters).ExpVar = nan; % to be implemenated
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
        end
        Alg_name = 'Spectral';
    case 7
%         DIST=distanceMatrix(MapsToUse');
%         DIST(DIST==0)=inf;
%         DIST=min(DIST);
%         para=5*mean(DIST);
%         disp('Performing Gaussian kernel PCA...');
%         %MapsToUse = normc(MapsToUse);
%          [Y3, eigVector]=kPCA(MapsToUse',29,'gaussian',para);
% 
%         %mu = mean(MapsToUse');
% 
%         %[eigenvectors, scores] = pca(MapsToUse');
%         %[Y3, eigVector, eigValue]=PCAV2(MapsToUse',10);

        [mappedA, mapping] = compute_mapping(MapsToUse','KPCA', 29, 'gauss');

        opts.b =1;
        opts.fitmeas ='GEV';
        opts.optimised =1;
        opts.MS_Temp = Param.MS_Temp;
        A_all = cell(length(Clut_Range), 1);
        L_all = cell(length(Clut_Range), 1);
        
        
         %Xhat = scores(:,1:nComp) * eigenvectors(:,1:nComp)';
         %Xhat = bsxfun(@plus, Xhat, mu);
        for nClusters = Clut_Range
            
            %[b_model,label,Res] = modkmeans(mappedA',nClusters,opts);
            %b_model = b_model';
                            %b_model_r(i,:)=kPCA_PreImage(b_model(i,:)',eigVector,MapsToUse',para);

            [label,b_model,Res] = kmeans(mappedA,nClusters);
            b_model = b_model';
            for i=1:nClusters
                
                S = MapsToUse(:,label==i)*MapsToUse(:, label==i)';

                %finding eigenvector with largest value and normalising it
                [eVecs,eVals] = eig(S,'vector');
                [~,idx] = max(abs(eVals));
                A(:,i) = eVecs(:,idx);
                A(:,i) = A(:,i)./sqrt(sum(A(:,i).^2));
            end
            label = label';
            A_all{nClusters-ClustPar.MinClasses+1}=A;
            L_all{nClusters-ClustPar.MinClasses+1}=label';
            msinfo.MSMaps(nClusters).Maps = A';
            msinfo.MSMaps(nClusters).ExpVar =nan;
            msinfo.MSMaps(nClusters).ColorMap = lines(nClusters);
            msinfo.MSMaps(nClusters).SortMode = 'none';
            msinfo.MSMaps(nClusters).SortedBy = 'none';
        end
        % Reconstruct the data 
        Alg_name ='KPCA_modkmeans'; 
        [KL, KL_nrm, W, CV, GEV] = calc_fitmeasV2(MapsToUse,A_all, L_all);

    otherwise
        fprintf('Bad Selection of alg. \n');
end

%% Add Performance Metrics
[KL, KL_nrm, W, CV, GEV] = calc_fitmeasV2(MapsToUse,A_all, L_all);

for nClusters = Clut_Range
    
    msinfo.Performance(nClusters).KL =...
        KL(nClusters-ClustPar.MinClasses+1);
    
    msinfo.Performance(nClusters).KL_nrm =...
        KL_nrm(nClusters-ClustPar.MinClasses+1); % to be implemenated
    
    msinfo.Performance(nClusters).W =...
        W(nClusters-ClustPar.MinClasses+1);
    
    msinfo.Performance(nClusters).CV =...
        CV(nClusters-ClustPar.MinClasses+1);
    
    msinfo.Performance(nClusters).GEV =...
        GEV(nClusters-ClustPar.MinClasses+1);
    
    msinfo.Performance(nClusters).Alg = Alg_name;
end
%[g] = KL_Metric(MapsToUse,L_all,Clut_Range); 
g = zeros(1, max(Clut_Range));
msinfo.KL = zeros(1, max(Clut_Range));

msinfo.ClustPar = ClustPar;

msinfo.MapsToUse = MapsToUse;

EEG.msinfo = msinfo;

%% Plot MSs
c = redblue(31);
for nClusters = Clut_Range
    
    h=figure;    
    for iMS =1:nClusters
        subplot(1, nClusters, iMS)
        topoplot_new(EEG.msinfo.MSMaps(nClusters).Maps(iMS,:),...
            EEG.chanlocs,'headrad', 0.6,'maplimits', [-0.4, 0.4],...
            'colormap',c);
    end
    
    file_loc = fullfile(DataList{iSubj, 4},...
        sprintf('MS_K%d.png', nClusters));
    
    print(h, file_loc, '-dpng')
    
    close;
    
end 
f= fopen(fullfile(DataList{iSubj, 4},'stat.txt'),'w+');
fprintf(f,'#Clusters, KL, KL_nrm, KL_Obada, CV, GEV, Alg. \n');
for nClusters = Clut_Range
    ind = nClusters - Clut_Range(1) + 1;
    fprintf(f,'%d, %0.3f, %0.3f, %0.3f, %0.3f, %0.3f, %s\n',nClusters,...
        KL(ind), KL_nrm(ind), g(nClusters), CV(ind), GEV(ind), Alg_name);
end 
fclose(f);
end
