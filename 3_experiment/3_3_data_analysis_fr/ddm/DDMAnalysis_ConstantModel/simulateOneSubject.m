function generatedData = simulateOneSubject(homePath)
    
%% load behavioral data
fid = fopen(fullfile(homePath,'DDMAnalysis','Data_AllSubjects.txt'));
t = textscan(fid,'%s');
t = reshape(t{1},15,length(t{1})/15)';
t = t(2:end, :);

SelfProp = cellfun(@(x)str2num(x),t(:,4));
OtherProp = cellfun(@(x)str2num(x),t(:,5));

% select a random set of 90 trials, in the proportion shown to participants
selected = randperm(length(SelfProp),90);

SelfProp = SelfProp(selected) - 20;
OtherProp = OtherProp(selected) - 20;

% seed random number generator
pause(rand)
rng('shuffle')

% now, select a set of parameters to generate the data
ndt = .5 + .4*rand; % select non-decision time in the interval .5-.9
barrier = .1 + rand*.1; % select threshold in interval .1 to .2
wSelfInit = .025 + .01*randn; % select initial self weight mean .025, s.d. .01;
changeSelf = -.005 - .02*rand; % select reduction in self weight in interval -.005 to -.025;
wSelfFinal = wSelfInit + changeSelf;
wOtherFinal = .008 + .01*randn; % select final other weight mean .008, s.d. .01;
wIneqFinal = .008 + .01*randn; % select final inequality weight in mean .008, s.d. .01;
timeShift = .4*rand; % select time of change in the interval 0 to 400ms

params.barrier = barrier;
params.timeShift = timeShift;
params.nonDec = ndt;
params.nSim = 1;
params.maxRT = 4;

Resp = zeros(1,90);
RT = zeros(1,90);

for t = 1:length(SelfProp)
    params.initDrift = wSelfInit*SelfProp(t); % assume since this is only factor, its weight is somewhat magnified
    params.finalDrift = wSelfFinal*SelfProp(t) + wOtherFinal*OtherProp(t) + wIneqFinal * (-1 * abs(SelfProp(t) - OtherProp(t))/2);
    
    temp = simulDDM_valShiftNormApprox(params);
    Resp(t) = temp.simData.resp;
    RT(t) = temp.simData.rt;
end

Resp(Resp == -1) = 0;

generatedData.SelfProp = SelfProp;
generatedData.OtherProp = OtherProp;
generatedData.Resp = Resp;
generatedData.RT = RT;

generatingParameters.wSelfInit = wSelfInit;
generatingParameters.wSelfFinal = wSelfFinal;
generatingParameters.wOtherFinal = wOtherFinal;
generatingParameters.wIneqFinal = wIneqFinal;
generatingParameters.barrier = barrier;
generatingParameters.ndt = ndt;
generatingParameters.timeShift = timeShift;

generatedData.generatingParameters = generatingParameters;