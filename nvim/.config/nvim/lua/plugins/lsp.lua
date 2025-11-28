return {
  -- Mason: ensure LSP servers are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "rust-analyzer",
        "pyright",
        "typescript-language-server",
        "eslint-lsp",
        "lua-language-server",
      },
    },
  },
  -- Treesitter: syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "rust",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "lua",
        "json",
        "yaml",
        "toml",
        "markdown",
      },
    },
  },
}
