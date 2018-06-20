function [ EEG ] = setPeaksParam( EEG )
% This function is an extsntion for Peak detection Alg. 
EEG.peakParam.MinPeakDistance = 10; %ms 
EEG.peakParam.Fs = EEG.srate; % Hz
EEG.peakParam.NPeaks = 1000; % peak





end

