function Data = simulDDM_valShiftNormApprox(varargin)
% function simulDDM_normApprox([params])
% Determines the probability of boundary crossing for a DDM process given
% particular parameters, using several approximations to achieve a
% reasonable balance between accuracy and speed of estimation (the irony of
% which tradeoff is deeply appreciated)
% Approximations include:
%  1) a discrete transition probability matrix, in both time and diffusion
%  space (see simPrecision and numSteps variables)
%  2) a discrete/limited updating of transition probabilities under
%  conditions of collapsing barriers
%
% Author: Cendri Hutcherson
% Date: 04/05/2015
%
% Arguments:
% params - a structure with fields that specify core variables of the DDM 
% and levels of precision desired for the approximation. If params is not 
% given, or does not contain a fieldname for a given variable, the default
% value will be used
%
% initDrift: scalar specifying the initial rate of value accumulation
%            default = .08
% finalDrift: scalar specifying the final rate of value accumulation
%            default = .08 (i.e. no change)
% barrier: decision threshold
%          default = .15;
% startPt: bias in starting point
%          default = 0;
% startPtVar: variability in starting point
%          default = 0;
% nonDec: non-decision time (sum of sensory and motor delays, in secs)
%         default = .3;
% maxRT: maximum response time limit (in secs)
%        default = 4 seconds
% s: noise parameter, by convention set to .1 (all other parameter values
%    will scale to this noise term)
% simPrecision: discrete time step (in secs) to estimate state transitions
%               default = .001
% summaryPrecision: time step for reporting probabilities (in secs)
%                   helps if you want to compress variables for storage;                 
%                   default = .001 (no compression)
% numSteps: bin size for estimate diffusion movement (this is the heart of
%           approximation that allows for faster computation)
%
% nSim: variable that determines how many simulated individual choices and
% RTs are generated (default = 0, no simulations)

% Output:
% Data structure with following fields:
% pCross1: prob of a no response in each time-bin (uses summaryPrecision)
% pCross2: prob of a yes response in each time-bin
% pNonResp: probability of no response within given time limit
%
% Author: Cendri Hutcherson
% With thanks to Gabriela Tavares, who wrote a version of the discrete bin 
% estimation in Python, from which this script is adapted


%% ----------------- INITIALIZE PARAMETERS OF MODEL ---------------------%%

% set defaults for inputs to DDM (e.g. integrated value of the option)
initDrift = .08; % value of the option initially
finalDrift = .08; % value of the option after a transition to final value
timeShift = 0; % time at which value begins to transition from initial to final
rateShift = 1000; % speed at which value transitions from initial to final. 1000 is essentially immediately

% set defaults for parameters of DDM
barrier = .15;  % bounds on DDM process (defines -barrier and +barrier)
startPt = 0;
startPtVar = 0;
nonDec = .3; % non-decision time for each attribute
maxRT = 4;
s = .1; % within-trial drift parameter, serving as scaling parameter that by convention is set to .1

% set defaults for estimation
simPrecision = .001; % simulation time precision in seconds
summaryPrecision = simPrecision; % precision for summary - helps to condense for data storage

numSteps = 50; % defines granularity of states

nSim = 0; 
% overwrite defaults for any specified parameters (contained in params
% structure)
if ~isempty(varargin)
    paramNames = fieldnames(varargin{1});
    params = varargin{1};
    
    for i = 1:length(paramNames)
        eval([paramNames{i} '= params.' paramNames{i} ';']);
    end
end

%% -------------- SET UP AND RUN DDM  -------------- %%
nTimeSteps = floor(maxRT/simPrecision);

binLowEdge = [-Inf linspace(-barrier, barrier, numSteps + (mod(numSteps,2) == 1))]; % define bins for each drift state
binHiEdge = [linspace(-barrier, barrier, numSteps + (mod(numSteps,2) == 1)) Inf];
CoMstates = (binLowEdge + binHiEdge)/2; % define the center of each state-bin

