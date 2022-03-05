-- This file generates the commit graph as a script.

require('flog/graph')

flog_get_graph(
    -- enable_vim
    false,
    -- enable_porcelain
    true,
    -- start_token
    arg[1],
    -- enable_graph
    arg[2] == 'true',
    -- cmd
    arg[3])
