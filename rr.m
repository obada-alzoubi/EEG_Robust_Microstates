function [ EEG ] = rr( f, Param )

EEG =load(f);
EEG = EEG.EEG;
%mEEG = mean(EEG.data,1);
    
%EEG.data = EEG.data - repmat(mEEG,size(EEG.data,1),1);
    
%EEG.data = EEG.data ./ mean(std(EEG.data,0,2));
%normc_fcn = @(m) sqrt(m.^2 ./ sum(m.^2));
%EEG.data = normc_fcn(EEg.data);

subjFolder = fullfile(Param.DATASETPATH_OUT, EEG.setname);

mkdir(subjFolder)

end

