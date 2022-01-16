vim9script

#
# This file contains functions which implement Flog Vim commands.
#
# The "cmd/" folder contains functions for each command.
#

# The implementation of ":Flog".
def flog#cmd#flog(args: list<string>): void
  if !flog#fugitive#is_fugitive_buffer()
    throw g:flog_not_a_fugitive_buffer
  endif

  var state = flog#state#create()

  const fugitive_repo = flog#fugitive#get_repo()
  flog#state#set_fugitive_repo(state, fugitive_repo)
  const workdir = flog#state#get_fugitive_workdir(state)

  var default_opts = flog#state#get_default_opts()
  const opts = flog#cmd#flog#args#parse(default_opts, workdir, args)
  flog#state#set_opts(state, opts)

  flog#cmd#flog#buf#open(state)

  const cmd = flog#cmd#flog#git#build_log_cmd()
  const parsed = flog#cmd#flog#git#parse_log_output(flog#utils#shell#run(cmd))
  flog#state#set_commits(state, parsed.commits)

  const graph = flog#graph#generate(parsed.commits, parsed.all_commit_content)

  flog#cmd#flog#buf#set_content(graph.output)
enddef
