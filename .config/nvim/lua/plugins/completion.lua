return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = { enabled = false },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" }, -- dadbod removed from default
        per_filetype = {
          sql = { "dadbod", "lsp", "path", "snippets", "buffer" },
        },
      },
    },
  },
}
