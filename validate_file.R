## validatie script in R.
## 
## 
score_mijn_csv <- function(csvpad){
    validatie_bestand = readr::read_csv("flaskcokehaven/testscoring.csv")
    eigenbestand <- readr::read_csv(csvpad)
    check_file(eigenbestand)
    validatie_bestand %>% 
        inner_join(
            eigenbestand %>% select(containerid), 
            by = "containerid") %>% 
        filter(coke_ind == 1) %>% 
        summarize(kilos = sum(coke_kilo))
    
}

check_file<- function(bestand){
    stopifnot(colnames(bestand) == 'containerid')
    stopifnot(nrow(bestand) ==400)
}
