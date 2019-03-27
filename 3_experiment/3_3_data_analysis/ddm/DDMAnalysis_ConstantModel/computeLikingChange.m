cond = input('Which condition? (nat, health, desire): ','s');

files = dir(['fittedData/fittedResults*' cond '.mat']);

fileName = mfilename('fullpath');

dataPath = regexp(fileName,'.*DDMAnalysis','match');
dataPath = fullfile(dataPath{1}(1:(end - 11)), 'BehavioralData/');

subjIDs = {};
for f = 1:length(files)
    if ~isempty(regexp(files(f).name,'.mat'))
        tok = regexp(files(f).name,'(\d{1,3})', 'tokens');
        subjIDs = [subjIDs tok{1}];
    end
end

load(fullfile(dataPath,'AveFoodRatings.mat'))

for s = 1:length(subjIDs)
    subjID = subjIDs{s};
    PreRating = load([dataPath subjID '/Data.' subjID '.LikingRatings-Pre.mat']);
    try
        PostRating = load([dataPath subjID '/Data.' subjID '.AttributeRatings-Post.mat']);
        PostRating = PostRating.Data;
    catch
        PostRating = [];
    end
    
    PreRating = PreRating.Data;
    
    OrderData = load([dataPath subjID '/Data.' subjID '.1.mat']);
    switch cond
        case 'nat'
            orderToUse = 'FoodOrderNat';
        case 'health'
            orderToUse = 'FoodOrderReg1';
        otherwise
            orderToUse = 'FoodOrderReg2';
    end
    conditionTrials = find(ismember(PreRating.Food,OrderData.Data.(orderToUse){1}));
    
    Liking1 = [];
    Liking2 = [];
    Health = [];
    Taste = [];
    t = 1;
    for trial = conditionTrials % for each trial
        if ~isempty(PostRating)
            selectedTrial = strcmp(PostRating.Attribute,'Health') ...
                & strcmp(PostRating.Food,PreRating.Food{trial});
        else
            selectedTrial = 0;
        end
        
        if any(selectedTrial)
            Health(t) = PostRating.Resp{selectedTrial};
            InterpolatedH(t) = 0;
        else
            Health(t) = AveHealthRating{strcmp(Foods,PreRating.Food{trial})};
            InterpolatedH(t) = 1;
        end
        
        if ~isempty(PostRating)
            selectedTrial = strcmp(PostRating.Attribute,'Taste') ...
                & strcmp(PostRating.Food,PreRating.Food{trial});
        else
            selectedTrial = 0;
        end
        
        if any(selectedTrial)
            Taste(t) = PostRating.Resp{selectedTrial};
            InterpolatedT(t) = 0;
        else
            Taste(t) = AveTasteRating{strcmp(Foods,PreRating.Food{trial})};
            InterpolatedT(t) = 1;
        end
        
        Liking1(t) = PreRating.Resp{trial};
        
        if ~isempty(PostRating)
            selectedTrial = strcmp(PostRating.Attribute,'Liking') ...
                & strcmp(PostRating.Food,PreRating.Food{trial});
            if any(selectedTrial)
                Liking2(t) = PostRating.Resp{selectedTrial};
            else
                Liking2(t) = NaN;
            end
        else
            Liking2(t) = NaN;
        end
        
        t = t + 1;
    end
    
    meanChange(s) = nanmean(Liking2 - Liking1);
    
    betas1 = glmfit([Health' Taste'], Liking1);
    betas2 = glmfit([Health' Taste'], Liking2);
    
    meanInterceptChange(s) = betas2(1) - betas1(1);
    meanTasteChange(s) = betas2(3) - betas1(3);
    meanHealthChange(s) = betas2(2) - betas1(2);

end