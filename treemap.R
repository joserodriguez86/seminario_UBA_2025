library(treemapify)


censo_personas %>% 
  count(provincia_f) %>% 
  ggplot(aes(fill = provincia_f, area = n)) +
  geom_treemap() +
  geom_treemap_text(
    aes(label = provincia_f),
    grow = T,
    reflow = T,
    colour = "white"
  ) +
  theme(legend.position = "none")
