return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            cmd = { "terraform-ls", "serve" }
            filetypes = { 'terraform', 'terraform-vars' }
            root_markers = { '.terraform', '.git' }
            settings = {
                ignoreSingleFileWarning = false,
            }
        end
    },
    {
        "mason-org/mason.nvim",
        config = function() end
    },
    {
        "mason-org/mason-lspconfig.nvim",
        config = function() end
    },
}
