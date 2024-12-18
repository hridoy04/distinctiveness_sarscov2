library(tidyverse)
library(ggpubr)

final %>% mutate (prev28_14 = (prevalence_28days - prevalence_14days), prev42_28 = (prevalence_42days - prevalence_28days), prev56_42 = (prevalence_56days - prevalence_42days))
prev_dist_df <- final %>% select(c(country, Lineage, Date, normalized_dist_value, prev28_14, prev42_28, prev56_42))

usa <-prev_dist_df %>% filter(country == 'USA') %>% arrange(desc(Date))
colnames(final)

cor.test(final$normalized_dist_value, final$prev56_42)                                                   


ggscatter(final, x = "Distinctiveness_value_mean", y = "prev28_14", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "distinctiveness_value", ylab = "prevalence28-14days")