% create distance matrices for the low and high end of each bin from each
% bin center
allDiffsLo = repmat(binLowEdge',1,length(CoMstates)) - repmat(CoMstates,length(CoMstates),1);
allDiffsHi = repmat(binHiEdge',1,length(CoMstates)) - repmat(CoMstates,length(CoMstates),1);

pStates = zeros(length(CoMstates),1); % # of states + 2 absorbing states (boundary crosses)
pStates(binLowEdge <= (startPt + startPtVar) & binHiEdge > (startPt - startPtVar)) = ...
    1/sum(binLowEdge <= startPt + startPtVar & binHiEdge > startPt - startPtVar); % start centered at startPt with uniform distribution startPtVar
cumCrossUp = zeros(nTimeSteps,1);
cumCrossDown = zeros(nTimeSteps,1);

% estimate initial transition probabilities
pDiffsLo = normcdf(allDiffsLo,initDrift*simPrecision,s*sqrt(simPrecision));
pDiffsHi = normcdf(allDiffsHi,initDrift*simPrecision,s*sqrt(simPrecision));
pTransit = pDiffsHi - pDiffsLo; % creates transition matrix from state to state
pTransit(isnan(pTransit)) = 1;

absorbingHi = binHiEdge > barrier; % state beyond upper barrier
absorbingLo = binLowEdge < -barrier; % state beyond lower barrier
absorbMat = diag(absorbingLo + absorbingHi);
pTransit(:,absorbingHi | absorbingLo) = absorbMat(:,absorbingHi | absorbingLo);

% estimate final transition probabilities
pDiffsFLo = normcdf(allDiffsLo,finalDrift*simPrecision,s*sqrt(simPrecision));
pDiffsFHi = normcdf(allDiffsHi,finalDrift*simPrecision,s*sqrt(simPrecision));
pTransitF = pDiffsFHi - pDiffsFLo; % creates transition matrix from state to state
pTransitF(isnan(pTransitF)) = 1;

absorbingHi = binHiEdge > barrier; % state beyond upper barrier
absorbingLo = binLowEdge < -barrier; % state beyond lower barrier
absorbMat = diag(absorbingLo + absorbingHi);
pTransit(:,absorbingHi | absorbingLo) = absorbMat(:,absorbingHi | absorbingLo);
pTransitF(:,absorbingHi | absorbingLo) = absorbMat(:,absorbingHi | absorbingLo);

timeStepsNeededToChange = max((abs(initDrift - finalDrift)/(rateShift*simPrecision)),1);
mixingRate = 1/timeStepsNeededToChange;

for t = max(1,floor(nonDec/simPrecision)):nTimeSteps
    % estimate cumulative fraction of DDMs in absorbing states
    cumCrossUp(t) = absorbingHi*pStates;
    cumCrossDown(t) = absorbingLo*pStates;

    if t < timeShift/simPrecision + floor(nonDec/simPrecision)
        pTransitAtT = pTransit;
    else
        timePastShift = t - timeShift/simPrecision - floor(nonDec/simPrecision);
        if timePastShift < timeStepsNeededToChange
            % average two transition matrices proportional to time past
            % value shift
            pTransitAtT = (1 - timePastShift*mixingRate)*pTransit + (timePastShift*mixingRate)*pTransitF;
        else
            % otherwise, use final value
            pTransitAtT = pTransitF;
        end
    end
    
    pStates = pTransitAtT*pStates;
    if(sum(pStates(~absorbingLo & ~absorbingHi)) < .0001) % quit if sufficiently low probability not to have terminated
        break;
    end
end

cumCrossUp(t+1:end) = cumCrossUp(t);
cumCrossDown(t+1:end) = cumCrossDown(t);
pCross1 = [0;diff(cumCrossDown)];
pCross2 = [0;diff(cumCrossUp)];

pNonResp = 1 - sum(pCross1) - sum(pCross2);

% simulate nSim individual choices and RTs, if requested
if nSim > 0

    temp = rand(nSim,1);
    resp = zeros(nSim,1);
    rt = NaN*zeros(nSim,1);
    resp(temp <= sum(pCross1)) = -1;
    resp(temp > sum(pCross1)) = 1;
    resp(temp > (1 - pNonResp)) = NaN;

    pRTNo = cumsum(pCross1);
    pRTYes = cumsum(pCross2) + sum(pCross1);
    for j = 1:nSim
        if ~isnan(resp(j))
            if resp(j) == -1
                rt(j) = find(pRTNo > temp(j),1)/1000;
            else
                rt(j) = find(pRTYes > temp(j),1)/1000;
            end
        end

    end
    Data.simData.resp = resp;
    Data.simData.rt = rt;
end

condenseFactor = summaryPrecision/simPrecision;
if condenseFactor > 1
    pCross1 = reshape(pCross1,condenseFactor,length(pCross1)/condenseFactor);
    pCross1 = sum(pCross1,1);
    pCross2 = reshape(pCross2,condenseFactor,length(pCross2)/condenseFactor);
    pCross2 = sum(pCross2,1);
end

if condenseFactor < 1
    simTP = simPrecision:simPrecision:min(maxRT, length(pCross1)*simPrecision);
    summaryTP = summaryPrecision:summaryPrecision:min(maxRT, length(pCross1)*simPrecision);
    temp = interp1(simTP, pCross1, summaryTP, 'linear','extrap');
    pCross1 = temp/(sum(temp)/sum(pCross1));
    temp = interp1(simTP, pCross2, summaryTP, 'linear','extrap');
    pCross2 = temp/(sum(temp)/sum(pCross2));
end

Data.pCross1 = pCross1;
Data.pCross2 = pCross2;
Data.pNonResp = 1 - sum(Data.pCross1) - sum(Data.pCross2);

if isinf(maxRT) % if no time limit, summarize up to max simulated RT
    nSummaryBins = length(Data.pCross1)/summaryPrecision;
else % otherwise summarize up to stipulated time limit
    nSummaryBins = maxRT/summaryPrecision; 
end

summaryBins = linspace(summaryPrecision, maxRT, nSummaryBins);
Data.summaryBins = summaryBins - summaryPrecision/2;