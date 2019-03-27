attach(ChoiceData)

source('~/Desktop/Dropbox/Experiments/FoodReg3/Analysis/AddPerSubject.R')

subjNames = unique(ChoiceData$Subject)
nSubjects = length(subjNames)

psd = data.frame(Subject = rep(subjNames,each = 3), Cond = rep(c('nat','health','decrease'), length(subjNames)))
ChoiceData$Condition = 'nat'
ChoiceData$Condition[ChoiceData$Instruction == 'Focus on Healthiness'] = 'health'
ChoiceData$Condition[ChoiceData$Instruction == 'Decrease Desire'] = 'decrease'

f = function(x){
  Accepted = with(x, Choice == 1)
  HealthyFoods = with(x, Health > 3)
  TastyFoods = with(x, Taste > 3)
  ChoseHealthy = with(x,Choice == 1 & Health > 3 | Choice < 1 & Health <=3)
  ChoseTasty = with(x, (Choice == 1 & Taste > 3) | (Choice == 0 & Taste <= 3))
  ChoseHT = Accepted[HealthyFoods & TastyFoods]
  ChoseHUT = Accepted[HealthyFoods & !TastyFoods]
  ChoseUHT = Accepted[!HealthyFoods & TastyFoods]
  ChoseUHUT = Accepted[!HealthyFoods & !TastyFoods]
  FirstDevAccepted = with(x, DrxFirstDevChoice == 1)
  FirstDevToTastiest = (x$Taste > 3 & x$DrxFirstDevChoice == 1) | (x$Taste <= 3 & x$DrxFirstDevChoice == 0)
  FirstDevToHealthiest = (x$Health > 3 & x$DrxFirstDevChoice == 1) | (x$Health <= 3 & x$DrxFirstDevChoice == 0)
  FirstChoseHT = FirstDevAccepted[HealthyFoods & TastyFoods]
  FirstChoseHUT = FirstDevAccepted[HealthyFoods & !TastyFoods]
  FirstChoseUHT = FirstDevAccepted[!HealthyFoods & TastyFoods]
  FirstChoseUHUT = FirstDevAccepted[!HealthyFoods & !TastyFoods]
  
  c(mean(Accepted, na.rm = TRUE), mean(FirstDevAccepted, na.rm = TRUE),
    mean(ChoseHealthy,na.rm = TRUE),mean(ChoseTasty,na.rm = TRUE),
    mean(ChoseHT, na.rm = TRUE), mean(ChoseHUT, na.rm = TRUE),
    mean(ChoseUHT, na.rm = TRUE), mean(ChoseUHUT, na.rm = TRUE),
    mean(FirstChoseHT, na.rm = TRUE), mean(FirstChoseHUT, na.rm = TRUE),
    mean(FirstChoseUHT, na.rm = TRUE), mean(FirstChoseUHUT, na.rm = TRUE),
    mean(ChoseHealthy[x$NumChangeMindChoice%%2 == 1],na.rm = TRUE),
    mean(ChoseTasty[x$NumChangeMindChoice%%2 == 1],na.rm = TRUE),
    mean(x$ChoiceRT,na.rm = TRUE),
    mean(x$FirstDevTimeChoice,na.rm = TRUE),
    mean(FirstDevToHealthiest,na.rm = TRUE),
    mean(FirstDevToTastiest,na.rm = TRUE),
    mean(x$FirstDevTimeChoice[ChoseHealthy],na.rm = TRUE),
    mean(x$FirstDevTimeChoice[!ChoseHealthy],na.rm = TRUE),
    mean(x$FirstDevTimeChoice[ChoseTasty],na.rm = TRUE),
    mean(x$FirstDevTimeChoice[!ChoseTasty],na.rm = TRUE),    
    mean(x$ChoiceRT[ChoseHealthy],na.rm = TRUE),
    mean(x$ChoiceRT[!ChoseHealthy],na.rm = TRUE),
    mean(x$ChoiceRT[ChoseTasty],na.rm = TRUE),
    mean(x$ChoiceRT[!ChoseTasty],na.rm = TRUE),
    mean(x$ChoiceRT[ChoseHT],na.rm = TRUE),
    mean(x$ChoiceRT[ChoseHUT],na.rm = TRUE),
    mean(x$ChoiceRT[ChoseUHT],na.rm = TRUE),
    mean(x$ChoiceRT[ChoseUHUT],na.rm = TRUE),
    mean(x$ChoiceRT[Accepted], na.rm = TRUE),
    mean(x$ChoiceRT[!Accepted], na.rm = TRUE),
    mean(x$NumChangeMindChoice[ChoseHealthy],na.rm = TRUE),
    mean(x$NumChangeMindChoice[!ChoseHealthy],na.rm = TRUE),
    mean(x$NumChangeMindChoice[ChoseTasty],na.rm = TRUE),
    mean(x$NumChangeMindChoice[!ChoseTasty],na.rm = TRUE)    
  )
}
psd = AddPerSubject(ChoiceData, psd, f, varname = c('PercentAccepted','PercentFirstAccepted',
                                                    'PercentChoseHealthiest','PercentChoseTastiest',
                                                    'PercentChoseHT','PercentChoseHUT',
                                                    'PercentChoseUHT','PercentChoseUHUT', 
                                                    'FirstPercentChoseHT','FirstPercentChoseHUT',
                                                    'FirstPercentChoseUHT','FirstPercentChoseUHUT',
                                                    'ChangedToHealthy','ChangedToTasty','RT',
                                                    'FirstDevTime','FirstDevDrxTowardHealthiest',
                                                    'FirstDevDrxTowardTastiest','FirstDevChoseHealthiest',
                                                    'FirstDevChoseLessHealthy','FirstDevChoseTastiest',
                                                    'FirstDevChoseLessTasty','RTChoseHealthiest',
                                                    'RTChoseLessHealthy','RTChoseTastiest',
                                                    'RTChoseLessTasty','RTChoseHT','RTChoseHUT',
                                                    'RTChoseUHT','RTChoseUHUT','RTAccept','RTReject',
                                                    'NChangeMindChoseHealthiest','NChangeMindChoseLessHealthy',
                                                    'NChangeMindChoseTastiest','NChangeMindChoseLessTasty'))

