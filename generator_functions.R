lading <-
  data.frame(
    gekoeld = c(rep(1, 6), rep(0, 9)),
    lading = c(
      "Fruit", "Vlees en vleeswaren", "Vis", "Niet-voedsel", "Overig voedsel", "Groente",
      "Machines", "Overige", "Afval", "Chemie", "Bouwmaterialen", "Olieproducten", "Hout en Textiel", "Levensmiddelen", "Elektronica"
    ),
    prob = c(5, 2, 1, 1, 0.5, 0.5, 7, 10, 20, 10, 4, 6, 21, 9, 3)
  )
# gekoeld is 11/121 miljoen ton ik maak ervan 10% van totaal

generate_lading <- function(n) {
  sample(lading$lading, size = n, replace = TRUE, prob = lading$prob)
}

afkomst_landen <- data.frame(
  afkomst = c(
    # noord amerika
    "USA",
    "Mexico",
    "Canada",
    # midden amerika
    "Costa Rica",
    "Guatemala",
    "Nicaragua",
    "Panama",
    "El Salvador",
    # zuid amerika
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
    "Venezuela",
    # rest landen
    "Norway",
    "United Kingdom",
    "South Africa",
    "Kenia",
    "Tanzania",
    "Nigeria",
    "Egypte",
    "Namibia",
    # Azie
    "China",
    "India",
    "Vietnam",
    "Indonesia",
    "Bangladesh",
    "Japan",
    "South Korea"
  ),
  prob = c(
    2, 1, 2, # 5 % noord amerika
    0.2, 0.3, 1, 1, 0.5, # 3 % midden america
    1, 1, 1.75, 1, 1, 1, 0.25, 1, 1, 1, 0.5, 0.5, # 11 % Zuid america
    rep(0.5, 8), # restlanden 4%
    51, # china
    5, 3, 2, 2,
    9,
    5
  )
)


generate_afkomst <- function(n) {
  sample(afkomst_landen$afkomst, size = n, replace = TRUE, prob = afkomst_landen$prob)
}
create_codeframe <- function(n) {
  testframe <- data.frame(
    land_van_afkomst = generate_afkomst(n),
    lading = generate_lading(n),
    date = sample(
      seq.Date(
        from = as.Date("2019-01-01"),
        to = as.Date("2019-12-31"),
        by = 1
      ),
      replace = TRUE,
      size = n
    ),
    TUE = sample(c(1, 2), size = n, replace = TRUE, prob = c(0.2, 0.8))
  )
  testframe$weight <- runif(n, min = 2900, max = 14500)
  testframe <- merge(testframe, lading[,c("gekoeld", "lading")], by="lading")
  testframe
}

base_prop <- 0.003 # way more than estimated actuals I estimated 0.17%

create_fruit_probs <- function(testframe) {
  testframe$base_prop <- rnorm(n = nrow(testframe), mean = base_prop, sd = (base_prop / 2))
  lowest_value <- min(testframe$base_prop[testframe$base_prop > 0])
  testframe$base_prop[testframe$base_prop < 0] <- lowest_value
  testframe$fruit_mod <- 0.75
  testframe$fruit_mod[testframe$lading == "Fruit"] <- 2
  testframe$fruit_mod[testframe$lading == "Vlees en vleeswaren"] <- 1.75
  testframe$fruit_mod[testframe$lading == "Afval"] <- 1.5
  message(paste0("current mean fruit mod ", mean(testframe$fruit_mod)))
  testframe
}


# mean(testframe$fruit_mod) # 0.9926
# date
create_date_props <- function(testframe) {
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "January"] <- 0.40
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "February"] <- 2.2
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "March"] <- 2.40
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "April"] <- 2.7
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "May"] <- 2.70
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "June"] <- 2.60
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "July"] <- 2.40
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "August"] <- 1.00
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "September"] <- 0.40
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "October"] <- 0.30
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "November"] <- 0.20
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "December"] <- 0.30
  testframe$month_mod[weekdays(testframe$date,abbreviate = FALSE) %in% c("Friday", "Saturday")] <- 0.10 + testframe$month_mod[weekdays(testframe$date) %in% c("Friday", "Saturday")]
  testframe$month_mod[strftime(testframe$date, "%d") %in% c("01", "02", "03", "04")] <- testframe$month_mod[strftime(testframe$date, "%d") %in% c("01", "02", "03", "04")] - 0.30
  message(paste0("month_mod average is: ",mean(testframe$month_mod)))
  testframe
}

