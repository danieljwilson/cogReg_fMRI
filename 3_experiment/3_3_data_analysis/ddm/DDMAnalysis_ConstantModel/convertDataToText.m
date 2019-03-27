function convertDataToText(varargin)

fileName = mfilename('fullpath');
dataPath = regexp(fileName,'.*DDMAnalysis','match');
dataPath = fullfile(dataPath{1}(1:(end - 11)), 'BehavioralData/');

files = dir(fullfile(dataPath,'*'));
subjects = {files(3:end).name};

for s = 1:length(subjects)
    subjID = subjects{s};
    fprintf('Processing mouse data for subject %s...\n',subjID)
    
    %% Get trial data for each part
    clear Choice
    % process data for Part 1 (unregulated choice)
    if exist([dataPath subjID '/Data.' subjID '.ChoiceTask.mat'],'file')
        
    load([dataPath subjID '/Data.' subjID '.ChoiceTask.mat'])
    
    if exist(fullfile(dataPath,subjID,'MouseChoice.mat'),'file')
        load(fullfile(dataPath,subjID,'MouseChoice.mat'))
    end
    
    if showPlots
        [w, rect] = Screen('OpenWindow',0, [], [1100,645,1440,900]); 
    end
    if startTrial < length(Data.Choice)
        for t = startTrial:length(Data.Choice)
            clc;
            sprintf('Processing trial %d for subject %s...\n\n',t, subjID)
    %         input(['View trial ' num2str(t)])
            Choice(t) = processMouseTrace_handCorrect([Data.ChoiceX{t},Data.ChoiceY{t}],Data.ChoiceTime{t},showPlots);
            save(fullfile(dataPath,subjID,'MouseChoice.mat'),'Choice');
        end 
    end    
    % load pre-task rating data
    PreRating = load([dataPath subjID '/Data.' subjID '.LikingRatings-Pre.mat']);
    try
        PostRating = load([dataPath subjID '/Data.' subjID '.AttributeRatings-Post.mat']);
    catch
        PostRating = [];
    end
    
    %% Print trial-by-trial variables to separate .txt file
   
    fprintf('Processing trial data for subject %s...\n',subjID)
    
    % delete file if it already exists (avoids appending each time this is
    % run)
    if exist([dataPath subjID '/ChoiceData_' subjID '.csv'],'file')
        delete([dataPath subjID '/ChoiceData_' subjID '.csv'])
    end
    
    fid = fopen([dataPath subjID '/ChoiceData_' subjID '.csv'],'a');
    
    headers = {'Subject','Trial','Instruction','Food','Liking1','Liking2',...
               'Taste','Health','Amount', ...
            'Choice','ChoiceRT','WantedToRating','HadToRating','FirstDevTimeChoice',...    
            'InitAngleChoice','NumChangeMindChoice','FinalDevTimeChoice','MaxVelocityChoice',...
            'DrxFirstDevChoice','TotalAUCChoice','AUCtoNonChosenChoice',...
            'AUCtoChosenChoice','MaxDevChoice','Interpolated_Health','Interpolated_Taste'};
    % print vars at top of file
    for h = 1:length(headers) - 1
        fprintf(fid,'%s,',headers{h});
    end
    
    fprintf(fid,'%s\n',headers{end});
    
    % print info 
    colVars = {'Data.subjid','t','Data.InstructionOnTrial{t}','FoodStem',...
               'Liking1','Liking2','Taste','Health','Amount',...
               'Data.Choice{t}','Data.ChoiceTime{t}(end)',...
               'Data.HadToRating{t}','Data.WantedToRating{t}',...
               'Choice(t).firstDeviation','Choice(t).initialAngle','Choice(t).nChangeMind',...
               'Choice(t).timeFinalChoice','Choice(t).maxVelocity',...
               'Choice(t).drxFirstDev','Choice(t).AUCTotal',...
               'Choice(t).AUCToNonChosen','Choice(t).AUCToChosen','Choice(t).maxDev','InterpolatedH','InterpolatedT'...
               };
    
    load(fullfile(dataPath,'AveFoodRatings.mat'));
    
    for t = 1:length(Data.Choice) % for each trial
        if ~isempty(PostRating)
            selectedTrial = strcmp(PostRating.Data.Attribute,'Health') ...
                & strcmp(PostRating.Data.Food,Data.FoodOnTrial{t});
        else
            selectedTrial = 0;
        end
        
        if any(selectedTrial)
            Health = PostRating.Data.Resp{selectedTrial};
            InterpolatedH = 0;
        else
            Health = AveHealthRating{strcmp(Foods,Data.FoodOnTrial{t})};
            InterpolatedH = 1;
        end
        
        if ~isempty(PostRating)
            selectedTrial = strcmp(PostRating.Data.Attribute,'Taste') ...
                & strcmp(PostRating.Data.Food,Data.FoodOnTrial{t});
        else
            selectedTrial = 0;
        end
        
        if any(selectedTrial)
            Taste = PostRating.Data.Resp{selectedTrial};
            InterpolatedT = 0;
        else
            Taste = AveTasteRating{strcmp(Foods,Data.FoodOnTrial{t})};
            InterpolatedT = 1;
        end
        
        Liking1 = PreRating.Data.Resp{strcmp(PreRating.Data.Attribute,'Liking') ...
            & strcmp(PreRating.Data.Food,Data.FoodOnTrial{t})};
        
        if ~isempty(PostRating)
            selectedTrial = strcmp(PostRating.Data.Attribute,'Liking') ...
                & strcmp(PostRating.Data.Food,Data.FoodOnTrial{t});
            if any(selectedTrial)
                Liking2 = PostRating.Data.Resp{selectedTrial};
            else
                Liking2 = NaN;
            end
        else
            Liking2 = NaN;
        end
        FoodStem = Data.FoodOnTrial{t}(1:(regexp(Data.FoodOnTrial{t},'_','once') - 1));
        Amount = Data.FoodOnTrial{t}(regexp(Data.FoodOnTrial{t},'_','once') + 1);
        
        for c = 1:length(colVars) - 1
            eval(['v = ' colVars{c} ';']);
            printvar(v,fid,',');
        end
        eval(['v = ' colVars{c + 1} ';']);
        printvar(v,fid,'\n');

    end
    
    
