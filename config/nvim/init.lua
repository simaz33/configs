vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.opt.syntax = "on"
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.smartcase = true
-- vim.opt.noswapfile
-- vim.opt.nobackup
-- vim.opt.undodir=~/.vim/undodir
-- vim.opt.undofile
vim.opt.incsearch = true
vim.opt.hlsearch = true

require("config.lazy")
require("nvim-tree").setup({
    update_focused_file = {
    enable = true,
    update_root = true
  }
})

require("mason").setup()
require("mason-lspconfig").setup()

--vim.lsp.config['terraformls'] = {
--    cmd = { "terraform-ls", "serve" },
--    filetypes = { 'terraform', 'terraform-vars' },
--    root_markers = { '.terraform', '.git' },
--    settings = {
--        ignoreSingleFileWarning = true,
--    }
--}

vim.diagnostic.config({
    -- virtual_lines = true,
    virtual_text = true,
})

vim.keymap.set("n", "<C-e>", ":NvimTreeToggle<CR>", { silent = true, noremap = true })
