#' Anhänge von eSTATISTIK Nachrichten abrufen und herunterladen
#'
#'
#' @param nachrichten_df DataFrame der Nachrichten von [get_nachrichten()].
#' @param user_auth Eine Liste mit den eSTATISTIK Benutzerdaten: `list(username = "", password = "")`. Das
#' Passwort wird nachgefragt, wenn es leergelassen wird. Dadurch kann das Speichern des Passworts
#' im R Skript umgangen werden.
#' @param verbosity Default: 0. Detaillevel der Debug Informationen (0 bis 3).
#' @param basis_url Die URL des eSATISTIK Erhebungsportals.
#' Default: <https://erhebungsportal.estatistik.de/Erhebungsportal>
#' @return `get_anhaenge_info` gibt ein DataFrame der Nachrichten mit den IDs der Anhänge zurück.
#' @examples
#' \dontrun{
#' user_auth <- list(username = "IhrBenutzername")
#' # oder
#' user_auth <- list(username = "IhrBenutzername", password = "IhrPasswort")
#'
#' df_nachrichten <- get_nachrichten(user_auth = user_auth) |>
#'   get_anhaenge_info(user_auth = user_auth) |>
#'   download_anhaenge(user_auth = user_auth, path = ".")
#' print(df_nachrichten)
#' }

#' @export
#' @rdname anhaenge
get_anhaenge_info <- function(
    nachrichten_df, user_auth, verbosity = 0,
    basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal") {
  # R CMD CHECK glücklich machen
  id <- anzahlAnhaenge <- anhang <- NULL

  nachrichten_df |>
    dplyr::mutate(anhang = purrr::map2(id, anzahlAnhaenge, .get_anhang,
      user_auth = user_auth, verbosity = verbosity, basis_url = basis_url
    )) |>
    tidyr::unnest_wider(anhang, names_sep = "_") |>
    tidyr::unnest(cols = tidyr::starts_with("anhang_"))
}

.get_anhang <- function(
    nachrichten_id, anzahlAnhaenge, user_auth, verbosity = 0,
    basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal") {
  url <- glue::glue(basis_url, "/ws/sda/nachrichten", "/{nachrichten_id}/anhaenge")

  result <- httr2::request(url) |>
    httr2::req_auth_basic(user_auth$username, user_auth$password) |>
    httr2::req_perform(verbosity = verbosity)

  out <- result |>
    httr2::resp_body_json() |>
    purrr::map_dfr(tibble::as_tibble)

  return(out)
}

#' @export
#' @rdname anhaenge
#' @param path Pfad des Ordners indem die heruntergeladenen Anhänge gespeichert werden sollen.
#' @return `download_anhaenge` gibt ein DataFrame der Nachrichten mit Speicherort und Größe der Anhänge zurück.
#' @importFrom utils object.size
download_anhaenge <- function(
    nachrichten_df, path = "out", user_auth, verbosity = 0,
    basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal") {
  if (!dir.exists(path)) dir.create(path)

  out <- nachrichten_df |>
    split(seq_len(nrow(nachrichten_df))) |>
    purrr::map_dfr(.download_anhang,
      user_auth = user_auth, path = path,
      verbosity = verbosity, basis_url = basis_url
    )

  return(out)
}

.download_anhang <- function(
    nachrichten_df, user_auth, path, verbosity = 0,
    basis_url = "https://erhebungsportal.estatistik.de/Erhebungsportal") {
  # DataFrame sollte genau eine Nachricht beinhalten, nicht mehr oder weniger
  if (is.null(nachrichten_df) || !is.data.frame(nachrichten_df) ||
      nrow(nachrichten_df) != 1) {
        return(NULL)
  }

  # Kein Anhang zum herunterladen
  if (is.null(nachrichten_df$anhang_id) || is.na(nachrichten_df$anhang_id)) {
    out <- nachrichten_df |> dplyr::mutate(location = NA_character_, anhang_size = utils::object.size(NULL))
    return(out)
  }

  # nolint start
  nachrichten_id <- nachrichten_df$id
  anhang_id <- nachrichten_df$anhang_id
  # nolint end

  anhang_name <- file.path(path, nachrichten_df$anhang_dateiname)

  url <- glue::glue(basis_url, "/ws/sda/nachrichten/{nachrichten_id}/anhaenge/{anhang_id}")


  response <- httr2::request(url) |>
    httr2::req_auth_basic(user_auth$username, user_auth$password) |>
    # TODO: Mit tryCatch ersetzen
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform(verbosity = verbosity)

  content_type <- httr2::resp_content_type(response)

  if (content_type != "application/octet-stream") {
    status <- httr2::resp_status(response)
    message(glue::glue("{Sys.time()} HTTP-Status {status}: {anhang_name} konnte nicht heruntergeladen werden"))
    anhang_name <- NA_character_
    anhang_size <- utils::object.size(NULL)
  } else {
    response_body <- response |>
      httr2::resp_body_raw()
    anhang_size <- utils::object.size(response_body)
    writeBin(response_body, con = anhang_name)
    message(glue::glue("{Sys.time()}: {anhang_name} heruntergeladen ({round(anhang_size/1024)} kbytes)"))
  }

  out <- nachrichten_df |>
    dplyr::mutate(
      location = anhang_name,
      anhang_size = anhang_size
    )

  return(out)
}
