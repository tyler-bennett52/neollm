local M = {}

-- Default configuration
M.config = {
  timeout_ms = 10000,
  system_prompt = [[
You are an AI programming assistant integrated into a code editor. Your purpose is to help the user with programming tasks as they write code.
    ]],
  services = {
    -- We'll add services later
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

function M.get_visual_selection()
  local s_start = vim.fn.getpos "'<"
  local s_end = vim.fn.getpos "'>"
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function M.prompt(opts)
  local input = opts.args
  if opts.range == 2 then
    input = M.get_visual_selection()
  end
  print('User input:', input)
  -- We'll implement the actual LLM call later
end

function M.load()
  -- This function can be empty for now
  -- We'll use it to ensure the plugin is loaded before use
end

return M