create_country_mod <- function(testframe) {
  # higher risk from certain countries
  testframe$country_risk <- 0.99
  testframe$country_risk[testframe$land_van_afkomst %in% c("Ecuador", "Peru", "Venezuela", "Colombia", "Suriname")] <- 3.5
  testframe$country_risk[testframe$land_van_afkomst %in% c("Bolivia", "Guyana", "Chili")] <- 0.70
  message(paste0("country_risk mean mod is: ",mean(testframe$country_risk)))
  testframe
}
ships <- tibble::tribble(
  ~name, ~max_teu,
  "OOCL Hong Kong", 21413,
  "OOCL Germany", 21413,
  "OOCL Japan", 21413,
  "Madrid Maersk", 20568,
  "Munich Maersk", 20568,
  "Moscow Maersk", 20568,
  "MOL Truth", 20182,
  "MOL Triumph", 20170,
  "COSCO Shipping Universe", 21237,
  "Ever Golden", 20124,
  "MSC gulsun", 23756,
  "MSC Isabella", 23656
)
c_ontv <- tibble::tribble(
  ~ontvanger, ~prop,
  "K. Vaak", 1,
  "S Klaas", 1,
  "K Atvanger", 6,
  "Global middleman BV", 20,
  "Steuerhinterziehung GmbH", 20,
  "R Taghi", 5,
  "Onbekend", 35,
  "K. Erstman", 2,
  "zandbak Inc", 10
)


create_ship_info <- function(testframe){
  testframe$ship <- sample(ships$name, size = nrow(testframe), replace=TRUE, prob = ships$max_teu)
  testframe$stops_in_between <- sample(c(0,1,2),size = nrow(testframe), prob=c(1000,10,1), replace = TRUE)
  testframe$ship_mod <- 0.99
  testframe$ship_mod[testframe$ship %in% c("MOL Triumph", "MOL Truth")]  <- 2
  testframe$ship_mod[testframe$stops_in_between!=0] <- 4
  testframe$ship_flag <- sample(c("Panama","Liberia", "Hong Kong","Marschall Islands"), size=nrow(testframe), replace = TRUE)
  message(paste0("ship_mod average is", mean(testframe$ship_mod)))
  #message(paste0('taking ', ceiling(nrow(testframe)*base_prop), " rows from ", nrow(testframe)))
  specials <- sample(x=1:nrow(testframe), size = ceiling(nrow(testframe)*base_prop),replace = FALSE)
  testframe$containercolor = sample(c("Cherryred", "Darkgreen", "Grey","White","Green"),size=nrow(testframe),replace = TRUE)
  testframe$containercolor[specials] <- 'SpaceBlack'
  testframe$ontvanger_container <- sample(c_ontv$ontvanger, size = nrow(testframe), prob =c_ontv$prop, replace = TRUE)
  testframe$container_mod <- 0.9
  testframe$container_mod[testframe$ontvanger_container == "K Atvanger"] <- 10
  testframe$container_mod[specials]<- 9
  message(paste0("container_mod average is", mean(testframe$container_mod)))
  testframe
}

