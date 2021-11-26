set.seed(123145)
source("generator_functions.R")

dataset_cokehaven <- 
    create_codeframe(n = 4e5) |> 
    create_fruit_probs() |> 
    create_date_props() |> 
    create_country_mod() |> 
    create_ship_info() |>
    create_drugs() |> 
    add_reistijd() |>
    rearrange_for_output()


samples <- rsample::initial_split(dataset_cokehaven,prop = 0.80, strata = "coke_ind")
print(samples)
rsample::training(samples) |> readr::write_csv('trainingset_cokehaven.csv')
rsample::testing(samples) |> dplyr::select(-coke_ind, -coke_kilo) |> readr::write_csv('testset_cokehaven.csv')
rsample::testing(samples) |> 
    dplyr::select(containerid, coke_ind, coke_kilo) |> 
    readr::write_csv(file = "flaskcokehaven/testscoring.csv")

