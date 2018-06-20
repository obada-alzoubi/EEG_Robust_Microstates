T1000_HC = copyT500('sub_files/MA_Medicated.csv');
T500 = copyT500('sub_files/T500_list.csv');
OUT_FOLDER = 'L:\jbodurka\Obada\ICA_Corrected_MS';
SOURCE_FOLDER ='L:\NPC\Analysis\T1000\data-organized';

nSubjs = length(T1000_HC);

for iSubj=1:nSubjs
    % Copy files 
    temp_out = fullfile(OUT_FOLDER, T1000_HC{iSubj});

    temp_sess = fullfile(SOURCE_FOLDER,T1000_HC{iSubj},'T0', 'functional_session');
    
    if exist(temp_sess, 'file') == 7 & find(strcmp(T500, T1000_HC{iSubj}))& exist(temp_out, 'file') ~= 7
        %
%         if exist(temp_out, 'file') ~= 7
% 
%         end
        mkdir(temp_out)        
        vhdr = fullfile(temp_sess,...
            sprintf('%s-T0-REST-R1-RAW.vhdr', T1000_HC{iSubj}));
        eeg = fullfile(temp_sess,...
            sprintf('%s-T0-REST-R1-RAW.eeg', T1000_HC{iSubj}));
        vmrk = fullfile(temp_sess,...
            sprintf('%s-T0-REST-R1-RAW.vmrk', T1000_HC{iSubj}));
        
        status1 = copyfile(vhdr, temp_out);
        status2 = copyfile(eeg, temp_out);
        status3 = copyfile(vmrk, temp_out);       
        if status1&status2&status3
            fprintf('Sucessfully copied %s \n', T1000_HC{iSubj})
        else
            fprintf('Fail to copy files for  %s \n', T1000_HC{iSubj})

        end
    end
    
    
end