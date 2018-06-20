% Script to calcuate EEG microstate 
% Author: Obada Al Zoubi
function [badSubjs] = SanityCheck(Param )
%% General Config.

EEGLABPATH = Param.EEGLABPATH;

addpath(EEGLABPATH);

%%
DataList = Param.DataList;

Nsubj = length(DataList);

eeglab; close;

badSubjs = {};
iBad = 1; 

for iSubj =1:Nsubj
    
    fprintf(1,'Clustersing dataset %s (%i/%i)', strcat('subj_', ...
        int2str(iSubj)), iSubj, Nsubj);
    
    %mkdir(DataList{iSubj, 4})
    
    try 
        if Param.edf==true % ICA Corretec
            EEG = pop_fileio(DataList{iSubj, 3});
            %EEG = pop_select(EEG, 'channel', 1:31);% Remove ECG Channel
            %EEG = pop_eegfiltnew(EEG, 1,40); 
            %EEG = pop_reref( EEG, []);
            %EEG.chanlocs=pop_chanedit(EEG.chanlocs,'load',...
            %{ 'sub_files\Obada_updated.ced', 'filetype','autodetect'});
            %EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp',...
            %    'load',{'locations.ced' 'filetype' 'autodetect'});
            %EEG = eeg_checkset( EEG ); 
            %EEG.setname = DataList{iSubj, 1};
        else   % Chun KI corrected 
            EEG =rr(DataList{iSubj, 3}, Param);
            %EEG = pop_eegfiltnew(EEG, 1,40); 
            %EEG = pop_reref( EEG, []);
            %EEG.chanlocs=pop_chanedit(EEG.chanlocs,'load',...
            %{ 'sub_files\Obada_updated.ced', 'filetype','autodetect'});
            
        end

    catch
        fprintf(1,'Err : Had a problem with  %s \n', DataList{iSubj, 3})
        badSubjs{iBad} = DataList{iSubj, 3};
        iBad = iBad +1;
    end
    
end


end

