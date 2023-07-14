require("nvim-treesitter.configs").setup {
  ensure_installed = { "rust", "solidity", "lua", "typescript", "javascript", "help" },
  highlight = { enable = true },
}
