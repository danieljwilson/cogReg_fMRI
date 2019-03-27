# Behavioral
library(tidyverse)
library(lme4)
library(car)
library(ggplot2)
library(lmerTest)


# Load Data
load("FoodRegfMRI_dt.RData")
dt = full_dt

# The following lines of code mean-centre the predictors
dt = dt %>%
  mutate( pre_liking = pre_liking - mean(pre_liking, na.rm = T),
          post_liking = post_liking - mean(post_liking, na.rm = T),
          taste = taste - mean(taste, na.rm = T),
          health = health - mean(health, na.rm = T)
  )

# add choice column
dt$choice = 0
dt$choice[dt$resp > 2] = 1

# Reaction time between 3 conditions

by_cond <- dt %>% 
  group_by(cond)

by_cond %>% summarise(
  rt = mean(rt, na.rm = TRUE)
)

# Make three dts

dt_nat = dt[dt$cond == "Respond Naturally",]
dt_health = dt[dt$cond == "Focus on Healthiness",]
dt_dd = dt[dt$cond == "Decrease Desire",]

# Overall RTs
mean(dt_nat$rt, na.rm = TRUE)
mean(dt_dd$rt, na.rm = TRUE)
mean(dt_health$rt, na.rm = TRUE)

p <- ggplot(dt, aes(cond, rt))
p + geom_violin(draw_quantiles = c(0.25, 0.5, 0.75), aes(fill = cond))


m_rt = lmer(rt ~ cond + (1|subject), data = dt)
summary(m_rt)
anova(m_rt)

# Yes RTs
mean(dt$rt[dt$cond == "Respond Naturally" & dt$resp>2], na.rm = TRUE)
mean(dt$rt[dt$cond == "Decrease Desire" & dt$resp>2], na.rm = TRUE)
mean(dt$rt[dt$cond == "Focus on Healthiness" & dt$resp>2], na.rm = TRUE)

x = dt[dt$choice==1,]
p_yes <- ggplot(x, aes(cond, rt))
p_yes + geom_boxplot(aes(fill=cond))

# No RTs
mean(dt$rt[dt$cond == "Respond Naturally" & dt$resp<3], na.rm = TRUE)
mean(dt$rt[dt$cond == "Decrease Desire" & dt$resp<3], na.rm = TRUE)
mean(dt$rt[dt$cond == "Focus on Healthiness" & dt$resp<3], na.rm = TRUE)

x = dt[dt$choice==0,]
p_no <- ggplot(x, aes(cond, rt))
p_no + geom_boxplot(aes(fill=cond))

# Azadeh: important to select outliers (look in natural condition)

# Logistic regressions on taste and health
m_nat <- glmer(choice ~ taste + health + (1|subject),
               data = dt_nat, family = binomial,
               control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)

m_dd <- glmer(choice ~ taste + health + (1|subject),
              data = dt_dd, family = binomial,
              control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)

m_health <- glmer(choice ~ taste + health + (1|subject),
              data = dt_health, family = binomial,
              control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)

summary(m_nat)
summary(m_dd)
summary(m_health)