f = function(x){
  c(mean(x$HadToRating,na.rm = TRUE), mean(x$WantedToRating, na.rm = TRUE))
}
psd = AddPerSubject(ChoiceData, psd, f, varname = c('HadTo','WantedTo'))
psd$WantedToDiff = NA
psd$WantedToDiff[psd$Cond == 'decrease'] = psd$WantedTo[psd$Cond == 'decrease'] - psd$WantedTo[psd$Cond == 'nat']
psd$WantedToDiff[psd$Cond == 'health'] = psd$WantedTo[psd$Cond == 'health'] - psd$WantedTo[psd$Cond == 'nat']

psd$HadToDiff[psd$Cond == 'decrease'] = psd$HadTo[psd$Cond == 'decrease'] - psd$HadTo[psd$Cond == 'nat']
psd$HadToDiff[psd$Cond == 'health'] = psd$HadTo[psd$Cond == 'health'] - psd$HadTo[psd$Cond == 'nat']

psd$RT_HvUH = with(psd,RTChoseHealthiest - RTChoseLessHealthy)
psd$RT_TvUT = with(psd,RTChoseTastiest - RTChoseLessTasty)
psd$RT_HvUH_UT = with(psd,RTChoseHUT - RTChoseUHUT)
psd$RT_HvUH_T = with(psd,RTChoseHT - RTChoseUHT)

f = function(x){
  c(
    mean(x$FinalDevTimeChoice,na.rm = TRUE),
    mean(x$NumChangeMindChoice,na.rm = TRUE)
    )
}
psd = AddPerSubject(ChoiceData,psd,f,varname = c('FinalDevTime','NChangeMind'))

f = function(x){
  m = summary(lm(Liking1 ~ Health + Taste, data = x, na.action = na.omit))
  c(m$coefficients['Health','Estimate'],m$coefficients['Taste','Estimate'])
  }

psd = AddPerSubject(ChoiceData,psd,f,c('HealthWeightLiking','TasteWeightLiking'))

require(logistf)
f = function(x){
  if(!all(is.na(x$Taste)) & !all(is.na(x$Health))){
  m1 = logistf(Choice ~ Health + Taste, data = x, na.action = na.omit)
  m2= logistf(DrxFirstDevChoice ~ Health + Taste, data = x, na.action = na.omit)
#   m2= glm(DrxFirstDev ~ DiffHealth + DiffTaste, family = binomial(link = logit), data = x, na.action = na.omit)
  c(m1$coefficients['(Intercept)'], m1$coefficients['Health'], m1$coefficients['Taste'],
    m2$coefficients['(Intercept)'], m2$coefficients['Health'],m2$coefficients['Taste']) 
  }else{
    return(c(NA, NA, NA, NA, NA, NA))
  }
}
psd = AddPerSubject(ChoiceData,psd,f,c('M1_Intercept','M1_HealthWeight','M1_TasteWeight'
                                       ,'M2_Intercept','M2_FirstDevHealthWeight','M2_FirstDevTasteWeight'))

