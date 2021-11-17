set.seed(123145)
source("generator_functions.R")

dataset_cokehaven <- 
    create_codeframe(n = 4e5) |> 
    create_fruit_probs() |> 
    create_date_props() |> 
    create_country_mod() |> 
    create_drugs() |> 
    add_reistijd()


samples <- rsample::initial_split(dataset_cokehaven,prop = 0.80, strata = "coke_ind")
print(samples)
rsample::training(samples) |> readr::write_csv('trainingset_cokehaven.csv')
rsample::testing(samples) |> readr::write_csv('testset_cokehaven.csv')
