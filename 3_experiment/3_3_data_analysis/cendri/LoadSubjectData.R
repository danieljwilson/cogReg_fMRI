# load choice data for all subjects

# load mouse Choice data for all subjects
MouseData = read.table(paste('SubjectData/',subjNames[1],'/MouseTracePerChoice_', subjNames[1], '.txt', sep = ""),sep = "\t",header = TRUE)

for(subj in 2:nSubjects){ # subjNames[2:nSubjects]
  print(paste('Loading', subjNames[subj]))
  temp = read.table(paste('SubjectData/', subjNames[subj], '/MouseTracePerChoice_', subjNames[subj], '.txt', sep = ""),sep = "\t",header = TRUE)
  MouseData = rbind.data.frame(MouseData,temp)
}
MouseData$Subject = as.factor(MouseData$Subject)

# load mouse Choice 100 data for all subjects
MouseData100 = read.table(paste('SubjectData/', subjNames[1], '/MouseTrace100PerChoice_', subjNames[1], '.txt', sep = ""),sep = "\t",header = TRUE)


for(subj in 2:nSubjects){
  print(paste('Loading Mouse100', subjNames[subj]))
  temp = read.table(paste('SubjectData/', subjNames[subj], '/MouseTrace100PerChoice_', subjNames[subj], '.txt', sep = ""),sep = "\t",header = TRUE)
  MouseData100 = rbind.data.frame(MouseData100,temp)
}
MouseData100$Subject = as.factor(MouseData100$Subject)

# load choice data for all subjects
ChoiceData = read.table(paste('SubjectData/',subjNames[1],'/ChoiceData_', subjNames[1], '.csv', sep = ""),sep = ",",header = TRUE)

for(subj in 2:nSubjects){
  print(paste('Loading ChoiceData ', subjNames[subj]))
  temp = read.table(paste('SubjectData/',subjNames[subj],'/ChoiceData_', subjNames[subj], '.csv', sep = ""),sep = ",",header = TRUE)
  ChoiceData = rbind.data.frame(ChoiceData,temp)
}

# load rating data for all subjects
RatingData = read.table(paste('SubjectData/',subjNames[1],'/RatingDataForGLM_', subjNames[1], '.txt', sep = ""),sep = "\t",header = TRUE)

for(subj in 2:nSubjects){
  print(paste('Loading Ratings', subjNames[subj]))
  temp = read.table(paste('SubjectData/',subjNames[subj],'/RatingDataForGLM_', subjNames[subj], '.txt', sep = ""),sep = "\t",header = TRUE)
  RatingData = rbind.data.frame(RatingData,temp)
}

ChoiceData$DrxFirstDevChoice[ChoiceData$DrxFirstDevChoice == -1] = 0
ChoiceData$Choice[ChoiceData$Choice == -1] = 0
ChoiceData$Condition = 'nat'
ChoiceData$Condition[ChoiceData$Instruction == 'Focus on Unhealthiness'] = 'unhealthy'
ChoiceData$Condition[ChoiceData$Instruction == 'Focus on Healthiness'] = 'healthy'
ChoiceData$Condition[ChoiceData$Instruction == 'Decrease Desire'] = 'decrease'

# pdata = read.csv('~/Desktop/Dropbox/Experiments/FoodReg2/SubjectData/FoodReg2_PostStudyQ.csv')
# for(q in 1:18){
#   temp = pdata[[paste('TFQ', q, sep = "")]]
#   temp2 = vector(mode = 'numeric', length = length(temp))
#   temp2[temp == 'Definitely false'] = 1
#   temp2[temp == 'Mostly false'] = 2
#   temp2[temp == 'Mostly true'] = 3
#   temp2[temp == 'Definitely true'] = 4
#   pdata[[paste('TFQ', q, sep = "")]] = temp2
# }

# for(q in 1:30){
#   temp = pdata[[paste('BIS', q, sep = "")]]
#   temp2 = vector(mode = 'numeric', length = length(temp))
#   temp2[temp == 'Rarely'] = 1
#   temp2[temp == 'Occasionally'] = 2
#   temp2[temp == 'Often'] = 3
#   temp2[temp == 'Amost always/Always'] = 4
#   pdata[[paste('BIS', q, sep = "")]] = temp2
# }
# pdata$TFQ_Restraint = with(pdata, TFQ2 + TFQ11 + TFQ12 + TFQ15 + TFQ16 + ceiling(TFQ18/2))
# pdata$TFQ_UncontrolledEating = with(pdata, TFQ1 + TFQ4 + TFQ5 + TFQ7 + TFQ8 + 
#                                       TFQ9 + TFQ13 + TFQ14 + TFQ17)
# pdata$TFQ_EmotionalEating = with(pdata, TFQ3 + TFQ6 + TFQ10)
# 
# pdata$BIS_SelfControl = with(pdata, (5 - BIS1) + (5 - BIS7) + (5 - BIS8) + (5 - BIS12) + 
#                             (5 - BIS13) + BIS14)
# pdata$BIS_CogComplexity = with(pdata, (5 - BIS10) + (5-BIS15) + BIS18 + BIS27 + (5-BIS29))
# pdata$BIS_Planning = pdata$BIS_SelfControl + pdata$BIS_CogComplexity
# pdata$BIS_Attention = with(pdata, BIS5 + (5-BIS9) + BIS11 + (5-BIS20) + BIS28)
# pdata$BIS_CogInstability = with(pdata, BIS6 + BIS24 + BIS26)
# pdata$BIS_OverallAttention = pdata$BIS_Attention + pdata$BIS_CogInstability
# pdata$BIS_Motor = with(pdata, BIS2 + BIS3 + BIS4 + BIS17 + BIS19 + BIS22 + BIS25)
# pdata$BIS_Perseverance = with(pdata, BIS16 + BIS21 + BIS23 + (5-BIS30))
# pdata$BIS_OverallMotor = pdata$BIS_Motor + pdata$BIS_Perseverance
# 
# for(s in intersect(unique(psd$Subject), unique(pdata$Subject))){
# psd$TFQ_Restraint[psd$Subject == s] = pdata$TFQ_Restraint[pdata$Subject == s]
# psd$TFQ_UncontrolledEating[psd$Subject == s] = pdata$TFQ_UncontrolledEating[pdata$Subject == s]
# psd$TFQ_EmotionalEating[psd$Subject == s] = pdata$TFQ_EmotionalEating[pdata$Subject == s]
# 
# psd$BIS_SelfControl[psd$Subject == s] = pdata$BIS_SelfControl[pdata$Subject ==s]
# psd$BIS_CogComplexity[psd$Subject == s] = pdata$BIS_CogComplexity[pdata$Subject ==s]
# psd$BIS_Planning[psd$Subject == s] = pdata$BIS_Planning[pdata$Subject ==s]
# 
# psd$BIS_Attention[psd$Subject == s] = pdata$BIS_Attention[pdata$Subject ==s]
# psd$BIS_CogInstability[psd$Subject == s] = pdata$BIS_CogInstability[pdata$Subject ==s]
# psd$BIS_OverallAttention[psd$Subject == s] = pdata$BIS_OverallAttention[pdata$Subject ==s]
# 
# psd$BIS_Motor[psd$Subject == s] = pdata$BIS_Motor[pdata$Subject ==s]
# psd$BIS_Perseverance[psd$Subject == s] = pdata$BIS_Perseverance[pdata$Subject ==s]
# psd$BIS_OverallMotor[psd$Subject == s] = pdata$BIS_OverallMotor[pdata$Subject ==s]
# }
# 

