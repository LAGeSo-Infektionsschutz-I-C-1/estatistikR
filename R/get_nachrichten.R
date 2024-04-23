#' Nachrichten im eSTATSITK Postfach abrufen
#'
#' @param user_auth Eine Liste mit den eSTATISTIK Benutzerdaten list(username, password). Das
#' Passwort wird nachgefragt, wenn es leergelassen wird. Dadurch kann das Speichern des Passworts
#' im R Skript umgangen werden.
#' @param verbosity Default: 0. Detaillevel der Debug Informationen (0 bis 3).
#' @param basis_url Die URL des eSATISTIK Erhebungsportals.
#' Default: https://erhebungsportal.estatistik.de/Erhebungsportal
#' @return `get_nachrichten` gibt ein DataFrame der Nachrichten zurück.
#' `get_nachrichten_raw` gibt das HTTP-Response-Objekt zurück.
#' @examples
#' \dontrun{
#' user_auth <- list(username = "IhrBenutzername")
#' # oder
#' user_auth <- list(username = "IhrBenutzername", password = "IhrPasswort")
#'
#' df_nachrichten <- get_nachrichten(user_auth = user_auth)
#' print(df_nachrichten)
#' }
#' @export

get_nachrichten <- function(
    user_auth = list(username = NA, password = NA),
    verbosity = 0,
    basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal"
) {

  # R CMD CHECK glücklich machen
  versanddatum <- NULL

  get_nachrichten_raw(
    user_auth = user_auth,
    verbosity = verbosity,
    basis_url = basis_url
  ) |>
    httr2::resp_body_json() |>
    purrr::map_dfr(
      \(x) purrr::keep(x,
          names(x) %in% c("id", "betreff", "thema", "versanddatum", "absender", "anzahlAnhaenge")) |>
        purrr::modify_at("thema", list) |>
        tibble::as_tibble()) |>
    dplyr::mutate(versanddatum = lubridate::as_datetime(versanddatum))
}

#' @export
#' @rdname get_nachrichten
get_nachrichten_raw <- function(
    user_auth = list(username = NA, password = NA),
    verbosity = 0,
    basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal"
) {

  # Erzeugt die vollständige URL für den Endpunkt
  url <- paste0(basis_url, "/ws/sda/nachrichten")

  # Fragt die Nachrichten ab
  response <- httr2::request(url) |>
    httr2::req_auth_basic(user_auth$username, user_auth$password) |>
    httr2::req_perform(verbosity = verbosity)

  # Gib das vollständige Response-Objekt zurück
  return(response)
}
