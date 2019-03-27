function varargout = runChoiceTask(varargin)
%
% Script for running a single subject through a ratings task, to collect measures of 
% subjective perceptions of health and taste for the self-other
% decision-making task
%
% Author: Cendri Hutcherson
% Last modified: Sept. 26, 2013

% try % for debugging purposes

%% --------------- START NEW DATAFILE FOR CURRENT SESSION --------------- %
    studyid = 'FoodReg3'; % change this for every study
    homepath = determinePath(studyid);
if isempty(varargin)
    addpath([homepath filesep 'PTBScripts'])
    PTBParams = InitPTB(homepath,'DefaultSession','ChoiceTask');
else
    PTBParams = varargin{1};
    PTBParams.inERP = 0;
    Data.subjid = PTBParams.subjid;
    Data.ssnid = 'ChoiceTask';
    Data.time = datestr(now);
 
    PTBParams.datafile = fullfile(PTBParams.homepath, 'SubjectData', ...
                         num2str(PTBParams.subjid), ['Data.' num2str(PTBParams.subjid) '.' Data.ssnid '.mat']);
    save(PTBParams.datafile, 'Data')
end

%% ----------------------- INITIALIZE VARIABLES ------------------------- %
PTBParams.imgpath = fullfile(PTBParams.homepath,'PTBScripts');
foodPathIndex = regexp(PTBParams.homepath,studyid);
PTBParams.foodPath = fullfile(PTBParams.homepath(1:foodPathIndex - 1),'AllFoodPics');

[PTBParams.StartButton, PTBParams.StartButtonSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'StartButton.png'), 'PNG', PTBParams);
[PTBParams.StartButtonHighlighted, PTBParams.StartButtonSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'StartButton_highlighted.png'), 'PNG', PTBParams);
[PTBParams.YesButton, PTBParams.YesButtonSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'YesButton.png'), 'PNG', PTBParams);
[PTBParams.YesButtonHighlighted, PTBParams.YesButtonHighlightedSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'YesButton_highlighted.png'), 'PNG', PTBParams);
[PTBParams.NoButton, PTBParams.NoButtonSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'NoButton.png'), 'PNG', PTBParams);
[PTBParams.NoButtonHighlighted, PTBParams.NoButtonHighlightedSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'NoButton_highlighted.png'), 'PNG', PTBParams);
[PTBParams.AgreeKeys, PTBParams.AgreeKeysSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'AgreeKeys.jpeg'), 'JPG', PTBParams);

if mod(PTBParams.subjid,6) < 3
    PTBParams.RLOrder = 0;
else
    PTBParams.RLOrder = 1;
end

[PTBParams.NatInsrx, PTBParams.NatPicSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'NatInsrx.png'), 'PNG', PTBParams);

[PTBParams.RegInsrx1, PTBParams.RegPicSize1] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'HealthInsrx.jpg'), 'JPG', PTBParams); % format is JPG for stupid reasons related to PPT. Stupid PPT!

[PTBParams.RegInsrx2, PTBParams.RegPicSize2] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'DecreaseInsrx.png'), 'PNG', PTBParams);


subjRatingFile = fullfile(PTBParams.homepath,'SubjectData',num2str(PTBParams.subjid),...
        ['Data.', num2str(PTBParams.subjid), '.LikingRatings-Pre.mat']);
if exist(subjRatingFile,'file')
    RateData = load(subjRatingFile);
    RateData = RateData.Data;
    
    RateData.Resp = cell2mat(RateData.Resp);
    
    for i = 1:length(RateData.Food)
        FoodStem{i} = RateData.Food{i}(1:(regexp(RateData.Food{i},'_','once') - 1));
    end
    
    uniqueFoods = unique(FoodStem);
    aveRating = zeros(length(uniqueFoods),1);
    for f = 1:length(uniqueFoods)
        aveRating(f) = mean(RateData.Resp(searchcell(RateData.Food,uniqueFoods{f},'contains')));
    end
    % assign foods to 3 groups of roughly equally liked foods
    [sortedResp indexResp] = sort(aveRating);
    uniqueFoods = uniqueFoods(indexResp);
else
    [num, text] = xlsread(fullfile(PTBParams.homepath, 'FoodsToUse.xlsx'));
    foodnames = text(1:end,1);
    foodnames(cellfun(@(x)~ischar(x),foodnames)) = [];
    foodnames = deblank(foodnames);
    FoodOrder = foodnames(randperm(length(foodnames)));
    RateData.Food = FoodOrder;
    for i = 1:length(foodnames)
        FoodStem{i} = foodnames{i}(1:(regexp(foodnames{i},'_','once') - 1));
    end
    
    uniqueFoods = unique(FoodStem);
    uniqueFoods = randperm(uniqueFoods);
