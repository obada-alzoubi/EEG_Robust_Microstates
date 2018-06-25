function [] =save_in_Parall(EEG, sM, sD, Param, iSubj)

    subjFolder = Param.DataList{iSubj, 4};
    mkdir(subjFolder)
    EEG_file = fullfile(subjFolder, sprintf('%s_EEG_MS.mat', EEG.setname));
    save(EEG_file, 'EEG')
    sM_file = fullfile(subjFolder, sprintf('%s_sM_SOM.mat', EEG.setname));
    save(sM_file, 'sM')
    sD_file = fullfile(subjFolder, sprintf('%s_sD_SOM.mat', EEG.setname));
    save(sD_file, 'sD')
    
    
end