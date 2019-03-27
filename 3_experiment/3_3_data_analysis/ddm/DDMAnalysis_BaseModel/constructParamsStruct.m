function params = constructParamsStruct(inputs)
% function takes a row vector of values and constructs a 'params' structure
% for use with computeLL_NormApprox.m
params.finalTaste = inputs(1);
params.finalHealth = inputs(2);
params.barrier = inputs(3);
params.startPt = inputs(4) * params.barrier;
params.nonDec = inputs(5);
params.timeShift = 0;   

% some defaults
params.initTaste = 0;
params.initHealth = 0;
params.simPrecision = .005;
params.summaryPrecision = .005;
params.maxRT = 4;