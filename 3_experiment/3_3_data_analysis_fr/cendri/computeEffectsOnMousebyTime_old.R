computeEffectsOnMouseByTime = function(Data, TrialData, mouseVarName = "MouseX", adjustToFirstDevVar = 'none', 
                                       zeroToFirstDevVar = 'none', normvars = FALSE, returnP = FALSE, lmType = 'lm', maxLength = 150){
  # USAGE: 
  # Requires two dataframes: 
  # Data: Mouse trace data that should consist of two variables:
  #       1. mouseVarName: (default = "MouseX") a signed x trajectory for each trial (can be of different lengths)
  #       2. TimePt: a sample-identifying vector specifying identical time-points across different mouse traces
  #       3. Trial: a vector assigning each mouse trace to a particular trial (should match trial names in TrialData below)
  # TrialData: Trial level data consisting of the following required and addition variables:
  #            1. Trial: used to link trial-level effects to mouse traces for that trial
  #            2 - N. N variable effects desired to be modeled over time, each effect specified in a different column variable
  
  countWarnings <- function(expr) 
  {
    .number_of_warnings <- 0L
    frame_number <- sys.nframe()
    ans <- withCallingHandlers(expr, warning = function(w) 
    {
      assign(".number_of_warnings", .number_of_warnings + 1L, 
             envir = sys.frame(frame_number))
      invokeRestart("muffleWarning")
    })
    return(list(ans = ans, noWarn = .number_of_warnings))
  }

  trialIDsMouse = unique(Data$Trial)
  TrialData = subset(TrialData, Trial %in% trialIDsMouse)
  trialIDsData = unique(TrialData$Trial)
  
  # remove mouse data before first choice initiation, if requested, leaving 100ms baseline for comparison
  if(adjustToFirstDevVar != 'none'){
    for(t in trialIDsMouse){
      Data = Data[!(Data$Time < TrialData[TrialData$Trial == t, adjustToFirstDevVar] - .1 & Data$Trial == t),]
      Data$TimePt[Data$Trial == t] = 1:length(Data$TimePt[Data$Trial == t])
      }    
  }
  
  # zero out movements prior to first recorded choice initiation
  if(zeroToFirstDevVar != 'none'){
    for(t in trialIDsMouse){
      Data[(Data$Time < TrialData[TrialData$Trial == t, zeroToFirstDevVar] & Data$Trial == t),mouseVarName] = 0
    }    
  }
  
  maxTime = min(maxLength, max(Data$TimePt))
  
  if(all(trialIDsMouse %in% trialIDsData) & all(trialIDsData %in% trialIDsMouse)){# run analyses if trial identifiers match up
  
        nTrials = length(trialIDsMouse)
        XPos = matrix(0,length(trialIDsMouse))

        PredictorNames = names(TrialData)
        PredictorNames = PredictorNames[PredictorNames != 'Trial' & PredictorNames != adjustToFirstDevVar & PredictorNames != zeroToFirstDevVar]
        
        # normalize all variables prior to entry in GLM, if requested
        if(normvars){
          for(p in 1:length(PredictorNames)){
            TrialData[[PredictorNames[p]]] = (TrialData[[PredictorNames[p]]] - mean(TrialData[[PredictorNames[p]]], na.rm = TRUE))/
                                          sd(TrialData[[PredictorNames[p]]], na.rm = TRUE)
            }
        }
        PredData = vector(mode = 'list', length = length(PredictorNames))
        names(PredData) = PredictorNames
        
        lmExpression = paste("XPos ~",PredictorNames[1], sep = " ")
        
        if(length(PredictorNames) > 1){
            for(p in 2:length(PredictorNames)){
              lmExpression = paste(lmExpression, "+", PredictorNames[p], sep = " ")         
              }
          }
        lmFmla = as.formula(lmExpression)
        
        Betas = Betas_SE= Pvals = matrix(data = NA, nrow = maxTime, ncol = length(PredictorNames))
        colnames(Betas) = PredictorNames
        colnames(Betas_SE) = PredictorNames
        colnames(Pvals) = PredictorNames
        
        for(time in 2:maxTime){
#           print(time)
          t = 1
          for(trial in trialIDsMouse){      
            if(any(Data$TimePt == time & Data$Trial == trial)){
              # if there is data for that time point, add it
              XPos[t] = Data[[mouseVarName]][Data$TimePt == time & Data$Trial == trial]
            }else{
              # otherwise insert last position
              XPos[t] = Data[[mouseVarName]][Data$Trial == trial][length(Data[[mouseVarName]][Data$Trial == trial])]
            }
            t = t + 1
          }
          if(length(which(!is.na(XPos))) < 10){ # if there are too few trials from which to judge
            m = list(coefficients = rep(NA,length(PredictorNames)))
            
          }else{
            if(lmType == 'binomial'){
              m = countWarnings(glm(lmFmla, data = TrialData, family = binomial(logit), na.action = na.omit))
              if(m$noWarn > 0){
                logF = TRUE
                m = logistf(lmFmla,data = TrialData, na.action = na.omit)
              }else{
                logF = FALSE
                m = summary(m$ans)
              }
            }else{
              m = summary(lm(lmFmla,data = TrialData, na.action = na.omit))
            }
          }
          
          if(!any(is.na(m$coefficients)) ){ # is.na(m$coefficients['(Intercept)', 't value'])
            if(lmType == 'binomial' && logF){ # if penalized logistic was used
              for(p in 1:length(PredictorNames)){
                Betas[time,p] = m$coefficients[PredictorNames[p]]
                Betas_SE[time,p] = diag(m$var)[m$terms == PredictorNames[p]]^.5
                Pvals[time,p] = m$prob[PredictorNames[p]]
              }
            }else{ # if normal maximum likelihood was used
              for(p in 1:length(PredictorNames)){
#                 Betas[time,p] = m$coefficients[PredictorNames[p],'Estimate']
#                 Betas_SE[time,p] = m$coefficients[PredictorNames[p],'Std. Error']
#                 if(lmType == 'binomial'){
#                   Pvals[time,p] = m$coefficients[PredictorNames[p],'Pr(>|z|)']
#                 }else{
#                   Pvals[time,p] = m$coefficients[PredictorNames[p],'Pr(>|t|)']
#                 }
                Betas[time,p] = tryCatch(
                  m$coefficients[PredictorNames[p],'Estimate']
                  ,error = function(e){NA})
                Betas_SE[time,p] = tryCatch(
                  m$coefficients[PredictorNames[p],'Std. Error']
                  ,error = function(e){NA})
              
                if(lmType == 'binomial'){
                  Pvals[time,p] = tryCatch(m$coefficients[PredictorNames[p],'Pr(>|z|)']
                           ,error = function(e){NA})
                }else{
                  Pvals[time,p] = tryCatch(m$coefficients[PredictorNames[p],'Pr(>|t|)']
                           ,error = function(e){NA})
                }
                
              }
            }
          }else{
            for(p in 1:length(PredictorNames)){
              Betas[time,p] = NA
              Betas_SE[time,p] = NA
              Pvals[time,p] = 1
            }
          }
        }
        
        if(lmType == 'binomial'){
          # correct any overfitting based on too few observations or variability in predictors
          overfitPts = Betas > 100 | (Betas_SE > 10)
          Betas[overfitPts] = 0
          Betas_SE[overfitPts] = 0
          Pvals[overfitPts] = 1
        }
        for(p in 1:length(PredictorNames)){
          
          if(!returnP){
            data = matrix(0,3,maxTime)
          }else{
            data = matrix(0,4,maxTime)
          }
          data[1,] = Betas[,PredictorNames[p]]
          data[2,] = Betas[,PredictorNames[p]] - Betas_SE[,PredictorNames[p]]
          data[3,] = Betas[,PredictorNames[p]] + Betas_SE[,PredictorNames[p]]
          if(returnP){
            data[4,] = Pvals[,PredictorNames[p]]
          }
          PredData[[PredictorNames[p]]] = data
          
        }
  
    return(PredData)
  }else{
    print('Trial identifiers do not line up!')
  }
}