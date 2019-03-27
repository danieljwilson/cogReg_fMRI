library(data.table)
library(R.matlab)

# in case it is lurking
remove(full_dt)

# List of all subjects
subjects = c(101:116, 118:140, 142:164)

# 101 missing task CSVs 
# 103, 105, 106 missing Main-Post.mat
# 150 didn't save correctly...missing one response?
# 151 quit after 6 runs

# LOOP Through Subjects
for (sub in subjects){
  print(sub)
  # LOAD Matlab Matrices
  attrib_post = readMat(paste0("data/subjects/", sub ,"/Data.", sub, ".AttributeRatings-Post.mat"))
  liking_pre = readMat(paste0("data/subjects/", sub, "/Data.", sub, ".LikingRatings-Pre.mat"))
  #main_post = readMat(paste0("data/subjects/", sub, "/Data.", sub, ".Main-Post.mat"))
  main_pre = readMat(paste0("data/subjects/", sub, "/Data.", sub, ".Main-Pre.mat"))
  
  # DATA for pre/post liking as well as health/taste
  liking_pre_dt = data.table(food = unlist(liking_pre$Data[[5]]),
                             pre_liking = as.numeric(unlist(liking_pre$Data[[6]]))
  )
  
  rating_post_dt = data.table(food = unlist(attrib_post$Data[[5]]),
                              attribute = unlist(attrib_post$Data[[10]]),
                              rating = as.numeric(unlist(attrib_post$Data[[6]]))
  )
  
  liking_post_dt = subset(rating_post_dt, attribute == 'Liking')
  liking_post_dt = data.table(food = liking_post_dt$food, post_liking = liking_post_dt$rating)
  health_dt = subset(rating_post_dt, attribute == 'Health')
  health_dt = data.table(food = health_dt$food, health = health_dt$rating)
  taste_dt = subset(rating_post_dt, attribute == 'Taste')
  taste_dt = data.table(food = taste_dt$food, taste = taste_dt$rating)
  
  
  # LOOP Through Blocks (9)
  # for (block in 1:9){   # changed this to the monstrosity below to check how many sessions exist for subject
  for (block in 1:length(list.files(path = paste0("data/subjects/", sub, "/"), pattern = paste0("Data.", toString(sub), ".\\d.mat")))){
    
    # load block data
    x = readMat(paste0("data/subjects/", sub, "/Data.", sub, ".", block, ".mat"))
    
    subject = rep(as.numeric(unlist(x$Data["subjid",1,1])),30)
    block = rep(as.numeric(unlist(x$Data["ssnid",1,1])),30)
    
    # condition
    cond = unlist(x$Data[["Instruction",1,1]])
    # other data columns
    food = unlist(x$Data[["Food",1,1]])
    resp = unlist(x$Data[["Resp",1,1]])
    rt = unlist(x$Data[["ChoiceRT",1,1]])
    
    #hunger_pre = rep(unlist(main_pre$Data[[5]]),30)
    #hunger_post = rep(unlist(main_post$Data[[5]]),30)
    
    # create data table for block
    DT = data.table(subject = subject,
                    block = block,
                    cond = cond,
                    food = food,
                    resp = resp,  
                    rt = rt
                    #hunger_pre = hunger_pre
                    #hunger_post = hunger_post
    )
    
    # add ratings too block
    combined_dt = merge(DT, liking_pre_dt, by="food", sort=FALSE)
    combined_dt = merge(combined_dt, liking_post_dt, by="food", sort=FALSE)
    combined_dt = merge(combined_dt, taste_dt, by="food", sort=FALSE)
    combined_dt = merge(combined_dt, health_dt, by="food", sort=FALSE)
    
    # Check if we have already made the full dataframe
    if (!exists("full_dt")){
      full_dt = combined_dt[0,]
    }
    
    # Add to previous data.table
    full_dt = rbind(full_dt, combined_dt)
    
  }
}

save(full_dt, file = "FoodRegfMRI_dt.RData")



