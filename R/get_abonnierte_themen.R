#' Abonnierte eSTATISITIK Themen abfragen
#'
#' Diese Funktion ruft die abonnierten Themen ab.
#'
#' @param user_auth Eine Liste mit den eSTATISTIK Benutzerdaten list(username, password). Das
#' Passwort wird nachgefragt, wenn es leergelassen wird. Dadurch kann das Speichern des Passworts
#' im R Skript umgangen werden.
#' @param verbosity Default: 0. Detaillevel der Debug Informationen (0 bis 3).
#' @param basis_url Die URL des eSATISTIK Erhebungsportals.
#' Default: https://erhebungsportal.estatistik.de/Erhebungsportal
#' @return Gibt die abonnierten Themen zurück.
#' @examples
#' \dontrun{
#' user_auth <- list(username = "IhrBenutzername", password = "IhrPasswort")
#' get_abonnierte_themen(user_auth = user_auth)
#'
#' user_auth <- list(username = "IhrBenutzername")
#' get_abonnierte_themen(user_auth = user_auth)
#' }
#' @export

get_abonnierte_themen <- function(
    user_auth = list(username = "", password = NULL),
    verbosity = 0,
    basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal"
) {

  # Erzeugt die vollständige URL für den Endpunkt
  url <- paste0(basis_url, "/ws/sda/themen")

  # Fragt die abbonierten Themen ab
  result <- httr2::request(url) |>
    httr2::req_auth_basic(user_auth$username, user_auth$password) |>
    httr2::req_perform(verbosity = verbosity)

  tidy_df <- httr2::resp_body_json(result) |>
    purrr::map_dfr(tibble::as_tibble)

  return(tidy_df)
}
