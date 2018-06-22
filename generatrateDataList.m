%% Generate reading file for EEG Microstate processing  
% Read Subjects Info 
[id,Age,Gender,Group] = readSubjectsInfo(fullfile(pwd, 'sub_files',...
    'subInfo.csv'));
% Try to read data  
nSubj = length (id);

sourcefolder = 'L:\\jbodurka\\Obada\\Datasets\\T-500\\EEG-Microstate-HC\\';
destfolder = 'L:\\jbodurka\\Obada\\Datasets\\T-500\\EEG-Microstate-HC_OUT\\';
GroupName ='Healthy Control';
DataList =[];
subj ={};
source= {};
dest ={};
cnt =1;
% Loop over all subjects 
for iSubj=1:nSubj
    fileName = sprintf('L:\\jfeinstein\\Obada\\T_500\\ProcessedEEG_bash\\%s\\T0\\eeg\\eeg_%s-T0-REST-R1-PREP.mat',...
        id{iSubj}, id{iSubj});
    if exist(fileName, 'file') == 2
        if strcmp(Group{iSubj}, GroupName) 
            
            %copyfile fileName dest
            load(fileName)
            if ~isempty(EEG.data)
                
                subj{cnt} = id{iSubj};
                source{cnt} = sprintf('%s\\Sub_%s.mat', sourcefolder,id{iSubj});
                dest{cnt} = sprintf('%s\\%s', destfolder, id{iSubj});
                cnt =cnt +1;

            end
        end
    end
end
DataList.subj=subj;
DataList.source=source;
DataList.dest=dest;
save('sub_files/HC_Group.mat', 'DataList')
