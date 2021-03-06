#' @title Create the internal runtime parameter list
#'   used internally in [make()].
#' @description This configuration list
#' is also required for functions such as [outdated()].
#' It is meant to be specific to
#' a single call to [make()], and you should not modify
#' it by hand afterwards. If you later plan to call [make()]
#' with different arguments (especially `targets`),
#' you should refresh the config list with another call to
#' [drake_config()]. For changes to the
#' `targets` argument
#' specifically, it is important to recompute the config list
#' to make sure the internal workflow network has all the targets you need.
#' Modifying the `targets` element afterwards will have no effect
#' and it could lead to false negative results from
#' [outdated()].
#' @export
#' @return The master internal configuration list of a project.
#' @seealso [make()], [drake_plan()], [vis_drake_graph()]
#' @param plan Workflow plan data frame.
#'   A workflow plan data frame is a data frame
#'   with a `target` column and a `command` column.
#'   (See the details in the [drake_plan()] help file
#'   for descriptions of the optional columns.)
#'   Targets are the objects that drake generates,
#'   and commands are the pieces of R code that produce them.
#'   You can create and track custom files along the way
#'   (see [file_in()], [file_out()], and [knitr_in()]).
#'   Use the function [drake_plan()] to generate workflow plan
#'   data frames.
#'
#' @param targets Character vector, names of targets to build.
#'   Dependencies are built too. Together, the `plan` and
#'   `targets` comprise the workflow network
#'   (i.e. the `graph` argument).
#'   Changing either will change the network.
#'
#' @param envir Environment to use. Defaults to the current
#'   workspace, so you should not need to worry about this
#'   most of the time. A deep copy of `envir` is made,
#'   so you don't need to worry about your workspace being modified
#'   by `make`. The deep copy inherits from the global environment.
#'   Wherever necessary, objects and functions are imported
#'   from `envir` and the global environment and
#'   then reproducibly tracked as dependencies.
#'
#' @param verbose Logical or numeric, control printing to the console.
#'   - `0` or `FALSE`: print nothing.
#'   - `1` or `TRUE`: print only targets to build.
#'   - `2`: plus checks and cache info.
#'   - `3`: plus missing imports.
#'   - `4`: plus all imports.
#'   - `5`: plus execution and total build times for targets.
#'   - `6`: plus notifications when targets are being stored.
#'
#' @param hook Deprecated.
#'
#' @param skip_targets Logical, whether to skip building the targets
#'   in `plan` and just import objects and files.
#'
#' @param parallelism Character scalar, type of parallelism to use.
#'   For detailed explanations, see the
#'   [high-performance computing chapter](https://ropenscilabs.github.io/drake-manual/hpc.html)
#'   of the user manual.
#'
#'   You could also supply your own scheduler function
#'   if you want to experiment or aggressively optimize.
#'   The function should take a single `config` argument
#'   (produced by [drake_config()]). Existing examples
#'   from `drake`'s internals are the `backend_*()` functions:
#'   - `backend_loop()`
#'   - `backend_clustermq()`
#'   - `backend_future()`
#'   - `backend_hasty()` (unofficial)
#'   However, this functionality is really a back door
#'   and should not be used for production purposes unless you really
#'   know what you are doing and you are willing to suffer setbacks
#'   whenever `drake`'s unexported core functions are updated.
#'
#' @param jobs Maximum number of parallel workers for processing the targets.
#'   You can experiment with [predict_runtime()]
#'   to help decide on an appropriate number of jobs.
#'   For details, visit
#'   <https://ropenscilabs.github.io/drake-manual/time.html>.
#'
#' @param jobs_preprocess Number of parallel jobs for processing the imports
#'   and doing other preprocessing tasks.
#'
#' @param packages Character vector packages to load, in the order
#'   they should be loaded. Defaults to `rev(.packages())`, so you
#'   should not usually need to set this manually. Just call
#'   [library()] to load your packages before `make()`.
#'   However, sometimes packages need to be strictly forced to load
#'   in a certain order, especially if `parallelism` is
#'   `"Makefile"`. To do this, do not use [library()]
#'   or [require()] or [loadNamespace()] or
#'   [attachNamespace()] to load any libraries beforehand.
#'   Just list your packages in the `packages` argument in the order
#'   you want them to be loaded.
#'
#' @param lib_loc Character vector, optional.
#'   Same as in `library()` or `require()`.
#'   Applies to the `packages` argument (see above).
#'
#' @param prework Expression (language object), list of expressions,
#'   or character vector.
#'   Code to run right before targets build.
#'   Called only once if `parallelism` is `"loop"`
#'   and once per target otherwise.
#'   This code can be used to set global options, etc.
#'
#' @param prepend Deprecated.
#' @param command Deprecated.
#' @param args Deprecated.
#' @param recipe_command Deprecated.
#'
#' @param log_progress Logical, whether to log the progress
#'   of individual targets as they are being built. Progress logging
#'   creates a lot of little files in the cache, and it may make builds
#'   a tiny bit slower. So you may see gains in storage efficiency
#'   and speed with
#'   `make(..., log_progress = FALSE)`.
#'
#' @param cache drake cache as created by [new_cache()].
#'   See also [get_cache()].
#'
#' @param fetch_cache Deprecated.
#'
#' @param timeout `deprecated`. Use `elapsed` and `cpu` instead.
#'
#' @param cpu Same as the `cpu` argument of `setTimeLimit()`.
#'   Seconds of cpu time before a target times out.
#'   Assign target-level cpu timeout times with an optional `cpu`
#'   column in `plan`.
#'
#' @param elapsed Same as the `elapsed` argument of `setTimeLimit()`.
#'   Seconds of elapsed time before a target times out.
#'   Assign target-level elapsed timeout times with an optional `elapsed`
#'   column in `plan`.
#'
#' @param retries Number of retries to execute if the target fails.
#'   Assign target-level retries with an optional `retries`
#'   column in `plan`.
#'
#' @param force Logical. If `FALSE` (default) then `drake` 
#'   imposes checks if the cache was created with an old
#'   and incompatible version of drake.
#'   If there is an incompatibility, `make()` stops to
#'   give you an opportunity to
#'   downgrade `drake` to a compatible version
#'   rather than rerun all your targets from scratch.
#'
#' @param graph An `igraph` object from the previous `make()`.
#'   Supplying a pre-built graph could save time.
#'
#' @param trigger Name of the trigger to apply to all targets.
#'   Ignored if `plan` has a `trigger` column.
#'   See [trigger()] for details.
#'
#' @param skip_imports Logical, whether to totally neglect to
#'   process the imports and jump straight to the targets. This can be useful
#'   if your imports are massive and you just want to test your project,
#'   but it is bad practice for reproducible data analysis.
#'   This argument is overridden if you supply your own `graph` argument.
#'
#' @param skip_safety_checks Logical, whether to skip the safety checks
#'   on your workflow. Use at your own peril.
#'
#' @param lazy_load Either a character vector or a logical. Choices:
#'   - `"eager"`: no lazy loading. The target is loaded right away
#'     with [assign()].
#'   - `"promise"`: lazy loading with [delayedAssign()]
#'   - `"bind"`: lazy loading with active bindings:
#'     `bindr::populate_env()`.
#'   - `TRUE`: same as `"promise"`.
#'   - `FALSE`: same as `"eager"`.
#'
#'   `lazy_load` should not be `"promise"`
#'   for `"parLapply"` parallelism combined with `jobs` greater than 1.
#'   For local multi-session parallelism and lazy loading, try
#'   `library(future); future::plan(multisession)` and then
#'   `make(..., parallelism = "future_lapply", lazy_load = "bind")`.
#'
#'   If `lazy_load` is `"eager"`,
#'   drake prunes the execution environment before each target/stage,
#'   removing all superfluous targets
#'   and then loading any dependencies it will need for building.
#'   In other words, drake prepares the environment in advance
#'   and tries to be memory efficient.
#'   If `lazy_load` is `"bind"` or `"promise"`, drake assigns
#'   promises to load any dependencies at the last minute.
#'   Lazy loading may be more memory efficient in some use cases, but
#'   it may duplicate the loading of dependencies, costing time.
#'
#' @param session_info Logical, whether to save the `sessionInfo()`
#'   to the cache. This behavior is recommended for serious [make()]s
#'   for the sake of reproducibility. This argument only exists to
#'   speed up tests. Apparently, `sessionInfo()` is a bottleneck
#'   for small [make()]s.
#'
#' @param cache_log_file Name of the cache log file to write.
#'   If `TRUE`, the default file name is used (`drake_cache.log`).
#'   If `NULL`, no file is written.
#'   If activated, this option uses
#'   [drake_cache_log_file()] to write a flat text file
#'   to represent the state of the cache
#'   (fingerprints of all the targets and imports).
#'   If you put the log file under version control, your commit history
#'   will give you an easy representation of how your results change
#'   over time as the rest of your project changes. Hopefully,
#'   this is a step in the right direction for data reproducibility.
#'
#' @param seed Integer, the root pseudo-random number generator
#'   seed to use for your project.
#'   In [make()], `drake` generates a unique
#'   local seed for each target using the global seed
#'   and the target name. That way, different pseudo-random numbers
#'   are generated for different targets, and this pseudo-randomness
#'   is reproducible.
#'
#'   To ensure reproducibility across different R sessions,
#'   `set.seed()` and `.Random.seed` are ignored and have no affect on
#'   `drake` workflows. Conversely, `make()` does not usually
#'   change `.Random.seed`,
#'   even when pseudo-random numbers are generated.
#'   The exceptions to this last point are
#'   `make(parallelism = "clustermq")` and
#'   `make(parallelism = "clustermq_staged")`,
#'   because the `clustermq` package needs to generate random numbers
#'   to set up ports and sockets for ZeroMQ.
#'
#'   On the first call to `make()` or `drake_config()`, `drake`
#'   uses the random number generator seed from the `seed` argument.
#'   Here, if the `seed` is `NULL` (default), `drake` uses a `seed` of `0`.
#'   On subsequent `make()`s for existing projects, the project's
#'   cached seed will be used in order to ensure reproducibility.
#'   Thus, the `seed` argument must either be `NULL` or the same
#'   seed from the project's cache (usually the `.drake/` folder).
#'   To reset the random number generator seed for a project,
#'   use `clean(destroy = TRUE)`.
#'
#' @param caching Character string, only applies to
#'   `"clustermq"`, `"clustermq_staged"`, and `"future"` parallel backends.
#'   The `caching` argument can be either `"master"` or `"worker"`.
#'   - `"master"`: Targets are built by remote workers and sent back to
#'     the master process. Then, the master process saves them to the
#'     cache (`config$cache`, usually a file system `storr`).
#'     Appropriate if remote workers do not have access to the file system
#'     of the calling R session. Targets are cached one at a time,
#'     which may be slow in some situations.
#'   - `"worker"`: Remote workers not only build the targets, but also
#'     save them to the cache. Here, caching happens in parallel.
#'     However, remote workers need to have access to the file system
#'     of the calling R session. Transferring target data across
#'     a network can be slow.
#'
#' @param keep_going Logical, whether to still keep running [make()]
#'   if targets fail.
#'
#' @param session An optional `callr` function if you want to
#'   build all your targets in a separate master session:
#'   for example, `make(plan = my_plan, session = callr::r_vanilla)`.
#'   Running `make()` in a clean, isolated
#'   session can enhance reproducibility.
#'   But be warned: if you do this, [make()] will take longer to start.
#'   If `session` is `NULL` (default), then [make()] will just use
#'   your current R session as the master session. This is slightly faster,
#'   but it causes [make()] to populate your workspace/environment
#'   with the last few targets it builds.
#'
#' @param pruning_strategy Deprecated. See `memory_strategy`.
#'
#' @param memory_strategy Character scalar, name of the
#'   strategy `drake` uses to manage targets in memory. For more direct
#'   control over which targets `drake` keeps in memory, see the
#'   help file examples of [drake_envir()]. The `memory_strategy` argument
#'   to `make()` and `drake_config()` is an attempt at an automatic
#'   catch-all solution. These are the choices.
#'
#' - `"speed"`: Once a target is loaded in memory, just keep it there.
#'   This choice maximizes speed and hogs memory.
#' - `"memory"`: Just before building each new target,
#'   unload everything from memory except the target's direct dependencies.
#'   This option conserves memory, but it sacrifices speed because
#'   each new target needs to reload
#'   any previously unloaded targets from storage.
#' - `"lookahead"`: Just before building each new target,
#'   search the dependency graph to find targets that will not be
#'   needed for the rest of the current `make()` session.
#'   In this mode, targets are only in memory if they need to be loaded,
#'   and we avoid superfluous reads from the cache.
#'   However, searching the graph takes time,
#'   and it could even double the computational overhead for large projects.
#'
#' Each strategy has a weakness.
#' `"speed"` is memory-hungry, `"memory"` wastes time reloading
#' targets from storage, and `"lookahead"` wastes time
#' traversing the entire dependency graph on every [make()]. For a better
#' compromise and more control, see the examples in the help file
#' of [drake_envir()].
#'
#' @param makefile_path Path to the `Makefile` for
#'   `make(parallelism = "Makefile")`. If you set this argument to a
#'   non-default value, you are responsible for supplying this same
#'   path to the `args` argument so `make` knows where to find it.
#'   Example: `make(parallelism = "Makefile", makefile_path = ".drake/.makefile", command = "make", args = "--file=.drake/.makefile")`
#'
#' @param console_log_file Character scalar,
#'   connection object (such as `stdout()`) or `NULL`.
#'   If `NULL`, console output will be printed
#'   to the R console using `message()`.
#'   If a character scalar, `console_log_file`
#'   should be the name of a flat file, and
#'   console output will be appended to that file.
#'   If a connection object (e.g. `stdout()`)
#'   warnings and messages will be sent to the connection.
#'   For example, if `console_log_file` is `stdout()`,
#'   warnings and messages are printed to the console in real time
#'   (in addition to the usual in-bulk printing
#'   after each target finishes).
#'
#' @param ensure_workers Logical, whether the master process
#'   should wait for the workers to post before assigning them
#'   targets. Should usually be `TRUE`. Set to `FALSE`
#'   for `make(parallelism = "future_lapply", jobs = n)`
#'   (`n > 1`) when combined with `future::plan(future::sequential)`. 
#'   This argument only applies to parallel computing with persistent workers
#'   (`make(parallelism = x)`, where `x` could be `"mclapply"`,
#'   `"parLapply"`, or `"future_lapply"`).
#'
#' @param garbage_collection Logical, whether to call `gc()` each time
#'   a target is built during [make()].
#'
#' @param template A named list of values to fill in the `{{ ... }}`
#'   placeholders in template files (e.g. from [drake_hpc_template_file()]).
#'   Same as the `template` argument of `clustermq::Q()` and
#'   `clustermq::workers`.
#'   Enabled for `clustermq` only (`make(parallelism = "clustermq_staged")`),
#'   not `future` or `batchtools` so far.
#'   For more information, see the `clustermq` package:
#'   <https://github.com/mschubert/clustermq>.
#'   Some template placeholders such as `{{ job_name }}` and `{{ n_jobs }}`
#'   cannot be set this way.
#'
#' @param sleep In its parallel processing, `drake` uses
#'   a central master process to check what the parallel
#'   workers are doing, and for the affected high-performance
#'   computing workflows, wait for data to arrive over a network.
#'   In between loop iterations, the master process sleeps to avoid throttling.
#'   The `sleep` argument to `make()` and `drake_config()`
#'   allows you to customize how much time the master process spends
#'   sleeping.
#'
#'   The `sleep` argument is a function that takes an argument
#'   `i` and returns a numeric scalar, the number of seconds to
#'   supply to `Sys.sleep()` after iteration `i` of checking.
#'   (Here, `i` starts at 1.)
#'   If the checking loop does something other than sleeping
#'   on iteration `i`, then `i` is reset back to 1.
#'
#'   To sleep for the same amount of time between checks,
#'   you might supply something like `function(i) 0.01`.
#'   But to avoid consuming too many resources during heavier
#'   and longer workflows, you might use an exponential
#'   back-off: say,
#'   `function(i) { 0.1 + 120 * pexp(i - 1, rate = 0.01) }`.
#'
#' @param hasty_build A user-defined function.
#'   In "hasty mode" (`make(parallelism = "hasty")`)
#'   this is the function that evaluates a target's command
#'   and returns the resulting value. The `hasty_build` argument
#'   has no effect if `parallelism` is any value other than "hasty".
#'
#'   The function you pass to `hasty_build` must have arguments `target`
#'   and `config`. Here, `target` is a character scalar naming the
#'   target being built, and `config` is a configuration list of
#'   runtime parameters generated by [drake_config()].
#'
#' @param layout `config$layout`, where `config` is the return value
#'   from a prior call to `drake_config()`. If your plan or environment
#'   have changed since the last `make()`, do not supply a `layout` argument.
#'   Otherwise, supplying one could save time.
#'
#' @param lock_envir Logical, whether to lock `config$envir` during `make()`.
#'   If `TRUE`, `make()` quits in error whenever a command in your
#'   `drake` plan (or `prework`) tries to add, remove, or modify
#'   non-hidden variables in your environment/workspace/R session.
#'   This is extremely important for ensuring the purity of your functions
#'   and the reproducibility/credibility/trust you can place in your project.
#'   `lock_envir` will be set to a default of `TRUE` in `drake` version
#'   7.0.0 and higher.
#'
#' @examples
#' \dontrun{
#' test_with_dir("Quarantine side effects.", {
#' load_mtcars_example() # Get the code with drake_example("mtcars").
#' # Construct the master internal configuration list.
#' config <- drake_config(my_plan)
#' if (requireNamespace("visNetwork")) {
#'   vis_drake_graph(config) # See the dependency graph.
#'   if (requireNamespace("networkD3")) {
#'     sankey_drake_graph(config) # See the dependency graph.
#'   }
#' }
#' # These functions are faster than otherwise
#' # because they use the configuration list.
#' outdated(config) # Which targets are out of date?
#' missed(config) # Which imports are missing?
#' })
#' }
drake_config <- function(
  plan,
  targets = NULL,
  envir = parent.frame(),
  verbose = 1L,
  hook = NULL,
  cache = drake::get_cache(
    verbose = verbose, console_log_file = console_log_file),
  fetch_cache = NULL,
  parallelism = "loop",
  jobs = 1L,
  jobs_preprocess = 1L,
  packages = rev(.packages()),
  lib_loc = NULL,
  prework = character(0),
  prepend = NULL,
  command = NULL,
  args = NULL,
  recipe_command = NULL,
  timeout = NULL,
  cpu = Inf,
  elapsed = Inf,
  retries = 0,
  force = FALSE,
  log_progress = FALSE,
  graph = NULL,
  trigger = drake::trigger(),
  skip_targets = FALSE,
  skip_imports = FALSE,
  skip_safety_checks = FALSE,
  lazy_load = "eager",
  session_info = TRUE,
  cache_log_file = NULL,
  seed = NULL,
  caching = c("master", "worker"),
  keep_going = FALSE,
  session = NULL,
  pruning_strategy = NULL,
  makefile_path = NULL,
  console_log_file = NULL,
  ensure_workers = TRUE,
  garbage_collection = FALSE,
  template = list(),
  sleep = function(i) 0.01,
  hasty_build = NULL,
  memory_strategy = c("speed", "memory", "lookahead"),
  layout = NULL,
  lock_envir = TRUE
) {
  force(envir)
  unlink(console_log_file)
  deprecate_fetch_cache(fetch_cache)
  if (!is.null(hook)) {
    warning(
      "Argument `hook` is deprecated.",
      call. = FALSE
    ) # 2018-10-25 # nolint
  }
  if (!is.null(pruning_strategy)) {
    warning(
      "Argument `pruning_strategy` is deprecated. ",
      "Use `memory_strategy` instead.",
      call. = FALSE
    ) # 2018-11-01 # nolint
  }
  if (!is.null(timeout)) {
    warning(
      "Argument `timeout` is deprecated. ",
      "Use `elapsed` and/or `cpu` instead.",
      call. = FALSE
      # 2018-12-07 # nolint
    )
  }
  if (!is.null(graph)) {
    warning(
      "Argument `graph` is deprecated. Instead, ",
      "the preprocessing of the graph is memoized to save time.",
      call. = FALSE
      # 2018-12-19 # nolint
    )
  }
  if (!is.null(layout)) {
    warning(
      "Argument `layout` is deprecated. Instead, ",
      "the preprocessing of the layout is memoized to save time.",
      call. = FALSE
      # 2018-12-19 # nolint
    )
  }
  deprecate_fetch_cache(fetch_cache)
  if (!is.null(timeout)) {
    warning(
      "Argument `timeout` is deprecated. ",
      "Use `elapsed` and/or `cpu` instead.",
      call. = FALSE
      # 2018-12-07 # nolint
    )
  }
  if (!is.null(hasty_build)) {
    warning(
      "Argument `hasty_build` is deprecated. ",
      "Check out https://github.com/wlandau/drake.hasty instead.",
      call. = FALSE
      # 2018-12-07 # nolint
    )
  }
  if (!is.null(session)) {
    # Deprecated on 2018-12-18.
    warning(
      "The ", sQuote("session"), " argument of make() and drake_config() ",
      "is deprecated. make() will NOT run in a separate callr session. ",
      "For reproducibility, you may wish to try make(lock_envir = TRUE). ",
      "Details: https://github.com/ropensci/drake/issues/623.",
      call. = FALSE
    )
  }
  if (
    !is.null(command) ||
    !is.null(args) ||
    !is.null(recipe_command) ||
    !is.null(prepend) ||
    !is.null(makefile_path)
  ) {
    warning(
      "Arguments `command`, `args`, `prepend`, `makefile_path`, ",
      "`recipe_command` are deprecated ",
      "because Makefile parallelism is no longer supported.",
      call. = FALSE
      # 2019-01-03 # nolint
    )
  }
  plan <- sanitize_plan(plan)
  if (is.null(targets)) {
    targets <- plan$target
  } else {
    targets <- sanitize_targets(plan, targets)
  }
  if (is.null(cache)) {
    cache <- recover_cache_(
      verbose = verbose,
      fetch_cache = fetch_cache,
      console_log_file = console_log_file
    )
  }
  if (identical(force, TRUE)) {
    drake_set_session_info(cache = cache, full = session_info)
  }
  seed <- choose_seed(supplied = seed, cache = cache)
  trigger <- convert_old_trigger(trigger)
  layout <- create_drake_layout(
    plan = plan,
    envir = envir,
    verbose = verbose,
    jobs = jobs,
    console_log_file = console_log_file,
    trigger = trigger,
    cache = cache
  )
  graph <- create_drake_graph(
    plan = plan,
    layout = layout,
    targets = targets,
    cache = cache,
    jobs = jobs_preprocess,
    console_log_file = console_log_file,
    verbose = verbose
  )
  import_names <- igraph::V(graph)$name[igraph::V(graph)$imported]
  imports <- subset_graph(graph, import_names)
  schedule <- subset_graph(graph, plan$target)
  cache_path <- force_cache_path(cache)
  lazy_load <- parse_lazy_arg(lazy_load)
  memory_strategy <- match.arg(memory_strategy)
  caching <- match.arg(caching)
  ht_encode_path <- ht_new()
  ht_decode_path <- ht_new()
  ht_encode_namespaced <- ht_new()
  ht_decode_namespaced <- ht_new()
  out <- list(
    plan = plan,
    targets = targets,
    envir = envir,
    eval = new.env(parent = envir),
    cache = cache,
    cache_path = cache_path,
    parallelism = parallelism,
    jobs = jobs,
    jobs_preprocess = jobs_preprocess,
    verbose = verbose,
    packages = packages,
    lib_loc = lib_loc,
    prework = prework,
    layout = layout,
    ht_encode_path = ht_encode_path,
    ht_decode_path = ht_decode_path,
    ht_encode_namespaced = ht_encode_namespaced,
    ht_decode_namespaced = ht_decode_namespaced,
    graph = graph,
    imports = imports,
    schedule = schedule,
    seed = seed,
    trigger = trigger,
    timeout = timeout,
    cpu = cpu,
    elapsed = elapsed,
    retries = retries,
    skip_targets = skip_targets,
    skip_imports = skip_imports,
    skip_safety_checks = skip_safety_checks,
    log_progress = log_progress,
    lazy_load = lazy_load,
    session_info = session_info,
    cache_log_file = cache_log_file,
    caching = caching,
    keep_going = keep_going,
    session = session,
    memory_strategy = memory_strategy,
    console_log_file = console_log_file,
    ensure_workers = ensure_workers,
    garbage_collection = garbage_collection,
    template = template,
    sleep = sleep,
    hasty_build = hasty_build,
    lock_envir = lock_envir,
    force = force
  )
  out <- enforce_compatible_config(out)
  config_checks(out)
  out
}

#' @title Do the prework in the `prework`
#'   argument to [make()].
#' @export
#' @keywords internal
#' @description For internal use only.
#' The only reason this function is exported
#' is to set up parallel socket (PSOCK) clusters
#' without too much fuss.
#' @return Inivisibly returns `NULL`.
#' @param config internal configuration list
#' @param verbose_packages logical, whether to print
#'   package startup messages
#' @examples
#' \dontrun{
#' test_with_dir("Quarantine side effects.", {
#' if (suppressWarnings(require("knitr"))) {
#' load_mtcars_example() # Get the code with drake_example("mtcars").
#' # Create a master internal configuration list with prework.
#' con <- drake_config(my_plan, prework = c("library(knitr)", "x <- 1"))
#' # Do the prework. Usually done at the beginning of `make()`,
#' # and for distributed computing backends like "future_lapply",
#' # right before each target is built.
#' do_prework(config = con, verbose_packages = TRUE)
#' # The `eval` element is the environment where the prework
#' # and the commands in your workflow plan data frame are executed.
#' identical(con$eval$x, 1) # Should be TRUE.
#' }
#' })
#' }
do_prework <- function(config, verbose_packages) {
  for (package in union(c("methods", "drake"), config$packages)) {
    expr <- as.call(c(
      quote(require),
      package = package,
      lib.loc = as.call(c(quote(c), config$lib_loc)),
      quietly = TRUE,
      character.only = TRUE
    ))
    if (verbose_packages) {
      expr <- as.call(c(quote(suppressPackageStartupMessages), expr))
    }
    eval(expr, envir = config$eval)
  }
  if (is.character(config$prework)) {
    config$prework <- parse(text = config$prework)
  }
  if (is.language(config$prework)) {
    eval(config$prework, envir = config$eval)
  } else if (is.list(config$prework)) {
    lapply(config$prework, eval, envir = config$eval)
  }
  invisible()
}
