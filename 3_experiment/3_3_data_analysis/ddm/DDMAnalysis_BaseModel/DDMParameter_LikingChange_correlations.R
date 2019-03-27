setwd('~/Desktop/Dropbox/Projects/FoodRegFMRI/')
d = read.csv('DDMAnalysis_BaseModel/DDM_ParameterEstimates_Bayes.csv')

LikingChange_DvN = d$LikingChange_Desire - d$LikingChange_Nat
LikingChange_HvN = d$LikingChange_Health - d$LikingChange_Nat

InterceptChange_DvN = d$InterceptChange_Desire - d$InterceptChange_Nat
InterceptChange_HvN = d$InterceptChange_Health - d$InterceptChange_Nat

TasteLikingChange_DvN = d$TasteChange_Desire - d$TasteChange_Nat
TasteLikingChange_HvN = d$TasteChange_Health - d$TasteChange_Nat

HealthLikingChange_DvN = d$HealthChange_Desire - d$HealthChange_Nat
HealthLikingChange_HvN = d$HealthChange_Health - d$HealthChange_Nat

TasteChange_DvN = d$Taste_Desire - d$Taste_Nat
HealthChange_DvN = d$Health_Desire - d$Health_Nat
BiasChange_DvN = d$StBias_Desire - d$StBias_Nat

TasteChange_HvN = d$Taste_Health - d$Taste_Nat
HealthChange_HvN = d$Health_Health - d$Health_Nat
BiasChange_HvN = d$StBias_Health - d$StBias_Nat

cor.test(LikingChange_DvN, TasteChange_DvN)
cor.test(LikingChange_DvN, HealthChange_DvN)
cor.test(LikingChange_DvN, BiasChange_DvN)

plot(LikingChange_DvN, TasteChange_DvN)
plot(LikingChange_DvN, HealthChange_DvN)
plot(LikingChange_DvN, BiasChange_DvN)

summary(lm(LikingChange_DvN ~ TasteChange_DvN + HealthChange_DvN + BiasChange_DvN))

cor.test(InterceptChange_DvN, TasteChange_DvN)
cor.test(InterceptChange_DvN, HealthChange_DvN)
cor.test(InterceptChange_DvN, BiasChange_DvN)

summary(lm(InterceptChange_DvN ~ TasteChange_DvN + HealthChange_DvN + BiasChange_DvN))

cor.test(TasteLikingChange_DvN, TasteChange_DvN)
cor.test(TasteLikingChange_DvN, HealthChange_DvN)
cor.test(TasteLikingChange_DvN, BiasChange_DvN)

summary(lm(TasteLikingChange_DvN ~ TasteChange_DvN + HealthChange_DvN + BiasChange_DvN))

cor.test(HealthLikingChange_DvN, TasteChange_DvN)
cor.test(HealthLikingChange_DvN, HealthChange_DvN)
cor.test(HealthLikingChange_DvN, BiasChange_DvN)

summary(lm(HealthLikingChange_DvN ~ TasteChange_DvN + HealthChange_DvN + BiasChange_DvN))

cor.test(LikingChange_HvN, TasteChange_HvN)
cor.test(LikingChange_HvN, HealthChange_HvN)
cor.test(LikingChange_HvN, BiasChange_HvN)

summary(lm(LikingChange_HvN ~ TasteChange_HvN + HealthChange_HvN + BiasChange_HvN))

cor.test(InterceptChange_HvN, TasteChange_HvN)
cor.test(InterceptChange_HvN, HealthChange_HvN)
cor.test(InterceptChange_HvN, BiasChange_HvN)

summary(lm(InterceptChange_HvN ~ TasteChange_HvN + HealthChange_HvN + BiasChange_HvN))

cor.test(TasteLikingChange_HvN, TasteChange_HvN)
cor.test(TasteLikingChange_HvN, HealthChange_HvN)
cor.test(TasteLikingChange_HvN, BiasChange_HvN)

plot(TasteLikingChange_HvN, TasteChange_HvN)
plot(TasteLikingChange_HvN, HealthChange_HvN)
plot(TasteLikingChange_HvN, BiasChange_HvN)

summary(lm(TasteLikingChange_HvN ~ TasteChange_HvN + HealthChange_HvN + BiasChange_HvN))

cor.test(HealthLikingChange_HvN, TasteChange_HvN)
cor.test(HealthLikingChange_HvN, HealthChange_HvN)
cor.test(HealthLikingChange_HvN, BiasChange_HvN)

summary(lm(HealthLikingChange_HvN ~ TasteChange_HvN + HealthChange_HvN + BiasChange_HvN))

