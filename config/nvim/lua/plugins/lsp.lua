return {
    {
        -- enable only specific lspservers
        -- I dont need all.
        "neovim/nvim-lspconfig",
        enabled = true,
        opts = {
            servers = {
                clangd = {
                    enable = false, 
                    on_attach = function(client)
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end,                    
                },  -- only for by beloved C
                lua_ls = { enabled = false }, -- disable lua lsp server
            },
        },
    },
}