create_drugs <- function(testframe) {
  message(paste0("base prob is ", base_prop))
  props <- testframe$base_prop * testframe$fruit_mod * testframe$month_mod * testframe$country_risk  * testframe$ship_mod  * testframe$container_mod
  props[is.na(props)] <- base_prop
  props[props < 0] <- base_prop
  message(paste0("props higher than 1: ", length(props[props > 0])))
  props[props > 1] <- 0.99
  n = length(props)
  # message(paste0("fraction higher then 50% fruit: ",sum((testframe$base_prop * testframe$fruit_mod) >.5)/n))
  # message(paste0("fraction higher then 50% month_mod: ",sum((testframe$base_prop * testframe$month_mod) >.5)/n))
  # message(paste0("fraction higher then 50% country_risk: ",sum((testframe$base_prop * testframe$country_risk) >.5)/n))
  # message(paste0("fraction higher then 50% container: ",sum((testframe$base_prop * testframe$container_mod) >.5)/n))
  # message(paste0("fraction higher then 50% ship: ",sum((testframe$base_prop * testframe$ship_mod) >.5)/n))
  message(paste0("fraction higher then 50%: ", sum(props > 0.5)/n)) 
  message(paste0("mean average prob is: ", mean(props))) # 0.01747
  # this is unfortunately not vectorized.
  testframe$coke_ind <- 
      purrr::map_int(props, ~ sample(
          c(1L, 0L), 
          size = 1, 
          prob = c(.x, 1 - .x))
          )
  n_total = nrow(testframe)
  n_codecontainers = sum(testframe$coke_ind == 1)
  message(paste0(n_codecontainers," (",round(n_codecontainers/n_total *100,2), "%) Of the ",n_total," containers contains cocaine"))
  # add kilos
  testframe$coke_kilo <- 0
  nc <- sum(testframe$coke_ind == 1)
  c_ind <- which(testframe$coke_ind == 1)
  vers_1 <- sample(c_ind, size = 0.75 * nc)
  vers_2 <- c_ind[!c_ind %in% vers_1]
  testframe$coke_kilo[vers_1] <- round(rbeta(n = length(vers_1), 2, 5) * 21)
  testframe$coke_kilo[vers_2] <- round(rnorm(n = length(vers_2), 21, 5))
  message(paste0(round(sum(testframe$coke_kilo),2)," kilo drugs generated"))
  message(paste0("on average drugscontainers contain ",round(mean(testframe$coke_kilo[c_ind]))," kilos."))
  # remove
  testframe$fruit_mod <- NULL
  testframe$base_prop <- NULL
  testframe$country_risk <- NULL
  testframe$month_mod <- NULL
  testframe
}

add_reistijd <- function(testframe) {
  # reistijden per continent?
  #     zuid america 16-20 dagen

  #
  zuid__mid_america <- testframe$land_van_afkomst %in% c(
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
      "Venezuela",
      "Costa Rica",
      "Guatemala",
      "Nicaragua",
      "Panama",
      "El Salvador"
  )
  testframe$days[zuid__mid_america] <- generate_days(zuid__mid_america, 16, 20)
  # canada 12 dagen
  # new york 10
  noord_amerika <- testframe$land_van_afkomst %in%
    c(
      "USA",
      "Mexico",
      "Canada"
    )

  testframe$days[noord_amerika] <- generate_days(noord_amerika, 10, 13)
  dichtbij <- testframe$land_van_afkomst %in% c(
    "Norway",
    "United Kingdom"
  ) # 1-2
  testframe$days[dichtbij] <- generate_days(dichtbij, 1, 2)
  # tanzania 20 dagen 15-25
  #
  afrika <- testframe$land_van_afkomst %in% c(
    "South Africa",
    "Kenia",
    "Tanzania",
    "Nigeria",
    "Egypte",
    "Namibia"
  )
  testframe$days[afrika] <- generate_days(afrika, 15, 25)
  # india 20 dagen tot 35 dagen
  # Azie
  azie <- testframe$land_van_afkomst %in% c(
    "China",
    "India",
    "Vietnam",
    "Indonesia",
    "Bangladesh"
  )
  testframe$days[azie] <- generate_days(azie, 19, 35)
  # ver azie 42-52 dagen
  ver_azie <- testframe$land_van_afkomst %in% c(
    "Japan",
    "South Korea"
  )
  testframe$days[ver_azie] <- generate_days(ver_azie, 42, 52)
  testframe$days[testframe$coke_ind == 1] <- testframe$days[testframe$coke_ind == 1] + sample(c(0, 1, 2), size =length(testframe$days[testframe$coke_ind == 1]), replace = TRUE, prob = c(0.20, 0.75, 0.05))
  testframe$load_date <- testframe$date - testframe$days
  testframe$arrival_date <- testframe$date
  testframe$date <- NULL
  #testframe$days <- NULL
  testframe
}

generate_days <- function(vec, min, max) {
  n <- sum(vec)
  round(runif(n, min, max))
}



rearrange_for_output <- function(testframe){
  message("resorting and adding id")
  result <- testframe
  result <- result[order(result$load_date, result$land_van_afkomst),]
  result$containerid <- sprintf(fmt = "gcn79%06d", 1:nrow(result))
    result <- result[,c(
      "containerid",
      "load_date","arrival_date","land_van_afkomst","lading","gekoeld", 
      "TUE","weight","ship","stops_in_between" ,
      "ship_flag", "containercolor" , "ontvanger_container",
      "coke_ind", "coke_kilo")]
    
    result
}
