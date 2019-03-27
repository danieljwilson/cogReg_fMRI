function PTBParams = InitPTB(homepath,varargin)
% function [subjid ssnid datafile PTBParams] = InitPTB(homepath,['DefaultSession',ssnid])
% 
% Function for initializing parameters at the beginning of a session
%
% homepath: Path name to scripts directory for the study
%
% Author: Cendri Hutcherson
% Last Modified: 2-16-2016

%% housecleaning before the guests arrive
cd(homepath);
close all; Screen('CloseAll'); 
homepath = [pwd '/'];

%% Get Subject Info 
% Check to make sure aren't about to overwrite duplicate session!
checksubjid = 1;
while checksubjid == 1
    subjid      = input('Subject number:  ', 's');
    ssnid       = input('Session number:  ', 's');
    
    % Set defaults for subject number and session
    if isempty(subjid)
        subjid = '999';
    end
    
    if isempty(ssnid)
        if isempty(varargin) || ~any(strcmp(varargin,'DefaultSession'))
            ssnid = '1';
        else
            ind = find(strcmp(varargin,'DefaultSession'));
            ssnid = varargin{ind + 1};
        end
    end
    fprintf('\nSaving datafile as Data.%s.%s.mat\n\n',subjid,ssnid)

    if exist([homepath 'SubjectData/' subjid '/Data.' subjid '.' ssnid '.mat'],'file') == 2
        cont = input('WARNING: Datafile already exists!  Overwrite? (y/n)  ','s');
        if cont == 'y'
            checksubjid = 0;
        else
            checksubjid = 1;
        end
    else
        checksubjid = 0;
    end
end 

% create name of datafile where data will be stored    
if ~exist([homepath 'SubjectData/' subjid],'dir')
    mkdir([homepath 'SubjectData/' subjid]);
end


Data.subjid = subjid;
Data.ssnid = ssnid;
Data.time = datestr(now);

datafile = fullfile(homepath, 'SubjectData', subjid, ['Data.' subjid '.' ssnid '.mat']);
save(datafile,'Data');

%% Initialize parameters for fMRI
inMRI = input('Run the study using MRI? 0 = no, 1 = yes (default): ');
if isempty(inMRI)
    inMRI = 1;
end
PTBParams.inMRI = inMRI;

% get TR duration
if inMRI
    PTBParams.TR = input('Length of TR (in secs, default = 2): ');
else
    PTBParams.TR = 2;
end

if isempty(PTBParams.TR) % sets default TR
    PTBParams.TR = 2;
end


%% Initialize parameters for EEG if necessary

inERP = input('Run the study using EEG? 0 = no (default), 1 = yes: ');

if isempty(inERP)
    inERP = 0; 
end

PTBParams.inERP = inERP;
PTBParams.KbDevice = -1;

if inERP
%---- INITIALIZE DAQ -----
    err=DaqDConfigPort(daq(1),0,0); % configuring digital port A for output
    err=DaqDConfigPort(daq(1),1,0); % configuring digital port B for output
    stat{1}=bin2dec('00000000'); % default - I60
    
    % EEG triggers
    stat{2}=bin2dec('00000001'); % I61  -
    stat{3}=bin2dec('00000010'); % I62  -
    stat{4}=bin2dec('00000011'); % I63  -
    stat{5}=bin2dec('00000100'); % I64  -
    stat{6}=bin2dec('00000101'); % I65  - flag
    stat{7}=bin2dec('00000110'); % I66  - flag
    stat{8}=bin2dec('00000111'); % I67  - flag
    stat{9}=bin2dec('00001000'); % I68  - BREAK
    stat{10}=bin2dec('00001001');% I69  -
    stat{11}=bin2dec('00001010');% I70  -
    stat{12}=bin2dec('00001011');% I71  -
    stat{13}=bin2dec('00001100');% I72  -
    stat{14}=bin2dec('00001101');% I73  -
    stat{16}=bin2dec('00001111');% I75  -
    stat{17}=bin2dec('00010000');% I76  -
    stat{18}=bin2dec('00010001');% I77  -
    stat{19}=bin2dec('00010010');% I78  -
    stat{20}=bin2dec('00010011');% I79  -
    
    % VICON triggers
    % stat{100}=bin2dec('00100000'); % ON    <=> EEG I60
    % stat{200}=bin2dec('01000000'); % OFF   <=> EEG I60
    % stat{300}=bin2dec('10000000'); % RESET <=> EEG I60

    PTBParams.stat = stat;
    PTBParams.pulse_duration = 0.01;         % 10 ms pulse
end


%% Initialize PsychToolbox Parameters and save in PTBParams struct

    AssertOpenGL;
    ListenChar(2); % don't print keypresses to screen
    Screen('Preference', 'SkipSyncTests', 1); % use if VBL fails
    Screen('Preference', 'VisualDebugLevel',3);

    HideCursor;
    screenNum = 0;
    
    if str2double(subjid) > 900
%     use next line if want to run in partial screen mode
        [w, rect] = Screen('OpenWindow',screenNum, [], [0 0 800 600]); 
    else
        [w, rect] = Screen('OpenWindow',screenNum);
    end
    ctr = [rect(3)/2, rect(4)/2]; 
    white=WhiteIndex(w);
    black=BlackIndex(w);
    gray = (WhiteIndex(w) + BlackIndex(w))/2;
    ifi = Screen('GetFlipInterval', w);
    
    PTBParams.win = w;
    PTBParams.rect = rect;
    PTBParams.ctr = ctr;
    PTBParams.white = white;
    PTBParams.black = black;
    PTBParams.gray = gray;
    PTBParams.ifi = ifi;
    PTBParams.datafile = datafile;
    PTBParams.homepath = homepath;
    PTBParams.subjid = str2double(subjid);
    PTBParams.ssnid = ssnid;
    PTBParams.numKeys = {'1!' '2@' '3#' '4$' '5%' '6^' '7&' '8*' '9(' '0)'};
    
    % set key mapping
    if mod(PTBParams.subjid, 2)
        PTBParams.KeyOrder = {4 3 2 1};
    else
        PTBParams.KeyOrder = {1 2 3 4};
    end
    
    % save PTBParams structure
    datafile = fullfile(homepath, 'SubjectData', subjid, ['PTBParams.' PTBParams.ssnid '.mat']);
    save(datafile,'PTBParams');
    Screen(w,'TextSize',round(.1*ctr(2)));
    Screen('TextFont',w,'Helvetica');
    Screen('FillRect',w,black);
    
    % used to initialize mousetracking object, otherwise the first time
    % this is called elsewhere it can take up to 300ms, throwing off timing
    [tempx, tempy] = GetMouse(w);
    
    WaitSecs(.5);
%% Seed random number generator 
%(note that different versions of Matlab allow/deprecate different random 
% number generators, so I've incorporated some flexibility here

[v d] = version; % get Matlab version
if datenum(d) > datenum('April 8, 2011') % compare to first release of rng
    rng('shuffle')
else
    rand('twister',sum(100*clock));
end

