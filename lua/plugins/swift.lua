return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("swift").setup({
        features = {
          lsp = {
            auto_setup = false,
          },
        },
      })
    end,
  },
}
