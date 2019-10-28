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

  it 'has empty preview windows'
    Expect flog#get_state().preview_window_ids == []
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

  it 'does not crash on previewing commit'
    call flog#preview_commit('Gsplit')
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

  it 'has empty preview windows'
    Expect flog#get_state().preview_window_ids == []
  end
end

describe 'flog#preview_commit()'
  before
    Flog
    call flog#preview_commit('Gsplit')
    wincmd w
  end

  after
    if &ft ==# 'git'
      quit
    endif
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'sets filetype'
    Expect &ft ==# 'git'
  end

  it 'opens in a preview window'
    Expect winnr('$') == 2
    Expect flog#get_state().preview_window_ids == [win_getid()]
  end
end

" implicitly does not open in a preview window
describe 'flog#git("", "", "status")'
  before
    Flog
    call flog#git('', '', 'status')
  end

  after
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'does not open in a window'
    Expect &ft ==# 'floggraph'
    Expect winnr('$') == 1
    Expect flog#get_state().preview_window_ids == []
  end
end

" explicitly opens in a preview window
describe 'flog#git("", "!", "status")'
  before
    Flog
    call flog#git('', '!', 'status')
  end

  after
    if &ft ==# 'git'
      call flog#quit()
    endif
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'opens in a preview window'
    wincmd w
    Expect &ft ==# 'git'
    Expect winnr('$') == 2
    Expect flog#get_state().preview_window_ids == [win_getid()]
  end
end

" implicitly opens in a preview window
describe 'flog#git("", "", "diff")'
  before
    Flog
    call flog#git('', '', 'diff')
  end

  after
    if &ft ==# 'git'
      call flog#quit()
    endif
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'opens in a preview window'
    wincmd w
    Expect &ft ==# 'git'
    Expect winnr('$') == 2
    Expect flog#get_state().preview_window_ids == [win_getid()]
  end
end

" both explicitly and implicitly opens in a preview window
describe 'flog#git("", "!", "diff")'
  before
    Flog
    call flog#git('', '!', 'diff')
  end

  after
    if &ft ==# 'git'
      call flog#quit()
    endif
    if &ft ==# 'floggraph'
      call flog#quit()
    endif
  end

  it 'opens in a preview window'
    wincmd w
    Expect &ft ==# 'git'
    Expect winnr('$') == 2
    Expect flog#get_state().preview_window_ids == [win_getid()]
  end
end

" vim: set et sw=2 ts=2 fdm=marker:
