return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
      },
    },
  },
  -- Don't auto-open on startup
  init = function()
    vim.g.neo_tree_remove_legacy_commands = 1
  end,
}
