setwd('~/Desktop/Dropbox/Experiments/FoodReg3/')
# clear out workspace and start with a clean slate!
source('~/Desktop/Dropbox/General/Rscripts/detachDataRS.R')$value() # clear out the workspace
rm(list = ls())

# import two functions for plotting
source('~/Desktop/Dropbox/General/Rscripts/lineanderrbars.R')
source('~/Desktop/Dropbox/General/Rscripts/PrettyBarPlots.R')

# load in some of the non-default packages that we will need to use
pck = c('nlme','MASS','ggplot2','logistf','lme4','Hmisc','fields','colorRamps','R.matlab','RColorBrewer','Cairo')

temp = lapply(pck,library,character.only=T)
rm(list = c('temp','pck'))


# load in data from memory (post-processing)
load('~/Desktop/Dropbox/Experiments/FoodReg3/Analysis/FoodReg3.RData')

# create variables that otherwise could be loaded in from memory (see above)
subjNames = c(1:7, 9, 11:17,19:33,35:39)
nSubjects = length(subjNames)
source('Analysis/LoadSubjectData.R')
source('Analysis/ProcessPerSubjectData.R')

# data cleaning
# Does the subject have sufficient variability in choice behavior? Excludes 22 and 35
tapply(ChoiceData$Choice,ChoiceData$Subject,function(x)mean(x, na.rm = TRUE))

psd$Include = 1
psd$Include[psd$Subject %in% c(22,35)] = 0

# Does the subject have reasonable RTs?
tapply(ChoiceData$ChoiceRT, ChoiceData$Subject, function(x)mean(x, na.rm = TRUE))

ExcludedSubjects = c(22,35)

StatsPerCondition(subset(psd,Include == 1),'RT', nDig = 4)

psd$Cond = factor(psd$Cond, levels(psd$Cond)[c(3,1,2)])
StatsPerCondition(psd,'M1_TasteWeight', nDig = 4)
quartz('',3,3.5)
clrs = c('gray','blue','red')
PrettyBarPlots(subset(psd, Include == 1),varorder = 'RT', gpFactor = 'Cond', clrs = clrs)

PrettyBarPlots(subset(psd, Include == 1),varorder = 'M1_TasteWeight', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(subset(psd, Include == 1),varorder = 'M1_HealthWeight', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(subset(psd, Include == 1),varorder = 'M1_Intercept', gpFactor = 'Cond', clrs = clrs)

PrettyBarPlots(subset(psd, Include == 1),varorder = 'M2_FirstDevTasteWeight', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(subset(psd, Include == 1),varorder = 'M2_FirstDevHealthWeight', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(subset(psd, Include == 1),varorder = 'M2_FirstDevIntercept', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))

PrettyBarPlots(psd,varorder = 'PercentChoseHT', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'PercentChoseHUT', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'PercentChoseUHT', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'PercentChoseUHUT', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'PercentChoseHealthiest', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'PercentChoseTastiest', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))

PrettyBarPlots(psd,varorder = 'NChangeMind', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))

PrettyBarPlots(psd,varorder = 'LikingChangeAll', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'LikingChangeTasty', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'LikingChangeHealth', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'LikingChangeHUT', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'LikingChangeUHT', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'LikingChangeHT', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'LikingChangeUnhealthy', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))
PrettyBarPlots(psd,varorder = 'LikingChangeUntasty', gpFactor = 'Cond', clrs = clrs, xlbl = c('Nat','Health','Decrease'))

summary(lme(Choice ~ Taste + Amount + Health + Liking1, random = ~1|Subject, na.action = na.omit
            , data = subset(ChoiceData, Instruction == 'Decrease Desire')))
summary(lme(Choice ~ Taste + Amount + Health + Liking1, random = ~1|Subject, na.action = na.omit
            , data = subset(ChoiceData, Instruction == 'Respond Naturally')))
summary(lme(Choice ~ Taste + Amount + Health + Liking1, random = ~1|Subject, na.action = na.omit
            , data = subset(ChoiceData, Instruction == 'Focus on Healthiness')))

summary(glmer(Choice ~ Taste*Instruction + Health*Instruction + Liking1*Instruction
              + (1|Subject) + (Taste|Subject) + (Health|Subject) + (Liking1|Subject) + (Instruction|Subject)
              , family = binomial(link = 'logit'), na.action = na.omit
            , data = subset(ChoiceData, Instruction != 'Respond Naturally' & !Subject %in% c(22,35))))

summary(glmer(Choice ~ Taste*Instruction + Health*Instruction + Liking1*Instruction
              + (1|Subject) + (Taste|Subject) + (Health|Subject) + (Liking1|Subject) + (Instruction|Subject)
              , family = binomial(link = 'logit'), na.action = na.omit
              , data = subset(ChoiceData)))

summary(aov(PercentAccepted~Instruction, data = subset(psd,Instruction != 'nat')))
summary(aov(PercentAccepted~Subject%%3, data = subset(psd,Instruction == 'nat')))

t.test(psd$PercentAccepted[psd$Instruction == 'healthy'], psd$PercentAccepted[psd$Instruction == 'decrease'])
t.test(psd$PercentAccepted[psd$Instruction == 'unhealthy'], psd$PercentAccepted[psd$Instruction == 'decrease'])
t.test(psd$PercentAccepted[psd$Instruction == 'unhealthy'], psd$PercentAccepted[psd$Instruction == 'healthy'], var.equal = TRUE)

# mod(0) = healthy, mod(1) = unhealthy, mod(2) = decrease
summary(aov(RT~Cond, data = psd))
summary(aov(RT~Instruction, data = subset(psd,Instruction != 'nat')))
summary(aov(RT~Subject%%3, data = subset(psd,Instruction == 'nat')))

t.test(psd$RT[psd$Cond == 'reg' & psd$Subject %% 3 == 0], psd$RT[psd$Cond == 'nat' & psd$Subject %% 3 == 0], paired = TRUE)
t.test(psd$RT[psd$Cond == 'reg' & psd$Subject %% 3 == 1], psd$RT[psd$Cond == 'nat' & psd$Subject %% 3 == 1], paired = TRUE)
t.test(psd$RT[psd$Cond == 'reg' & psd$Subject %% 3 == 2], psd$RT[psd$Cond == 'nat' & psd$Subject %% 3 == 2], paired = TRUE)


t.test(psd$RT[psd$Instruction == 'healthy'], psd$RT[psd$Instruction == 'decrease'], var.equal = TRUE)
t.test(psd$RT[psd$Cond == 'reg' & psd$Subject %% 3 == 1] - psd$RT[psd$Cond == 'nat' & psd$Subject %% 3 == 1]
       , psd$RT[psd$Cond == 'reg' & psd$Subject %% 3 == 0] - psd$RT[psd$Cond == 'nat' & psd$Subject %% 3 == 0], var.equal = TRUE)

