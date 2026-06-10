return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        dap = {
          adapter = {
            type = "server",
            port = "${port}",
            executable = {
              command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
              args = { "--port", "${port}" },
            },
          },
        },
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
              },
              checkOnSave = true,
              check = { command = "clippy" },
              procMacro = { enable = true },
              inlayHints = {
                chainingHints = { enable = true },
                parameterHints = { enable = true },
                typeHints = { enable = true },
                closingBraceHints = { enable = true, minLines = 25 },
              },
            },
          },
        },
      }
    end,
  },
}
