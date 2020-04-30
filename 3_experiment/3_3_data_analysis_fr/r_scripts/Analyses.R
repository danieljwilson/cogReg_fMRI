#### Import libraries & Load Data ####
  
library(tidyverse)
library(lme4)
library(car)
library(ggplot2)
library(lmerTest)
library(broom)
library(data.table)

# Neither of these seem to work?
unloadNamespace("Rmisc")
detach("package:Rmisc", unload=TRUE)

source("helper_functions.R")

#### Load Data ####
load("../data/FoodRegfMRI_dt.RData")
dt = full_dt

# number of rows with NA values (example row 281/291...):
length(which(is.na(dt)))

# add some columns and center predictors, remove NA rows
dt = process_data_table(dt)

# Make condition dts
dt_nat = dt[dt$cond == "Respond Naturally",]
dt_health = dt[dt$cond == "Focus on Healthiness",]
dt_dd = dt[dt$cond == "Decrease Desire",]

# means by subject and by condition
  # and calculate health/taste change w/baseline
dt_subj = by_subject(dt)

#### 1. REACTION TIME ####
# Reaction time between 3 conditions
dt %>% 
  group_by(cond) %>%
  summarise(rt = mean(rt, na.rm = TRUE))

p <- ggplot(dt, aes(cond, rt))
p + geom_violin(draw_quantiles = c(0.25, 0.5, 0.75), aes(fill = cond))

# Differences in RTs significant?
m_rt = lmer(rt ~ cond + (1|subject), data = dt)
summary(m_rt)

# Difference between Health/Desire RT sig?
t.test(dt$rt[dt$cond=="Decrease Desire"], dt$rt[dt$cond=="Focus on Healthiness"])

# Response by condition
dt %>%
  group_by(cond, choice) %>%
  summarise(rt = mean(rt, na.rm=TRUE))

# Azadeh: important to select outliers (look in natural condition)


#### 2. Choice by Condition ####

# Yes
dt %>% 
  group_by(cond) %>%
  summarise(yes_response = mean(choice, na.rm = TRUE))

# repeated measures Anova
aov(choice~cond + Error(subject), data = dt, na.action = na.omit)

m <- glmer(choice ~ cond + (1|subject),
               data = dt, family = binomial,
               control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)
summary(m)


#### 3. Logistic Regression: Health/Taste ####

plot_health_taste(dt_nat, dt_dd, dt_health)

# Natural
m_nat <- glmer(choice ~ taste + health + (1|subject),
               data = dt_nat, family = binomial,
               control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)
summary(m_nat)

# Decrease
m_dd <- glmer(choice ~ taste + health + (1|subject),
              data = dt_dd, family = binomial,
              control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)
summary(m_dd)

# Health
m_health <- glmer(choice ~ taste + health + (1|subject),
                  data = dt_health, family = binomial,
                  control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)
summary(m_health)

#### 4. Pre/Post Liking ####

# Do i need to group by subject first??

# option for "good subjects"
# dt = dt %>% filter(subject %in% good_subjects)

# HEALTH
pp_health <- summarySE(dt, measurevar="post_pre", groupvars=c("healthy","cond"))

# Separate plots
pp_h_plot = ggplot(pp_health, aes(cond, post_pre, color = cond)) +
  geom_point() +
  geom_errorbar(aes(ymin = post_pre-se, ymax = post_pre+se)) 
pp_h_plot + facet_grid(cols = vars(healthy))
# Same plot
ggplot(pp_health, aes(cond, post_pre, color = healthy)) +
  geom_point() +
  geom_errorbar(aes(ymin = post_pre-se, ymax = post_pre+se)) 


# TASTE
pp_taste <- summarySE(dt, measurevar="post_pre", groupvars=c("tasty","cond"))

# Separate plots
pp_t_plot = ggplot(pp_taste, aes(cond, post_pre, color = cond)) +
  geom_point() +
  geom_errorbar(aes(ymin = post_pre-se, ymax = post_pre+se)) 
pp_t_plot + facet_grid(cols = vars(tasty))
# Same plot
ggplot(pp_taste, aes(cond, post_pre, color = tasty)) +
  geom_point() +
  geom_errorbar(aes(ymin = post_pre-se, ymax = post_pre+se)) 

# compute by subject
  # how successful at regulating during the scan
  # weighting on taste and health by condition
  # if you were successful at regulating during the scan, does that predict if those changes last?



#### 5. Regulation Success? #### 

# Natural
model <- glmer(choice ~ taste + health + (1 + taste + health|subject),
               data = dt_nat, family = binomial,
               control = glmerControl(optimizer= 'bobyqa'))

dt_subj$intercept[dt_subj$cond=="Respond Naturally"] = coef(model)$subject[,1]
dt_subj$taste_slope[dt_subj$cond=="Respond Naturally"] = coef(model)$subject[,2]
dt_subj$health_slope[dt_subj$cond=="Respond Naturally"] = coef(model)$subject[,3]
  
# Decrease
model <- glmer(choice ~ taste + health + (1 + taste + health|subject),
               data = dt_dd, family = binomial,
               control = glmerControl(optimizer= 'bobyqa'))

