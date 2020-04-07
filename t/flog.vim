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
    call flog#run_tmp_command(flog#format_commit(flog#get_commit_at_current_line(), 'Gsplit %s'))
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

" vim: set et sw=2 ts=2 fdm=marker:
