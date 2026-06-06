return {
    {
        -- enable only specific lspservers
        -- I dont need all.
        "neovim/nvim-lspconfig",
        enabled = true,
        opts = {
            servers = {
                clangd = { enabled = true },                  -- only for by beloved C
                lua_ls = { enabled = false }, -- disable lua lsp server
            },
        },
    },
}
