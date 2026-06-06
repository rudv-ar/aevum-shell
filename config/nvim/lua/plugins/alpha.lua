return {
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local ascii = require("ascii")
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = table.concat(
        ascii.art.text.neovim.sharp, "\n"
      )
      return opts
    end,
  },
}
