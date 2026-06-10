-- NvChad `defaults()` runs before this file (see plugins/init.lua); it sets
-- vim.lsp.config("*", ...) and enables lua_ls.

local nvlsp = require "nvchad.configs.lspconfig"
local on_attach = nvlsp.on_attach

local function python_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  on_dir(vim.fs.root(fname, {
    "pyproject.toml",
    "ruff.toml",
    ".ruff.toml",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "poetry.lock",
    ".python-version",
    ".git",
  }))
end

local function ruff_cmd_for_root(root_dir)
  if not root_dir or root_dir == "" then
    return { "ruff", "server" }
  end

  local candidates = {
    root_dir .. "/.venv/bin/ruff",
    root_dir .. "/venv/bin/ruff",
    root_dir .. "/.env/bin/ruff",
    root_dir .. "/env/bin/ruff",
  }

  for _, p in ipairs(candidates) do
    if vim.uv.fs_stat(p) then
      return { p, "server" }
    end
  end

  return { "ruff", "server" }
end

local function python_path_for_root(root_dir)
  if not root_dir or root_dir == "" then
    return nil
  end

  local candidates = {
    root_dir .. "/.venv/bin/python",
    root_dir .. "/venv/bin/python",
    root_dir .. "/.env/bin/python",
    root_dir .. "/env/bin/python",
  }

  for _, p in ipairs(candidates) do
    if vim.uv.fs_stat(p) then
      return p
    end
  end

  return nil
end

local function biome_cmd_for_root(root_dir)
  if not root_dir or root_dir == "" then
    return { "biome", "lsp-proxy" }
  end

  local local_cmd = root_dir .. "/node_modules/.bin/biome"
  if vim.fn.executable(local_cmd) == 1 then
    return { local_cmd, "lsp-proxy" }
  end

  return { "biome", "lsp-proxy" }
end

local function js_biome_root(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    on_dir(vim.fn.getcwd())
    return
  end

  on_dir(vim.fs.root(fname, {
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml",
    "bun.lockb",
    "bun.lock",
    "biome.json",
    "biome.jsonc",
    "tsconfig.json",
    "jsconfig.json",
    "package.json",
    ".git",
  }) or vim.fn.getcwd())
end

-- lsps with default overrides only
vim.lsp.config("cssls", {})

vim.lsp.config("html", {
  filetypes = { "html", "heex" },
})

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
      gofumpt = true,
    },
  },
})

vim.lsp.config("pyright", {
  root_dir = python_root_dir,
  on_new_config = function(new_config, root_dir)
    local python_path = python_path_for_root(root_dir)
    if python_path then
      new_config.settings = new_config.settings or {}
      new_config.settings.python = new_config.settings.python or {}
      new_config.settings.python.pythonPath = python_path
    end
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

vim.lsp.config("ruff", {
  root_dir = python_root_dir,
  cmd = { "ruff", "server" },
  on_new_config = function(new_config, root_dir)
    new_config.cmd = ruff_cmd_for_root(root_dir)
  end,
})

-- Svelte: same root markers as nvim-lspconfig, but always resolve root.
-- Upstream only calls on_dir when the file exists on disk; new buffers never
-- get an LSP client, so completion is dead until first write.
vim.lsp.config("svelte", {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then
      on_dir(vim.fn.getcwd())
      return
    end

    local root_markers = {
      "package-lock.json",
      "yarn.lock",
      "pnpm-lock.yaml",
      "bun.lockb",
      "bun.lock",
      "deno.lock",
    }
    local markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
      or (function()
        local m = vim.list_extend({}, root_markers)
        m[#m + 1] = ".git"
        return m
      end)()

    on_dir(vim.fs.root(bufnr, markers) or vim.fn.getcwd())
  end,
})

vim.lsp.config("biome", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  cmd = { "biome", "lsp-proxy" },
  root_dir = js_biome_root,
  workspace_required = false,
  on_new_config = function(new_config, root_dir)
    new_config.cmd = biome_cmd_for_root(root_dir)
  end,
})

vim.lsp.config("tailwindcss", {
  filetypes = {
    "html",
    "css",
    "scss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
    "heex",
    "elixir",
    "eelixir",
  },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(fname, {
      "tailwind.config.js",
      "tailwind.config.ts",
      "assets/css/app.css",
      "mix.exs",
    }))
  end,
  init_options = {
    userLanguages = {
      elixir = "html-eex",
      eelixir = "html-eex",
      heex = "html-eex",
    },
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        elixir = "html",
        eelixir = "html",
        heex = "html",
      },
      experimental = {
        classRegex = {
          [[class: "([^"]*)]],
          [[class: '([^']*)]],
          '~H""".*class="([^"]*)".*"""',
          [[class="([^"]*)]],
        },
      },
      validate = true,
    },
  },
})

vim.lsp.config("emmet_language_server", {
  filetypes = {
    "css",
    "eruby",
    "html",
    "javascript",
    "javascriptreact",
    "less",
    "sass",
    "scss",
    "pug",
    "svelte",
    "typescript",
    "typescriptreact",
    "heex",
  },
  init_options = {
    ---@type table<string, string>
    includeLanguages = {},
    --- @type string[]
    excludeLanguages = {},
    --- @type string[]
    extensionsPath = {},
    --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
    preferences = {},
    --- @type boolean Defaults to `true`
    showAbbreviationSuggestions = true,
    --- @type "always" | "never" Defaults to `"always"`
    showExpandedAbbreviation = "always",
    --- @type boolean Defaults to `false`
    showSuggestionsAsSnippets = false,
    --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
    syntaxProfiles = {},
    --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
    variables = {},
  },
})

vim.lsp.config("marksman", {
  filetypes = { "markdown", "md" },
})

vim.lsp.config("yamlls", {
  filetypes = { "yaml", "yml" },
  settings = {
    yaml = {
      keyOrdering = false,
      validate = true,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
    },
  },
})

vim.lsp.config("ts_ls", {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(
      vim.fs.root(fname, { "tsconfig.json", "tsconfig.base.json", "jsconfig.json", "package.json", ".git" })
        or vim.fn.getcwd()
    )
  end,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})

vim.lsp.config("jsonls", {
  filetypes = { "json", "jsonc" },
  settings = {
    json = {
      validate = { enable = true },
    },
  },
})

vim.lsp.config("clangd", {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
})

vim.lsp.config("elixirls", {
  cmd = { "elixir-ls" },
  filetypes = { "elixir", "eelixir", "heex" },
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false,
      enableTestLenses = true,
      suggestSpecs = true,
    },
  },
})

vim.lsp.config("sourcekit", {
  cmd = { "xcrun", "sourcekit-lsp" },
  filetypes = { "swift", "objective-c", "objective-cpp" },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(fname, {
      "Package.swift",
      "buildServer.json",
      ".git",
    }) or vim.fn.getcwd())
  end,
})

vim.lsp.enable({
  "cssls",
  "html",
  "gopls",
  "pyright",
  "ruff",
  "biome",
  "ts_ls",
  "svelte",
  "tailwindcss",
  "sourcekit",
  "emmet_language_server",
  "clangd",
  "elixirls",
  "yamlls",
  "marksman",
  "jsonls",
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
  callback = function(args)
    vim.lsp.codelens.enable(true, { bufnr = args.buf })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end
  end,
})