psd$HealthRegSucc = NA
psd$HealthRegSucc[psd$Cond == 'decrease'] = psd$M1_HealthWeight[psd$Cond == 'decrease'] - psd$M1_HealthWeight[psd$Cond == 'nat']
psd$HealthRegSucc[psd$Cond == 'health'] = psd$M1_HealthWeight[psd$Cond == 'health'] - psd$M1_HealthWeight[psd$Cond == 'nat']
psd$TasteRegSucc[psd$Cond == 'decrease'] = psd$M1_TasteWeight[psd$Cond == 'nat'] - psd$M1_TasteWeight[psd$Cond == 'decrease']
psd$TasteRegSucc[psd$Cond == 'health'] = psd$M1_TasteWeight[psd$Cond == 'nat'] - psd$M1_TasteWeight[psd$Cond == 'health']

psd$AcceptRegSucc[psd$Cond == 'health'] = psd$PercentAccepted[psd$Cond == 'health'] - psd$PercentAccepted[psd$Cond == 'nat']
psd$AcceptRegSucc[psd$Cond == 'decrease'] = psd$PercentAccepted[psd$Cond == 'decrease'] - psd$PercentAccepted[psd$Cond == 'nat']


f = function(x){
  c(mean(x$Liking1, na.rm = TRUE),
    mean(x$Liking2, na.rm = TRUE),
    mean((x$Liking2 - x$Liking1), na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Health > 3], na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Health <= 3], na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Taste > 3], na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Taste <= 3], na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Health > 3 & x$Taste > 3], na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Health > 3 & x$Taste <= 3], na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Health <= 3 & x$Taste > 3], na.rm = TRUE),
    mean((x$Liking2 - x$Liking1)[x$Health <= 3 & x$Taste <= 3], na.rm = TRUE))
}
psd = AddPerSubject(ChoiceData, psd, f, c('MeanLiking1','MeanLiking2','LikingChangeAll','LikingChangeHealth','LikingChangeUnhealthy',
                                          'LikingChangeTasty','LikingChangeUntasty',
                                          'LikingChangeHT','LikingChangeHUT','LikingChangeUHT','LikingChangeUHUT'))

f = function(x){
  m1 = logistf(Choice ~ Health + Liking, data = x, na.action = na.omit)
  m2= logistf(DrxFirstDevChoice ~ Health + Liking, data = x, na.action = na.omit)
  #   m2= glm(DrxFirstDev ~ DiffHealth + DiffTaste, family = binomial(link = logit), data = x, na.action = na.omit)
  c(m1$coefficients['(Intercept)'], m1$coefficients['Health'], m1$coefficients['Liking'],
    m2$coefficients['(Intercept)'], m2$coefficients['Health'],m2$coefficients['Liking']) 
}
psd = AddPerSubject(ChoiceData,psd,f,c('M3_Intercept','M3_HealthWeight','M3_LikingWeight'
                                       ,'M4_Intercept','M4_FirstDevHealthWeight','M4_FirstDevTasteWeight'))

f = function(x){
  m1 = logistf(Choice ~ Taste + Health + Liking, data = x, na.action = na.omit)
  m2= logistf(DrxFirstDevChoice ~ Taste + Health + Liking, data = x, na.action = na.omit)
  #   m2= glm(DrxFirstDev ~ DiffHealth + DiffTaste, family = binomial(link = logit), data = x, na.action = na.omit)
  c(m1$coefficients['(Intercept)'], m1$coefficients['Taste'], m1$coefficients['Health'], m1$coefficients['Liking'],
    m2$coefficients['(Intercept)'], m1$coefficients['Taste'], m2$coefficients['Health'],m2$coefficients['Liking']) 
}
psd = AddPerSubject(ChoiceData,psd,f,c('M5_Intercept','M5_TasteWeight','M5_HealthWeight','M5_LikingWeight'
                                       ,'M6_Intercept','M6_FirstDevTasteWeight','M6_FirstDevHealthWeight','M6_FirstDevTasteWeight'))


