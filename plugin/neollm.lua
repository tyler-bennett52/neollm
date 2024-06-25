if vim.fn.has 'nvim-0.7.0' == 0 then
  vim.api.nvim_err_writeln 'NeoLLM requires at least nvim-0.7.0.'
  return
end

-- Plugin interface
vim.api.nvim_create_user_command('NeoLLMPrompt', function(args)
  require('neollm').prompt { prompt = args.args }
end, { nargs = '+' })
