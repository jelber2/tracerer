#' Calculates the Effective Sample Sizes from a parsed BEAST2 log file
#' @param traces a dataframe with traces with removed burn-in
#' @param sample_interval the interval in timesteps between samples
#' @param cores the number of cores you would like to use to process esses - can only be 1 if operating system is Windows
#' @return the effective sample sizes
#' @examples
#'   # Parse an example log file
#'   estimates_all <- parse_beast_log(
#'     get_tracerer_path("beast2_example_output.log")
#'   )
#'
#'   # Remove burn-ins
#'   estimates <- remove_burn_ins(estimates_all,
#'     burn_in_fraction = 0.1
#'   )
#'
#'   # Calculate the effective sample sizes of all parameter estimates
#'   esses <- calc_esses(
#'     estimates,
#'     sample_interval = 1000,
#'     cores = 70
#'   )
#'
#'   expected <- c(10, 10, 10, 10, 7, 10, 9, 6)
#'   testit::assert(all(esses == expected))
#' @export
#' @author Richel J.C. Bilderbeek
calc_esses <- function(
  traces,
  sample_interval,
  cores
) {

  if (!is.data.frame(traces)) {
    stop("traces must be a data.frame")
  }
  if (sample_interval < 1) {
    stop("sample interval must be at least one")
  }

  if (cores <= 0) {
    stop("cores must be >= 1")
  }
  
  # Remove warning: no visible binding for global variable 'Sample'
  Sample <- NULL; rm(Sample) # nolint use uppercase variable name just like BEAST2
  # Remove the Sample column from the dataframe
  traces <- subset(traces, select = -c(Sample )) # nolint use uppercase variable name just like BEAST2

  esses <- rep(NA, ncol(traces))
  
  # Determine the operating system. If Windows, do not allow more than 1 core.
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Windows'){
      if (cores > 1) {
        stop("Operating System is Windows, which only supports 1 core with doParallel::foreach") # stop if Operating System = Windows and more than 1 core is specified.
      }
    }
  }
  else {
    library(doParallel)
    registerDoParallel(cores=cores)
    esses <- foreach (i=1:length(traces), .combine=c, .inorder=TRUE) %dopar% {tracerer::calc_ess(as.numeric(t(traces[i])), sample_interval = sample_interval)}
  }

  df <- traces[1, ]
  df[1, ] <- esses
  testit::assert(nrow(df) == 1)
  testit::assert(names(df) == names(traces))

  # Round off values to nearest integers
  df[1, ] <- as.integer(df[1, ] + 0.5)

  df
}
