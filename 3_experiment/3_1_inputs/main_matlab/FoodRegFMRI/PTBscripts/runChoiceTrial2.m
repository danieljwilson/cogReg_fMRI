function TrialData = runChoiceTrial2(Food, Instruction, PTBParams)

% Trial procedure for study FoodReg (fMRI version)
% Trial structure:
%    1. Fixation (1 sec)
%    2. Presentation of proposal, with 4 seconds deliberation
%       to collect response from subject
%    3. Display Choice
%    4. ITI
%
% Author: Cendri Hutcherson
% Date: 02-17-2018

ctr = PTBParams.ctr;
LateResp = 'NULL';
LateRT = NaN;

%========================= 0. Load necessary images ======================%

[FoodPic, FoodSize] = makeTxtrFromImg(fullfile(PTBParams.homepath,'FoodPics',Food),...
    'JPG',PTBParams);

KeyPicPosition = findPicLoc(PTBParams.ChoiceScaleSize,[.5,.85],PTBParams,'ScreenPct',.4);

newSize = abs(KeyPicPosition([1,2]) - KeyPicPosition([3,4]));

%========================= 1. Show fixation cross ========================%

% % Draw fixation screen
% Screen('FillRect',PTBParams.win,PTBParams.black);
% DrawFormattedText(PTBParams.win, '+', 'center', 'center', PTBParams.white);
% FixationOn = Screen(PTBParams.win,'Flip');

%================ 2. Present food and collect response ===============%

Screen('DrawTexture',PTBParams.win,FoodPic,[],findPicLoc(FoodSize,[.5,.4],PTBParams,...
    'ScreenPct',.35));
DrawFormattedText(PTBParams.win, ... Screen
                  Instruction,... Instructional Cue
                  'center',.25*ctr(2),PTBParams.white);
Screen('DrawTexture',PTBParams.win,PTBParams.ChoiceScale,[],KeyPicPosition);
FoodOn = Screen(PTBParams.win,'Flip',[],1);
[Resp, RT] = collectResponse(4,1,PTBParams.numKeys(1:4));
if ~strcmp(Resp,'NULL')
    Resp = str2double(Resp(1));
end

RT = RT - FoodOn;

if ~strcmp(RT,'NaN') && ~isnan(RT)
% draw a red square around chosen option for 300ms
    Screen('FrameRect', PTBParams.win, [255,0,0], ...
           [KeyPicPosition(1) + (.25*(Resp - 1) + .05)*newSize(1), ...
            KeyPicPosition(2), ...
            KeyPicPosition(1) + (.25*Resp - .05) *newSize(1), ...
            KeyPicPosition(2) + .45*newSize(2)],...
            5); % lineWidth
    ChoiceDisplayed = Screen('Flip',PTBParams.win);
end

%==== 3. Show fixation (or reminder participant to respond in 4 secs) ====%

% If participant doesn't respond within 4 seconds, remind them of the
% time limit
if strcmp(RT,'NaN') || isnan(RT)
    Screen(PTBParams.win,'FillRect',[0 0 0]);
    DrawFormattedText(PTBParams.win, '    TOO SLOW!\n\nYOUR CHOICE WILL BE DETERMINED AT RANDOM.', ...
                      'center','center', PTBParams.white);
    ChoiceDisplayed = Screen(PTBParams.win,'Flip');
    [LateResp, LateRT] = collectResponse(.95,0,PTBParams.numKeys(1:4));
    
    PostChoiceFixation = DrawFormattedText(PTBParams.win, '+', 'center','center', PTBParams.white);
    Screen('Flip', PTBParams.win,ChoiceDisplayed + 1,1);   
    LateRT = LateRT - FoodOn;
    if ~strcmp(LateResp,'NULL')
        LateResp = str2double(LateResp(1));
        LateResp = PTBParams.KeyOrder{LateResp}; % recode response by RL orientation
    end
else
    % display fixation after choice
    DrawFormattedText(PTBParams.win, '+', 'center','center', PTBParams.white);
    PostChoiceFixation = Screen('Flip', PTBParams.win,ChoiceDisplayed + .25,1);

    Resp = PTBParams.KeyOrder{Resp}; % recode response by RL orientation
end

%========= 4. Present ITI ==========%

if ~strcmp(RT,'NaN') && ~isnan(RT)
    blankDuration = (4 - RT) + 1;
else
    blankDuration = 0;
end
WaitSecs(blankDuration); 

TrialData.Food = Food;
TrialData.Resp = Resp;
TrialData.ChoiceRT  = RT;
TrialData.LateResp = LateResp;
TrialData.LateRT = LateRT;
TrialData.Instruction = Instruction;
TrialData.FoodOn = FoodOn - PTBParams.StartTime;
TrialData.PostChoiceFixationOn = PostChoiceFixation - PTBParams.StartTime;

Screen('Close',FoodPic);