t.test(psd$RT[psd$Cond == 'reg' & psd$Subject %% 3 == 2] - psd$RT[psd$Cond == 'nat' & psd$Subject %% 3 == 2]
       , psd$RT[psd$Cond == 'reg' & psd$Subject %% 3 == 0] - psd$RT[psd$Cond == 'nat' & psd$Subject %% 3 == 0], var.equal = TRUE)

t.test(psd$PercentChoseHT[psd$Instruction == 'healthy'], psd$PercentChoseHT[psd$Instruction == 'decrease'])
t.test(psd$PercentChoseHUT[psd$Instruction == 'healthy'], psd$PercentChoseHUT[psd$Instruction == 'decrease'])
t.test(psd$PercentChoseUHT[psd$Instruction == 'healthy'], psd$PercentChoseUHT[psd$Instruction == 'decrease'])
t.test(psd$PercentChoseUHUT[psd$Instruction == 'healthy'], psd$PercentChoseUHUT[psd$Instruction == 'decrease'])

t.test(psd$PercentChoseHT[psd$Instruction == 'healthy'], psd$PercentChoseHT[psd$Instruction == 'unhealthy'])
t.test(psd$PercentChoseHUT[psd$Instruction == 'healthy'], psd$PercentChoseHUT[psd$Instruction == 'unhealthy'])
t.test(psd$PercentChoseUHT[psd$Instruction == 'healthy'], psd$PercentChoseUHT[psd$Instruction == 'unhealthy'])
t.test(psd$PercentChoseUHUT[psd$Instruction == 'healthy'], psd$PercentChoseUHUT[psd$Instruction == 'unhealthy'])

healthygp_reg = psd$Subject %% 3 == 0 & psd$Cond == 'reg'
unhealthygp_reg = psd$Subject %% 3 == 1 & psd$Cond == 'reg'
decreasegp_reg = psd$Subject %% 3 == 2 & psd$Cond == 'reg'
healthygp_nat = psd$Subject %% 3 == 0 & psd$Cond == 'nat'
unhealthygp_nat = psd$Subject %% 3 == 1 & psd$Cond == 'nat'
decreasegp_nat = psd$Subject %% 3 == 2 & psd$Cond == 'nat'

# decrease desire vs. avoid unhealthy
t.test(psd$PercentChoseHT[unhealthygp_reg] - psd$PercentChoseHT[unhealthygp_nat]
       , psd$PercentChoseHT[decreasegp_reg] - psd$PercentChoseHT[decreasegp_nat])

t.test(psd$PercentChoseHUT[unhealthygp_reg] - psd$PercentChoseHUT[unhealthygp_nat]
       , psd$PercentChoseHUT[decreasegp_reg] - psd$PercentChoseHUT[decreasegp_nat])

t.test(psd$PercentChoseUHT[unhealthygp_reg] - psd$PercentChoseUHT[unhealthygp_nat]
       , psd$PercentChoseUHT[decreasegp_reg] - psd$PercentChoseUHT[decreasegp_nat], var.equal = TRUE)

t.test(psd$PercentChoseUHUT[unhealthygp_reg] - psd$PercentChoseUHUT[unhealthygp_nat]
       , psd$PercentChoseUHUT[decreasegp_reg] - psd$PercentChoseUHUT[decreasegp_nat], var.equal = TRUE)

# decrease desire vs healthy approach focus
t.test(psd$PercentChoseHT[healthygp_reg] - psd$PercentChoseHT[healthygp_nat]
       , psd$PercentChoseHT[decreasegp_reg] - psd$PercentChoseHT[decreasegp_nat])

t.test(psd$PercentChoseHUT[healthygp_reg] - psd$PercentChoseHUT[healthygp_nat]
       , psd$PercentChoseHUT[decreasegp_reg] - psd$PercentChoseHUT[decreasegp_nat])

t.test(psd$PercentChoseUHT[healthygp_reg] - psd$PercentChoseUHT[healthygp_nat]
       , psd$PercentChoseUHT[decreasegp_reg] - psd$PercentChoseUHT[decreasegp_nat], var.equal = TRUE)

t.test(psd$PercentChoseUHUT[healthygp_reg] - psd$PercentChoseUHUT[healthygp_nat]
       , psd$PercentChoseUHUT[decreasegp_reg] - psd$PercentChoseUHUT[decreasegp_nat], var.equal = TRUE)

# approach healthy vs avoid unhealthy gp
t.test(psd$PercentChoseHT[healthygp_reg] - psd$PercentChoseHT[healthygp_nat]
       , psd$PercentChoseHT[unhealthygp_reg] - psd$PercentChoseHT[unhealthygp_nat])

t.test(psd$PercentChoseHUT[healthygp_reg] - psd$PercentChoseHUT[healthygp_nat]
       , psd$PercentChoseHUT[unhealthygp_reg] - psd$PercentChoseHUT[unhealthygp_nat])

t.test(psd$PercentChoseUHT[healthygp_reg] - psd$PercentChoseUHT[healthygp_nat]
       , psd$PercentChoseUHT[unhealthygp_reg] - psd$PercentChoseUHT[unhealthygp_nat], var.equal = TRUE)

t.test(psd$PercentChoseUHUT[healthygp_reg] - psd$PercentChoseUHUT[healthygp_nat]
       , psd$PercentChoseUHUT[unhealthygp_reg] - psd$PercentChoseUHUT[unhealthygp_nat], var.equal = TRUE)


quartz('',4,2.5); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = c('PercentChoseUHUT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.22))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = c('PercentChoseUHUT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.22))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = c('PercentChoseUHUT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.22))

quartz('',4,2.5); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = c('PercentChoseHUT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.35))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = c('PercentChoseHUT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.35))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = c('PercentChoseHUT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.35))

quartz('',4,2.5); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = c('PercentChoseUHT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.45))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = c('PercentChoseUHT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.45))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = c('PercentChoseUHT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.45))

quartz('',4,2.5); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = c('PercentChoseHT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.45))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = c('PercentChoseHT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.45))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = c('PercentChoseHT')
               , gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0,.45))


# 0 == Focus on Health
quartz('',7,3); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 2 == 0),varorder = 'RT', gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0, 1.5))
PrettyBarPlots(subset(psd,Subject %% 2 == 1),varorder = 'RT', gpFactor = 'Cond', clrs = c('red','blue'), yaxislim = c(0, 1.5))

t.test(psd$M1_HealthWeight[psd$Instruction == 'health'], psd$M1_HealthWeight[psd$Instruction == 'decrease'], var.equal = TRUE)

t.test(psd$NChangeMind[healthygp_reg], psd$NChangeMind[healthygp_nat], paired = TRUE)
t.test(psd$NChangeMind[unhealthygp_reg], psd$NChangeMind[unhealthygp_nat], paired = TRUE)
t.test(psd$NChangeMind[decreasegp_reg], psd$NChangeMind[decreasegp_nat], paired = TRUE)

t.test(psd$NChangeMind[healthygp_reg] - psd$NChangeMind[healthygp_nat]
       , psd$NChangeMind[unhealthygp_reg] - psd$NChangeMind[unhealthygp_nat], var.equal = TRUE)

