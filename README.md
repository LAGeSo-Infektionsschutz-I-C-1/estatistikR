# estatistikR

<!-- badges: start -->

[![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

R Client für den Nachrichtenabruf vom eSTATISTIK Erhebungsportal der Statistischen Ämter des Bundes und der Länder Deutschland.

## Installation

Das Paket kann mithilfe des R Pakets `devtools` installiert werden:

``` r
devtools::install_github("LAGeSo-Infektionsschutz-I-C-1/estatistikR")
```

## Benutzung

Um alle Anhänge aller Nachrichten

``` r
library(estatistikR)

# Zugangsdaten für das eSTATISITK Erhebungsportal
user_auth <- list(username = "IhrBenutzername", password = "IhrPasswort")

# Herunterladen des Anhangs der neusten Nachricht
df_nachrichten <- get_nachrichten(user_auth  = user_auth) |>
  head(n = 1) |>
  get_anhaenge_info(user_auth  = user_auth) |>
  download_anhaenge(user_auth  = user_auth, path = ".")

# Wenn der Download erfolgreich war, kann die Nachricht als gelesen markiert werden
# Die Nachricht taucht dann über die API nicht mehr auf 
# und wird im online Portal grau dargestellt.
df_nachrichten |>
  markiere_nachrichten_gelesen(user_auth  = user_auth)
```
