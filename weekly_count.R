#weekly_count of seq no and then normalize that with cases
library(tidyverse)
library(anytime)
library(lubridate)



df <- read_csv("final_csv_df_variant.csv")
df$`Collection date` <- anydate(df$`Collection date`)
unique(df$Location)

week_seq_df <- df %>% drop_na() %>% rename(Sequence_ID = `Accession ID`, Lineage = `Pango lineage`, Date = `Collection date`, country = Location) %>% 
      arrange(Date) %>% filter(Date >= "2020-01-05") %>% 
      mutate(week = cut.Date(Date, breaks = '1 week', labels = FALSE), year = year(Date), month = month(Date)) %>% 
      group_by(country, year, month, week, Lineage) %>% mutate(lineage_total = n()) %>% 
      group_by(country, year, month, week) %>% 
      mutate(week_total=n(), lineage_percentage_per_week = 100*lineage_total/week_total) %>% 
      distinct(country, year, month, week, Lineage, .keep_all = TRUE) %>% 
      arrange(country) %>% ungroup()

case <- read_csv("new_cases.csv")
week_case_df <- case %>% pivot_longer(cols = 2:ncol(case), names_to = "country", values_to = "case_per_week") %>% 
  filter(case_per_week != 0) %>% mutate (year = year(date), month = month(date), 
                                         week = cut.Date(date, breaks = '1 week', labels = FALSE)) %>% select(!c(date))



week_case_seq_df <- left_join(week_seq_df, week_case_df, by = c("country", "year", "month", "week")) %>% select(!Date) %>% mutate (normalized_count_per_week = (lineage_percentage_per_month*case_per_week)/100)



#monthly case for missing seq months 

daily_case_df <- read_csv("daily_case.csv")
  
  
monthly_case_df <- daily_case_df %>% drop_na() %>% 
  pivot_longer(cols = 2:ncol(case), names_to = "country", values_to = "case_per_day") %>% 
  filter(case_per_day != 0) %>% mutate (year = year(date), month = month(date)) %>% 
  group_by(country, year, month) %>%  summarise (monthly_case = sum(case_per_day))

missed_month <- week_seq_df %>% group_by(country, year) %>% distinct(month, .keep_all = T) %>% 
                group_by(country, year) %>% summarise(ex = list(unique(month))) %>% 
                mutate (missing = lapply(ex, function(x){setdiff(1:12,x)})) %>% select (!ex) %>% unnest(missing) %>% 
                rename (month = missing)

case_missed_month <- missed_month %>% left_join(monthly_case_df, by = c("country", "year", "month"))

#or use existing_month %>% mutate (missing = map2(ex, function(x){setdiff(1:12,x)}))