# f = function(x){
#   print(x$Subject[1])
#   FirstDevQuantiles = quantile(x$FirstDevTimeChoice, probs = seq(1/5, 1, length = 5))
#   FirstDevQuantiles = c(0,FirstDevQuantiles)
#   vals = vector(mode = 'numeric')
#   for(h in 1:5){
#     temp = subset(x,FirstDevTimeChoice >= FirstDevQuantiles[h] & FirstDevTimeChoice <= FirstDevQuantiles[h+1])
#     if(sd(temp$DiffHealth) > 0 & sd(temp$DiffTaste) > 0){
#       m = logistf(DrxFirstDev ~ DiffHealth + DiffTaste, data = temp, na.action = na.omit)
#       vals = c(vals,m$coefficients['DiffHealth'],m$coefficients['DiffTaste'])
#     }else{
#       vals = c(vals,NA,NA)
#     }
#   }
#   return(vals)  
# }

# psd = AddPerSubject(ChoiceData,psd,f,c('FirstDevHealthWeightQ1','FirstDevTasteWeightQ1',
#                                        'FirstDevHealthWeightQ2','FirstDevTasteWeightQ2',
#                                        'FirstDevHealthWeightQ3','FirstDevTasteWeightQ3',
#                                        'FirstDevHealthWeightQ4','FirstDevTasteWeightQ4',
#                                        'FirstDevHealthWeightQ5','FirstDevTasteWeightQ5'))
#                     
# psd$HvUHChoiceRT = psd$RTChoseHealthiest - psd$RTChoseLessHealthy
# psd$HUTvHTChoiceRT = psd$RTChoseHUT - psd$RTChoseHT

# psd$HvUHNChangeMind = psd$NChangeMindChoseHealthiest - psd$NChangeMindChoseLessHealthy
# psd$TvUTChoiceRT = psd$RTChoseTastiest - psd$RTChoseLessTasty
# psd$HvUHFirstDev = psd$FirstDevChoseHealthiest - psd$FirstDevChoseLessHealthy
# psd$TvUTFirstDev = psd$FirstDevChoseTastiest - psd$FirstDevChoseLessTasty
# psd$TotalMoveTime = psd$RT - psd$FirstDevTime
# psd$TvUTNChangeMind = psd$NChangeMindChoseTastiest - psd$NChangeMindChoseLessTasty
# 
# f = function(x){
#   FirstDevQuantiles = quantile(x$FirstDevTimeChoice, probs = seq(1/5, 1, length = 5))
#   FirstDevQuantiles = c(0,FirstDevQuantiles)
#   if(length(unique(FirstDevQuantiles)) == length(FirstDevQuantiles)){
#     x$FirstDevQuantile = cut(x$FirstDevTimeChoice,breaks = FirstDevQuantiles, labels = c(1,2,3,4,5))
#     return(tapply(x$FirstDevTimeChoice,x$FirstDevQuantile,function(x)mean(x,na.rm = TRUE)))
#   }else{return(c(NA,NA,NA,NA,NA))}
# }
# psd = AddPerSubject(ChoiceData, psd, f, varname = c('Q1_FirstDevRT','Q2_FirstDevRT','Q3_FirstDevRT',
#                                                                           'Q4_FirstDevRT','Q5_FirstDevRT'))
# 
# f = function(x){
#   FirstDevQuantiles = quantile(x$FirstDevTimeChoice[x$FirstDevTimeChoice > .150], probs = seq(1/5, 1, length = 5))
#   FirstDevQuantiles = c(0,FirstDevQuantiles)
#   x$FirstDevQuantile = cut(x$FirstDevTimeChoice,breaks = FirstDevQuantiles, labels = c(1,2,3,4,5))
#   HealthWeights = TasteWeights = vector(mode = 'numeric')
#   for(q in 1:5){
#     temp = subset(x,FirstDevQuantile == q & FirstDevTimeChoice > .15)
#     if(sd(temp$DiffHealth) > 0 & sd(temp$DiffTaste) > 0){
#       m = logistf(DrxFirstDev==1 ~ DiffHealth + DiffTaste, data = temp, na.action = na.omit)
#       HealthWeights[q] = m$coefficients['DiffHealth']
#       TasteWeights[q] = m$coefficients['DiffTaste']
#     }else{
#       HealthWeights[q] = NA
#       TasteWeights[q] = NA
#     }
#   }
#   return(c(HealthWeights,TasteWeights))
# }
# psd = AddPerSubject(ChoiceData, psd, f, 
#                                varname = c("FirstDevHealthWeightBQ1","FirstDevHealthWeightBQ2","FirstDevHealthWeightBQ3","FirstDevHealthWeightBQ4","FirstDevHealthWeightBQ5",    
#                                            "FirstDevTasteWeightBQ1","FirstDevTasteWeightBQ2", "FirstDevTasteWeightBQ3", "FirstDevTasteWeightBQ4","FirstDevTasteWeightBQ5"))
# 
# f = function(x){
#   c(mean(x$TimeChange1, na.rm = TRUE), 
#     mean(x$TimeChange1, na.rm = TRUE) - mean(x$FirstDevTimeChoice[x$NumChangeMindChoice > 0]))
# }
# psd = AddPerSubject(ChoiceData,psd, f, varname = c('TimeFirstChangeMind','ComparativeTimeFirstChangeMind'))

