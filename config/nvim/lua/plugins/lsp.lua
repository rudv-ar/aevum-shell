return {
    {
        -- enable only specific lspservers
        -- I dont need all.
        "neovim/nvim-lspconfig",
        enabled = false,
        opts = {
            servers = {
                clangd = {
                    enable = false, 
                },  -- only for by beloved C
                lua_ls = { enabled = false }, -- disable lua lsp server
            },
        },
    },
}
