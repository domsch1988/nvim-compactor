local api = vim.api
local buf, win

local function open_window()
  buf = api.nvim_create_buf(false, true) -- create new emtpy buffer

  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- get dimensions
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  -- calculate our floating window size
  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)

  -- and its starting position
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  -- set some options
  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  -- and finally create it with buffer attached
  win = api.nvim_open_win(buf, true, opts)
end

local border_opts = {
  style = "minimal",
  relative = "editor",
  width = win_width + 2,
  height = win_height + 2,
  row = row - 1,
  col = col - 1
}

local border_buf = api.nvim_create_buf(false, true)

local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
local middle_line = '║' .. string.rep(' ', win_width) .. '║'
for i=1, win_height do
  table.insert(border_lines, middle_line)
end
table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')

api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)
-- set bufer's (border_buf) lines from first line (0) to last (-1)
-- ignoring out-of-bounds error (false) with lines (border_lines)

local border_win = api.nvim_open_win(border_buf, true, border_opts)
win = api.nvim_open_win(buf, true, opts)
api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

local function set_mappings()
  local mappings = {
    ['['] = 'update_view(-1)',
    [']'] = 'update_view(1)',
    ['<cr>'] = 'open_file()',
    h = 'update_view(-1)',
    l = 'update_view(1)',
    q = 'close_window()',
    k = 'move_cursor()'
  }

  for k,v in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"whid".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end

local function close_window()
  api.nvim_win_close(win, true)
end

-- Our file list start at line 4, so we can prevent reaching above it
-- from bottm the end of the buffer will limit movment
local function move_cursor()
  local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
  api.nvim_win_set_cursor(win, {new_pos, 0})
end

-- Open file under cursor
local function open_file()
  local str = api.nvim_get_current_line()
  close_window()
  api.nvim_command('edit '..str)
end

return {
  whid = whid,
  update_view = update_view,
  open_file = open_file,
  move_cursor = move_cursor,
  close_window = close_window
}

local function whid()
  position = 0 -- if you want to preserve last displayed state just omit this line
  open_window()
  set_mappings()
  update_view(0)
  api.nvim_win_set_cursor(win, {4, 0}) -- set cursor on first list entry
end
