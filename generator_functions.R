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
    "Verenigde Staten van Amerika",
    "Mexico",
    "Canada",
    # midden amerika
    "Costa Rica",
    "Guatemala",
    "Nicaragua",
    "Panama",
    "El Salvador",
    # zuid amerika
    "Argentinië",
    "Bolivia",
    "Brazilië",
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
    "Noorwegen",
    "Verenigd Koninkrijk",
    "Zuid Afrika",
    "Kenia",
    "Tanzania",
    "Nigeria",
    "Egypte",
    "Namibië",
    # Azie
    "China",
    "India",
    "Vietnam",
    "Indonesië",
    "Bangladesh",
    "Japan",
    "Zuid Korea"
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
  testframe$container_id <- 
  testframe
}


create_fruit_probs <- function(testframe) {
  base_prop <- 0.002 # way more than estimated actuals
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
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "January"] <- 0.80
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "February"] <- 1.1
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "March"] <- 1.20
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "April"] <- 1.35
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "May"] <- 1.45
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "June"] <- 1.35
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "July"] <- 1.20
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "August"] <- 1.00
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "September"] <- 0.80
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "October"] <- 0.70
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "November"] <- 0.60
  testframe$month_mod[months(testframe$date,abbreviate = FALSE) == "December"] <- 0.50
  testframe$month_mod[weekdays(testframe$date,abbreviate = FALSE) %in% c("Friday", "Saturday")] <- 0.10 + testframe$month_mod[weekdays(testframe$date) %in% c("Friday", "Saturday")]
  testframe$month_mod[strftime(testframe$date, "%d") %in% c("01", "02", "03", "04")] <- testframe$month_mod[strftime(testframe$date, "%d") %in% c("01", "02", "03", "04")] - 0.30
  # mean(testframe$month_mod) # 1.02
  testframe
}

create_country_mod <- function(testframe) {
  # higher risk from certain countries
  testframe$country_risk <- 0.99
  testframe$country_risk[testframe$land_van_afkomst %in% c("Ecuador", "Peru", "Venezuela", "Colombia", "Suriname")] <- 1.5
  testframe$country_risk[testframe$land_van_afkomst %in% c("Bolivia", "Guyana", "Chili")] <- 0.85
  # mean(testframe$country_risk) # 1.01
  testframe
}


create_drugs <- function(testframe) {
  props <- testframe$base_prop * testframe$fruit_mod * testframe$month_mod * testframe$country_risk
  props[is.na(props)] <- 0.00175
  props[props <0] <- 0.00175
  # mean(props) # 0.01747
  # this is unfortunately not vectorized.
  testframe$coke_ind <- 
      purrr::map_int(props, ~ sample(
          c(1L, 0L), 
          size = 1, 
          prob = c(.x, 1 - .x))
          ) 
  # add kilos
  testframe$coke_kilo <- 0
  nc <- sum(testframe$coke_ind == 1)
  c_ind <- which(testframe$coke_ind == 1)
  vers_1 <- sample(c_ind, size = 0.75 * nc)
  vers_2 <- c_ind[!c_ind %in% vers_1]
  testframe$coke_kilo[vers_1] <- rbeta(n = length(vers_1), 2, 5) * 20
  testframe$coke_kilo[vers_2] <- rnorm(n = length(vers_2), 20, 5)
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
    "Argentinië",
    "Bolivia",
    "Brazilië",
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
      "Verenigde Staten van Amerika",
      "Mexico",
      "Canada"
    )

  testframe$days[noord_amerika] <- generate_days(noord_amerika, 10, 13)
  dichtbij <- testframe$land_van_afkomst %in% c(
    "Noorwegen",
    "Verenigd Koninkrijk"
  ) # 1-2
  testframe$days[dichtbij] <- generate_days(dichtbij, 1, 2)
  # tanzania 20 dagen 15-25
  #
  afrika <- testframe$land_van_afkomst %in% c(
    "Zuid Afrika",
    "Kenia",
    "Tanzania",
    "Nigeria",
    "Egypte",
    "Namibië"
  )
  testframe$days[afrika] <- generate_days(afrika, 15, 25)
  # india 20 dagen tot 35 dagen
  # Azie
  azie <- testframe$land_van_afkomst %in% c(
    "China",
    "India",
    "Vietnam",
    "Indonesië",
    "Bangladesh"
  )
  testframe$days[azie] <- generate_days(azie, 19, 35)
  # ver azie 42-52 dagen
  ver_azie <- testframe$land_van_afkomst %in% c(
    "Japan",
    "Zuid Korea"
  )
  testframe$days[ver_azie] <- generate_days(ver_azie, 42, 52)
  testframe$days[testframe$coke_ind == 1] <- testframe$days[testframe$coke_ind == 1] + sample(c(0, 1, 2), size = sum(testframe$coke_ind == 1), replace = TRUE, prob = c(0.20, 0.75, 0.05))
  testframe$load_date <- testframe$date - testframe$days
  testframe$arrival_date <- testframe$date
  testframe$date <- NULL
  testframe$days <- NULL
  testframe
}

generate_days <- function(vec, min, max) {
  n <- sum(vec)
  round(runif(n, min, max))
}
