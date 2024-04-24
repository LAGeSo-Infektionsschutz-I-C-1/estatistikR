# estatistikR

<!-- badges: start -->

[![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental) [![R-CMD-check](https://github.com/LAGeSo-Infektionsschutz-I-C-1/estatistikR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/LAGeSo-Infektionsschutz-I-C-1/estatistikR/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

R Client für den Nachrichtenabruf vom eSTATISTIK Erhebungsportal der Statistischen Ämter des Bundes und der Länder Deutschlands.

## Installation

Das Paket kann mithilfe des R Pakets `devtools` installiert werden:

``` r
devtools::install_github("LAGeSo-Infektionsschutz-I-C-1/estatistikR")
```

## Benutzung

Mithilfe des R Pakets können alle Nachrichten im Postfach des eSTATISITK Erhebungsportals abgerufen und die Anhänge von einer oder mehrer Nachrichten heruntergeladen werden:

``` r
library(estatistikR)

# Zugangsdaten für das eSTATISITK Erhebungsportal
user_auth <- list(username = "IhrBenutzername", password = "IhrPasswort")

# Abrufen aller Nachrichten im Postfach
df_nachrichten <- get_nachrichten(user_auth  = user_auth)
print(df_nachrichten)

# Herunterladen des Anhangs der neusten Nachricht
df_nachrichten_downloaded <- df_nachrichten |>
  head(n = 1) |>
  get_anhaenge_info(user_auth  = user_auth) |>
  download_anhaenge(user_auth  = user_auth, path = ".")
print(df_nachrichten_downloaded)

# Wenn der Download erfolgreich war, kann die Nachricht als gelesen markiert werden
# Die Nachricht taucht dann über die API nicht mehr auf 
# und wird im online Portal grau dargestellt.
df_nachrichten |>
  markiere_nachrichten_gelesen(user_auth  = user_auth)
```
