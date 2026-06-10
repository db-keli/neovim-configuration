require "nvchad.options"

-- add yours here!

-- True-color terminal: required for Base46 / Treesitter GUI colors.
vim.o.termguicolors = true

local o = vim.opt
o.relativenumber = true
o.tabstop = 4
o.shiftwidth = 4
o.wrap = false
o.sidescroll = 1
o.sidescrolloff = 5
o.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    print("File changed on disk. Buffer reloaded.")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "html", "svelte" },
  callback = function()
    vim.opt_local.expandtab = true
  end,
})
require("gitsigns").setup {
  current_line_blame = true, -- Enable blame line by default
}

vim.opt.guifont = "Fantasque Sans Mono:h12"
vim.opt.linespace = 2

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
