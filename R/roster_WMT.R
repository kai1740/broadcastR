

#' Title
#'
#' @param teamName 
#' @param url 
#' @param sport 
#'
#' @return
#'
#' @examples
fetchRoster_WMT <- function(teamName, url, sport){
  page <- xml2::read_html(url)
  
  players <- rvest::html_node(page, "table#roster_sort, table[class*='roster']")
  
  roster <- rvest::html_table(players)
  
  return(roster)
}


#' Title
#'
#' @param roster_df 
#'
#' @return
#'
#' @examples
cleanRoster_WMT <- function(roster_df){
  # Split bats into bats/throws, hometown into hometown/state, remove lbs from weight.
  
  player_df <- roster_df %>% 
    try(tidyr::separate("B/T",
                    into = c("Bats","Throws"),
                    sep = "/")) %>% 
    dplyr::rename_at(dplyr::vars(dplyr::starts_with("Pos")),~"Position") %>% 
    tidyr::separate("Hometown",
                    into = c("Hometown","State"),
                    sep = ", +") %>% 
    dplyr::rename(Height = "Ht.",
                  Weight = "Wt.") %>% 
    dplyr::mutate(Position1 = stringr::str_extract(Position,"[A-z/123]+$"),
                  Height = stringr::str_replace(Height, "(\\d)-(\\d+)","\\1'\\2\\\"")) %>%
    dplyr::select(-Position)
  
  return(dplyr::as_tibble(player_df))

}


getRoster_WMT <- function(teamName, url, sport){
  
  roster <- fetchRoster_WMT(teamName, url, sport)
  
  rosterClean <- cleanRoster_WMT(roster)
  
  return(rosterClean)
}
