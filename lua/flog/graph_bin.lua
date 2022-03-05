-- This file generates the commit graph as a script.

require('flog/graph')

local enable_vim = false
local start_token = arg[1]
local enable_graph = arg[2] == 'true'
local cmd = arg[3]

flog_get_graph(enable_vim, true, start_token, enable_graph, cmd)
