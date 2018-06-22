function [] = plotTopo(EEG, Param, name)

c = redblue(31);
ClustPars = Param.ClustPars;
Clut_Range = ClustPars.MinClasses:ClustPars.MaxClasses;
% Make output dir if needed 
loc = Param.GrndMeanFig; 
if exist(loc,'dir')~=7
    fprintf('output dir is not exsit, thus making one. \n')
    mkdir(loc)
end
for nClusters = Clut_Range
    % loop over all micorsate 
    h=figure;    
    for iMS =1:nClusters
        subplot(1, nClusters, iMS)
        topoplot_new(EEG.msinfo.MSMaps(nClusters).Maps(iMS,:),...
            EEG.chanlocs,'headrad', 0.6,...
            'colormap',c);
    end
    
    file_loc = fullfile(loc,...
        sprintf('GrdMean_%s_K%d.png', name, nClusters));
    
    print(h, file_loc, '-dpng')
    
    close;
    
end 

end

