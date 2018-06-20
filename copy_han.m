%clc; clear; close all;
%%
currentFolder = pwd; 

%addpath(fullfile(pwd, 'EEGLAB'));

chan_loc_name = 'Obada_updated.ced';

chan_loc_dir = fullfile(pwd, 'sub_files', chan_loc_name);

eeglab; close;
%%

% Read Subjects Info 
[id,Age,Gender,Group] = readSubjectsInfo(fullfile(pwd, 'sub_files',...
    'subInfo.csv'));
% Try to read data  
nSubj = length (id);
%
EEGDatabase = [];
count=1;
healthy = 0;
MDD =0;
dest = 'L:\\jbodurka\\Obada\\HAN\\EEG_HC\\';

% Loop over all subjects 
for iSubj=1:nSubj
    fileName = sprintf('L:\\jfeinstein\\Obada\\T_500\\ProcessedEEG_bash\\%s\\T0\\eeg\\eeg_%s-T0-REST-R1-PREP.mat',...
        id{iSubj}, id{iSubj});
    if exist(fileName, 'file') == 2
        if strcmp(Group{iSubj}, 'Healthy Control') 
            %copyfile fileName dest
            load(fileName)
            if ~isempty(EEG.data)
                %EEG.chanlocs=pop_chanedit(EEG.chanlocs,'load',...
                %    { chan_loc_dir, 'filetype','autodetect'});

                %EEG = pop_select( EEG,'time', [60 300]);

                %EEG = pop_eegfiltnew(EEG, 2, 20);
                
                EEG.setname = id{iSubj};
                
                output_name = sprintf('%s\\%s.mat', dest, id{iSubj});

                save(output_name, 'EEG' )
            end
        end
    end
end