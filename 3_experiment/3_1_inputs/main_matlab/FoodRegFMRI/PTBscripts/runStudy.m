function runStudy(varargin)
% Project: Regulation study to examine effects of two
% different forms of attentional focus (health focus vs. decrease-wanting
% focus).
%
% Script: Assesses liking ratings of foods, and runs participants through practice
% trials for the study (both basic choice and regulation practice). Assumes
% that all major instructions are delivered on paper.
%
% Author: Cendri Hutcherson
% Date: 02-15-16
%

% make sure PTBParams structure is properly set up
if isempty(varargin) % if script is called from command line   
    studyid = 'FoodRegFMRI';
    pathtofile = mfilename('fullpath');
    homepath = pathtofile(1:(regexp(pathtofile,studyid)+ length(studyid)));
    addpath([homepath filesep 'PTBscripts'])
    PTBParams = InitPTB(homepath,'DefaultSession','Main');
else % if script is called from main script
    PTBParams = varargin{1};
    Data.subjid = PTBParams.subjid;
    Data.ssnid = 'Main';
    Data.time = datestr(now);
    
    save(PTBParams.datafile, 'Data')
end

% specify image path and pre-load necessary images
PTBParams.imgpath = [PTBParams.homepath 'PTBscripts/'];

if mod(PTBParams.subjid, 2)
    LRdrx = 'RL';
else
    LRdrx = 'LR';
end

SessionClockStart = GetSecs();
PTBParams.StartTime = SessionClockStart;
datafile = PTBParams.datafile;
logData(datafile,1,SessionClockStart);

% set program to wait until experimenter presses 'co' (for COntinue)
DrawFormattedText(PTBParams.win,'Please wait...','center','center',PTBParams.white);
Screen(PTBParams.win, 'Flip');
collectResponse([],1,'c');
collectResponse([],1,'o');

%% =======================  ASSESS HUNGER LEVELS =========================%
% intro slide
showInstruction(1,PTBParams,'RequiredKeys',{'RightArrow','right'}); 

% hunger level slide
[HungerLevel,HungerLevelRT] = showInstruction(2,PTBParams, 'RequiredKeys',PTBParams.numKeys(1:9));
HungerLevel = HungerLevel(1);
HungerTime = datestr(now);
logData(datafile,1,HungerLevel,HungerLevelRT,HungerTime);

%% =========== COLLECT PRE-REG LIKING OF ALL FOODS =============%

runLikingRatingTrials(PTBParams);

%% ============== RUN PRACTICE TRIALS FOR CHOICE TASK ====================%
runPracticeForChoice(PTBParams);

%% ============== RUN CHOICE TASK ====================%
for session = 1:9
    PTBParams.ssnid = session;
    runSession(PTBParams);
end

%% ============== ASSESS HUNGER LEVELS ==============%
[HungerLevel,HungerLevelRT] = showInstruction(38,PTBParams, 'RequiredKeys',PTBParams.numKeys(1:9));
HungerTime = datestr(now);
logData(datafile,2,HungerLevel,HungerLevelRT,HungerTime);

%% ==============   GET SECOND ROUND OF ATTRIBUTE RATINGS ================%
runRatingTrials(PTBParams);

%% ================ SELECT RANDOM TRIAL TO COUNT ===================%
determineFood(PTBParams);

SessionEndTime = datestr(now);
logData(datafile,1,SessionEndTime);

if isempty(varargin)
    Screen('CloseAll'); 
    ListenChar(1);
end

% catch ME
%     ME
%     ME.stack.file
%     ME.stack.line
%     ME.stack.name
%     Screen('CloseAll');
%     ListenChar(1);
% end



