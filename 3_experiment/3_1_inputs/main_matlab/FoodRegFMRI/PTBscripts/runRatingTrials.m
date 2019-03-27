function runRatingTrials(varargin)
%
% Script for running a single subject through a ratings task, to collect measures of 
% subjective perceptions of health and taste for the food choice
% decision-making task
%
% Author: Cendri Hutcherson
% Last modified: Sept. 26, 2013

% try % for debugging purposes

%% --------------- START NEW DATAFILE FOR CURRENT SESSION --------------- %

studyid = 'FoodRegFMRI'; % change this for every study

if isempty(varargin)
    homepath = determinePath(studyid);
    addpath([homepath filesep 'PTBScripts'])
    PTBParams = InitPTB(homepath,'DefaultSession','AttributeRatings-Post');
else
    PTBParams = varargin{1};
    PTBParams.inERP = 0;
    Data.subjid = PTBParams.subjid;
    Data.ssnid = 'AttributeRatings-Post';
    Data.time = datestr(now);
 
    PTBParams.datafile = fullfile(PTBParams.homepath, 'SubjectData', ...
                         num2str(PTBParams.subjid), ['Data.' num2str(PTBParams.subjid) '.' Data.ssnid '.mat']);
    save(PTBParams.datafile, 'Data')
end

%% ----------------------- INITIALIZE VARIABLES ------------------------- %
imgpath = [PTBParams.homepath 'PTBscripts/'];
PTBParams.foodPath = fullfile(PTBParams.homepath,'FoodPics');
% load names of foods
PTBParams.nFoods = 270;
[num, text] = xlsread(fullfile(PTBParams.homepath, 'FoodsToUse.xlsx'));
foodnames = text(1:end,1);
foodnames(cellfun(@(x)~ischar(x),foodnames)) = [];
foodnames = deblank(foodnames);
PTBParams.FoodNames = foodnames;

SessionStartTime = GetSecs();
trial = 1;
datafile = PTBParams.datafile;
logData(datafile,trial,SessionStartTime);

insrx = 38;
while insrx >=38 && insrx < 40
    if insrx == 38
        showInstruction(insrx,PTBParams,'RequiredKeys',{'RightArrow','right'});
        insrx = insrx + 1;
    else
        Resp = showInstruction(insrx,PTBParams,'RequiredKeys',{'RightArrow','LeftArrow','right','left'});
        if strcmp(Resp,'LeftArrow') || strcmp(Resp,'left')
            insrx = insrx - 1;
        else
            insrx = insrx + 1;
        end
    end
end

[PTBParams.RateKeys, PTBParams.RateKeysSize] = ...
                makeTxtrFromImg([imgpath 'LikingRatingKeys.png'], 'PNG', PTBParams);
trial = 1;
for food = randperm(length(PTBParams.FoodNames))
    TrialData = getFoodRating(food, PTBParams);
    TrialData.Attribute = 'Liking';
    logData(PTBParams.datafile, trial, TrialData)
    trial = trial + 1;
end


ratingOrder = {'Health', 'Taste'};
ratingOrder = ratingOrder(randperm(length(ratingOrder)));

% if mod(PTBParams.subjid,2)
%     KeyOrder = 'RL';
% else
%     KeyOrder = 'LR';
% end
           

for r = 1:length(ratingOrder)
    switch ratingOrder{r}
        case 'Taste'
            insrx = 40;
            % load in pictures of taste rating keys
            [PTBParams.RateKeys, PTBParams.RateKeysSize] = ...
                makeTxtrFromImg([imgpath 'TasteRatingKeys.png'], 'PNG', PTBParams);
            
        case 'Health'
            insrx = 41;
            % load in pictures of health rating keys
            [PTBParams.RateKeys, PTBParams.RateKeysSize] = ...
                makeTxtrFromImg([imgpath 'HealthRatingKeys.png'], 'PNG', PTBParams);
    end
    
    showInstruction(insrx, PTBParams,'RequiredKeys',{'RightArrow','right'});
    
    for food = randperm(length(PTBParams.FoodNames))
        TrialData = getFoodRating(food, PTBParams);
        TrialData.Attribute = ratingOrder{r};
        logData(PTBParams.datafile, trial, TrialData)
        trial = trial + 1;
    end

end

SessionEndTime = datestr(now);
trial = 1;
datafile = PTBParams.datafile;
logData(datafile,trial,SessionEndTime);
    
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