#!/usr/bin/env Rscript
## setwd("~/myfile/Research simulation/Quantum_Xiaxuan")
## Run all sim_runs_15 scripts sequentially and record timing.

args <- commandArgs(trailingOnly = TRUE)

script_arg <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", script_arg, value = TRUE)
if (length(file_arg) == 1) {
  script_path <- sub("^--file=", "", file_arg)
  script_dir <- dirname(normalizePath(script_path))
  setwd(script_dir)
}

run_dir <- if (length(args) >= 1) args[1] else "sim_runs_15"
log_path <- if (length(args) >= 2) args[2] else file.path("results", "run_all_rerun.log")
timing_path <- if (length(args) >= 3) args[3] else file.path("results", "run_all_timing.csv")

if (!dir.exists(run_dir)) {
  stop(sprintf("Run directory not found: %s", run_dir))
}

scripts <- sort(list.files(run_dir, pattern = "^run_.*\\.R$", full.names = TRUE))
if (length(scripts) == 0) {
  stop(sprintf("No run scripts found in %s", run_dir))
}

dir.create(dirname(log_path), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(timing_path), recursive = TRUE, showWarnings = FALSE)
log_con <- file(log_path, open = "wt")
on.exit(close(log_con), add = TRUE)

rscript <- Sys.which("Rscript")
if (rscript == "") {
  stop("Rscript not found in PATH.")
}

timing <- data.frame(
  script = character(),
  start_time = character(),
  end_time = character(),
  elapsed_sec = numeric(),
  status = character(),
  exit_code = integer(),
  stringsAsFactors = FALSE
)

total_start <- Sys.time()

for (script in scripts) {
  start_time <- Sys.time()
  start_msg <- sprintf("[%s] Running %s", format(start_time, "%F %T"), script)
  cat(start_msg, "\n")
  writeLines(start_msg, log_con)
  flush(log_con)

  tmp_out <- tempfile("run_all_output_", fileext = ".log")
  exit_code <- suppressWarnings(system2(rscript, script, stdout = tmp_out, stderr = tmp_out))
  if (file.exists(tmp_out)) {
    writeLines(readLines(tmp_out, warn = FALSE), log_con)
    unlink(tmp_out)
  }

  end_time <- Sys.time()
  elapsed <- as.numeric(difftime(end_time, start_time, units = "secs"))
  status <- if (exit_code == 0) "ok" else "failed"
  end_msg <- sprintf("[%s] Finished %s (status=%s, elapsed=%.1f s)",
                     format(end_time, "%F %T"), script, status, elapsed)
  cat(end_msg, "\n")
  writeLines(end_msg, log_con)
  flush(log_con)

  timing <- rbind(timing, data.frame(
    script = script,
    start_time = format(start_time, "%F %T"),
    end_time = format(end_time, "%F %T"),
    elapsed_sec = elapsed,
    status = status,
    exit_code = exit_code,
    stringsAsFactors = FALSE
  ))
  write.csv(timing, timing_path, row.names = FALSE)

  if (exit_code != 0) {
    stop(sprintf("Script failed: %s (exit code %d)", script, exit_code))
  }
}

total_end <- Sys.time()
total_elapsed <- as.numeric(difftime(total_end, total_start, units = "secs"))
total_msg <- sprintf("Total elapsed: %.1f s (%.2f min)", total_elapsed, total_elapsed / 60)
cat(total_msg, "\n")
writeLines(total_msg, log_con)
