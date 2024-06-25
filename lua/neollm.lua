local M = {}

-- Default configuration
local config = {
  timeout_ms = 10000,
  system_prompt = [[
You are an AI programming assistant integrated into a code editor. Your purpose is to help the user with programming tasks as they write code.
    ]],
  services = {
    -- We'll add services later
  },
}

function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
end

function M.prompt(opts)
  print('User input:', opts.prompt)
  -- We'll implement the actual LLM call later
end

return M
