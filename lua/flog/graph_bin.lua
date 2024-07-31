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
    -- enable_graph
    arg[2] == 'true',
    -- default_collapsed
    arg[3] == 'true',
    -- cmd
    arg[4],
    -- collapsed_commits
    {})
