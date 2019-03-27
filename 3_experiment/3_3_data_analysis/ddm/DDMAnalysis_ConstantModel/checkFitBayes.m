cond = input('Which condition? (nat, health, desire): ','s');

files = dir(['fittedData/fittedResults*' cond '.mat']);

subjIDs = {};
for f = 1:length(files)
    if ~isempty(regexp(files(f).name,'.mat'))
        tok = regexp(files(f).name,'(\d{1,3})', 'tokens');
        subjIDs = [subjIDs tok{1}];
    end
end
length(subjIDs)
allEstimated = zeros(1,6);
allEstimatedMedian = zeros(1,6);
allEstimatedMode = zeros(1,6);

clear p_*

for fNum = 1:length(subjIDs)
    fprintf('%s\t',subjIDs{fNum});
    if mod(fNum,10) == 0
        fprintf('\n');
    end
    load(['fittedData/fittedResults_' subjIDs{fNum} '_' cond '.mat'])
    
    ObservedData(fNum) = Subject_data;


    %% Extract chain data and compute the mean parameter set
    burnin=500;
    np    = size(Chain_data.param_chain,2); % # params
    
    for i = 1:np
        ptemp=Chain_data.param_chain(burnin:end,i,:);
        ptemp=ptemp(:);
        ptemp_mean=nanmean(ptemp);
        ptemp_median=nanmedian(ptemp);
        
        [KD, KDvalues] = getKernelDensity(ptemp,.05);
        ptemp_mode = KDvalues(KD == max(KD));
        eval(['p_mean(' num2str(i) ')=ptemp_mean;'])
        eval(['p_median(' num2str(i) ')=ptemp_median;'])
        eval(['p_mode(' num2str(i) ')=ptemp_mode;'])
        clear ptemp_mean ptemp  
    end


    allEstimated(fNum,:) = p_mean;
    allEstimatedMedian(fNum,:) = p_median;
    allEstimatedMode(fNum,:) = p_mode;
    
    if ~exist(['fittedData/sim_of_fittedResults_' subjIDs{fNum} '_' cond '.mat'],'file')
        % simulate choices and RTs
        weights = allEstimated(fNum,1:2);
        allVals = weights*[Subject_data.Taste'; Subject_data.Health'] + allEstimated(fNum,6);

        params.barrier = allEstimated(fNum,3);
        params.startPt = allEstimated(fNum,4)*allEstimated(fNum,3);
        params.nonDec = allEstimated(fNum,5);
        params.simPrecision = .001;
        params.nSim = 1000;

        SimData(fNum).Resp = zeros(1000,length(allVals));
        SimData(fNum).RT = zeros(1000,length(allVals));
        SimData(fNum).Taste = Subject_data.Taste;
        SimData(fNum).Health = Subject_data.Health;

        for t = 1:length(allVals)
            params.finalDrift = allVals(t);
            tempSimData = simulDDM_valShiftNormApprox(params);
            NonResp = isnan(tempSimData.simData.resp);
            tempSimData.simData.resp = +(tempSimData.simData.resp > 0);
            tempSimData.simData.resp(NonResp) = NaN;

            SimData(fNum).Resp(:,t) = tempSimData.simData.resp;
            SimData(fNum).RT(:,t) = tempSimData.simData.rt;
        end
        
        SimulatedResponses = SimData(fNum);
        save(['fittedData/sim_of_fittedResults_' subjIDs{fNum} '_' cond '.mat'],'SimulatedResponses')
    else
        load(['fittedData/sim_of_fittedResults_' subjIDs{fNum} '_' cond '.mat'])
        SimData(fNum) = SimulatedResponses;
    end
    Compare.AcceptanceRate(fNum) = nanmean(Subject_data.Resp);
    Compare.AcceptanceRate_Sim(fNum) = nanmean(SimData(fNum).Resp(:));
    
    Compare.RT(fNum) = nanmean(Subject_data.RT);
    Compare.RT_Sim(fNum) = nanmean(SimData(fNum).RT(:));
    
    Compare.NonResps(fNum) = mean(isnan(Subject_data.Resp));
%     Compare.PercHealthy(fNum) = nanmean(Subject_data.Resp);
%     Compare.PercHealth_Sim(fNum) = nanmean(SimData(fNum).Resp(:));
    
