function LL = computeLL_NormApprox(params, observedData)

% unpack observedData structure
Resp = observedData.Resp;
RT = observedData.RT;
Taste = observedData.Taste;
Health = observedData.Health;

LLTrial = zeros(length(Resp),1);

initWeights = [params.initTaste params.initHealth];
finalWeights = [params.finalTaste params.finalHealth];

if params.timeShift == 0
    finalDrifts = [Taste Health]*finalWeights';
    initDrifts = finalDrifts; % initial and final are same thing with no shift       
else
    initDrifts = [Taste Health]*initWeights';
    finalDrifts = [Taste Health]*finalWeights';
end

uniqueVals = unique([initDrifts,finalDrifts],'rows');
for t = 1:size(uniqueVals,1)
    params.initDrift = uniqueVals(t,1); % 
    params.finalDrift = uniqueVals(t,2);

    trials = find(initDrifts == uniqueVals(t,1)' & finalDrifts == uniqueVals(t,2)');

    RTs = RT(trials);
    if any(isnan(RTs))
        params.maxRT = 4;
    else
        params.maxRT = max(RTs) + .01;
    end
    temp = simulDDM_valShiftNormApprox(params);

    for s = 1:length(trials)
        switch Resp(trials(s))
            case 0
                LLTrial(trials(s)) = log(temp.pCross1(floor(RT(trials(s)) * 200)) + eps);
            case 1
                LLTrial(trials(s)) = log(temp.pCross2(floor(RT(trials(s)) * 200)) + eps);
            otherwise
                LLTrial(trials(s)) = log(temp.pNonResp + eps);
        end
    end
end

LL = sum(LLTrial);