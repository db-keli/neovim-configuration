local conform = require "conform"

local opts = {
  formatters_by_ft = {
    -- go stuff
    go = { "gofumpt", "goimports_reviser", "golines" },
    -- python stuff
    python = {
      "ruff_format",
      "ruff_fix",
    },
    -- web dev stuff
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    svelte = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd", "djlint" },
    markdown = { "prettierd" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    -- elixir
    elixir = { "mix" },
    eelixir = { "mix" },
    heex = { "mix" },
  },

  format_on_save = {
    -- Enable format on save
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

conform.setup(opts)

-- Prefer Ruff for imports: run only import-related fixes.
-- This keeps "fix-on-save" focused and avoids surprising refactors.
conform.formatters.ruff_fix = vim.tbl_deep_extend("force", conform.formatters.ruff_fix or {}, {
  args = { "check", "--fix", "--select", "I", "--stdin-filename", "$FILENAME", "-" },
})

-- Automatically format on save for any buffer that supports formatting
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    conform.format { bufnr = args.buf }
  end,
})

return opts
