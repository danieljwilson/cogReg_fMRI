MouseAnalysis = function(PredVars, MouseData, ChoiceData,
                         adjustToFirstDevVar = 'none',
                         zeroToFirstDevVar = 'none',
                         mouseVar = 'DrxBin', lmType = 'binomial',
                         Conds = c('nat','decrease','health'),
                         maxLength = 150,
                         normalized = FALSE){

  source('~/Desktop/Dropbox/Experiments/FoodReg1/Analysis/computeEffectsOnMousebyTime.R')
  e = new.env()
  require(logistf)
  
  for(Cond in Conds){
    for(p in c(PredVars,'Intercept')){
      assign(paste(p, 'Effects', gsub("\\s","",Cond),sep = ""), matrix(NA, nSubjects,maxLength), envir = e)
      assign(paste(p, 'Effects', gsub("\\s","",Cond), 'SEMinus',sep = ""), matrix(NA, nSubjects,maxLength), envir = e)
      assign(paste(p, 'Effects', gsub("\\s","",Cond), 'SEPlus',sep = ""), matrix(NA, nSubjects,maxLength), envir = e)
      assign(paste(p, 'Effects', gsub("\\s","",Cond), 'PVal',sep = ""), matrix(NA, nSubjects,maxLength), envir = e)
      
    }
    for(SUBJ in 1:nSubjects){
      print(paste('Working on subject', subjNames[SUBJ], ',',Cond,'trials'  ))
      TrialData = subset(ChoiceData, Subject == subjNames[SUBJ])
      selectedTrials = TrialData$Trial[TrialData$Condition == Cond] 
      
      if(length(selectedTrials) > 0){
        Data = subset(MouseData,Subject == subjNames[SUBJ] & Trial %in% selectedTrials)
        TrialData = subset(TrialData,Trial %in% selectedTrials)
        TrialData = TrialData[,names(TrialData) %in% c('Trial',PredVars,adjustToFirstDevVar,zeroToFirstDevVar)]
        for(p in PredVars){
          if(all(is.na(TrialData[[p]]))){
            TrialData = TrialData[,names(TrialData) != p]
          }
        }
        PredData = computeEffectsOnMouseByTime(Data,TrialData,mouseVarName = mouseVar,
                                               adjustToFirstDevVar = adjustToFirstDevVar,
                                               zeroToFirstDevVar = zeroToFirstDevVar,normvars = FALSE, 
                                               returnP = TRUE, lmType = lmType,maxLength = maxLength)
        
        vals = vector(mode = 'numeric')
        
        for(p in names(PredData)){

          assign(paste(p, 'Effects', gsub("\\s", "", Cond), sep = ""),{ z <- get(paste(p, 'Effects',gsub("\\s", "", Cond), sep = ""), envir = e)
                                                                        z[SUBJ,1:min(maxLength, dim(PredData[[p]])[2])] <- PredData[[p]][1,1:min(maxLength, dim(PredData[[p]])[2])]
                                                                        z[SUBJ,min(maxLength, dim(PredData[[p]])[2]):maxLength] <- PredData[[p]][1,dim(PredData[[p]])[2]]
                                                                        z }, envir = e ) #/PredData[[p]][1,dim(PredData[[p]])[2]]
          assign(paste(p, 'Effects', gsub("\\s", "", Cond), 'SEMinus', sep = ""),{ z <- get(paste(p, 'Effects',gsub("\\s", "", Cond), 'SEMinus', sep = ""), envir = e)
                                                                                   z[SUBJ,1:min(maxLength, dim(PredData[[p]])[2])] <- PredData[[p]][2,1:min(maxLength, dim(PredData[[p]])[2])]
                                                                                   z[SUBJ,min(maxLength, dim(PredData[[p]])[2]):maxLength] <- PredData[[p]][2,dim(PredData[[p]])[2]]
                                                                                   z }, envir = e) #/PredData[[p]][1,dim(PredData[[p]])[2]]
          assign(paste(p, 'Effects', gsub("\\s", "", Cond), 'SEPlus', sep = ""),{ z <- get(paste(p, 'Effects',gsub("\\s", "", Cond), 'SEPlus', sep = ""), envir = e) 
                                                                                  z[SUBJ,1:min(maxLength, dim(PredData[[p]])[2])] <- PredData[[p]][3,1:min(maxLength, dim(PredData[[p]])[2])]
                                                                                  z[SUBJ,min(maxLength, dim(PredData[[p]])[2]):maxLength] <- PredData[[p]][3,dim(PredData[[p]])[2]]
                                                                                  z }, envir = e ) #/PredData[[p]][1,dim(PredData[[p]])[2]]
          assign(paste(p, 'Effects', gsub("\\s", "", Cond), 'PVal', sep = ""),{ z <- get(paste(p, 'Effects',gsub("\\s", "", Cond), 'PVal', sep = ""), envir = e) 
                                                                                z[SUBJ,1:min(maxLength, dim(PredData[[p]])[2])] <- PredData[[p]][4,1:min(maxLength, dim(PredData[[p]])[2])]
                                                                                z[SUBJ,min(maxLength, dim(PredData[[p]])[2]):maxLength] <- PredData[[p]][4,dim(PredData[[p]])[2]]
                                                                                z }, envir = e ) #/PredData[[p]][1,dim(PredData[[p]])[2]]
          
        }  
      }  
    }
  }
  
  return(e)
}