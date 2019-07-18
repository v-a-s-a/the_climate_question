# load ESS data, preprocess and subset to variables of interest

library(tidyverse)
library(essurvey)
library(rstan)
library(labelled)

set_email('trubetskoy.vasa@gmail.com')

round_8 <- import_rounds(8, )

base_variables <- c('idno', 'cntry')

interesting_variables <- c('eduyrs')

questions <- var_label(round_8) %>%
  as_tibble() %>%
  gather(key = 'variable_name', value = 'description')

climate_questions <- questions %>%
  filter(str_detect(description, 'climate'))

responses <- round_8 %>%
  select(one_of(c(base_variables, climate_questions$variable_name, interesting_variables)))

# is this the right thing to do?
responses <- recode_missings(responses, c("Don't know", "Refusal"))

country_summaries <- responses %>%
  group_by(cntry) %>%
  summarise(mean_inctxff = mean(inctxff, na.rm = T))