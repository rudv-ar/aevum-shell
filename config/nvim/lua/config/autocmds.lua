-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")


vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("CTemplate", { clear = true }),
  pattern = "*.c",
  callback = function(args)
    local template = vim.fn.stdpath("config") .. "/templates/skeleton.c"
    if vim.fn.filereadable(template) == 0 then return end

    local lines = vim.fn.readfile(template)
    local cursor_pos = nil

    for i, line in ipairs(lines) do
      lines[i] = line:gsub("//FILENAME//", vim.fn.expand("%:t"))
                      :gsub("//DATE//", os.date("%Y-%m-%d"))
      if lines[i]:find("//CURSOR//") then
        cursor_pos = i
        lines[i] = lines[i]:gsub("//CURSOR//", "")
      end
    end

    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)

    if cursor_pos then
      vim.api.nvim_win_set_cursor(0, { cursor_pos, 0 })
    end
  end,
});
