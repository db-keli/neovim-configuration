return {
  {
    "scalameta/nvim-metals",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "scala", "sbt" },
    config = function()
      local metals_config = require("metals").bare_config()
      metals_config.settings = {
        showImplicitArguments = true,
        showInferredType = true,
        excludedPackages = {
          "akka.actor.typed.javadsl",
          "com.github.swagger.akka.javadsl",
        },
      }

      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        metals_config.capabilities = cmp_nvim_lsp.default_capabilities()
      end

      local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt" },
        callback = function()
          require("metals").initialize_or_attach(metals_config)
        end,
        group = group,
      })
    end,
  },
}
