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
    arg[2],
    -- enable_graph
    arg[3] == 'true',
    -- default_collapsed
    arg[4] == 'true',
    -- cmd
    arg[5],
    -- collapsed_commits
    {})
