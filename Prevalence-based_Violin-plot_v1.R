#the code will generate a violin plot for the dataframe df: containing the prevalence change distributions for each lineage

#import necessary libraries
library(ggplot2)
library(dplyr)
library(tidyverse)


#load the data and make it ready for violin plot
df %>% mutate(value42_28 = case_when(prev42_28>0 ~ 'gtz', prev42_28 <0 ~ 'ltz', prev42_28 == 0 ~ 'zero'), 
              value56_42 = case_when(prev56_42>0 ~ 'gtz', prev56_42 <0 ~ 'ltz', prev56_42 == 0 ~ 'zero'))

y_new <- df %>% filter(country %in% country_high_seq_rate) %>% 
  select(Sequence_ID, Lineage, country, Distinctiveness_value, starts_with('value')) %>% 
  pivot_longer(cols = starts_with("value"), names_to = 'prev', values_to='prev_value') %>% 
  mutate(prev_value = case_when(prev_value == 'ltz' ~ 'decreasing', 
                                prev_value == 'zero' ~ 'stable', 
                                prev_value == 'gtz' ~ 'increasing'),
         prev = case_when      (prev=='value28_14' ~ 'relative prevalence (28days - 14days)', 
                                 prev=='value42_28' ~ 'relative prevalence (42days - 28days)', 
                                 prev=='value56_42' ~ 'relative prevalence (56days - 42days)'))
  

y_new %>% drop_na() %>% ggplot(aes(Distinctiveness_value, prev_value)) + 
  geom_violin(trim=FALSE, fill= 'grey95') + 
  scale_x_continuous(breaks = seq(0,60,10)) +
  scale_y_discrete(limits= c('decreasing', 'stable', 'increasing')) +
  scale_color_grey() +
  stat_summary(fun.data = mean_sdl, geom='pointrange', color ='black') +
  facet_wrap(~prev, nrow=1, ncol = 3, strip.position = 'top', 
             labeller = label_wrap_gen(width=20)) + 
  labs (x='Distribution of Distinctiveness Value', y= 'Growth type of variants',
       title= "Variant growth patterns effect on distinctiveness distribution") +
  theme_classic() +
  theme(axis.title.x =  element_text(size=28,face='bold'), 
        axis.title.y =  element_text(size=28,face='bold'),
        axis.text.y = element_text(size=24,face='italic'),
        axis.text.x = element_text(size=24,face='italic', angle = 60, hjust =1),
        strip.text = element_text(face='bold', size =26),
        title=element_text(size=28,face='bold'),
        legend.position = 'none') +
  coord_flip()

# panel.background = element_rect(fill = "white", colour = "black", size = 1),
# plot.background = element_rect(fill = "white", colour = "black", size = 2),
# panel.grid.major = element_line(size = 0.5, linetype = 'dashed', colour = "gray"),
# panel.grid.minor = element_line(size = 0.25, linetype = 'dotted', colour = "gray"))


y <- y %>% mutate(prev = case_when(prev=='value28_14' ~ 'relative prevalence (28days - 14days)', 
                                   prev=='value42_28' ~ 'relative prevalence (42days - 28days)', 
                                   prev=='value56_42' ~ 'relative prevalence (56days - 42days)'))

y[which(y$prev_value=='gtz'),4] = 'increasing'
y[which(y$prev_value=='zero'),4] = 'stable'
y[which(y$prev_value=='ltz'),4] = 'decreasing'


ggplot(y %>% drop_na(), aes(Distinctiveness_value, value28_14, color = value28_14, fill = value28_14)) + 
  geom_violin(trim=FALSE) +
  stat_summary(fun.data = mean_sdl, geom='pointrange', color ='white') +
  stat_summary(fun = median, geom='point', color ='black') +
  scale_y_discrete(label= c('decreasing', 'stable', 'increasing'), limits=c('ltz','zero','gtz')) +
  labs(x='Distribution of Distinctiveness Value', y= 'Relative Prevalence (28 days - 14 days)') +
  theme(axis.title.x =  element_text(face='bold'), axis.title.y =  element_text(face='bold'),
        axis.text.x = element_text(face='italic'),
        axis.text.y = element_text(face='italic'),
        legend.position = 'none')


x_rbd <- rbd_antigen %>% select(Lineage, dist_value_rbd, starts_with('value'), prev28_14, prev42_28, prev56_42)
x_rbd <- x_rbd %>% pivot_longer(cols = starts_with("prev"), names_to = 'prev', values_to='prev_value')
x_rbd %>% drop_na() %>% ggplot(aes(dist_value_rbd, prev_value, fill=prev)) + 
  geom_violin(trim=FALSE, color = 'black') + 
  scale_y_discrete(limits= c('decreasing', 'stable', 'increasing')) +   
  stat_summary(fun.data = mean_sdl, geom='pointrange', color ='white') +
  facet_wrap(~prev, nrow=3, ncol = 1, strip.position = 'right',labeller = label_wrap_gen(width=10)) + 
  labs(x='Distribution of Distinctiveness Value', y= 'Growth type of variants',
       title= 'Distribution of distinctiveness \n(RBD region) in variants \nbased on growth patterns') +
  theme(axis.title.x =  element_text(size=18,face='bold'),
        axis.title.y =  element_text(size=18,face='bold'),
        axis.text.x = element_text(size=16,face='italic'),
        axis.text.y = element_text(size=16,face='italic'),
        title=element_text(size=20,face='bold'),
        strip.text = element_text(face='bold', size = 12),
        legend.position = 'none')

x_rbd
x_rbd <- x_rbd %>% mutate(prev_value = case_when(prev_value > 0 ~ 'increasing', prev_value<0 ~ 'decreasing', 
                                                 prev_value == 0 ~ 'stable'))
x_rbd <- x_rbd %>% mutate(prev = case_when(prev == 'prev28_14' ~ 'relative prevalence (28days - 14days)', 
                                           prev == 'prev42_28' ~ 'relative prevalence (42days - 28days)',
                                           prev == 'prev56_42' ~ 'relative prevalence (56days - 42days)'))

x_antigen <- merge(df, antigen, by='Sequence_ID')
x_antigen <- x_antigen %>% select(Lineage, dist_value_antigen, prev28_14, prev42_28, prev56_42)
x_antigen <- x_antigen %>% pivot_longer(cols = starts_with("prev"), names_to = 'prev', values_to='prev_value')
x_antigen %>% drop_na() %>% ggplot(aes(dist_value_antigen, prev_value, fill=prev)) + 
  geom_violin(trim=FALSE, color = 'black') + 
  scale_y_discrete(limits= c('decreasing', 'stable', 'increasing')) +   
  stat_summary(fun.data = mean_sdl, geom='pointrange', color ='white') +
  facet_wrap(~prev, nrow=3, ncol = 1, strip.position = 'right',labeller = label_wrap_gen(width=10)) + 
  labs(x='Distribution of Distinctiveness Value', y= 'Growth type of variants',
       title= 'Distribution of distinctiveness \n(antigenic sites) in variants \nbased on growth patterns') +
  theme(axis.title.x =  element_text(size=18,face='bold'),
        axis.title.y =  element_text(size=18,face='bold'),
        axis.text.x = element_text(size=16,face='italic'),
        axis.text.y = element_text(size=16,face='italic'),
        title=element_text(size=20,face='bold'),
        strip.text = element_text(face='bold', size = 12),
        legend.position = 'none')

x_antigen
x_antigen <- x_antigen %>% 
  mutate(prev_value = case_when(prev_value > 0 ~ 'increasing', prev_value<0 ~ 'decreasing', 
                                prev_value == 0 ~ 'stable'))
x_antigen <- x_antigen %>% 
  mutate(prev = case_when(prev == 'prev28_14' ~ 'relative prevalence (28days - 14days)', 
                          prev == 'prev42_28' ~ 'relative prevalence (42days - 28days)',
                          prev == 'prev56_42' ~ 'relative prevalence (56days - 42days)'))



ks.test(i$Distinctiveness_value, 'pnorm')
wilcox.test(i$Distinctiveness_value, d$Distinctiveness_value, alternative = 'greater')
z
y

z <- aov(Distinctiveness_value ~ prev/prev_value, data = y)
summary(z)
tukey_result <- TukeyHSD(z, digits=30)
tukey_result

# Convert Tukey's HSD results to a data frame for plotting
tukey_data <- as.data.frame(tukey_result$`prev:prev_value`)
tukey_data$comparison <- rownames(tukey_data)
tukey_data <- tibble(tukey_data)
data_spike <- tukey_data %>% 
  filter(str_detect(comparison, 
                    "\\b^relative prevalence \\(28days - 14days\\):.*-relative prevalence \\(28days - 14days\\):.*$\\b|\\b^relative prevalence \\(42days - 28days\\):.*-relative prevalence \\(42days - 28days\\):.*$\\b|\\b^relative prevalence \\(56days - 42days\\):.*-relative prevalence \\(56days - 42days\\):.*$\\b"))

write_csv(data_spike, 'tukey_spike.csv')

# Plot the Tukey HSD results
ggplot(tukey_all, aes(x = comparison, y = diff)) +
  geom_point() +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Tukey HSD Test Results",
       x = "Comparison",
       y = "Difference in Means") +
  theme(axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16),
        axis.text.x = element_text(size=12),
        axis.text.y = element_text(size=12),
        plot.title = element_text(size=18, hjust=1.2)) +
  coord_flip() + 
  geom_text(aes(label = sprintf("p = %.2g", `p adj`)), vjust = -1.5,
            hjust = 0.1, size = 5) + facet_wrap(~protein) +
  theme_bw()

tukey_all$comparison <- str_replace_all(tukey_all$comparison, "-relative", "-\nrelative")
str_wrap(tukey_antigen$comparison, width = 60)

################# for the plots for the high seq variants ##############################################

z <- aov(Distinctiveness_value ~ prev/prev_value, data = y_new)
summary(z)
tukey_result <- TukeyHSD(z, digits=10)
tukey_result_new <- tukey_result 

# Convert Tukey's HSD results to a data frame for plotting
tukey_data <- as.data.frame(tukey_result$`prev:prev_value`)
tukey_data$comparison <- rownames(tukey_data)
tukey_data <- tibble(tukey_data)
data_spike <- tukey_data %>% 
  filter(str_detect(comparison, 
                    "\\b^relative prevalence \\(28days - 14days\\):.*-relative prevalence \\(28days - 14days\\):.*$\\b|\\b^relative prevalence \\(42days - 28days\\):.*-relative prevalence \\(42days - 28days\\):.*$\\b|\\b^relative prevalence \\(56days - 42days\\):.*-relative prevalence \\(56days - 42days\\):.*$\\b"))

write_csv(data_spike, 'tukey_spike.csv')

# Plot the Tukey HSD results
ggplot(data_spike, aes(x = comparison, y = diff)) +
  geom_point() +
  geom_errorbar(aes(ymin = lwr, ymax = upr), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Tukey-HSD Test on Anova results",
       x = "Comparison between different pattern of variant prevalence",
       y = "Average Distinctivness difference") +
  theme_classic() +
  theme(axis.title.x = element_text(size=28),
        axis.title.y = element_text(size=28),
        axis.text.x = element_text(size=24),
        axis.text.y = element_text(size=24),
        plot.title = element_text(size=28, face = 'bold', hjust= 0.5)) +
  coord_flip() + 
  geom_text(aes(label = sprintf("p = %.2g", `p adj`)), vjust = -1.5,
            hjust = 0.1, size = 8)
  #scale_x_discrete(labels = label_wrap(width = 22)) +
  #facet_wrap(~protein) +
  

data_spike$comparison <- str_replace_all(data_spike$comparison, "-relative", "-\nrelative")
str_wrap(tukey_antigen$comparison, width = 60)

