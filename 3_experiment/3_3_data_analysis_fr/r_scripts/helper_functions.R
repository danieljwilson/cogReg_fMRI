
#==== Process Data Table ====

process_data_table <- function(dt){
  # remove NA rows
  dt = dt[complete.cases(dt),]
  
  # Create healthy/unhealthy column
  dt$healthy = 'unhealthy'
  dt$healthy[dt$health>3] = 'healthy'
  
  # Create tasty/untasty column
  dt$tasty = 'untasty'
  dt$tasty[dt$taste>3] = 'tasty'
  
  #### Manipulate Data Table ####
  
  # The following lines of code mean-centre the predictors
  dt = dt %>%
    mutate( pre_liking_c = pre_liking - mean(pre_liking, na.rm = T),
            post_liking_c = post_liking - mean(post_liking, na.rm = T),
            taste_c = taste - mean(taste, na.rm = T),
            health_c = health - mean(health, na.rm = T)
    )
  
  # add choice column
  dt$choice = 0
  dt$choice[dt$resp > 2] = 1

  # convert resp to numeric
  dt$resp = as.numeric(dt$resp)
  
  # add post-pre value column
  dt$post_pre = dt$post_liking - dt$pre_liking
  dt$post_pre_c = dt$post_liking_c - dt$pre_liking_c
  
  dt$cond = factor(dt$cond, levels = c('Respond Naturally','Focus on Healthiness','Decrease Desire'))
  
  return(dt)
}

#==== By subject/condition ====

by_subject <-function(dt){
  dt_subj = dt %>%
    group_by(subject, cond) %>%
    summarise_at(vars(-c(food,cond,subject,block, healthy,tasty)),
                 funs(mean(., na.rm=TRUE)))
  
  return(dt_subj)
}


#==== Plot Health/Taste ====

plot_health_taste <-function(nat_data, decrease_data, health_data){
  # Natural Condition
  m_nat <- glmer(choice ~ taste + health + (1|subject),
                 data = nat_data, family = binomial,
                 control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)
  nat_td <- tidy(m_nat, conf.int = TRUE)
  nat_td$cond = 'natural'
  
  # Decrease Condition
  m_dd <- glmer(choice ~ taste + health + (1|subject),
                data = decrease_data, family = binomial,
                control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)
  dd_td <- tidy(m_dd, conf.int = TRUE)
  dd_td$cond = 'decrease'
  
  # Health Condition
  m_health <- glmer(choice ~ taste + health + (1|subject),
                    data = health_data, family = binomial,
                    control = glmerControl(optimizer= 'bobyqa'), nAGQ = 10)
  health_td <- tidy(m_health, conf.int = TRUE)
  health_td$cond = 'health'
  
  # Combined plot
  combined_td <- rbind(nat_td, dd_td, health_td)
  combined_td <- combined_td
  combined_plot <- ggplot(combined_td, aes(term, estimate, color = term)) +
    geom_point() +
    theme(legend.position="none") +
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high)) 
  
  combined_plot + facet_grid(cols = vars(cond))
}

#==== GG Plot Regression ====

ggplotRegression <- function (fit) {
  
  require(ggplot2)
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                       "Intercept =",signif(fit$coef[[1]],5 ),
                       " Slope =",signif(fit$coef[[2]], 5),
                       " P =",signif(summary(fit)$coef[2,4], 5)))
}
  