end

eval(['allEstimated' cond '= allEstimated;'])
eval(['allEstimatedMedian' cond '= allEstimatedMedian;'])
eval(['allEstimatedMode' cond '= allEstimatedMode;'])
eval(['Compare' cond '= Compare;'])

% exclude = allEstimated(:,7) > 1;
% allEstimated = allEstimated(~exclude,:);
% allEstimatedMedian = allEstimatedMedian(~exclude,:);
% allEstimatedMode = allEstimatedMode(~exclude,:);



figure('Position', [100,100,900,700],'Name','Model vs. Subject Prob of Acceptance')
obsResp = zeros(length(subjIDs),10);
simResp = zeros(length(subjIDs),10);
AvePredErrorChoice = zeros(length(subjIDs),1);
AveCorrChoice = NaN*zeros(length(subjIDs),1);
for s = 1:length(subjIDs)
    temp = SimData(s);
    tempObs = ObservedData(s);
    if ~isempty(temp) && ~all(isnan(temp.Resp(:)))
        meanRespPerTrial = nanmean(temp.Resp,1);

        binEdges = prctile(meanRespPerTrial,0:10:100);
        [h,whichBin] = histc(meanRespPerTrial, binEdges);


        for b = 1:10
            obsResp(s,b) = nanmean(tempObs.Resp(whichBin == b));
            simResp(s,b) = nanmean(meanRespPerTrial(whichBin==b));
        end
        f = subplot(7,8,s);
        hold on;
        scatter(simResp(s,:),obsResp(s,:),20,'fill')
        AvePredErrorChoice(s) = nanmean(simResp(s,:) - obsResp(s,:));
        missingPts = isnan(obsResp(s,:));
        temp = corrcoef(simResp(s,~missingPts),obsResp(s,~missingPts));
        AveCorrChoice(s) = temp(2);

        set(f,'XLimMode','manual','YlimMode','manual')
        plot(get(f,'XLim'),get(f,'XLim'),'--')
        hold off;
    end
end

figure('Position', [100,100,900,700],'Name','Model vs. Subject Prob of Acceptance - 10 %ile')
obsResp2 = zeros(length(subjIDs),10);
simResp2 = zeros(length(subjIDs),10);
AvePredErrorChoice = zeros(length(subjIDs),1);
AveCorrChoice = NaN*zeros(length(subjIDs),1);
for s = 1:length(subjIDs)
    temp = SimData(s);
    tempObs = ObservedData(s);
    if ~isempty(temp) && ~all(isnan(temp.Resp(:)))
        meanRespPerTrial = nanmean(temp.Resp,1);

        binEdges = 0:.1:1;
        [h,whichBin] = histc(meanRespPerTrial, binEdges);


        for b = 1:10
            obsResp2(s,b) = nanmean(tempObs.Resp(whichBin == b));
            simResp2(s,b) = nanmean(meanRespPerTrial(whichBin==b));
        end
        f = subplot(7,8,s);
        hold on;
        scatter(simResp2(s,:),obsResp2(s,:),20,'fill')
        AvePredErrorChoice(s) = nanmean(simResp2(s,:) - obsResp2(s,:));
        missingPts = isnan(obsResp2(s,:));
        temp = corrcoef(simResp2(s,~missingPts),obsResp2(s,~missingPts));
%         AveCorrChoice(s) = temp(2);

        set(f,'XLimMode','manual','YlimMode','manual')
        plot(get(f,'XLim'),get(f,'XLim'),'--')
        hold off;
    end
end

figure('Position', [100,100,900,700],'Name','Model vs. Subject RT')
obsRT = zeros(length(subjIDs),10);
simRT = zeros(length(subjIDs),10);
AveCorrRT = NaN*zeros(length(subjIDs),1);
for s = 1:length(subjIDs)
    temp = SimData(s);
    tempObs = ObservedData(s);
    if ~isempty(temp) && ~all(isnan(temp.Resp(:)))
        meanRTPerTrial = nanmean(temp.RT,1);

        binEdges = prctile(meanRTPerTrial,0:10:100);
        [h,whichBin] = histc(meanRTPerTrial, binEdges);


        for b = 1:10
            obsRT(s,b) = nanmean(tempObs.RT(whichBin == b));
            simRT(s,b) = nanmean(meanRTPerTrial(whichBin==b));
        end
        f = subplot(7,8,s);
        hold on;
        scatter(simRT(s,:),obsRT(s,:),20,'fill')
        missingPts = isnan(obsRT(s,:));
        temp = corrcoef(simRT(s,~missingPts),obsRT(s,~missingPts));
        AveCorrRT(s) = temp(2);