f = function(x){
  cor.test(x$Rating[x$Attribute == 'Taste'],x$Rating[x$Attribute == 'Health'])$estimate
}
psd = AddPerSubject(RatingData,psd, f, varname = 'HTCorrel', byCond = FALSE)

f = function(x){
  c(mean(x$RT[x$Attribute == 'Health']), mean(x$RT[x$Attribute == 'Taste']), sd(x$RT[x$Attribute == 'Health']),sd(x$RT[x$Attribute == 'Taste']))
}
psd = AddPerSubject(RatingData,psd,f,varname = c('HealthRT','TasteRT','HealthRTSD','TasteRTSD'), byCond = FALSE)


f = function(x){
  Houtliers = x$HealthRT > (mean(x$HealthRT) + 2.5*sd(x$HealthRT)) | (x$HealthRT < mean(x$HealthRT) - 2.5*sd(x$HealthRT))
  Toutliers = x$TasteRT > (mean(x$TasteRT) + 2.5*sd(x$TasteRT)) | (x$TasteRT < mean(x$TasteRT) - 2.5*sd(x$TasteRT))
  c(mean(x$HealthRT[!Houtliers]), mean(x$TasteRT[!Toutliers]), sd(x$HealthRT[!Houtliers]),sd(x$TasteRT[!Toutliers]))
}
psd = AddPerSubject(RatingData,psd,f,varname = c('HealthRTCrrct','TasteRTCrrct','HealthRTSDCrrct','TasteRTSDCrrct'), byCond = FALSE)



f = function(x){
  m = logistf(DrxFirstDev ~ DiffTaste*FirstDevTimeChoice + DiffHealth*FirstDevTimeChoice, data = x)
  temp = m$coefficients[5:6]
  temp[abs(temp) > 5] = NA
  return(temp)
}

psd = AddPerSubject(ChoiceData,psd, f, varname = c('TastexDevTime','HealthxDevTime'))

f = function(x){
  c(mean(x$ChoiceRT - x$FinalDevTimeChoice, na.rm = TRUE),sd(x$ ChoiceRT - x$FinalDevTimeChoice, na.rm = TRUE))
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('FinalMoveDuration','FinalMoveDurationSD'))

f = function(x){
  mean(x$FirstDevTimeChoice[x$FirstDevTimeChoice >= .2], na.rm = TRUE)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('FirstDevTimeNoEarly200'))

f = function(x){
#   m = glm(DrxFirstDev ~ DiffHealth + DiffTaste, family = binomial(link = 'logit'),
#           data = subset(x,FirstDevTimeChoice >= .2), na.action = na.omit)
  m = logistf(DrxFirstDev ~ DiffHealth + DiffTaste,
          data = subset(x,FirstDevTimeChoice > .2), na.action = na.omit)
  return(m$coefficients[2:3])
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('FirstDevHealthWeightNoEarly200','FirstDevTasteWeightNoEarly200'))

f = function(x){
  mean(as.numeric(x$FirstDevTimeChoice <= .2), na.rm = TRUE)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('PercentEarlyExcluded200'), byCond = FALSE)

f = function(x){
  mean(x$FirstDevTimeChoice[x$FirstDevTimeChoice >= .150], na.rm = TRUE)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('FirstDevTimeNoEarly150'))

f = function(x){
  #   m = glm(DrxFirstDev ~ DiffHealth + DiffTaste, family = binomial(link = 'logit'),
  #           data = subset(x,FirstDevTimeChoice >= .2), na.action = na.omit)
  m = logistf(DrxFirstDev ~ DiffHealth + DiffTaste,
              data = subset(x,FirstDevTimeChoice >= .150), na.action = na.omit)
  return(m$coefficients[2:3])
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('FirstDevHealthWeightNoEarly150','FirstDevTasteWeightNoEarly150'))

