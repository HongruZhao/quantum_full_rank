## Global simulation parameters for adaptive tomography studies.

N <- 2
d <- N^2 - 1

n_total <- 50
mc_reps <- 100
refit_every <- 1

fast_mode <- tolower(Sys.getenv("QT_FAST", "")) %in% c("1", "true", "yes")
if (fast_mode) {
  n_total <- 20
  mc_reps <- 20
  refit_every <- 2
}

n_init_by_library <- function(lib_id) {
  lib_id <- as.integer(lib_id)
  if (lib_id %in% c(1, 2, 3, 4)) return(10)
  10
}

init_settings_by_library <- function(lib_id) {
  lib_id <- as.integer(lib_id)
  if (lib_id == 1) return(c(1, 2, 3))
  if (lib_id == 2) return(c(1, 2, 3))
  if (lib_id == 3) return(c(1, 2))
  if (lib_id == 4) return(c(1, 2, 3, 4))
  integer(0)
}

solver <- "SCS"
eps_prob <- 1e-12
eps_log <- 1e-12
ridge_inv <- 1e-8
eta_mle <- 1e-3
mu_logcosh <- 0.05

true_state_mode <- "fixed"
theta_true <- c(0.35, -0.25, 0.40)

sigma_x <- matrix(c(0, 1, 1, 0), 2, 2)
sigma_y <- matrix(c(0, -1i, 1i, 0), 2, 2)
sigma_z <- matrix(c(1, 0, 0, -1), 2, 2)
obs_list <- list(sigma_x, sigma_z)

seed_base <- 123
seed_lib4 <- 2025
plot_min_n <- 10

params <- list(
  N = N,
  d = d,
  n_total = n_total,
  mc_reps = mc_reps,
  refit_every = refit_every,
  n_init_by_library = n_init_by_library,
  solver = solver,
  eps_prob = eps_prob,
  eps_log = eps_log,
  ridge_inv = ridge_inv,
  eta_mle = eta_mle,
  mu_logcosh = mu_logcosh,
  true_state_mode = true_state_mode,
  theta_true = theta_true,
  obs_list = obs_list,
  init_settings_by_library = init_settings_by_library,
  seed_base = seed_base,
  seed_lib4 = seed_lib4,
  plot_min_n = plot_min_n
)