%% Process rating data independently
    fprintf('Processing ratings data for subject %s...\n',subjID)
    if exist([dataPath subjID '/RatingDataForGLM_' subjID '.txt'],'file')
        delete([dataPath subjID '/RatingDataForGLM_' subjID '.txt'])
    end


    fid = fopen([dataPath subjID '/RatingDataForGLM_' subjID '.txt'],'a');

    headers = {'Subject','Block','Trial','Attribute','Food','Rating','RT'};
    % print vars at top of file
    for h = 1:length(headers) - 1
        fprintf(fid,'%s\t',headers{h});
    end

    fprintf(fid,'%s\n',headers{end});

    colVars = {'PreRating.Data.subjid','Block',...
        't','PreRating.Data.Attribute{t}','PreRating.Data.Food{t}',...
        'PreRating.Data.Resp{t}','PreRating.Data.RT{t}',};

    for t = 1:length(PreRating.Data.Food)
        if strcmp(PreRating.Data.Attribute{t},PreRating.Data.Attribute{1})
            Block = 1;
        else
            Block = 2;
        end

        for c = 1:length(colVars) - 1
                eval(['v = ' colVars{c} ';']);
                printvar(v,fid,'\t');
        end
        eval(['v = ' colVars{c + 1} ';']);
        printvar(v,fid,'\n');
    end
    
    fclose(fid);
    end
    
end

function printvar(var,fid,endCap)
    if isempty(var) || any(isnan(var))
        var = 'NA';
    end
    varInfo = whos('var');
    
    switch varInfo.class
        case 'char'
            fprintf(fid,['%s' endCap],var);
        case 'logical'
            fprintf(fid,['%d' endCap],var);
        otherwise
            fprintf(fid,['%.4f' endCap],var);
    end
    