f = function(x){
  mean(as.numeric(x$FirstDevTimeChoice <= .150), na.rm = TRUE)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('PercentEarlyExcluded150'), byCond = FALSE)

f = function(x){
  mean(x$FirstDevTimeChoice[x$FirstDevTimeChoice >= .100], na.rm = TRUE)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('FirstDevTimeNoEarly100'))

f = function(x){
  #   m = glm(DrxFirstDev ~ DiffHealth + DiffTaste, family = binomial(link = 'logit'),
  #           data = subset(x,FirstDevTimeChoice >= .2), na.action = na.omit)
  m = logistf(DrxFirstDev ~ DiffHealth + DiffTaste,
              data = subset(x,FirstDevTimeChoice >= .100), na.action = na.omit)
  return(m$coefficients[2:3])
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('FirstDevHealthWeightNoEarly100','FirstDevTasteWeightNoEarly100'))

f = function(x){
  mean(as.numeric(x$FirstDevTimeChoice <= .100), na.rm = TRUE)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('PercentEarlyExcluded100'), byCond = FALSE)

f = function(x){
  m = lm(ChoiceRT ~ abs(DiffTaste) + abs(DiffHealth) + RightFoodTaste + LeftFoodTaste + RightFoodHealth + LeftFoodHealth, 
     data = x, na.action = na.omit)
  return(m$coefficients)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('MRT_Intcpt','MRT_DiffTaste','MRT_DiffHealth','MRT_RTaste','MRT_LTaste',
                                                   'MRT_RHealth','MRT_LHealth'))

f = function(x){
  m = lm(FirstDevTimeChoice ~ abs(DiffTaste) + abs(DiffHealth) + RightFoodTaste + LeftFoodTaste + RightFoodHealth + LeftFoodHealth, 
         data = x, na.action = na.omit)
  return(m$coefficients)
}
psd = AddPerSubject(ChoiceData,psd, f, varname = c('MRT1_Intcpt','MRT1_DiffTaste','MRT1_DiffHealth','MRT1_RTaste','MRT1_LTaste',
                                                   'MRT1_RHealth','MRT1_LHealth'))


# personality
pdata = read.table('SubjectData/Post-study survey.csv', sep = ',', header = TRUE)
f = function(x){
  c(x$CogRestraint,x$UncontrolledEating,x$EmotionalEating,
    x$FoodScreener_VeggiesFiber,x$FoodScreener_VegOnly,x$FoodScreener_FatsAll,
    x$FoodScreener_Meats,x$FoodScreener_Fats,x$FoodScreener_Junk,x$Attention,
    x$CognitiveFlexibility, x$Motor, x$Perseverence,x$SelfControl,x$CogComplexity,x$PSSTotal)
}
psd = AddPerSubject(pdata,psd,f,varname = c('CogRestraint','UncontEating','EmotEating',
                                        'FiberConsumption','VegConsumption','FattyFoods','MeatConsumption',
                                        'FatConsumption','JunkConsumption','BISAttention','BISCogFlex','BISMotor',
                                        'BISPerseverence','BISSelfControl','BISCogComplex','PerceivedStress'),byCond = FALSE)

pdata$ThinkHealthyReg = as.numeric(pdata$ThinkHealthyReg)
pdata$ThinkHealthNat = as.numeric(pdata$ThinkHealthNat)
pdata$DecreaseDesireNat = as.numeric(pdata$DecreaseDesireNat)
pdata$DecreaseDesireReg = as.numeric(pdata$DecreaseDesireReg)

f = function(x){
  c(x$ThinkHealthyReg,x$ThinkHealthNat,x$DecreaseDesireReg,x$DecreaseDesireNat,
    x$ThinkUnhealthy,x$Avoid,x$ChangeThink,x$AvoidLook,x$Lied,x$ThinkHealthy,x$DecreaseDesire,x$AvoidTasty)
}
psd = AddPerSubject(pdata,psd,f,varname = c('ThinkHealthyReg','ThinkHealthyNat','DecreaseDesireReg','DecreaseDesireNat',
                                            'FocusUnhealthy','Avoid','ChangeThink','AvoidLook','Lied','FocusHealth','Decrease','AvoidTasty'
                                            ),byCond = FALSE)

f = function(x){
  c(x$ThinkHealthyReg,x$ThinkHealthNat,x$DecreaseDesireReg,x$DecreaseDesireNat)
}
psd = AddPerSubject(pdata,psd,f,varname = c('ThinkHealthyReg','ThinkHealthyNat','DecreaseDesireReg','DecreaseDesireNat'),byCond = FALSE)





