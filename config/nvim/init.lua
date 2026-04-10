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
-- vim.opt.binary = true
-- vim.opt.nofixendofline = true

require("config.lazy")
require("nvim-tree").setup({
    update_focused_file = {
    enable = true,
    update_root = true
  }
})
require("mason").setup()
require("mason-lspconfig").setup()

vim.keymap.set("n", "<C-e>", ":NvimTreeToggle<CR>", { silent = true, noremap = true })

vim.lsp.config["terraformls"] = {
    cmd = { "terraform-ls", "serve" },
    filetypes = { "terraform", "terraform-vars" },
    root_markers = { ".terraform", ".git" },
    init_options = {
       ignoreSingleFileWarning = true
    }
}
vim.lsp.enable("terraformls")

vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = {"*.tf", "*.tfvars", "*.hcl"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

vim.diagnostic.config({
    --virtual_lines = true,
    virtual_text = true,
})

-- Move the cursor to the last known position when re-opening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Set to correct path if using 'pyenv'
-- vim.g.python3_host_prog = '/path/to/python3'
