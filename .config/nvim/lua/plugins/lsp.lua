return {
  { "stevearc/conform.nvim", opts = {
    formatters_by_ft = {
      ["rust"] = { "rustfmt" },
    },
  } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
