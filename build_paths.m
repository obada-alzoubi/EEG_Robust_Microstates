function [info] = build_paths(info, source, dest, ICA)
% 

Nsubjs = length(info);
info(:,3)=nan(Nsubjs,1);% source field
info(:,4)=nan(Nsubjs,1); % destination field
isGood = false(Nsubjs, 1);
for iSubj=1:Nsubjs
    
    if ICA 
        % Corrected using ICA
        subName = strtrim(info{iSubj,1});
        sub_folder = fullfile(source, subName, 'e');

       % check if the export folder is there 
       if exist(sub_folder,'dir')==7

           % Fix jared inconsistency 
           EDF = dir([sub_folder, '\', '*.edf']);
           fileInd = -1;
           for iEDF =1: length(EDF)
               if any([find(strfind(EDF(iEDF).name, 'ICA_Corrected'))...
                       ,find(strfind(EDF(iEDF).name, 'ICA_CONVERTED'))...
                       , find(strfind(EDF(iEDF).name, 'ICA_CORRECTED'))...
                       , find(strfind(EDF(iEDF).name, 'ICA CONVERTED'))])
                   fileInd = iEDF;
               end

           end
          % Construct Path 
           if fileInd~=-1
               info(iSubj, 3) = fullfile(EDF(fileInd).folder, EDF(fileInd).name);
               info(iSubj, 4) = fullfile(dest, subName);
               isGood(iSubj, 1)= true;
           else
               %isGood(iSubj, 1)= false;
               fprintf('Problem with fidning data for %s. \n', subName);
           end

       end
       
    else
        % Corrected Using Chung Ki code 
        subName = strtrim(info{iSubj,1});
        sub_folder = fullfile(source, subName, 'T0', 'eeg');
        % check if the export folder is there 
       if exist(sub_folder,'dir')==7
           
           MAT = dir([sub_folder, '\', '*.mat']);
           fileInd = -1;
           for iMAT =1: length(MAT)
               if any([find(strfind(MAT(iMAT).name, 'REST'))])
                   fileInd = iMAT;
               end

           end
           
           if fileInd~=-1
               info(iSubj, 3) = fullfile(MAT(fileInd).folder, MAT(fileInd).name);
               info(iSubj, 4) = fullfile(dest, subName);
               isGood(iSubj, 1)= true;
           else
               %isGood(iSubj, 1)= false;
               fprintf('Problem with fidning data for %s. \n', subName);
           end
           
       end
    end
   
end 

info = info(isGood, :);

end

