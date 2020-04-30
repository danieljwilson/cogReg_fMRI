
#### LOAD LIBRARIES ####
library(tidyverse)

#### READ IN DATA ####
df = as.tibble(read_csv("../data/questionnaires.csv"), stringsAsFactors = FALSE)

# Select fMRI study subjects
fmri_sub <- grepl("FRMRI*", df[, 2][[1]])
df = df[fmri_sub, ]
df = as.data.table(df)

# Rename demo cols
names(df)[1:13] = c("demo_time",
                    "demo_id",
                    "demo_female",
                    "demo_ethnicity",
                    "demo_age",
                    "demo_weight",
                    "demo_height",
                    "demo_yrs_canada",
                    "demo_diet",
                    "demo_diet_detail",
                    "demo_familiar",
                    "demo_previous_food",
                    "demo_previous_food_time")

# Recode female
df[demo_female == "Female", demo_female := "1"]
df[demo_female == "Male", demo_female := "0"]

# Rename conditional effects cols
names(df)[14:24] = c("ce_1_diff_nat",
                    "ce_2_focus_h_nat",
                    "ce_3_focus_dd_nat",
                    "ce_4_diff_dd",
                    "ce_5_focus_h_dd",
                    "ce_6_focus_reduce_craving_dd",
                    "ce_7_success_control_response_dd",
                    "ce_8_diff_h",
                    "ce_9_focus_h_h",
                    "ce_10_focus_reduce_craving_h",
                    "ce_11_success_control_response_h")

# Rename strategy cols
names(df)[25:40] = c("s_1_think_unhealthy",
                    "s_2_xthink_hungry",
                    "s_3_change_foodthoughts",
                    "s_4_xlook_pics",
                    "s_5_think_healthy",
                    "s_6_xchange_want_changed_choice",
                    "s_7_try_dd",
                    "s_8_try_xthink_tasty",
                    "s_9_think_unhealthy",
                    "s_10_xthink_hungry",
                    "s_11_change_food_thoughts",
                    "s_12_xlook_pics",
                    "s_13_think_healthy",
                    "s_14_xchange_want_changed_choice",
                    "s_15_try_dd",
                    "s_16_try_xthink_tasty")


# Clean up DF
df <- df %>%
  mutate(
    demo_id = readr::parse_number(demo_id)
  )
remove(fmri_sub)

# List of good subjects
good_subjects = c(101:104, 106:112, 114, 116, 118:121, 123:126, 129:137, 139:140, 142:148, 150, 152:158, 162:164)
# Remove excluded subjects
df_good = df[df$demo_id %in% good_subjects,]


#### CLUSTERING ####

# Remove extra questionnaire cols
dfc = df_good[,1:40]

