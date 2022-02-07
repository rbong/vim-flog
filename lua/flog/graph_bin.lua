-- This file generates the commit graph as a script.

local graph_lib_path = arg[1]

dofile(graph_lib_path)

local enable_vim = false
local start_token = arg[2]
local enable_graph = arg[3] == 'true'
local cmd = arg[4]

flog_get_graph(enable_vim, true, start_token, enable_graph, cmd)
