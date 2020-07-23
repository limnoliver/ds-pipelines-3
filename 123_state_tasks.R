do_state_tasks <- function(oldest_active_sites, ...) {

  split_inventory(summary_file = '1_fetch/tmp/state_splits.yml', sites_info = oldest_active_sites)
  # Define task table rows
  # TODO: DEFINE A VECTOR OF TASK NAMES HERE
  task_name <- oldest_active_sites$state_cd

  # Define task table columns
  download_step <- create_task_step(
    step_name = 'download',
    # TODO: Make target names like "WI_data"
    target_name = function(task_name, ...) {
      sprintf('%s_data', task_name)
    },
    # TODO: Make commands that call get_site_data()
    command = function(task_name, ...) {
      sprintf("get_site_data(sites_info_file = '1_fetch/tmp/inventory_%s.tsv', parameter = parameter)", task_name)
    }
  )

  plot_step <- create_task_step(
    step_name = 'plot',
    target_name = function(task_name, ...){
      sprintf('3_visualize/out/timeseries_%s.png', task_name)
    },
    command = function(task_name, steps, ...) {
      sprintf("plot_site_data(out_file = target_name, site_data = %s, parameter = parameter)", steps[['download']]$target_name)
    }
  )

  tally_step <- create_task_step(
    step_name = 'tally',
    target_name = function(task_name, ...) {
      sprintf('%s_tally', task_name)
    },
    command = function(task_name, steps, ...) {
      sprintf('tally_site_obs(site_data = %s)', steps[['download']]$target_name)
    }
  )

  # Return test results to the parent remake file
  # Create the task plan
  task_plan <- create_task_plan(
    task_names = task_name,
    task_steps = list(download_step, plot_step, tally_step),
    add_complete = FALSE)

  # Create the task remakefile
  create_task_makefile(
    # TODO: ADD ARGUMENTS HERE
    task_plan = task_plan,
    makefile = '123_state_tasks.yml',
    include = 'remake.yml',
    sources = c(...),
    packages = c('dplyr', 'dataRetrieval', 'lubridate'),
    tickquote_combinee_objects = FALSE,
    finalize_funs = c())

  # Build the tasks
  scmake('123_state_tasks', remake_file='123_state_tasks.yml')

  # Return nothing to the parent remake file
  return()
}

split_inventory <- function(summary_file = '1_fetch/tmp/state_splits.yml', sites_info=oldest_active_sites) {

  if(!dir.exists('1_fetch/tmp')) dir.create('1_fetch/tmp')

  # loop over oldest_active_sites to create temp files
  for (state in sites_info$state_cd){
    temp_dat <- filter(sites_info, state_cd %in% state)
    temp_filename <- file.path('1_fetch', 'tmp', sprintf('inventory_%s.tsv', state))
    readr::write_tsv(temp_dat, path = temp_filename)
  }

  split_filenames <- file.path('1_fetch', 'tmp', sprintf('inventory_%s.tsv', sites_info$state_cd))
  split_filenames_a <- split_filenames[order(split_filenames)]

  # write summary file
  scipiper::sc_indicate(ind_file = summary_file, data_file = split_filenames_a)
}
