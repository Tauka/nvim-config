local nvim_lsp = require("lspconfig")

local on_attach = function(client, bufnr)
  local buf_map = vim.api.nvim_buf_set_keymap
  vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
  vim.cmd("command! LspFormatting lua vim.lsp.buf.formatting()")
  vim.cmd("command! LspCodeAction lua vim.lsp.buf.code_action()")
  vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
  vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
  vim.cmd("command! LspRefs lua vim.lsp.buf.references()")
  vim.cmd("command! LspTypeDef lua vim.lsp.buf.type_definition()")
  vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
  vim.cmd("command! LspDiagPrev lua vim.lsp.diagnostic.goto_prev()")
  vim.cmd("command! LspDiagNext lua vim.lsp.diagnostic.goto_next()")
  vim.cmd(
      "command! LspDiagLine lua vim.lsp.diagnostic.show_line_diagnostics()")
  vim.cmd("command! LspSignatureHelp lua vim.lsp.buf.signature_help()")

  buf_map(bufnr, "n", "<Leader>dd", ":LspDef<CR>", {silent = true})
  buf_map(bufnr, "n", "<Leader>rn", ":LspRename<CR>", {silent = true})
  buf_map(bufnr, "n", "gR", ":LspRefs<CR>", {silent = true})
  buf_map(bufnr, "n", "<Leader>df", ":LspTypeDef<CR>", {silent = true})
  buf_map(bufnr, "n", "K", ":LspHover<CR>", {silent = true})
  buf_map(bufnr, "n", "[a", ":LspDiagPrev<CR>", {silent = true})
  buf_map(bufnr, "n", "]a", ":LspDiagNext<CR>", {silent = true})
  buf_map(bufnr, "n", "ga", ":LspCodeAction<CR>", {silent = true})
  buf_map(bufnr, "n", "<Leader>a", ":LspDiagLine<CR>", {silent = true})
  buf_map(bufnr, "i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>",
          {silent = true})
  vim.cmd("highlight LspDiagnosticsUnderlineError ctermfg=1 cterm=bold,underline")
  vim.cmd("highlight LspDiagnosticsUnderlineWarning ctermfg=yellow cterm=bold,underline")
  vim.cmd("highlight LspDiagnosticsUnderlineHint ctermfg=yellow cterm=underline")

  local signs = { Error = "❌", Warning = "⚠️", Hint = "💡", Information = "ℹ️" }

  for type, icon in pairs(signs) do
    local hl = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

end

vim.o.updatetime = 150
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})]]

nvim_lsp.tsserver.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = false
    on_attach(client)
  end,
  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
       vim.lsp.diagnostic.on_publish_diagnostics, {
         virtual_text = false
       }
     ),
  }
}

local filetypes = {
  typescript = "eslint",
  typescriptreact = "eslint",
}

local linters = {
  eslint = {
    sourceName = "eslint",
    command = "eslint_d",
    rootPatterns = {".eslintrc.js", "package.json"},
    debounce = 100,
    args = {"--stdin", "--stdin-filename", "%filepath", "--format", "json"},
    parseJson = {
      errorsRoot = "[0].messages",
      line = "line",
      column = "column",
      endLine = "endLine",
      endColumn = "endColumn",
      message = "${message} [${ruleId}]",
      security = "severity"
    },
    securities = {[2] = "error", [1] = "warning"}
  }
}

local formatFiletypes = {
  typescript = "prettier",
  typescriptreact = "prettier"
}

nvim_lsp.diagnosticls.setup {
  on_attach = on_attach,
  filetypes = vim.tbl_keys(filetypes),
  init_options = {
    filetypes = filetypes,
    linters = linters,
    formatFiletypes = formatFiletypes
  }
}

local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
  },
  sources = {
    { name = 'path' },
    { name = 'buffer' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
  }
})

require'hop'.setup()
