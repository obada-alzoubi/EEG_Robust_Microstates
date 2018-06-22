function [ ] = groupAnalysisMSL_imb(Param )

% Script to calcuate EEG microstate 
% Author: Obada Al Zoubi
%% General Config.

EEGLABPATH = Param.EEGLABPATH;

DATASETPATH = Param.DATASETPATH;

DATASETPATH_OUT = Param.DATASETPATH_OUT;

addpath(EEGLABPATH);

Dir = dir(fullfile(DATASETPATH, 'S*'));

ClustPars = Param.ClustPars;


%%
Nsubj = size(Dir, 1);

eeglab; close;
load('arguments_SOM.mat')
for iSubj =1:Nsubj
    
    fprintf(1, 'Clustersing dataset %s (%i/%i)', strcat('subj_', ...
        int2str(iSubj)), iSubj, Nsubj);
    file_name = sprintf('%sR02.edf', Dir(iSubj).name);
    mkdir(fullfile(Param.DATASETPATH_OUT,Dir(iSubj).name));
    EEG = pop_biosig(fullfile(DATASETPATH, Dir(iSubj).name, file_name));
    EEG = pop_eegfiltnew(EEG, 1,30,528,0,[],1); 
    EEG = pop_reref( EEG, []);
    EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp','load',{'locations.ced' 'filetype' 'autodetect'});
    EEG = eeg_checkset( EEG ); 
    EEG.setname = Dir(iSubj).name;
   [ EEG ] = setPeaksParam( EEG );
   
    if length(Param.limitDuration)==2
         EEG = pop_select( EEG,'time', Param.limitDuration);        
    end
                 
    EEG = FindMSTemplatesV2(EEG, Param);
    
    % SOM - Experimental 
    
    [sM, sD] = expSOMV2(EEG, Param, arguments);
    
    save_in_Parall(EEG, sM, sD,  Param);
    
    
end



end