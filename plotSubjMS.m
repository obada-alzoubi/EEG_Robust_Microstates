function [  ] = plotSubjMS( ALLEEG, nMS, Param )
    % subplot all subjs EEG
    nSubjs = length(ALLEEG);
    nSubPlot =5;
    X = cell2mat({ALLEEG(1).chanlocs.X});
    Y = cell2mat({ALLEEG(1).chanlocs.Y});
    Z = cell2mat({ALLEEG(1).chanlocs.Z});
    
    mkdir(fullfile(Param.QALOCATION, 'QA'));
    
    for iSubj=1:nSubjs 
        
        if iSubj==1
            figure1 = figure('Position', [100, 100, 1024, 1024]);
            iFig = 1;
        end
        if mod(iSubj,nSubPlot)==0 || iSubj==nSubjs

            s = sprintf('sub_MS%d_%d_%d.png',nMS, iSubj-5, iSubj );
            file_loc = fullfile(Param.QALOCATION, 'QA', s);
            print(figure1, file_loc, '-dpng')
            %savefig(figure1, s)
            close;
            figure1 = figure('Position', [100, 100, 1024, 1024]);
            iFig = 1;


        end
        MSMaps = double(ALLEEG(iSubj).msinfo.MSMaps(nMS).Maps);
        try
        GEV = ALLEEG(iSubj).msinfo.Performance(nMS).GEV;
        KL = ALLEEG(iSubj).msinfo.Performance(nMS).KL;
        catch 
            GEV =-1;
            KL= -1;
        end 
        %MSOrders=Order_MS(ALLEEG, iSubj, nMS);
        %MSOrders = ones(nMS,1)*(nMS+1)  - MSOrders ;
        MSOrders =1:nMS;
        unidentified_MS = find(MSOrders==0);
        
        if ~isempty(unidentified_MS)
            C = setdiff([0, 1:nMS], MSOrders);
            for iC = C
                 MSOrders = 1:nMS;
            end
        end

        MSMaps_ordered = MSMaps(MSOrders, :); 
       
        for iMS = 1:nMS
            
            subplot(nSubPlot, nMS, iFig)
            
            dspCMap(MSMaps_ordered(iMS,:),[X; Y;Z],'NoScale','Resolution',3, 'Extrema');
            
            iFig = iFig +1 ;
            
            if ~isempty(unidentified_MS)
            
                s = sprintf(' %s - MS xxxx', ALLEEG(iSubj).setname);
            else
                s = sprintf('%s(GEV=%0.2f)(KL=%0.2f)', ALLEEG(iSubj).setname, GEV, KL);
                
            end
            
            title(s)
            
        end
        
    end
s = sprintf('sub_MS%d_%d_%d.png',nMS, iSubj-5, iSubj );
file_loc = fullfile(Param.QALOCATION, 'QA', s);
print(figure1, file_loc, '-dpng')
close;

end

function [orders]= Order_MS(ALLEEG, iSubj, nMS)

    X = cell2mat({ALLEEG(1).chanlocs.X});
    Y = cell2mat({ALLEEG(1).chanlocs.Y});
    Z = cell2mat({ALLEEG(1).chanlocs.Z});

    ALLDist = nan(nMS);
    for i=1:nMS
        for j=1:nMS

                V_tempalte = squeeze(ALLEEG(1).msinfo.MSMaps(nMS).Maps(i, :));% foirst subject is the template
                V_subj = squeeze(ALLEEG(iSubj).msinfo.MSMaps(nMS).Maps(j, :));% foirst subject is the template;


                [map_temp]=OdspCMap(double(V_tempalte),[X; Y;Z],'NoScale','Resolution',3);


                [map_subj]=OdspCMap(double(V_subj),[X; Y;Z],'NoScale','Resolution',3);

                map_temp = (map_temp-min(map_temp(:))) ./ (max(map_temp(:)-min(map_temp(:))));
                map_subj = (map_subj-min(map_subj(:))) ./ (max(map_subj(:)-min(map_subj(:))));

                Dist =ssim(sum((map_subj(:) - map_temp(:)) .^ 2));
                ALLDist(i,j)= Dist;

            
            
        end
    end
    orders = zeros(nMS, 1);
    c = 1;
    while length(find(orders))<nMS && c<=nMS^2
        %min_dist = max(ALLDist, [], 1, 'omitnan');
        [maxNum, maxIndex] = max(ALLDist(:));
        [row, col] = ind2sub(size(ALLDist), maxIndex);
        if orders(col)==0 && ~ismember(row, orders)% not ordered
            orders(col)=row;
            
        end
        ALLDist(row, col)=NaN;
        %ALLDist(:,ALLDist==val)=NaN;
        c=c+1;
                
    end
    
    % One microstate was not assigned 
    if find(orders==0)
        sprintf('Got problem dude!\n');
    end
    
    
end
