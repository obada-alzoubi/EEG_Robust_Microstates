% Construct DataList file 
T500 = copyT500('sub_files/subject_to_copy_updated.csv');
OUT_FOLDER = 'L:\jbodurka\Obada\ICA_Corrected_MS';
dataSource = 'L:\jbodurka\Obada\Datasets\T-500\EEG-Microstate-HC';
dataDest = 'L:\jbodurka\Obada\Datasets\T-500\EEG-Microstate-HC_OUT';
nSubs = length(T500);
DataList=[];
DataList.subj=[];
DataList.source=[];
DataList.dest=[];
for iSubj=1:nSubs
    DataList.subj{iSubj} = T500{iSubj};
    DataList.source{iSubj} = fullfile(dataSource, sprintf('Sub_%s.mat', T500{iSubj}));
    DataList.dest{iSubj} = fullfile(dataDest, T500{iSubj});
end

save('sub_files/DataList_10HC.mat', 'DataList')