end

RegForFood = [];
for block = 1:floor(length(indexResp)/3)
    RegForFood = [RegForFood, randperm(3)];
end
FoodOrderNat = [];
FoodOrderReg1 = [];
FoodOrderReg2 = [];
for i = 1:length(RegForFood)
    switch RegForFood(i)
        case 1
            FoodOrderNat = [FoodOrderNat RateData.Food(searchcell(RateData.Food,uniqueFoods{i},'contains'))];
        case 2
            FoodOrderReg1 = [FoodOrderReg1 RateData.Food(searchcell(RateData.Food,uniqueFoods{i},'contains'))];
        otherwise
            FoodOrderReg2 = [FoodOrderReg2 RateData.Food(searchcell(RateData.Food,uniqueFoods{i},'contains'))];
    end
end

FoodOrderNat = FoodOrderNat(1:70);
FoodOrderReg1 = FoodOrderReg1(1:70);
FoodOrderReg2 = FoodOrderReg2(1:70);

FoodOrderNat = FoodOrderNat(randperm(length(FoodOrderNat)));
FoodOrderReg1 = FoodOrderReg1(randperm(length(FoodOrderReg1)));
FoodOrderReg2 = FoodOrderReg2(randperm(length(FoodOrderReg2)));

SessionStartTime = GetSecs();
datafile = PTBParams.datafile;
logData(datafile,1,SessionStartTime);

% determine pseudorandom order of blocks (no more than 2 reps of any given
% block type)
BlockOrder = [];
for block = 1:7
    BlockOrder = [BlockOrder, randperm(3)];
end

datafile = PTBParams.datafile;
logData(datafile,1,FoodOrderNat,FoodOrderReg1, FoodOrderReg2, BlockOrder);

trial = 0;
for block = 1:length(BlockOrder) %
    switch BlockOrder(block) 
        case 1
            InsrxPic = PTBParams.NatInsrx;
            InsrxSize = PTBParams.NatPicSize;
            Food = FoodOrderNat(1:10);
            FoodOrderNat(1:10) = [];
            Insrx = 'Respond Naturally';
        case 2
            InsrxPic = PTBParams.RegInsrx1;
            InsrxSize = PTBParams.RegPicSize1;
            Food = FoodOrderReg1(1:10);
            FoodOrderReg1(1:10) = [];
            Insrx = 'Focus on Healthiness';
        otherwise
            InsrxPic = PTBParams.RegInsrx2;
            InsrxSize = PTBParams.RegPicSize2;
            Food = FoodOrderReg2(1:10);
            FoodOrderReg2(1:10) = [];
            Insrx = 'Decrease Desire';
    end
    
    Screen('DrawTexture',PTBParams.win,InsrxPic,[],...
        findPicLoc(InsrxSize,[.5,.5],PTBParams,'ScreenPct',1));
    Screen('Flip',PTBParams.win);
    WaitSecs(5);
    
    % select two trials to assess want-to and have-to motivation
    whtrials = randperm(10);
    whtrials = whtrials(1:2);
    
    for t = 1:10
        trial = trial + 1;   
        if any(t == whtrials)
            showRegRatings = 1;
        else
            showRegRatings = 0;
        end
        TrialData = runChoiceTrial(Food{t},Insrx,PTBParams,showRegRatings);
        logData(PTBParams.datafile,trial,TrialData);
    end
    
    % give participants a break every 40 trials
    if mod(block,4) == 0 && block < 20
        DrawFormattedText(PTBParams.win,['You may now take a break.\n'...
            'Whenever you are ready to continue, press any key.'], 'center',...
            'center',PTBParams.white,40);
        Screen('Flip',PTBParams.win);
        collectResponse;
    end
    
end

SessionEndTime = datestr(now);
logData(datafile,1,SessionEndTime);

% show end-screen
% showInstruction(36,PTBParams);
    
% catch ME
%     ME
%     ME.stack.file
%     ME.stack.line
%     ME.stack.name
%     Screen('CloseAll');
%     ListenChar(1);
% end



%% ------------------------  CLEAN-UP AND END  -------------------------- %

if isempty(varargin)
    close all; Screen('CloseAll'); ListenChar(1);
end

%-------------------------------------------------------------------------%

%=========================================================================%
%                   FUNCTIONS CALLED BY MAIN SCRIPT                       %
%=========================================================================%

function path = determinePath(studyid)
	% determines path name, to enable some platform independence
	pathtofile = mfilename('fullpath');

	path = pathtofile(1:(regexp(pathtofile,studyid)+ length(studyid)));