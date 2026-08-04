return {
  "nvim-treesitter/nvim-treesitter",

  branch = "main",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local treesitter = require("nvim-treesitter")

    treesitter.setup({})

    treesitter.install({
      "typescript",
      "tsx",
      "javascript",
      "python",
      "lua",
      "markdown",
      "markdown_inline",
      "go",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
