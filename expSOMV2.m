function [sM, sD] = expSOMV2(EEG, Param, arguments)
% Experimenal EEG SOM imp.
subjFolder = fullfile(Param.DATASETPATH_OUT, EEG.setname);
%mkdir(subjFolder)
%EEG_file = fullfile(subjFolder, sprintf('%s_EEG_MS.mat', EEG.setname));
MapsToUse = EEG.msinfo.MapsToUse;
sD = som_read_data('iris.data');   % Just for init. 
sD.data = MapsToUse';
nLabel = cell(size(sD.data, 1), 1);
nFeas = cell(size(sD.data, 2), 1);
for i=1:size(sD.data, 1)
    nLabel{i,1}= sprintf('S%d', i);
end
for i=1:size(sD.data, 2)
    nFeas{i,1}= sprintf('Ch%d', i);
end
sD.labels = nLabel;
sD.comp_names = nFeas;
sD.comp_norm = cell(size(sD.data, 2), 1);
%sD = som_normalize(sD,'var');

%sM = som_make(sD, 'seq');
sM = som_make(sD, 'msize', [10 10], 'seq');
sM = som_autolabel(sM,sD,'vote');
[~, pareto, ~] = somvis_p_matrix (sM, sD, 'estimate', 100); 

somvis_exec(sM, sD, [], pareto, 0, arguments{:});
FolderName = subjFolder;   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
fig_names = {'U_mat', 'U_star_mat', 'P_mat',  'hist','SDH', 'K_means_best', ...
    'K_means_dist_best', 'Wards', 'Wards_PCA','PCA' };
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = fig_names{11-iFig};
  saveas(FigHandle, fullfile(FolderName, sprintf('%s.png',FigName)));
  %close; 
end
close all;

end


