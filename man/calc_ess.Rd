% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_ess.R
\name{calc_ess}
\alias{calc_ess}
\title{Calculates the Effective Sample Size}
\usage{
calc_ess(trace, sample_interval)
}
\arguments{
\item{trace}{the values without burn-in}

\item{sample_interval}{the interval in timesteps between samples}
}
\value{
the effective sample size
}
\description{
Calculates the Effective Sample Size
}
\examples{
  filename <- get_tracerer_path("beast2_example_output.log")

 # Parse the file as-is and conclude the sampling interval
 df <- parse_beast_log(filename)
 sample_interval <- df$Sample[2] - df$Sample[1] # nolint BEAST2 style

 # Only keep the parameter estimates,
 # do not care about the sampling times anymore
 estimates <- subset(df, select = -Sample) # nolint BEAST2 style

 esses <- rep(NA, ncol(estimates))
 burn_in_fraction <- 0.1
 for (i in seq_along(estimates)) {
   # Trace with the burn-in still present
   trace_raw <- as.numeric(t(estimates[i]))

   # Trace with the burn-in removed
   trace <- remove_burn_in(
     trace = trace_raw,
     burn_in_fraction = 0.1
   )

   # Store the effectice sample size
   esses[i] <- calc_ess(trace, sample_interval = sample_interval)
 }

 # Use the values that TRACER shows
 expected_esses <- c(10, 10, 10, 10, 7, 10, 9, 6)
 testit::assert(all(expected_esses - esses < 0.5))
}
\seealso{
Java code can be found here: \url{https://github.com/CompEvol/beast2/blob/9f040ed0357c4b946ea276a481a4c654ad4fff36/src/beast/core/util/ESS.java#L161} # nolint URLs can be long
}
\author{
The original Java version of the algorithm was from Remco Bouckaert,
  ported to R and adapted by Richel J.C. Bilderbeek
}
