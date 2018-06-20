X = cell2mat({EEG.chanlocs.X});
Y = cell2mat({EEG.chanlocs.Y});
Z = cell2mat({EEG.chanlocs.Z});
figure;
msmaps= EEG.msinfo.MSMaps;
msmaps= double(msmaps(7).Maps);
figure
for i=1:7
subplot(1,7,i)
dspCMap(msmaps(i,:),[X; Y; Z],'NoScale','Resolution',3, 'Extrema');
end
figure;
for i=1:3
subplot(1,3,i)
dspCMap(centers(i,:),[X; Y; Z],'NoScale','Resolution',3, 'Extrema');
end