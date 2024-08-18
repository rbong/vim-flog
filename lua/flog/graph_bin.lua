-- This file generates the commit graph as a script.

require('flog/graph')

flog_get_graph(
    -- instance_number
    arg[1],
    -- is_vim
    false,
    -- is_nvim
    false,
    -- enable_porcelain
    true,
    -- start_token
    arg[2],
    -- enable_extended_chars
    arg[3] == 'true',
    -- enable_extra_padding
    arg[4] == 'true',
    -- enable_graph
    arg[5] == 'true',
    -- default_collapsed
    arg[6] == 'true',
    -- cmd
    arg[7],
    -- collapsed_commits
    {})
