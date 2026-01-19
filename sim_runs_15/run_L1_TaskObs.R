source("R/qt_design_core.R")
source("R/sim_params.R")

library_id <- 1
task_id <- "TaskObs"

res <- run_mc_study(library_id, task_id, params)

out_dir <- file.path("results", sprintf("lib%d_%s", library_id, task_id))
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

write.csv(res$summary, file.path(out_dir, "summary.csv"), row.names = FALSE)
saveRDS(res$raw, file.path(out_dir, "raw.rds"))

title <- paste(res$summary$lib_label[1], res$summary$task_label[1], sep = " | ")
plot_proxy_risk(res$summary, file.path(out_dir, "proxy_risk.png"), title = title)
plot_proxy_risk_rescaled(res$summary, file.path(out_dir, "proxy_risk_rescaled.png"), title = title)
