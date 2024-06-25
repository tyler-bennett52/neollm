local M = {}

M.config = {
  url = 'https://api.openai.com/v1/chat/completions',
  api_key = 'your_default_api_key',
  model = 'gpt-3.5-turbo',
  system_message = 'You are a poetic assistant, skilled in explaining complex programming concepts with creative flair.',
}

function M.setup(user_config)
  M.config = vim.tbl_extend('force', M.config, user_config or {})
end

local function get_selected_text(start_line, end_line)
  local lines = vim.fn.getline(start_line, end_line)
  return table.concat(lines, '\n')
end

local function insert_text_at_cursor(text)
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, pos[1], pos[1], false, vim.split(text, '\n'))
end

local function send_to_openai(selected_text)
  local http = require 'socket.http'
  local ltn12 = require 'ltn12'

  local response = {}
  local body = {
    model = M.config.model,
    messages = {
      { role = 'system', content = M.config.system_message },
      { role = 'user', content = selected_text },
    },
  }

  body = vim.fn.json_encode(body)
  local res, status_code, headers, status = http.request {
    url = M.config.url,
    method = 'POST',
    headers = {
      ['Content-Type'] = 'application/json',
      ['Authorization'] = 'Bearer ' .. M.config.api_key,
      ['Content-Length'] = tostring(#body),
    },
    source = ltn12.source.string(body),
    sink = ltn12.sink.table(response),
  }

  if status_code == 200 then
    local result = vim.fn.json_decode(table.concat(response))
    return result.choices[1].message.content
  else
    return 'Error: ' .. status_code
  end
end

function M.send_selection_to_openai(range_start, range_end)
  local selected_text = get_selected_text(range_start, range_end)
  if selected_text == '' then
    vim.api.nvim_err_writeln 'No text selected!'
    return
  end

  local response = send_to_openai(selected_text)
  insert_text_at_cursor(response)
end

-- Define the command :AIGO with range support
vim.api.nvim_create_user_command('AIGO', function(opts)
  M.send_selection_to_openai(opts.line1, opts.line2)
end, { range = true })

return M
