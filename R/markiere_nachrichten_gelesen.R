#' eSTATISTIK Nachrichten als gelesen markieren.
#'
#' Gelesene Nachrichten werden in der Nachrichtenliste nicht mehr angezeigt.
#'
#'
#' @param nachrichten_df DataFrame der Nachrichten von [get_nachrichten()].
#' @param user_auth Eine Liste mit den eSTATISTIK Benutzerdaten: `list(username = "", password = "")`. Das
#' Passwort wird nachgefragt, wenn es leergelassen wird. Dadurch kann das Speichern des Passworts
#' im R Skript umgangen werden.
#' @param verbosity Default: 0. Detaillevel der Debug Informationen (0 bis 3).
#' @param basis_url Die URL des eSATISTIK Erhebungsportals.
#' Default: [https://erhebungsportal.estatistik.de/Erhebungsportal]
#' @return Gibt eine Liste der API responses zurück.
#' @examples
#' \dontrun{
#' user_auth <- list(username = "IhrBenutzername")
#' # oder
#' user_auth <- list(username = "IhrBenutzername", password = "IhrPasswort")
#'
#' # Die älteste Nachricht als gelesen markieren
#' df_nachrichten <- get_nachrichten(user_auth = user_auth) |>
#'   tail(n = 1) |>
#'   markiere_nachrichten_gelesen(user_auth = user_auth)
#'
#' }

#' @export

markiere_nachrichten_gelesen <- function(
  nachrichten_df, user_auth = user_auth, verbosity = 0,
  basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal"
) {

  # R CMD CHECK glücklich machen
  id <- NULL

  out <- nachrichten_df |>
    dplyr::pull(id) |>
    purrr::map(.mark_as_read, user_auth = user_auth, verbosity = verbosity, basis_url = basis_url)

  return(out)
}

.mark_as_read <- function(
  nachrichten_id, user_auth, verbosity = 0,
  basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal"
) {

  url <- glue::glue(basis_url, "/ws/sda/nachrichten/{nachrichten_id}")

  response <- httr2::request(url) |>
    httr2::req_auth_basic(user_auth$username, user_auth$password) |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform(verbosity = verbosity)

  status <- httr2::resp_status(response)

  if (status != 200) {
    message(glue::glue("API Fehler: HTTP status {status} bei Nachricht ID {nachrichten_id}"))
  }

  return(response)
}
