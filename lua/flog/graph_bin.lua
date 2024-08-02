-- This file generates the commit graph as a script.

require('flog/graph')

flog_get_graph(
    -- enable_vim
    false,
    -- enable_nvim
    false,
    -- enable_porcelain
    true,
    -- start_token
    arg[1],
    -- enable_extended_chars
    arg[2] == 'true',
    -- enable_extra_padding
    arg[3] == 'true',
    -- enable_graph
    arg[4] == 'true',
    -- default_collapsed
    arg[5] == 'true',
    -- cmd
    arg[6],
    -- collapsed_commits
    {})
