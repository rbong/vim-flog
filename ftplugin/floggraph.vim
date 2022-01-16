vim9script

# Commands

command! -range=0 -complete=customlist,flog#cmd#flog#args#complete -nargs=* Flogsetargs call flog#cmd#flog_set_args([<f-args>])
