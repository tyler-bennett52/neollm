local M = {}
local http = require 'socket.http'
local ltn12 = require 'ltn12'
local json = require 'cjson'

-- Default configuration
M.config = {
  timeout_ms = 10000,
  system_prompt = [[
You are an AI programming assistant integrated into a code editor. Your purpose is to help the user with programming tasks as they write code.
  ]],
  services = {
    openai = {
      model = 'gpt-3.5-turbo', -- or whichever model you prefer
    },
  },
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Get API key from environment variable
  M.config.services.openai.api_key = os.getenv 'OPENAI_API_KEY'
  if not M.config.services.openai.api_key then
    error 'OPENAI_API_KEY environment variable is not set'
  end
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

function M.call_openai_api(prompt)
  if not M.config.services.openai.api_key then
    error 'OpenAI API key is not set. Please call M.setup() first.'
  end

  local request_body = json.encode {
    model = M.config.services.openai.model,
    messages = {
      { role = 'system', content = M.config.system_prompt },
      { role = 'user', content = prompt },
    },
  }

  local response_body = {}
  local request, code = http.request {
    url = 'https://api.openai.com/v1/chat/completions',
    method = 'POST',
    headers = {
      ['Content-Type'] = 'application/json',
      ['Authorization'] = 'Bearer ' .. M.config.services.openai.api_key,
    },
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body),
  }

  if code ~= 200 then
    error('OpenAI API request failed with code ' .. tostring(code))
  end

  local response = json.decode(table.concat(response_body))
  return response.choices[1].message.content
end

function M.write_to_file(content)
  local file = io.open('neollm.txt', 'w')
  if file then
    file:write(content)
    file:close()
    print 'Response written to neollm.txt'
  else
    error 'Failed to open neollm.txt for writing'
  end
end

function M.prompt(opts)
  local input = opts.args
  if opts.range == 2 then
    input = M.get_visual_selection()
  end
  print('User input:', input)

  local response = M.call_openai_api(input)
  M.write_to_file(response)
end

function M.load()
  -- This function can be empty for now
  -- We'll use it to ensure the plugin is loaded before use
end

return M