%         set(f,'XLimMode','manual','YlimMode','manual')
        plot(get(f,'XLim'),get(f,'XLim'),'--')
        hold off;
    end
end

% obsResp3 = zeros(length(subjIDs),6);
% simResp3 = zeros(length(subjIDs),6);
% for s = 1:length(subjIDs)
%     temp = SimData(s);
%     tempObs = ObservedData(s);
%     if ~isempty(temp)
%         meanRespPerTrial = nanmean(temp.Resp,1);
% 
%         binEdges = prctile(meanRTPerTrial,0:10:100);
%         [h,whichBin] = histc(meanRTPerTrial, binEdges);
% 
% 
%         for b = 1:10
%             obsRT(s,b) = nanmean(tempObs.RT(whichBin == b));
%             simRT(s,b) = nanmean(meanRTPerTrial(whichBin==b));
%         end
%         f = subplot(7,8,s);
%         hold on;
%         scatter(simRT(s,:),obsRT(s,:),20,'fill')
%         missingPts = isnan(obsRT(s,:));
%         temp = corrcoef(simRT(s,~missingPts),obsRT(s,~missingPts));
%         AveCorrRT(s) = temp(2);
% 
% %         set(f,'XLimMode','manual','YlimMode','manual')
%         plot(get(f,'XLim'),get(f,'XLim'),'--')
%         hold off;
%     end
% end

f = figure('Name','Ave Acceptance Rate');
scatter(Compare.AcceptanceRate,Compare.AcceptanceRate_Sim)
hold on;
% set(get(f,'CurrentAxes'),'XLimMode','manual','YlimMode','manual')
line(get(get(f,'CurrentAxes'),'XLim'),get(get(f,'CurrentAxes'),'XLim'),'LineStyle','--')

f = figure('Name','Ave RT');
scatter(Compare.RT,Compare.RT_Sim)
hold on;
% set(get(f,'CurrentAxes'),'XLimMode','manual','YlimMode','manual')
line(get(get(f,'CurrentAxes'),'XLim'),get(get(f,'CurrentAxes'),'XLim'),'LineStyle','--')

f = figure('Name','Average Model vs. Subject Acceptance Prob');
scatter(nanmean(simResp,1),nanmean(obsResp,1),'fill')
hold on
errorbar(nanmean(simResp,1),nanmean(obsResp,1),nanstd(obsResp,1)/sqrt(length(subjIDs)),'.')
%set(get(f,'CurrentAxes'),'XLimMode','manual','YlimMode','manual')
line(get(get(f,'CurrentAxes'),'XLim'),get(get(f,'CurrentAxes'),'XLim'),'LineStyle','--')

f = figure('Name','Average Model vs. Subject Acceptance Prob 10 %ile');
scatter(nanmean(simResp2,1),nanmean(obsResp2,1),'fill')
hold on
errorbar(nanmean(simResp2,1),nanmean(obsResp2,1),nanstd(obsResp2,1)/sqrt(length(subjIDs)),'.')
%set(get(f,'CurrentAxes'),'XLimMode','manual','YlimMode','manual')
line(get(get(f,'CurrentAxes'),'XLim'),get(get(f,'CurrentAxes'),'XLim'),'LineStyle','--')


f = figure('Name','Average Model vs. Subject RT');
scatter(nanmean(simRT,1),nanmean(obsRT,1),'fill')
hold on
errorbar(nanmean(simRT,1),nanmean(obsRT,1),nanstd(obsRT,1)/sqrt(length(subjIDs)),'.')
% set(get(f,'CurrentAxes'),'XLimMode','manual','YlimMode','manual')
line(get(get(f,'CurrentAxes'),'XLim'),get(get(f,'CurrentAxes'),'XLim'),'LineStyle','--')
