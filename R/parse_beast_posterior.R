#' Parses BEAST2 output files to a posterior
#' @param trees_filenames one or more names of the BEAST2 .trees output files.
#'   A BEAST2 run will create as much .trees files as there are alignments
#' @param log_filename name of the BEAST2 .trees output file
#' @return a posterior
#' @export
#' @examples
#'   trees_filenames <- get_tracerer_path("beast2_example_output.trees")
#'   log_filename <- get_tracerer_path("beast2_example_output.log")
#'   posterior <- parse_beast_posterior(
#'     trees_filenames = trees_filenames,
#'     log_filename = log_filename
#'   )
#'   testit::assert(is_posterior(posterior))
#' @seealso Use \code{\link{remove_burn_ins}} to remove the burn-ins from
#'   the posterior's estimates (\code{posterior$estimates})
#' @author Richel J.C. Bilderbeek
parse_beast_posterior <- function(
  trees_filenames,
  log_filename
) {

  if (!files_exist(trees_filenames)) {
    stop("'trees_filenames' must be the name of one or more existing files. ",
      "File(s) with name(s) '", trees_filenames, "' not found")
  }

  if (!file.exists(log_filename)) {
    stop("'log_filename' must be the name of an existing file. ",
      "File with name '", log_filename, "' not found")
  }

  posterior <- list()
  for (i in seq_along(trees_filenames)) {
    trees_filename <- trees_filenames[i]
    posterior[[i]] <- tracerer::parse_beast_trees(
      trees_filename
    )
  }
  n_trees <- length(trees_filenames)
  posterior[[n_trees + 1]] <- tracerer::parse_beast_log(
    log_filename
  )
  names(posterior) <- c(
    paste0(basename(tools::file_path_sans_ext(trees_filenames)), "_trees"),
    "estimates"
  )
  posterior
}
