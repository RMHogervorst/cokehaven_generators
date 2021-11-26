# starter R 
# \\\\R Hogervorst 2021\\\\
# 
# In dit startset maak ik gebruik van het {tidymodels} framework,
# dat maakt het makkelijk om te wisselen van model. Je bent natuurlijk helemaal
# vrij om andere keuzen te maken.
# 
# inhoud
#  - dataset overzicht
#  - split in test en trainingset
#  - initialisatie van random forest model
#  - feature engineering (eigenlijk alleen downsampling)
#  - train model op trainingsdata
#  - voorspel op testdata (voeg zowel predictions als classes toe)
#  - bekijk metrics en roc_curve
#  - schrijf voorspellingen weg in csv
# 
library(tidymodels)

dataset_cokehaven <- readr::read_csv('trainingset_cokehaven.csv')
# > glimpse(dataset_cokehaven)
# Rows: 320,000
# Columns: 15
# $ containerid         <chr> "gcn79000001", "gcn79000002", "gcn79000004", "…
# $ load_date           <date> 2018-11-10, 2018-11-10, 2018-11-10, 2018-11-1…
# $ arrival_date        <date> 2019-01-01, 2019-01-01, 2019-01-01, 2019-01-0…
# $ land_van_afkomst    <chr> "Japan", "Japan", "South Korea", "Japan", "Jap…
# $ lading              <chr> "Afval", "Machines", "Hout en Textiel", "Afval…
# $ gekoeld             <dbl> 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0…
# $ TUE                 <dbl> 2, 1, 2, 2, 1, 1, 1, 2, 2, 2, 2, 1, 2, 2, 2, 1…
# $ weight              <dbl> 12144.408, 11063.886, 9162.007, 10749.156, 895…
# $ ship                <chr> "Madrid Maersk", "OOCL Germany", "Munich Maers…
# $ stops_in_between    <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
# $ ship_flag           <chr> "Marschall Islands", "Liberia", "Hong Kong", "…
# $ containercolor      <chr> "Darkgreen", "White", "Grey", "Green", "Grey",…
# $ ontvanger_container <chr> "Onbekend", "zandbak Inc", "Onbekend", "zandba…
# $ coke_ind            <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…
# $ coke_kilo           <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0…

samples <- rsample::initial_split(dataset_cokehaven,prop = 0.80, strata = "coke_ind")
print(samples)
rsample::training(samples)
rsample::testing(samples) 

# create model specification
mod <- 
    rand_forest(mode = "classification",engine = "ranger")

# create feature engineering
FE <- 
    recipe(coke_ind~weight+lading+land_van_afkomst, data=training(samples)) %>% 
    step_bin2factor(coke_ind) %>% 
    themis::step_downsample(coke_ind, under_ratio = 2) %>% # reduces oto 7779
    prep(data=training(samples),retain=TRUE)

trained_model <- 
    mod %>% 
    fit(formula = coke_ind~weight+lading,data=juice(FE)) 
# 


# create collection of metrics
metrics <- yardstick::metric_set(accuracy, bal_accuracy,sensitivity, specificity)
testset <- readr::read_csv("testset_cokehaven.csv")
featured_testset <- bake(FE, testset)
predictions <- trained_model %>% 
    predict(featured_testset, type = "prob") %>% # get probabilities
    bind_cols(testset %>% select(containerid)) %>% 
    bind_cols(featured_testset) %>% 
    bind_cols( # get classes (I know this is a bit ugly)
        trained_model %>%  predict(featured_testset, type = "class")
        )
# ROC curve on basis of probabilties
predictions %>% roc_curve(truth =coke_ind, .pred_yes) %>% autoplot()

# meetrics based on predicted class
predictions %>% 
    metrics(truth = coke_ind,estimate = .pred_class)


top_predictions <- 
    predictions %>% 
    arrange(desc(.pred_yes)) %>% 
    head(400)

top_predictions %>% 
    select(containerid) %>% 
    readr::write_csv("predictions.csv")
