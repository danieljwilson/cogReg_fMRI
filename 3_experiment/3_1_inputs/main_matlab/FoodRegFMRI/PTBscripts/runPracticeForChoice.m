function varargout = runPracticeForChoice(varargin)
%
% Script for running a single subject through instructions for the choice
% task, as well as practice trials
%
% Author: Cendri Hutcherson
% Last modified: Feb 15, 2016

% try % for debugging purposes

%% --------------- START NEW DATAFILE FOR CURRENT SESSION --------------- %
studyid = 'FoodRegFMRI'; % change this for every study
if isempty(varargin)
    homepath = determinePath(studyid);
    addpath([homepath filesep 'PTBScripts'])

    PTBParams = InitPTB(homepath,'DefaultSession','Practice');
else
    PTBParams = varargin{1};
    PTBParams.inERP = 0;
    Data.subjid = PTBParams.subjid;
    Data.ssnid = 'Practice';
    Data.time = datestr(now);
 
    PTBParams.datafile = fullfile(PTBParams.homepath, 'SubjectData', ...
                         num2str(PTBParams.subjid), ['Data.' num2str(PTBParams.subjid) '.' Data.ssnid '.mat']);
    save(PTBParams.datafile, 'Data')
end

datafile = PTBParams.datafile;

PTBParams.StartTime = GetSecs();

%% ----------------------- INITIALIZE VARIABLES ------------------------- %  
SessionStartTime = GetSecs();
logData(datafile,1,SessionStartTime);
PTBParams.imgpath = fullfile(PTBParams.homepath,'PTBScripts');

if mod(PTBParams.subjid, 2) % counterbalance left-right orientation of choice
    LRdrx = 'RL';
    PTBParams.RLOrder = 0;
else
    LRdrx = 'LR';
    PTBParams.RLOrder = 1;
end

[PTBParams.ChoiceScale, PTBParams.ChoiceScaleSize] = ...
    makeTxtrFromImg([PTBParams.imgpath '/ChoiceScale' LRdrx '.png'], 'PNG', PTBParams);

[PTBParams.NatInsrx, PTBParams.NatPicSize] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'NatInsrx.png'), 'PNG', PTBParams);

[PTBParams.RegInsrx1, PTBParams.RegPicSize1] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'HealthInsrx.jpg'), 'JPG', PTBParams); % format is JPG for stupid reasons related to PPT. Stupid PPT!

[PTBParams.RegInsrx2, PTBParams.RegPicSize2] = ...
    makeTxtrFromImg(fullfile(PTBParams.imgpath, 'DecreaseInsrx.png'), 'PNG', PTBParams);

%% show Instructions
insrx = 7;
while insrx >= 7 && insrx <= 13
    switch insrx
        case 7
            % If this is the first instruction slide, participants can only
            % go forward (right arrow)
            showInstruction(insrx,PTBParams,'RequiredKeys',{'RightArrow','right'});
            insrx = insrx + 1;
        case 8
           % If this is the pre key instruction slide, determine whether to
           % show the slide with right-left or left-right ordering of the
           % response keys
           Resp = showInstruction(insrx,PTBParams,'RequiredKeys',...
            {'RightArrow','LeftArrow','right','left'});
            if isequal(Resp,'LeftArrow') || isequal(Resp,'left')
                % If left arrow, go back one slide
                insrx = insrx - 1;
            else
                if mod(PTBParams.subjid, 2)
                    insrx = insrx + 2;
                else
                    insrx = insrx + 1;
                end
            end
        case 9
            Resp = showInstruction(insrx,PTBParams,'RequiredKeys',...
            {'RightArrow','LeftArrow','right','left'});
            if isequal(Resp,'LeftArrow') || isequal(Resp,'left')
                % If left arrow, go back one slide
                insrx = insrx - 1;
            else
                % Skip slide 10 (the slide showing other order
                insrx = insrx + 2;
            end
        case 10
            Resp = showInstruction(insrx,PTBParams,'RequiredKeys',...
            {'RightArrow','LeftArrow','right','left'});
            if isequal(Resp,'LeftArrow') || isequal(Resp,'left')
                % If left arrow, go back two slides (skipping the slide
                % showing the other order)
                insrx = insrx - 2;
            else
                insrx = insrx + 1;
            end  
        otherwise
        % Allow participants to go either forward by pressing the right
        % arrow or backwards by pressing the left arrow, advance or
        % decrement the slide by 1
        Resp = showInstruction(insrx,PTBParams,'RequiredKeys',...
            {'RightArrow','LeftArrow','right','left'});
        if isequal(Resp,'LeftArrow') || isequal(Resp,'left')
            insrx = insrx - 1;
        else
            insrx = insrx + 1;
        end
    end
end

% Run 4 trials of the natural focus instructional condition with these 
% practice foods
foodPathIndex = regexp(PTBParams.homepath,studyid);
PTBParams.foodPath = fullfile(PTBParams.homepath(1:foodPathIndex - 1),'AllFoodPics');

% load names of foods
PTBParams.PracticeFoodNames = {'WetBeanCurd_3_8pc.jpg','Tostitos_4_15chips.jpg','TeddyGrahams_4_80cookies.jpg',...
         'Spam_5_5spoons.jpg'};

for trial = randperm(4) 
    TrialData = runChoiceTrial2(PTBParams.PracticeFoodNames{trial},'', PTBParams);
end


while insrx >= 14 && insrx <= 23
    switch insrx
        case 14
            showInstruction(insrx,PTBParams,'RequiredKeys',{'RightArrow','right'});
            insrx = insrx + 1;
        otherwise
            Resp = showInstruction(insrx,PTBParams,'RequiredKeys',{'RightArrow','LeftArrow','right','left'});
            if strcmp(Resp,'LeftArrow') || isequal(Resp,'left')
                insrx = insrx - 1;
            else
                insrx = insrx + 1;
            end
    end
end


% %======================   RUN COMPREHENSION QUIZ   =======================%

CorrectAnswers = [2, 3, 1, 3];

for q = 1:length(CorrectAnswers)
    QuizResp = showInstruction(insrx, PTBParams, 'RequiredKeys',PTBParams.numKeys(1:3));
    QuizResp = QuizResp(1);
    logData(datafile, q, QuizResp)
    
    CorrectResponse = str2num(QuizResp) == CorrectAnswers(q);
    fprintf('Question %d: %d\n',q,CorrectResponse)
    
    if CorrectResponse
        showInstruction(insrx + 1, PTBParams,'RequiredKeys',{'RightArrow','right'});
    else
        showInstruction(insrx + 2, PTBParams,'RequiredKeys',{'RightArrow','right'});
    end
    
    logData(datafile, q, CorrectResponse);
    
    insrx = insrx + 3;
end

showInstruction(insrx, PTBParams,'RequiredKeys',{'RightArrow','right'});


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