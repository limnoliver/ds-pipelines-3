do_state_tasks <- function(oldest_active_sites, ...) {

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
      sprintf("get_site_data(oldest_active_sites, state = I('%s'), parameter = parameter)", task_name)
    }
  )

  # Return test results to the parent remake file
  # Create the task plan
  task_plan <- create_task_plan(
    task_names = task_name,
    task_steps = list(download_step),
    add_complete = FALSE)

  # Create the task remakefile
  create_task_makefile(
    # TODO: ADD ARGUMENTS HERE
    task_plan = task_plan,
    makefile = '123_state_tasks.yml',
    include = 'remake.yml',
    sources = '1_fetch/src/get_site_data.R',
    packages = c('dplyr', 'dataRetrieval'),
    tickquote_combinee_objects = FALSE,
    finalize_funs = c())

  # Build the tasks
  scmake('123_state_tasks', remake_file='123_state_tasks.yml')

  # Return nothing to the parent remake file
  return()
}
