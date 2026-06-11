local conform = require "conform"

-- Organize imports via LSP before formatting
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    local clients = vim.lsp.get_clients({ bufnr = args.buf })
    for _, client in ipairs(clients) do
      if client:supports_method("textDocument/codeAction") then
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" } },
          apply = true,
        })
        break
      end
    end
  end,
})

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
    json = { "biome" },
    jsonc = { "biome" },
    svelte = { "prettierd" },
    css = { "biome" },
    html = { "biome" },
    markdown = { "prettierd" },
    yaml = { "prettierd" },
    yml = { "prettierd" },
    -- rust
    rust = { "rustfmt" },
    -- swift
    swift = { "swiftformat" },
    -- lua
    lua = { "stylua" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    -- elixir
    elixir = { "mix" },
    eelixir = { "mix" },
    heex = { "mix" },
  },

  format_on_save = function(bufnr)
    local ft = vim.bo[bufnr].filetype
    local timeout = ft == "scala" and 5000 or 500
    return { timeout_ms = timeout, lsp_fallback = true }
  end,
}

conform.setup(opts)

-- Prefer Ruff for imports: run only import-related fixes.
-- This keeps "fix-on-save" focused and avoids surprising refactors.
conform.formatters.ruff_fix = vim.tbl_deep_extend("force", conform.formatters.ruff_fix or {}, {
  args = { "check", "--fix", "--select", "I", "--stdin-filename", "$FILENAME", "-" },
})


return opts