t.test(psd$NChangeMind[healthygp_reg] - psd$NChangeMind[healthygp_nat]
       , psd$NChangeMind[decreasegp_reg] - psd$NChangeMind[decreasegp_nat], var.equal = TRUE)

t.test(psd$NChangeMind[unhealthygp_reg] - psd$NChangeMind[unhealthygp_nat]
       , psd$NChangeMind[decreasegp_reg] - psd$NChangeMind[decreasegp_nat], var.equal = TRUE)

quartz('',4,2.5); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = 'NChangeMind', gpFactor = 'Cond', clrs = c('red','blue'))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = 'NChangeMind', gpFactor = 'Cond', clrs = c('red','blue'))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = 'NChangeMind', gpFactor = 'Cond', clrs = c('red','blue'))

quartz('',4,2.5); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = 'PercentAccepted', gpFactor = 'Cond', clrs = c('red','blue'))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = 'PercentAccepted', gpFactor = 'Cond', clrs = c('red','blue'))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = 'PercentAccepted', gpFactor = 'Cond', clrs = c('red','blue'))

quartz('',4,2.5); currDev = dev.cur()
par(mfrow = c(1,3))
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = 'RT', gpFactor = 'Cond', clrs = c('red','blue'))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = 'RT', gpFactor = 'Cond', clrs = c('red','blue'))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = 'RT', gpFactor = 'Cond', clrs = c('red','blue'))



t.test(psd$M1_Intercept[psd$Instruction == 'healthy'], psd$M1_Intercept[psd$Instruction == 'decrease'], var.equal = TRUE)
t.test(psd$M1_Intercept[healthygp_nat], psd$M1_Intercept[decreasegp_nat], var.equal = TRUE)


t.test(psd$M1_TasteWeight[healthygp_nat], psd$M1_TasteWeight[unhealthygp_nat], var.equal = TRUE)
t.test(psd$M1_TasteWeight[healthygp_nat], psd$M1_TasteWeight[decreasegp_nat], var.equal = TRUE)
t.test(psd$M1_TasteWeight[unhealthygp_nat], psd$M1_TasteWeight[decreasegp_nat], var.equal = TRUE)

t.test(psd$M1_TasteWeight[healthygp_reg], psd$M1_TasteWeight[unhealthygp_reg], var.equal = TRUE)
t.test(psd$M1_TasteWeight[healthygp_reg], psd$M1_TasteWeight[decreasegp_reg], var.equal = TRUE)
t.test(psd$M1_TasteWeight[unhealthygp_reg], psd$M1_TasteWeight[decreasegp_reg], var.equal = TRUE)

t.test(psd$M1_TasteWeight[healthygp_reg], psd$M1_TasteWeight[healthygp_nat], paired = TRUE)
t.test(psd$M1_TasteWeight[unhealthygp_reg], psd$M1_TasteWeight[unhealthygp_nat], paired = TRUE)
t.test(psd$M1_TasteWeight[decreasegp_reg], psd$M1_TasteWeight[decreasegp_nat], paired = TRUE)

t.test(psd$M1_TasteWeight[healthygp_reg] - psd$M1_TasteWeight[healthygp_nat], 
       psd$M1_TasteWeight[unhealthygp_reg] - psd$M1_TasteWeight[unhealthygp_nat], 
       var.equal = TRUE)

t.test(psd$M1_HealthWeight[healthygp_reg] - psd$M1_HealthWeight[healthygp_nat], 
       psd$M1_HealthWeight[unhealthygp_reg] - psd$M1_HealthWeight[unhealthygp_nat], 
       var.equal = TRUE)

t.test(psd$M1_TasteWeight[healthygp_reg] - psd$M1_TasteWeight[healthygp_nat], 
       psd$M1_TasteWeight[decreasegp_reg] - psd$M1_TasteWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M1_HealthWeight[healthygp_reg] - psd$M1_HealthWeight[healthygp_nat], 
       psd$M1_HealthWeight[decreasegp_reg] - psd$M1_HealthWeight[decreasegp_nat], 
       var.equal = TRUE)


t.test(psd$M5_TasteWeight[healthygp_reg] - psd$M5_TasteWeight[healthygp_nat], 
       psd$M5_TasteWeight[decreasegp_reg] - psd$M5_TasteWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_LikingWeight[healthygp_reg] - psd$M5_LikingWeight[healthygp_nat], 
       psd$M5_LikingWeight[decreasegp_reg] - psd$M5_LikingWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_HealthWeight[healthygp_reg] - psd$M5_HealthWeight[healthygp_nat], 
       psd$M5_HealthWeight[decreasegp_reg] - psd$M5_HealthWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_TasteWeight[unhealthygp_reg] - psd$M5_TasteWeight[unhealthygp_nat], 
       psd$M5_TasteWeight[decreasegp_reg] - psd$M5_TasteWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_LikingWeight[unhealthygp_reg] - psd$M5_LikingWeight[unhealthygp_nat], 
       psd$M5_LikingWeight[decreasegp_reg] - psd$M5_LikingWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_HealthWeight[unhealthygp_reg] - psd$M5_HealthWeight[unhealthygp_nat], 
       psd$M5_HealthWeight[decreasegp_reg] - psd$M5_HealthWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M1_Intercept[unhealthygp_reg] - psd$M1_Intercept[unhealthygp_nat], 
       psd$M1_Intercept[healthygp_reg] - psd$M1_Intercept[healthygp_nat], 
       var.equal = TRUE)

