
function [ALLEEG, GroundMeanControlIndex] = groupAnalysisMSCalcstat(Param )

% Script to calcuate EEG microstate 
% Author: Obada Al Zoubi
%% General Config.

EEGLABPATH = Param.EEGLABPATH;

%DATASETPATH = Param.DATASETPATH;

%DATASETPATH_OUT = Param.DATASETPATH_OUT;

addpath(EEGLABPATH);

%ClustPars = Param.ClustPars;

%MSParam  = Param.MSParam;
DataList = Param.DataList;

% outputStatIndv  = Param.outputStatIndv;
% 
% outputStatGrand  = Param.outputStatGrand;



%%
Nsubj = length(DataList);

ControlGroup = [];

eeglab; close;

% loop for each file
ALLEEG_ = cell(Nsubj, 1);
%pool = gcp;
iSubj_corrected =1; % In case something was wrong with phase 1 processing 
for iSubj =1:Nsubj
    try
    fprintf(1, 'Reading dataset (%i/%i)', iSubj, Nsubj);

    load(fullfile(DataList{iSubj, 4} , ...
        sprintf('%s_EEG_MS.mat', DataList{iSubj, 1}) ));
     EEG.chanlocs=pop_chanedit(EEG.chanlocs,'load',...
    { 'sub_files\Obada_updated.ced', 'filetype','autodetect'});
    
    ALLEEG_{iSubj_corrected, 1} = EEG;
     
    
    ControlGroup = [ControlGroup iSubj_corrected];
    iSubj_corrected = iSubj_corrected +1;
    
    catch
        fprintf('something went wrong with  %s \n', DataList{iSubj, 1})
    end
end

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
close;


%%
for iSubj = 1:length(ControlGroup)
    
    ALLEEG = eeg_store(ALLEEG,  ALLEEG_{iSubj, 1}, ControlGroup(1, iSubj));
    
end
%%

EEG_mean_Grand = pop_CombMSTemplates(ALLEEG, ControlGroup, 0, 0, 'GrandMean');


[ALLEEG, EEG,  CURRENTSET] = eeg_store(ALLEEG, EEG_mean_Grand, CURRENTSET);

GroundMeanControlIndex = CURRENTSET;

%% Sort Part 
if Param.sort==1
    
    ALLEEG = pop_SortMSTemplates(ALLEEG, ControlGroup, 0,...
        GroundMeanControlIndex);
    ALLEEG = eeg_store(ALLEEG, EEG, CURRENTSET);
elseif Param.sort==2
    
    [ALLEEG2] = O_orderMS(ALLEEG, 4);
end



%%
if Param.plot==1
    [ALLEEG, EEG] = pop_ShowIndMSMaps(EEG_mean_Grand,...
        4, GroundMeanControlIndex, ALLEEG);
end
%%
% if Param.stat==1
% %     FitPars = struct('nClasses', 8, 'lambda', 0, 'b', 30, 'PeakFit', ...
% %         false, 'BControl', true);
% %     pop_QuantMSTemplates(ALLEEG, ControlGroup, 0, FitPars, [],outputStatIndv)
% % 
% %     pop_QuantMSTemplates(ALLEEG, ControlGroup, 1, FitPars,...
% %         GroundMeanControlIndex, outputStatGrand)
% end







end

