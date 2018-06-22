
function [ ALLEEG, GroundMeanControlIndex ] = groupAnalysisMS(Param )

% Script to calcuate EEG microstate 
% Author: Obada Al Zoubi
%% General Config.

EEGLABPATH = Param.EEGLABPATH;

DATASETPATH = Param.DATASETPATH;

addpath(EEGLABPATH);

Dir = dir(fullfile(DATASETPATH, '*.mat'));

ClustPars = Param.ClustPars;

MSParam  = Param.MSParam;

outputStatIndv  = Param.outputStatIndv;

outputStatGrand  = Param.outputStatGrand;



%%
Nsubj = size(Dir, 1);

ControlGroup = zeros(1, Nsubj);

eeglab; close;

% loop for each file
ALLEEG_ = cell(Nsubj, 1);
%pool = gcp;
for iSubj =1:Nsubj
    
    fprintf(1, 'Clustersing dataset %s (%i/%i)', iSubj, Nsubj);
    
    EEG =rr(fullfile(DATASETPATH, Dir(iSubj).name));
    
   [ EEG ] = setPeaksParam( EEG );
   if length(Param.limitDuration)==2
       EEG = pop_select( EEG,'time', Param.limitDuration);
   end
                 
    ALLEEG_{iSubj, 1} = pop_FindMSTemplates(EEG, ClustPars);
    
    
    ControlGroup(1, iSubj)= iSubj;
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
    
    [ALLEEG] = O_orderMS(ALLEEG, 4);
end


%%
if Param.plot==1
    [ALLEEG, EEG] = pop_ShowIndMSMaps(EEG_mean_Grand,...
        4, GroundMeanControlIndex, ALLEEG);
end
%%
if Param.stat==1
    FitPars = struct('nClasses', 7, 'lambda', 0, 'b', 30, 'PeakFit', ...
        false, 'BControl', true);
    pop_QuantMSTemplates(ALLEEG, ControlGroup, 0, FitPars, [],outputStatIndv)

    pop_QuantMSTemplates(ALLEEG, ControlGroup, 1, FitPars,...
        GroundMeanControlIndex, outputStatGrand)
end




end

