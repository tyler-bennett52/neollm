local M = {}

function M.check()
  vim.health.start 'NeoLLM'

  if vim.fn.has 'nvim-0.7.0' == 1 then
    vim.health.ok 'Neovim version 0.7.0 or higher'
  else
    vim.health.error 'Neovim version must be 0.7.0 or higher'
  end

  -- Add more health checks as needed
end

return M