t.test(psd$M5_Intercept[healthygp_reg] - psd$M5_Intercept[healthygp_nat], 
       psd$M5_Intercept[decreasegp_reg] - psd$M5_Intercept[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_Intercept[unhealthygp_reg] - psd$M5_Intercept[unhealthygp_nat], 
       psd$M5_Intercept[decreasegp_reg] - psd$M5_Intercept[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_Intercept[unhealthygp_reg] - psd$M5_Intercept[unhealthygp_nat], 
       psd$M5_Intercept[healthygp_reg] - psd$M5_Intercept[healthygp_nat], 
       var.equal = TRUE)

t.test(psd$M5_TasteWeight[unhealthygp_reg] - psd$M5_TasteWeight[unhealthygp_nat], 
       psd$M5_TasteWeight[healthygp_reg] - psd$M5_TasteWeight[healthygp_nat], 
       var.equal = TRUE)

t.test(psd$M5_HealthWeight[unhealthygp_reg] - psd$M5_HealthWeight[unhealthygp_nat], 
       psd$M5_HealthWeight[healthygp_reg] - psd$M5_HealthWeight[healthygp_nat], 
       var.equal = TRUE)

t.test(psd$M5_LikingWeight[unhealthygp_reg] - psd$M5_LikingWeight[unhealthygp_nat], 
       psd$M5_LikingWeight[healthygp_reg] - psd$M5_LikingWeight[healthygp_nat], 
       var.equal = TRUE)

t.test(psd$M5_LikingWeight[healthygp_reg] - psd$M5_LikingWeight[healthygp_nat], 
       psd$M5_LikingWeight[decreasegp_reg] - psd$M5_LikingWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M5_TasteWeight[healthygp_reg] - psd$M5_TasteWeight[healthygp_nat], 
       psd$M5_TasteWeight[decreasegp_reg] - psd$M5_TasteWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M2_FirstDevTasteWeight[healthygp_reg] - psd$M2_FirstDevTasteWeight[healthygp_nat], 
       psd$M2_FirstDevTasteWeight[decreasegp_reg] - psd$M2_FirstDevTasteWeight[decreasegp_nat], 
       var.equal = TRUE)

t.test(psd$M2_FirstDevTasteWeight[healthygp_reg],psd$M2_FirstDevTasteWeight[healthygp_nat], paired = TRUE) 
       
t.test(psd$M6_FirstDevLikingWeight[healthygp_reg],psd$M6_FirstDevLikingWeight[healthygp_nat], paired = TRUE) 



t.test(psd$M1_HealthWeight[unhealthygp_reg] - psd$M1_HealthWeight[unhealthygp_nat], 
       psd$M1_HealthWeight[healthygp_reg] - psd$M1_HealthWeight[healthygp_nat], 
       var.equal = TRUE)

t.test(psd$M1_TasteWeight[unhealthygp_reg] - psd$M1_TasteWeight[unhealthygp_nat], 
       psd$M1_TasteWeight[healthygp_reg] - psd$M1_TasteWeight[healthygp_nat], 
       var.equal = TRUE)



t.test(psd$M1_TasteWeight[unhealthygp_reg], psd$M1_TasteWeight[unhealthygp_nat], var.equal = TRUE)
t.test(psd$M1_TasteWeight[decreasegp_reg], psd$M1_TasteWeight[decreasegp_nat], var.equal = TRUE)


t.test(psd$M1_HealthWeight[psd$Instruction == 'nat' & psd$Subject %% 3 == 0], psd$M1_HealthWeight[psd$Instruction == 'nat' & psd$Subject %% 3 == 2], var.equal = TRUE)
t.test(psd$M1_HealthWeight[psd$Instruction == 'nat' & psd$Subject %% 3 == 0], psd$M1_HealthWeight[psd$Instruction == 'nat' & psd$Subject %% 3 == 1], var.equal = TRUE)
t.test(psd$M1_HealthWeight[psd$Instruction == 'nat' & psd$Subject %% 3 == 2], psd$M1_HealthWeight[psd$Instruction == 'nat' & psd$Subject %% 3 == 1], var.equal = TRUE)

t.test(psd$M1_HealthWeight[psd$Cond == 'reg' & psd$Subject %% 3 == 2], psd$M1_HealthWeight[psd$Cond == 'nat'& psd$Subject %% 3 == 2], paired = TRUE)
t.test(psd$M1_HealthWeight[psd$Cond == 'reg' & psd$Subject %% 3 == 1], psd$M1_HealthWeight[psd$Cond == 'nat'& psd$Subject %% 3 == 1], paired = TRUE)
t.test(psd$M1_HealthWeight[psd$Cond == 'reg' & psd$Subject %% 3 == 0], psd$M1_HealthWeight[psd$Cond == 'nat'& psd$Subject %% 3 == 0], paired = TRUE)

t.test(psd$M3_LikingWeight[psd$Instruction == 'health'], psd$M3_LikingWeight[psd$Instruction == 'decrease'], var.equal = TRUE)
t.test(psd$M1_TasteWeight[psd$Cond == 'nat' & psd$Subject %% 3 == 1]
       , psd$M1_TasteWeight[psd$Cond == 'nat' & psd$Subject %% 3 == 0], var.equal = TRUE)
t.test(psd$M1_HealthWeight[psd$Cond == 'nat' & psd$Subject %% 3 == 1]
       , psd$M1_HealthWeight[psd$Cond == 'nat' & psd$Subject %% 3 == 0], var.equal = TRUE)

t.test(psd$HealthRegSucc[psd$Instruction == 'healthy'], psd$HealthRegSucc[psd$Instruction == 'decrease'], var.equal = TRUE)
t.test(psd$HealthRegSucc[psd$Instruction == 'healthy'], psd$HealthRegSucc[psd$Instruction == 'unhealthy'], var.equal = TRUE)
t.test(psd$HealthRegSucc[psd$Instruction == 'decrease'], psd$HealthRegSucc[psd$Instruction == 'unhealthy'], var.equal = TRUE)

t.test(psd$TasteRegSucc[psd$Instruction == 'healthy'], psd$TasteRegSucc[psd$Instruction == 'decrease'], var.equal = TRUE)
t.test(psd$TasteRegSucc[psd$Instruction == 'unhealthy'], psd$TasteRegSucc[psd$Instruction == 'decrease'], var.equal = TRUE)
t.test(psd$TasteRegSucc[psd$Instruction == 'healthy'], psd$TasteRegSucc[psd$Instruction == 'unhealthy'], var.equal = TRUE)

t.test(psd$HealthRegSucc[psd$Instruction == 'healthy'], psd$HealthRegSucc[psd$Instruction == 'unhealthy'], var.equal = TRUE)
t.test(psd$TasteRegSucc[psd$Instruction == 'healthy'], psd$TasteRegSucc[psd$Instruction == 'unhealthy'], var.equal = TRUE)


dev.set(currDev)
PrettyBarPlots(subset(psd,Subject %% 3 == 0),varorder = c('M1_TasteWeight','M1_HealthWeight'), gpFactor = 'Cond'
               , clrs = c('red','midnightblue'), dispSigPrd = FALSE, yaxislim = c(-.25, 1.5))
PrettyBarPlots(subset(psd,Subject %% 3 == 1),varorder = c('M1_TasteWeight','M1_HealthWeight'), gpFactor = 'Cond'
               , clrs = c('red','midnightblue'), dispSigPrd = FALSE, yaxislim = c(-.25, 1.5))
PrettyBarPlots(subset(psd,Subject %% 3 == 2),varorder = c('M1_TasteWeight','M1_HealthWeight'), gpFactor = 'Cond'
               , clrs = c('red','midnightblue'), dispSigPrd = FALSE, yaxislim = c(-.25, 1.5))
quartz('',6,3); par(mfrow = c(1,2))
PrettyBarPlots(subset(psd,Subject %% 2 == 1),varorder = c('TasteRegSucc','HealthRegSucc') 
               , clrs = c('red','midnightblue'), dispSigPrd = FALSE, yaxislim = c(-.25, 1))
PrettyBarPlots(subset(psd,Subject %% 2 == 0),varorder = c('TasteRegSucc','HealthRegSucc')
               , clrs = c('red','midnightblue'), dispSigPrd = FALSE, yaxislim = c(-.25, 1))

psd$TasteRegSuccRev = -1*psd$TasteRegSucc
quartz('',6,3); par(mfrow = c(1,2))
PrettyBarPlots(subset(psd,Subject %% 2 == 1),varorder = c('TasteRegSuccRev','HealthRegSucc') 
               , clrs = c('red','midnightblue'), dispSigPrd = FALSE, yaxislim = c(-.75, .75))
PrettyBarPlots(subset(psd,Subject %% 2 == 0),varorder = c('TasteRegSuccRev','HealthRegSucc')
               , clrs = c('red','midnightblue'), dispSigPrd = FALSE, yaxislim = c(-.75, .75))


t.test(psd$M2_FirstDevTasteWeight[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$M2_FirstDevTasteWeight[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)

t.test(psd$M2_FirstDevTasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 1]
       , psd$M2_FirstDevTasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 0], var.equal = TRUE)
t.test(psd$M2_FirstDevTasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 1] - psd$M2_FirstDevTasteWeight[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$M2_FirstDevTasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 0] - psd$M2_FirstDevTasteWeight[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)
t.test(psd$M1_TasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 1] - psd$M1_TasteWeight[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$M1_TasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 0] - psd$M1_TasteWeight[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)



t.test(psd$M1_TasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 1]
       , psd$M1_TasteWeight[psd$Cond == 'reg' & psd$Subject %% 2 == 0], var.equal = TRUE)
t.test(psd$M1_Intercept[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$M1_Intercept[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)
t.test(psd$M1_Intercept[psd$Cond == 'reg' & psd$Subject %% 2 == 1]
       , psd$M1_Intercept[psd$Cond == 'reg' & psd$Subject %% 2 == 0], var.equal = TRUE)

t.test(psd$M2_Intercept[psd$Cond == 'reg' & psd$Subject %% 2 == 1]
       , psd$M2_Intercept[psd$Cond == 'reg' & psd$Subject %% 2 == 0], var.equal = TRUE)
t.test(psd$M2_Intercept[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$M2_Intercept[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)




t.test(psd$PercentAccepted[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$PercentAccepted[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)

t.test(psd$PercentAccepted[psd$Cond == 'reg' & psd$Subject %% 2 == 1]
       , psd$PercentAccepted[psd$Cond == 'reg' & psd$Subject %% 2 == 0], var.equal = TRUE)

t.test(psd$HealthWeightLiking[psd$Cond == 'reg' & psd$Subject %% 2 == 1]
       , psd$HealthWeightLiking[psd$Cond == 'reg' & psd$Subject %% 2 == 0], var.equal = TRUE)

t.test(psd$HealthWeightLiking[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$HealthWeightLiking[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)

t.test(psd$TasteWeightLiking[psd$Cond == 'nat' & psd$Subject %% 2 == 1]
       , psd$TasteWeightLiking[psd$Cond == 'nat' & psd$Subject %% 2 == 0], var.equal = TRUE)

t.test(psd$TasteWeightLiking[psd$Cond == 'reg' & psd$Subject %% 2 == 1]
       , psd$TasteWeightLiking[psd$Cond == 'reg' & psd$Subject %% 2 == 0], var.equal = TRUE)




StatsPerCondition = function(psd,varname, nDig = 2){
  var = psd[varname]
  stats = data.frame(Cond = c('nat','health','decrease'),
                     N = NA, Mean = NA, SD = NA, Min = NA, Max = NA, vZero = NA, vNat = NA, vHealth = NA, vDecrease = NA)
  c = 1
  Conditions = c('nat','health', 'decrease')
  tstats = vector(mode = 'character', length = 3)
  for(cond in Conditions){
    tVal = t.test(var[psd['Cond'] == cond])
    v0 = paste(formatC(tVal$statistic,digits = 2, format = "f"),'/',
               formatC(tVal$p.value,digits = 3, format = "f"),sep = "")
    for(t in 1:3){
      if(Conditions[t] == cond){
        tstats[t] = "."
      }else{
        tVal = t.test(var[psd['Cond'] == Conditions[t]], var[psd['Cond'] == cond], paired = TRUE)  
        tstats[t] = paste(formatC(tVal$statistic,digits = 2, format = "f"),'/',
                          formatC(tVal$p.value,digits = 3, format = "f"),sep = "")
      }
      
    }
    stats$N[c] = length(var[psd['Cond'] == cond & !is.na(var)]) # no. of observations
    stats$Mean[c] = mean(var[psd['Cond'] == cond], na.rm = TRUE) # mean
    stats$SD[c] = sd(var[psd['Cond'] == cond], na.rm = TRUE)
    stats$Min[c] = min(var[psd['Cond'] == cond], na.rm = TRUE)
    stats$Max[c] = max(var[psd['Cond'] == cond], na.rm = TRUE)
    stats[c,7:10] = c(v0,tstats)
    c = c + 1
  }
  print(format(stats, digits = nDig))
  print("")
  print("ANOVA: All Conditions")
  #a = summary(aov((formula(paste(varname, '~Cond + Error(Subject/Condition)'))), data = psd, na.action = na.omit))
  #a2 = summary(aov((formula(paste(varname, '~Cond + Error(Subject/Condition)'))), data = psd[psd$Condition != 'None',], na.action = na.omit))
  lmeFit <- lme(formula(paste(varname, '~Cond')), random=~1 | Subject, correlation=corCompSymm(form=~1|Subject),
                method="ML", data=psd, na.action = na.omit)
  print(anova(lmeFit))
  
  #print(a$"Error: Within"[[1]])
  #eta2 = a$"Error: Within"[[1]]['Condition','Sum Sq']/sum(c(a$"Error: Within"[[1]][,"Sum Sq"]),a$"Error: Subject"[[1]]$"Sum Sq")
  #print('Effect size eta^2')
  #   print(eta2)
  #   print("")
  #   print('ANOVA: 3 conditions only')
  #   print(a2$"Error: Within"[[1]])
}

for(pckg in c('nlme','lme4','MASS','ggplot2','logistf','reshape2','car')){
  library(pckg, character.only = TRUE)
}
rm(pckg)


source('Analysis/MouseAnalysis.R')
source('Analysis/PlotIndivMouseAnalysis.R')
xclude = function(x){subjNames %in% x}
PlotDataInCond = function(e, PredVars, Cond, filterOut = 0, ...){
  PlotData = lapply(mget(paste(PredVars,'Effects',gsub("\\s", "", Cond),sep = ""),envir=e),
                    function(x){x[xclude(filterOut),] = NA; return(x)})
  ylims = lineanderrbars(PlotData, newPlot = TRUE,
                         ylab = 'Effect on Trajectory',xlab = 'Time (ms)',xScale = c(0,16.67), linesAt = 0, ...)
  
}

PlotVarByCond = function(e, PredVar, whichConds = 1:4, filterOut = 0, ...){
  Conds = c('nat','decrease','healthy','unhealthy')
  PlotData = lapply(mget(paste(PredVar,'Effects',gsub("\\s", "", Conds[whichConds]),sep = ""),envir=e),
                    function(x){x[xclude(filterOut),] = NA; return(x)})
  
  ylims = lineanderrbars(PlotData, newPlot = TRUE,
                         ylab = 'Effect on Trajectory',xlab = 'Time (ms)',xScale = c(0,16.67), linesAt = 0, ...)
  
}

PlotVarInGroupByCond = function(e, PredVar, whichGp = 1, ...){
  if(whichGp == 1){
    Conds = c('nat','healthy')
    filter = subjNames[subjNames %% 3 != 0]
  }
  
  if(whichGp == 2){
    Conds = c('nat','unhealthy')
    filter = subjNames[subjNames %% 3 != 1]
  }
  if(whichGp == 3){
    Conds = c('nat','decrease')
    filter = subjNames[subjNames %% 3 != 2]
  }
  PlotData = c(lapply(mget(paste(PredVar,'Effects',gsub("\\s", "", Conds[1]),sep = ""),envir=e),
                      function(x){x[xclude(filter),] = NA; return(x)}),
               lapply(mget(paste(PredVar,'Effects',gsub("\\s", "", Conds[2]),sep = ""),envir=e),
                      function(x){x[xclude(filter),] = NA; return(x)}))
  
  ylims = lineanderrbars(PlotData, newPlot = TRUE,
                         ylab = 'Effect on Trajectory',xlab = 'Time (ms)',xScale = c(0,16.67)
                         , linesAt = 0, linetype = rep(1,2), ...)
  
}

PlotVarByGroupByCond = function(e, PredVar, whichConds = 1:3, ...){
  Conds1 = c('nat','healthy')
  Conds2 = c('nat','unhealthy')
  Conds3 = c('nat','decrease')
  PlotData = c(lapply(mget(paste(PredVar,'Effects',gsub("\\s", "", Conds1[whichConds]),sep = ""),envir=e),
                    function(x){x[xclude(subjNames[subjNames %% 3 == 0]),] = NA; return(x)}),
                  lapply(mget(paste(PredVar,'Effects',gsub("\\s", "", Conds2[whichConds]),sep = ""),envir=e),
                         function(x){x[xclude(subjNames[subjNames %% 3 == 1]),] = NA; return(x)}),
               lapply(mget(paste(PredVar,'Effects',gsub("\\s", "", Conds3[whichConds]),sep = ""),envir=e),
                      function(x){x[xclude(subjNames[subjNames %% 3 == 2]),] = NA; return(x)}))
                  
  ylims = lineanderrbars(PlotData, newPlot = TRUE,
                         ylab = 'Effect on Trajectory',xlab = 'Time (ms)',xScale = c(0,16.67)
                         , linesAt = 0, linetype = rep(1:length(whichConds), each = 2), ...)
  
}


MouseData$DrxBin = MouseData$Drx
MouseData$DrxBin[MouseData$Drx == -1] = 0
PredVars = c('Taste','Health')
SimpleModel = MouseAnalysis(PredVars,MouseData,ChoiceData)
SimpleModelTraj = MouseAnalysis(PredVars,MouseData,ChoiceData, mouseVar = 'Trajectory', lmType = 'lm')

RegAnalysisTraj = list()
RegAnalysisTraj$HealthSucc_HvN = SimpleModelTraj$HealthEffectshealth - SimpleModelTraj$HealthEffectsnat
RegAnalysisTraj$TasteSucc_HvN = SimpleModelTraj$TasteEffectsnat - SimpleModelTraj$TasteEffectshealth
RegAnalysisTraj$Intercept_HvN = SimpleModelTraj$InterceptEffectshealth - SimpleModelTraj$InterceptEffectsnat
RegAnalysisTraj$HealthSucc_DvN = SimpleModelTraj$HealthEffectsdecrease - SimpleModelTraj$HealthEffectsnat
RegAnalysisTraj$TasteSucc_DvN = SimpleModelTraj$TasteEffectsnat - SimpleModelTraj$TasteEffectsdecrease
RegAnalysisTraj$Intercept_DvN = SimpleModelTraj$InterceptEffectsdecrease - SimpleModelTraj$InterceptEffectsnat

RegAnalysis = list()
RegAnalysis$HealthSucc_HvN = SimpleModel$HealthEffectshealth - SimpleModel$HealthEffectsnat
RegAnalysis$TasteSucc_HvN = SimpleModel$TasteEffectsnat - SimpleModel$TasteEffectshealth
RegAnalysis$Intercept_HvN = SimpleModel$InterceptEffectshealth - SimpleModel$InterceptEffectsnat
RegAnalysis$HealthSucc_DvN = SimpleModel$HealthEffectsdecrease - SimpleModel$HealthEffectsnat
RegAnalysis$TasteSucc_DvN = SimpleModel$TasteEffectsnat - SimpleModel$TasteEffectsdecrease
RegAnalysis$Intercept_DvN = SimpleModel$InterceptEffectsdecrease - SimpleModel$InterceptEffectsnat

PredVars = c(PredVars,'Intercept')
clrs = c('red','blue','black')
quartz('',5,4)
PlotDataInCond(SimpleModel,PredVars,Cond = 'nat',color = clrs[1:3], showPVals = list(1,2,3))

quartz('',5,4)
PlotDataInCond(SimpleModel,PredVars,Cond = 'health',color = clrs[1:3], showPVals = list(1,2,3))

quartz('',5,4)
PlotDataInCond(SimpleModel,PredVars,Cond = 'decrease',color = clrs[1:3], showPVals = list(1,2,3))

quartz('',5,4)
PlotDataInCond(SimpleModel,PredVars,Cond = 'decrease',color = clrs[1:2], showPVals = list(1,2))

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$TasteSucc_DvN, RegAnalysis$TasteSucc_HvN)
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$HealthSucc_DvN, RegAnalysis$HealthSucc_HvN)
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$Intercept_DvN, RegAnalysis$Intercept_HvN)
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')



quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$TasteSucc_DvN, RegAnalysis$TasteSucc_HvN)
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysisTraj$HealthSucc_DvN, RegAnalysisTraj$HealthSucc_HvN)
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysisTraj$Intercept_DvN, RegAnalysisTraj$Intercept_HvN)
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')


quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==1,], RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==1,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==2,], RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==2,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==0,], RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==2,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==1,], RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==2,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==0,], RegAnalysis$TasteSucc_HvN[subjNames %% 3 ==1,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==0,], RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==2,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==0,], RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==1,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==1,], RegAnalysis$HealthSucc_HvN[subjNames %% 3 ==2,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

quartz('',3.3, 2.6); par(mar = c(4,3,1,1) + .1); plotDevice = dev.cur()
lineanderrbars(list(RegAnalysisTraj$HealthSucc_HvN[subjNames %% 2 ==0,], RegAnalysisTraj$HealthSucc_HvN[subjNames %% 2 ==1,])
               , rawdata = TRUE, color = c('blue','red'), showPVals = list(1,2,c(1, 2))
               , newPlot = TRUE, linesAt = 0, xScale = c(0,16.667), xlab = "Time",ylab = 'Regulatory Success')

dev.copy2pdf(device = plotDevice, file = 'Figures/DrxTimeSeries_RegSuccessIncreaseHealthDecreaseTaste.pdf')

psd$ThinkHealthyDiff = psd$ThinkHealthyReg - psd$ThinkHealthyNat
psd$DecreaseDesireDiff = psd$DecreaseDesireReg - psd$DecreaseDesireNat
summary(lm(HealthSuccess ~ FocusUnhealthy + Avoid + ChangeThink + AvoidLook + Lied + FocusHealth + Decrease , data = subset(psd, Cond == 'reg')))
summary(lm(TasteSuccess ~ FocusUnhealthy + Avoid + ChangeThink + AvoidLook + Lied + FocusHealth + Decrease , data = subset(psd, Cond == 'reg')))

summary(lm(HealthSuccess ~ FocusUnhealthy + Avoid + ChangeThink + AvoidLook + Lied + FocusHealth + Decrease , data = subset(psd, Instruction == 'health')))
summary(lm(HealthSuccess ~ ChangeThink + AvoidLook, data = subset(psd, Instruction == 'health')))

summary(lm(HealthSuccess ~ FocusUnhealthy + Avoid + ChangeThink + AvoidLook + Lied + FocusHealth + Decrease , data = subset(psd, Instruction == 'decrease')))
summary(lm(HealthSuccess ~ Decrease , data = subset(psd, Instruction == 'decrease')))

summary(lm(TasteSuccess ~ FocusUnhealthy + Avoid + ChangeThink + AvoidLook + Lied + FocusHealth + Decrease , data = subset(psd, Instruction == 'health')))
summary(lm(TasteSuccess ~ Decrease , data = subset(psd, Instruction == 'health')))

summary(lm(TasteSuccess ~ Lied, data = subset(psd, Instruction == 'decrease')))
summary(lm(TasteSuccess ~ Lied, data = subset(psd, Instruction == 'health')))




summary(lm(HealthSuccess ~ FocusUnhealthy + Avoid + ChangeThink + AvoidLook + Lied + FocusHealth + Decrease , data = subset(psd, Instruction == 'health')))


summary(lm(TasteSuccess ~ FocusUnhealthy + Avoid + ChangeThink + AvoidLook + Lied + FocusHealth + Decrease , data = subset(psd, Cond == 'reg')))



summary(lm(RegSuccessHealth_TWeight ~ FocusedUnhealthy + FocusedHunger + Reappraised + Avoided + Lied, data = subset(psd, Condition == 'natural')))
summary(lm(RegSuccessHealth_Perc ~ FocusedUnhealthy + FocusedHunger + Reappraised + Avoided + Lied, data = subset(psd, Condition == 'natural')))



quartz('',5,4)
PlotDataInCond(SimpleModelTraj,PredVars,Cond = 'health',color = clrs[1:2], showPVals = list(1,2, c(1,2)))

quartz('',5,4)
PlotDataInCond(SimpleModelTraj,PredVars,Cond = 'nat',color = clrs[1:2], showPVals = list(1,2, c(1,2)))

quartz('',5,4)
PlotVarByCond(SimpleModelTraj,'Taste',whichConds = c(1,3),color = c('red','firebrick4'), filterOut = subjNames[subjNames %% 2 == 1], showPVals = list(1,2,c(1,2)))

quartz('',5,4)
PlotVarByCond(SimpleModelTraj,'Taste',whichConds = c(1,2),color = c('red','firebrick4'), filterOut = subjNames[subjNames %% 2 == 0], showPVals = list(1,2,c(1,2)))

quartz('',5,4)
PlotVarByCond(SimpleModelTraj,'Health',whichConds = c(1,3),color = c('blue','midnightblue'), ylim = c(-.05,.3), filterOut = subjNames[subjNames %% 2 == 1], showPVals = list(1,2,c(1,2)))

quartz('',5,4)
PlotVarByCond(SimpleModelTraj,'Health',whichConds = c(1,2),color = clrs[1:2], filterOut = subjNames[subjNames %% 2 == 1], showPVals = list(1,2,c(1,2)))

quartz('',5,4)
PlotVarByGroupByCond(SimpleModelTraj,'Health',whichConds = c(1,2),color = c('springgreen4','midnightblue','springgreen4','orange'), showPVals = list(1,2,3,4,c(1,2), c(3,4)))

quartz('',5,4)
PlotVarByGroupByCond(SimpleModelTraj,'Taste',whichConds = c(1,2),color = c('springgreen4','midnightblue','springgreen4','orange'), showPVals = list(1,2,3,4,c(1,2), c(3,4)))


#TFEQ correlates
with(subset(psd,Cond == 'nat'),summary(lm(TFQ_Restraint~ M1_TasteWeight + M1_HealthWeight))) # p .08 on Health
with(subset(psd,Cond == 'nat'),summary(lm(TFQ_Restraint~ M1_HealthWeight))) # .76, p .05 on Health
with(subset(psd,Cond == 'nat'),summary(lm(TFQ_EmotionalEating~ M1_TasteWeight + M1_HealthWeight))) # -.74, p .02 on Taste
with(subset(psd,Cond == 'nat'),summary(lm(TFQ_UncontrolledEating~ M1_TasteWeight + M1_HealthWeight))) # n.s.

with(subset(psd,Cond == 'reg'),summary(lm(TFQ_Restraint~ M1_TasteWeight + M1_HealthWeight))) # n.s.
with(subset(psd,Instruction == 'healthy'),summary(lm(TFQ_Restraint~ M1_TasteWeight + M1_HealthWeight))) # -1.04 health, p = .06
with(subset(psd,Instruction == 'unhealthy'),summary(lm(TFQ_Restraint~ M1_TasteWeight + M1_HealthWeight))) # n.s.
with(subset(psd,Instruction == 'decrease'),summary(lm(TFQ_Restraint~ M1_TasteWeight + M1_HealthWeight))) # n.s.

with(subset(psd,Cond == 'reg'),summary(lm(TFQ_EmotionalEating~ M1_TasteWeight + M1_HealthWeight))) # n.s.
with(subset(psd,Instruction == 'healthy'),summary(lm(TFQ_EmotionalEating~ M1_TasteWeight + M1_HealthWeight))) # -1.04 health, p = .06
with(subset(psd,Instruction == 'unhealthy'),summary(lm(TFQ_EmotionalEating~ M1_TasteWeight + M1_HealthWeight))) # n.s.
with(subset(psd,Instruction == 'decrease'),summary(lm(TFQ_EmotionalEating~ M1_TasteWeight + M1_HealthWeight))) # - for health and taste, p < .04

with(subset(psd,Cond == 'reg'),summary(lm(TFQ_UncontrolledEating~ M1_TasteWeight + M1_HealthWeight))) # n.s.
with(subset(psd,Instruction == 'healthy'),summary(lm(TFQ_UncontrolledEating~ M1_TasteWeight + M1_HealthWeight))) # -1.04 for taste, p = .05
with(subset(psd,Instruction == 'unhealthy'),summary(lm(TFQ_UncontrolledEating~ M1_TasteWeight + M1_HealthWeight))) # + for taste, p = .06, - for Health, p = .04
with(subset(psd,Instruction == 'decrease'),summary(lm(TFQ_UncontrolledEating~ M1_TasteWeight + M1_HealthWeight))) # - for health and taste, p < .04


# Food consumption habits
with(subset(psd,Cond == 'nat'),summary(lm(FiberConsumption~ M1_TasteWeight + M1_HealthWeight))) # p .01 Taste, p .05 Heaalth
with(subset(psd,Cond == 'nat'),summary(lm(VegConsumption~ M1_TasteWeight + M1_HealthWeight))) # p .06 Taste, p .06 Heaalth
with(subset(psd,Cond == 'nat'),summary(lm(VegConsumption~ M1_TasteWeight))) # p .01 Taste
with(subset(psd,Cond == 'nat'),summary(lm(VegConsumption~ M1_HealthWeight))) # p .01 Health
# others (Fatty Foods, MeatConsumption,FatConsumption,JunkConsumption) not significant
with(subset(psd,Cond == 'nat'),summary(lm(M1_TasteWeight ~ FiberConsumption + VegConsumption + FattyFoods + MeatConsumption + JunkConsumption + FatConsumption))) # p .01 Taste, p .05 Heaalth
with(subset(psd,Cond == 'nat'),summary(lm(M1_TasteWeight ~ M1_HealthWeight + FiberConsumption))) # p .01 Taste, p .05 Heaalth

with(subset(psd,Cond == 'nat'),summary(lm(M1_HealthWeight ~ FiberConsumption + VegConsumption + FattyFoods + MeatConsumption + JunkConsumption + FatConsumption))) # p .01 Taste, p .05 Heaalth
with(subset(psd,Cond == 'nat'),summary(lm(M1_HealthWeight ~ M1_TasteWeight + FiberConsumption))) # p .007 Fiber

# Barratt Impulsivity
with(subset(psd,Cond == 'nat'),summary(lm(BIS_SelfControl ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .01
with(subset(psd,Cond == 'nat'),summary(lm(BIS_CogComplexity ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Cond == 'nat'),summary(lm(BIS_Planning ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Cond == 'nat'),summary(lm(BIS_Attention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'nat'),summary(lm(BIS_CogInstability ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'nat'),summary(lm(BIS_OverallAttention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'nat'),summary(lm(BIS_Perseverance ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'nat'),summary(lm(BIS_Motor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'nat'),summary(lm(BIS_OverallMotor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04

with(subset(psd,Cond == 'reg'),summary(lm(BIS_SelfControl ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .01
with(subset(psd,Cond == 'reg'),summary(lm(BIS_CogComplexity ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Cond == 'reg'),summary(lm(BIS_Planning ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Cond == 'reg'),summary(lm(BIS_Attention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'reg'),summary(lm(BIS_CogInstability ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'reg'),summary(lm(BIS_OverallAttention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'reg'),summary(lm(BIS_Perseverance ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'reg'),summary(lm(BIS_Motor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Cond == 'reg'),summary(lm(BIS_OverallMotor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04

with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_SelfControl ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .01
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_CogComplexity ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_Planning ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_Attention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_CogInstability ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_OverallAttention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_Perseverance ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_Motor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'decrease'),summary(lm(BIS_OverallMotor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04

with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_SelfControl ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .01
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_CogComplexity ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_Planning ~ M1_TasteWeight + M1_HealthWeight))) # + Health, p = .05
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_Attention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_CogInstability ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_OverallAttention ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_Perseverance ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_Motor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04
with(subset(psd,Instruction == 'healthy'),summary(lm(BIS_OverallMotor ~ M1_TasteWeight + M1_HealthWeight))) # - Taste, p = .04


with(subset(psd,Cond == 'nat'),summary(lm(BISAttention ~ M1_TasteWeight + M1_HealthWeight))) # p .009 Taste
with(subset(psd,Cond == 'reg'),summary(lm(BISAttention ~ M1_TasteWeight + M1_HealthWeight))) # p .03 Taste
with(subset(psd,Cond == 'reg'),summary(lm(BISPerseverence ~ M1_TasteWeight + M1_HealthWeight))) # p .09 Taste
# no other factors significant


psd$HealthSuccess[psd$Cond == 'reg'] = with(psd,M1_HealthWeight[Cond == 'reg'] - M1_HealthWeight[Cond == 'nat'])
psd$TasteSuccess[psd$Cond == 'reg'] = with(psd,M1_TasteWeight[Cond == 'nat'] - M1_TasteWeight[Cond == 'reg'])
psd$TotalSuccess = psd$TasteRegSucc + psd$HealthRegSucc

with(subset(psd,Instruction == 'nat'),summary(lm(TFQ_Restraint~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'nat'),summary(lm(TFQ_EmotionalEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'nat'),summary(lm(TFQ_UncontrolledEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04

with(subset(psd,Instruction == 'healthy'),summary(lm(TFQ_Restraint~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'unhealthy'),summary(lm(TFQ_Restraint~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'decrease'),summary(lm(TFQ_Restraint~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04

with(subset(psd,Instruction == 'healthy'),summary(lm(TFQ_EmotionalEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'unhealthy'),summary(lm(TFQ_EmotionalEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'decrease'),summary(lm(TFQ_EmotionalEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04

with(subset(psd,Instruction == 'healthy'),summary(lm(TFQ_UncontrolledEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'unhealthy'),summary(lm(TFQ_UncontrolledEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04
with(subset(psd,Instruction == 'decrease'),summary(lm(TFQ_UncontrolledEating~ TasteRegSucc + HealthRegSucc))) # - for health and taste, p < .04


summary(lme(LikingChange ~ Choice, random = ~1|Subject
             , data = subset(ChoiceData, Condition == 'nat'), na.action = na.omit))

summary(lme(LikingChange ~ Choice*Condition, random = ~1 + Condition|Subject
            , data = ChoiceData, na.action = na.omit))


summary(lme(LikingChange ~ Choice*WantedToRating + Choice*HadToRating, random = ~1|Subject
            , data = subset(ChoiceData, Condition == 'nat'), na.action = na.omit))

summary(lme(Liking2 ~ Liking1 + Condition, random = ~1|Subject
            , data = subset(ChoiceData), na.action = na.omit))

summary(lmer(LikingChange ~ Choice*WantedToRating + Choice*HadToRating + (1|Subject)
             , data = subset(ChoiceData, Condition == 'nat'), na.action = na.omit))

summary(lmer(LikingChange ~ Choice*WantedToRating + Choice*HadToRating + (1|Subject)
             , data = subset(ChoiceData, Condition == 'decrease'), na.action = na.omit))

summary(lmer(LikingChange ~ Choice*WantedToRating + Choice*HadToRating + (1|Subject)
             , data = subset(ChoiceData, Condition == 'health'), na.action = na.omit))

summary(lmer(HadToRating ~ Choice + HadToRating + Liking1 + Taste + Health + (1|Subject)
             , data = subset(ChoiceData, Condition == 'health'), na.action = na.omit))
