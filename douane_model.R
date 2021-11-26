### Douane model
# 300 op basis van zuid amerika, fruit, en 100 random
# 
# Uit rapportage:
# Voordat een schip de haven binnen vaart, heeft de Douane op basis van
# een risicoanalyse al vastgesteld welke controles zullen worden uitgevoerd.
# Evenals het land van origine is de soort goederen hierin een belangrijke factor, zo mogelijk
# gekoppeld aan informatie over het bedrijf. Waterdicht is deze werkwijze niet. Ook
# een schip uit een veiliger land kan drugs vervoeren, die al dan niet in een transitland
# zijn geplaatst. Als een medewerker de risicoprofielen deelt met
# criminelen, kunnen zij hierop hun handelwijzen aanpassen. Om die reden houdt de
# Douane tevens controles op basis van een aselecte steekproef.
# 
set.seed(612)
douane_data <- readr::read_csv("testset_cokehaven.csv")
library(dplyr)
first_selection <- douane_data %>% 
    filter(land_van_afkomst %in% c(
        "Argentinia",
        "Bolivia",
        "Brazil",
        "Chili",
        "Colombia",
        "Ecuador",
        "Guyana",
        "Paraguay",
        "Peru",
        "Suriname",
        "Uruguay",
        "Venezuela"
    )) %>% # 8547 left
    filter(lading %in% c("Fruit", "Groente")) %>% #506
    arrange(desc(stops_in_between), desc(weight)) %>% 
    slice_head(n=300) %>% 
    select(containerid)


second_selection <- 
    douane_data %>% 
    anti_join(first_selection) %>% 
    slice_sample(n=100) %>% 
    select(containerid)

bind_rows(
    first_selection,
    second_selection
) %>% readr::write_csv("douane_risicoanalyse.csv")

score_mijn_csv("douane_risicoanalyse.csv")

