local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local a = {}

function a.open(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.cmd(":e +"..entry.lnum.." "..entry.filename)
end

function a.open_in_tab(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.cmd(":tabnew +"..entry.lnum.." "..entry.filename)
end

function a.split(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.cmd(":split +"..entry.lnum.." "..entry.filename)
end

function a.vsplit(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    vim.cmd(":vsplit +"..entry.lnum.." "..entry.filename)
end

return a