dt_subj$intercept[dt_subj$cond=="Decrease Desire"] = coef(model)$subject[,1]
dt_subj$taste_slope[dt_subj$cond=="Decrease Desire"] = coef(model)$subject[,2]
dt_subj$health_slope[dt_subj$cond=="Decrease Desire"] = coef(model)$subject[,3]


# Health
model <- glmer(choice ~ taste + health + (1 + taste + health|subject),
               data = dt_health, family = binomial,
               control = glmerControl(optimizer= 'bobyqa'))

dt_subj$intercept[dt_subj$cond=="Focus on Healthiness"] = coef(model)$subject[,1]
dt_subj$taste_slope[dt_subj$cond=="Focus on Healthiness"] = coef(model)$subject[,2]
dt_subj$health_slope[dt_subj$cond=="Focus on Healthiness"] = coef(model)$subject[,3]



# Calculate difference of slopes with baseline (natural)
dt_subj = dt_subj %>%
  group_by(subject) %>%
  mutate( health_slope_change = health_slope - health_slope[cond=="Respond Naturally"],
          taste_slope_change = taste_slope - taste_slope[cond=="Respond Naturally"]
  )

# Label based on regulatory success (3 categories)
dt_subj = dt_subj %>%
  group_by(cond) %>%
  mutate( health_slope_change_cat = ntile(health_slope_change, 3),
          taste_slope_change_cat = ntile(taste_slope_change, 3)
  )

# Apply labels to original long dataframe
dt_merged = merge(dt, dt_subj, by=c("subject", "cond"))



library(Rmisc)
# HEALTH
pp_health_cat <- summarySE(dt_merged, measurevar="post_pre.x", groupvars=c("healthy","cond","health_slope_change_cat"))

# Plot
pp_h_plot = ggplot(pp_health_cat, aes(cond, post_pre.x, color = healthy)) +
  geom_point() +
  geom_errorbar(aes(ymin = post_pre.x-se, ymax = post_pre.x+se)) 
pp_h_plot + facet_grid(cols = vars(health_slope_change_cat))

# TASTE
pp_taste_cat <- summarySE(dt_merged, measurevar="post_pre.x", groupvars=c("tasty","cond","taste_slope_change_cat"))

# Separate plots
pp_t_plot = ggplot(pp_taste_cat, aes(cond, post_pre.x, color = tasty)) +
  geom_point() +
  geom_errorbar(aes(ymin = post_pre.x-se, ymax = post_pre.x+se)) 
pp_t_plot + facet_grid(cols = vars(taste_slope_change_cat))

# Plot 
# Health weight CHANGE in health condition 
hw = dt_subj$health_slope_change[dt_subj$cond=="Focus on Healthiness"]

#vs 
#PostPre Liking change in for unhealthy foods from Health Condition
pp = dt %>%
  group_by(subject) %>%
  summarise(change = mean(post_pre[cond=="Focus on Healthiness" & healthy=="unhealthy"], na.rm = TRUE))

pp$hw = hw

ggplotRegression(lm(change~hw, data = pp))


# Plot 
# Health weight CHANGE in health condition 
hw = dt_subj$health_slope_change[dt_subj$cond=="Focus on Healthiness"]

#vs 
#PostPre Liking change in for HEALTHY foods from Health Condition
pp = dt %>%
  group_by(subject) %>%
  summarise(change = mean(post_pre[cond=="Focus on Healthiness" & healthy=="healthy"], na.rm = TRUE))

pp$hw = hw

ggplotRegression(lm(change~hw, data = pp))

# Plot 
# Health weight CHANGE in health condition 
hw = dt_subj$health_slope_change[dt_subj$cond=="Focus on Healthiness"]

#vs 
#PostPre Liking change in for HEALTHY vs UNHEALTHY foods from Health Condition
pp_healthy = dt %>%
  group_by(subject) %>%
  summarise(change = mean(post_pre[cond=="Focus on Healthiness" & healthy=="healthy"], na.rm = TRUE))

pp_unhealthy = dt %>%
  group_by(subject) %>%
  summarise(change = mean(post_pre[cond=="Focus on Healthiness" & healthy=="unhealthy"], na.rm = TRUE))

pp$change = pp_healthy$change - pp_unhealthy$change
pp$hw = hw

ggplotRegression(lm(change~hw, data = pp))


#### 6. Weight Change ####

# HEALTH
pp_health <- summarySE(dt_subj, measurevar="health_slope_change", groupvars="cond")

# Same plot
ggplot(pp_health, aes(cond, health_slope_change)) +
  geom_point() +
  geom_errorbar(aes(ymin = health_slope_change-se, ymax = health_slope_change+se)) 

# TASTE
pp_taste <- summarySE(dt_subj, measurevar="taste_slope_change", groupvars="cond")

# Same plot
ggplot(pp_taste, aes(cond, taste_slope_change)) +
  geom_point() +
  geom_errorbar(aes(ymin = taste_slope_change-se, ymax = taste_slope_change+se)) 
