## ------------------------------------------------------------------------
library(tracerer)

## ------------------------------------------------------------------------
trees_file <- get_tracerer_path("beast2_example_output.log")
testit::assert(file.exists(trees_file))
estimates <- parse_beast_log(trees_file)
knitr::kable(estimates)

## ------------------------------------------------------------------------
esses <- rep(NA, ncol(estimates))
burn_in_fraction <- 0.1
for (i in seq_along(estimates)) {
  # Trace with the burn-in still present
  trace_raw <- as.numeric(t(estimates[i]))

  # Trace with the burn-in removed
  trace <- remove_burn_in(trace = trace_raw, burn_in_fraction = 0.1)

  # Store the effectice sample size
  esses[i] <- calc_ess(trace, sample_interval = 1000)
}

# Note that the first value of three is nonsense:
# it is the index of the sample. I keep it in
# for simplicity of writing this code
expected_esses <- c(3, 10, 10, 10, 10, 7, 10, 9, 6)
testit::assert(all(expected_esses - esses < 0.5))

df_esses <- data.frame(esses)
rownames(df_esses) <- names(estimates)
knitr::kable(df_esses)

## ------------------------------------------------------------------------
rprof_tmp_output <- "~/tmp_tracerer_rprof"
Rprof(rprof_tmp_output)

for (i in 1:1) {
  estimates <- rbind(estimates, estimates)
}
print(nrow(estimates))

esses <- rep(NA, ncol(estimates))
burn_in_fraction <- 0.1
for (i in seq_along(estimates)) {
  # Trace with the burn-in still present
  trace_raw <- as.numeric(t(estimates[i]))

  # Trace with the burn-in removed
  trace <- remove_burn_in(trace = trace_raw, burn_in_fraction = 0.1)

  # Store the effectice sample size
  esses[i] <- calc_ess(trace, sample_interval = 1000)
}

Rprof(NULL)
summaryRprof(rprof_tmp_output)

