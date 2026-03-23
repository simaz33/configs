return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local lspconfig = require('lspconfig')

            lspconfig['terraformls'].setup({ capabilities = capabilities })
        end
    },
}
