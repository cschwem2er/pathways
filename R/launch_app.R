#' @title launch the pathways shiny app
#' @name corpus_explorer
#' @description
#' \code{corpus_explorer} launches the shiny app to explore the Pathways corpus.
#' @param use_browser Choose whether you want to launch the shiny app in your browser.
#' Defaults to \code{TRUE}.
#'
#' @import shiny
#' @export
#'
#'
corpus_explorer <- function(use_browser = TRUE) {
appDir <- system.file("app", package = "pathways")
if (appDir == "") {
  stop("Could not find directory. Try re-installing `pathways`.",
       call. = FALSE)
}

if (use_browser == TRUE)
  runApp(appDir, display.mode = "normal",
                launch.browser = TRUE)
else runApp(appDir, display.mode = "normal")

}



#'#' @examples
#'
#'  \dontrun{

#' # launch the app
#' if(interactive()){
#'   corpus_explorer()
#' }
