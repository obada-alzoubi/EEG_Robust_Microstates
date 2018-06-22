% Script to calcuate EEG microstate 
% Author: Obada Al Zoubi
function [ ] = groupAnalysisMSL(Param )
%% General Config.

EEGLABPATH = Param.EEGLABPATH;

addpath(EEGLABPATH);

%%
DataList = Param.DataList;

Nsubj = length(DataList);

eeglab; close;

%load('arguments_SOM.mat')
normalizeEEG =Param.normalizeEEG;
%
%normc_fcn = @(m) sqrt(m.^2 ./ sum(m.^2));

for iSubj =1:Nsubj
    
    fprintf(1,'Clustersing dataset %s (%i/%i)', strcat('subj_', ...
        int2str(iSubj)), iSubj, Nsubj);
    
    mkdir(DataList{iSubj, 4})
    
    try 
        if Param.edf==true % ICA Corretec
            EEG = pop_fileio(DataList{iSubj, 3});
            EEG = pop_select(EEG, 'channel', 1:31);% Remove ECG Channel
            EEG = pop_eegfiltnew(EEG, 1,40); 
            EEG = pop_reref( EEG, []);
            EEG.chanlocs=pop_chanedit(EEG.chanlocs,'load',...
            { 'sub_files\Obada_updated.ced', 'filetype','autodetect'});
            %EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp',...
            %    'load',{'locations.ced' 'filetype' 'autodetect'});
            EEG = eeg_checkset( EEG ); 
            EEG.setname = DataList{iSubj, 1};
        else   % Chun KI corrected 
            EEG =rr(DataList{iSubj, 3}, Param);
            EEG = pop_eegfiltnew(EEG, 1,40); 
            EEG = pop_reref( EEG, []);
            EEG.chanlocs=pop_chanedit(EEG.chanlocs,'load',...
            { 'sub_files\Obada_updated.ced', 'filetype','autodetect'});
            
        end

       [ EEG ] = setPeaksParam( EEG );

        if length(Param.limitDuration)==2
             EEG = pop_select( EEG,'time', Param.limitDuration);        
        end
        %if normalizeEEG 
            %EEG.data = normc_fcn(EEG.data);
        %    EEG.data = normc(EEG.data);
        %end
        EEG.setname= DataList{iSubj, 1};

        EEG = FindMSTemplatesV2(EEG, Param, iSubj);


        % SOM - Experimental 

        %[sM, sD] = expSOMV2(EEG, Param, arguments);
        sM=[];
        sD=[];
        %sfile = strsplit(Dir(iSubj).name, '_');
        %sfile = sfile{1};
        %sfile = sprintf('%s.mat', sfile);
        %EEG.setname= sfile;
        save_in_Parall(EEG, sM, sD,  Param, iSubj);
    catch
        fprintf(1,'Had a problem in dataset %s (%i/%i)', strcat('subj_', ...
        int2str(iSubj)), iSubj, Nsubj);
    end
    
end


end

