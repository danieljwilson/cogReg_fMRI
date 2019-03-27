function varargout = determineFood(varargin)
%
% Script for running a single subject through a ratings task, to collect measures of 
% subjective perceptions of health and taste for the self-other
% decision-making task
%
% Author: Cendri Hutcherson
% Last modified: Sept. 26, 2013

% try % for debugging purposes

%% --------------- START NEW DATAFILE FOR CURRENT SESSION --------------- %
studyid = 'FoodRegFMRI'; % change this for every study
homepath = determinePath(studyid);

if isempty(varargin)
    addpath([homepath filesep 'PTBScripts'])
    PTBParams = InitPTB(homepath,'DefaultSession','FoodOutcome');
else
    PTBParams = varargin{1};
    PTBParams.inERP = 0;
    Data.subjid = PTBParams.subjid;
    Data.ssnid = 'FoodOutcome';
    Data.time = datestr(now);
 
    PTBParams.datafile = fullfile(PTBParams.homepath, 'SubjectData', ...
                         num2str(PTBParams.subjid), ['Data.' num2str(PTBParams.subjid) '.' Data.ssnid '.mat']);
    save(PTBParams.datafile, 'Data')
end

%% ----------------------- INITIALIZE VARIABLES ------------------------- %
imgpath = [PTBParams.homepath 'FoodPics/'];
foodPathIndex = regexp(PTBParams.homepath,studyid);
PTBParams.foodPath = imgpath;

% load names of foods
files = dir(fullfile(PTBParams.homepath,'SubjectData',num2str(PTBParams.subjid),...
    ['Data.', num2str(PTBParams.subjid), '.*.mat']));
filenames = {files.name};
isChoiceFile = cellfun(@(x)~isempty(x),regexp(filenames,['Data.', num2str(PTBParams.subjid), '.\d.mat']));
filenames = filenames(isChoiceFile);
Choice = {}; FoodOnTrial = {}; InstructionOnTrial = {};
for session = 1:length(filenames)
    choiceFile = fullfile(PTBParams.homepath,'SubjectData',num2str(PTBParams.subjid),...
        filenames{session});
    tempData = load(choiceFile);
    Choice = [Choice tempData.Data.Resp];
    FoodOnTrial = [FoodOnTrial tempData.Data.Food];
    InstructionOnTrial = [InstructionOnTrial tempData.Data.Instruction];
end

% remove non-responses
missedTrials = strcmp(Choice,'NULL');
Choice = Choice(~missedTrials);
FoodOnTrial = FoodOnTrial(~missedTrials);
InstructionOnTrial = InstructionOnTrial(~missedTrials);

[num, text] = xlsread([PTBParams.homepath(1:end - length(studyid) - 1), 'Food Tracking.xlsx']);
foodnames = text(2:end,1);
foodnames(cellfun(@(x)~ischar(x),foodnames)) = [];

foodquantities = num(:,1);
foodnames(foodquantities == 0) = [];
foodquantities(foodquantities == 0) = [];
availableFoods = {};
for f = 1:length(foodnames)
    for q = 1:foodquantities(f)
        temp = dir(fullfile(PTBParams.homepath(1:end - 9),'AllFoodPics',[foodnames{f} '_'  num2str(q) '_*']));
        availableFoods = [availableFoods {temp.name}];
    end   
end

availableTrials = [];
for i = 1:length(FoodOnTrial)
   if Choice{i} <= 2 % participant said no
       availableTrials = [availableTrials i];
   else
       if ~isempty(intersect(FoodOnTrial(i), availableFoods)) && Choice{i} > 2
           availableTrials = [availableTrials i];
       end
   end
end
trialSelected = availableTrials(ceil(rand(1)*length(availableTrials)));
Food = FoodOnTrial{trialSelected};
Insrx = InstructionOnTrial{trialSelected};
Choice = Choice{trialSelected};

SessionStartTime = GetSecs();
PTBParams.StartTime = SessionStartTime;
trial = 1;
datafile = PTBParams.datafile;
logData(datafile,trial,SessionStartTime);

showInstruction(43,PTBParams,'RequiredKeys',{'RightArrow','right'});
Screen(PTBParams.win,'FillRect',PTBParams.black);
Screen(PTBParams.win,'Flip');
WaitSecs(1);

DrawFormattedText(PTBParams.win,['Trial # selected: ' num2str(trialSelected)],...
    'center',.2*PTBParams.ctr(2),PTBParams.white);


DrawFormattedText(PTBParams.win,['The trial looked like this:'],...
    'center',.35*PTBParams.ctr(2),PTBParams.white);
TrialRevealed = Screen(PTBParams.win,'Flip',[],1);
WaitSecs(1);

% Display proposal
[FoodPic, FoodPicSize] = makeTxtrFromImg(fullfile(PTBParams.foodPath,Food),...
    'JPG',PTBParams);
FoodPicPosition = findPicLoc(FoodPicSize, [.5, .6], PTBParams, 'ScreenPct', .35);
Screen('DrawTexture',PTBParams.win, FoodPic, [], FoodPicPosition);
DrawFormattedText(PTBParams.win,Insrx,...
    'center',.5*PTBParams.ctr(2),PTBParams.white);
TrialRevealed = Screen(PTBParams.win,'Flip',[],1);
ProposalRevealed = Screen(PTBParams.win,'Flip',[],1);
WaitSecs(1);

if Choice > 2
        foodText = 'You responded yes. You must now eat this food.';
else
        foodText = 'You responded no. You will NOT eat any food.';
end

DrawFormattedText(PTBParams.win,[foodText],...
    'center',1.85*PTBParams.ctr(2),PTBParams.white,55,[],[],1.75);

FoodOn = Screen(PTBParams.win,'Flip',TrialRevealed+1,1);

% DrawFormattedText(PTBParams.win,['Please inform the experimenter that you '...
%     'are finished with this portion of the experiment'],'center',PTBParams.ctr(2)*1.65,...
%     PTBParams.white,40,[],[],1.75);
% Screen(PTBParams.win,'Flip',FoodOn+3,1);
collectResponse([],1,'c');
collectResponse([],1,'o');

SessionEndTime = datestr(now);
datafile = PTBParams.datafile;
trial = 1;
logData(datafile,trial,SessionEndTime);
logData(datafile,trial,Food,Insrx,Choice);
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