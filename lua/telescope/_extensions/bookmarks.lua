local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local m = require('marks')
local actions = require('marks.actions')

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local function all_marks()
  local items = {}
  local cwd = vim.fn.getcwd(0, 0).."/"

  for bufnr, buffer_state in pairs(m.mark_state.buffers) do
    for mark, data in pairs(buffer_state.placed_marks) do
      local text = vim.api.nvim_buf_get_lines(bufnr, data.line-1, data.line, true)[1]
      local filename = vim.api.nvim_buf_get_name(bufnr)
      filename = string.gsub(filename, cwd, "")

      table.insert(items, {
        bufnr = bufnr,
        filename = filename,
        line = data.line,
        col = data.col + 1,
        mark = mark,
        text = text:gsub("%s+", ""),
      })
    end
  end
  return items
end

-- Return all custom bookmarks
local function all_bookmarks()
  local items = {}
  local cwd = vim.fn.getcwd(0, 0).."/"

  for group_nr, group in pairs(m.bookmark_state.groups) do
    for bufnr, buffer_marks in pairs(group.marks) do
      local filename = vim.api.nvim_buf_get_name(bufnr)
      filename = string.gsub(filename, cwd, "")

      for line, mark in pairs(buffer_marks) do
      local text = vim.api.nvim_buf_get_lines(bufnr, line-1, line, true)[1]
        table.insert(items, {
          bufnr=bufnr,
          filename=filename,
          line=line,
          col=mark.col + 1,
          mark=group_nr,
          text=text
        })
      end
    end
  end
  return items
end

local displayer = entry_display.create {
  separator = " ",
  items = {
    { width = 4 },
    { width = 40 },
    { remaining = true },
  },
}

local make_display = function(entry)
  return displayer({
    { entry.icon, "Error" },
    { entry.text },
    { entry.filename, "Comment" },
  })
end

--  
local entry_maker = function (entry)
  return {
    icon = " "..entry.mark,
    filename = entry.filename,
    lnum = entry.line,
    text = entry.text,
    value = entry.text,
    ordinal = entry.text,
    display = make_display,
  }
end

local function picker(title, marks, opts)
  pickers.new(opts, {
    prompt_title = title,
    finder = finders.new_table({
      results = marks,
      entry_maker = entry_maker,
    }),
    previewer = conf.grep_previewer(opts),
    sorter = conf.file_sorter(opts),
    attach_mappings = function(_, map)
      map("i", "<CR>", actions.open)
      map("i", "<C-t>", actions.open_in_tab)
      map("i", "<C-s>", actions.split)
      map("i", "<C-v>", actions.vsplit)
      return true
    end,
  }):find()
end

return telescope.register_extension({
  exports = {
    chars = function (opts)
      picker('All Marks', all_marks(), opts or {})
    end,
    bookmarks = function (opts)
      picker('All Bookmarks', all_bookmarks(), opts or {})
    end,
  }
})
