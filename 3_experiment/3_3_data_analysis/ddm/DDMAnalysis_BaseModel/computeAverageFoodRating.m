load ~/Desktop/Dropbox/Projects/FoodRegFMRI/subjNameList.mat

% fileName = mfilename('fullpath');
% dataPath = regexp(fileName,'.*analysis','match');
dataPath = '~/Desktop/Dropbox/Projects/FoodRegFMRI/BehavioralData/';

for s = 1:length(subjNameList)
    subjID = subjNameList{s};
    
    %% Get rating data
    
    temp = load([dataPath subjID '/Data.' subjID '.LikingRatings-Pre.mat']);
    PreRating(s).Data = temp.Data;
    temp = load([dataPath subjID '/Data.' subjID '.AttributeRatings-Post.mat']);
    PostRating(s).Data = temp.Data;
end

Foods = PreRating(12).Data.Food;
for f = 1:length(Foods)
    HealthRating{f} = zeros(length(subjNameList),1);
    TasteRating{f} = zeros(length(subjNameList),1);
    for s = 1:length(subjNameList)
        selectedTrial = strcmp(PostRating(s).Data.Attribute,'Health') ...
            & strcmp(PostRating(s).Data.Food,Foods{f});
        if any(selectedTrial)
            HealthRating{f}(s) = PostRating(s).Data.Resp{selectedTrial};
        else
            HealthRating{f}(s) = NaN;
        end
        
        selectedTrial = strcmp(PostRating(s).Data.Attribute,'Taste') ...
            & strcmp(PostRating(s).Data.Food,Foods{f});
        if any(selectedTrial)
            TasteRating{f}(s) = PostRating(s).Data.Resp{selectedTrial};
        else
            TasteRating{f}(s) = NaN;
        end
    end
    AveHealthRating{f} = nanmean(HealthRating{f});
    AveTasteRating{f} = nanmean(TasteRating{f});
end