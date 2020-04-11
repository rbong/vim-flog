scriptencoding utf-8

runtime! plugin/fugitive.vim
runtime! plugin/flog.vim

describe ':Flog'
  before
    Flog
  end

  after
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'allows quitting'
    call flog#quit()
    Expect &ft !=# 'floggraph'
  end

  it 'sets filetype'
    Expect &ft ==# 'floggraph'
  end

  it 'shows output'
    Expect line('$') > 1
  end

  it 'opens in a tab'
    Expect winnr('$') == 1
    Expect tabpagenr() == 2
  end

  it 'has empty temporary windows'
    Expect flog#get_state().tmp_window_ids == []
  end
end

" returns empty log every time
describe ':Flog -- --not --glob="*"'
  before
    Flog -- --not --glob="*"
  end

  after
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'does not crash on opening temp commit'
    call flog#run_tmp_command('Gsplit %h')
    Expect winnr('$') == 1
  end
end

describe ':Flogsplit'
  before
    Flogsplit
  end

  after
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'sets filetype'
    Expect &ft ==# 'floggraph'
  end

  it 'shows output'
    Expect line('$') > 1
  end

  it 'opens in a split'
    Expect winnr('$') == 2
    Expect tabpagenr() == 1
  end

  it 'has empty temp windows'
    Expect flog#get_state().tmp_window_ids == []
  end
end

describe 'flog#run_tmp_command("Gsplit %h", 1)'
  before
    Flog
    call flog#run_tmp_command('Gsplit %h', 1)
  end

  after
    if &ft ==# 'git'
      close!
    endif
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'opens in a temp window'
    Expect &ft !=# 'floggraph'
    Expect winnr('$') == 2
    Expect flog#get_state().tmp_window_ids == [win_getid()]
  end
end

" implicitly does not open in a temp window
describe 'flog#run_tmp_command("Git status", 1)'
  before
    Flog
    call flog#run_tmp_command('Git status', 1)
  end

  after
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'does not open in a window'
    Expect &ft ==# 'floggraph'
    Expect winnr('$') == 1
    Expect flog#get_state().tmp_window_ids == []
  end
end

" explicitly opens in a temp window
describe 'flog#run_tmp_command("Git -p status", 1)'
  before
    Flog
    call flog#run_tmp_command('Git -p status', 1)
  end

  after
    call flog#quit()
  end

  it 'opens in a temp window'
    Expect &ft !=# 'floggraph'
    Expect winnr('$') == 2
    Expect flog#get_state().tmp_window_ids == [win_getid()]
  end
end

" implicitly opens in a temp window
describe 'flog#run_tmp_command("Git diff", 1)'
  before
    Flog
    call flog#run_tmp_command('Git diff', 1)
  end

  after
    call flog#quit()
  end

  it 'opens in a temp window'
    Expect &ft !=# 'floggraph'
    Expect winnr('$') == 2
    Expect flog#get_state().tmp_window_ids == [win_getid()]
  end
end

" both explicitly and implicitly opens in a temp window
describe 'flog#run_tmp_command("Git -p diff", 1)'
  before
    Flog
    call flog#run_tmp_command('Git -p diff', 1)
  end

  after
    call flog#quit()
  end

  it 'opens in a temp window'
    Expect &ft !=# 'floggraph'
    Expect winnr('$') == 2
    Expect flog#get_state().tmp_window_ids == [win_getid()]
  end
end

" vim: set et sw=2 ts=2 fdm=marker:
