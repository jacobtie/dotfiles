local parsers = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'vim',
  'vimdoc',
  'javascript',
  'typescript',
  'json',
  'yaml',
  'toml',
  'css',
  'scss',
  'go',
  'sql',
  'java',
}

local function start_treesitter(bufnr, lang)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if not pcall(vim.treesitter.start, bufnr, lang) then
    return
  end
  if vim.treesitter.query.get(lang, 'indents') then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local treesitter = require 'nvim-treesitter'
      treesitter.install(parsers)

      local available = {}
      for _, lang in ipairs(treesitter.get_available()) do
        available[lang] = true
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        callback = function(event)
          local lang = vim.treesitter.language.get_lang(event.match)
          if not lang then
            return
          end
          if vim.treesitter.language.add(lang) then
            start_treesitter(event.buf, lang)
            return
          end
          if not available[lang] then
            return
          end
          treesitter.install(lang):await(vim.schedule_wrap(function()
            start_treesitter(event.buf, lang)
          end))
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {}
      vim.keymap.set('n', '[c', function()
        require('treesitter-context').go_to_context(vim.v.count1)
      end, { silent = true })
    end,
  },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup {
        use_default_keymaps = false,
      }
      vim.keymap.set('n', '<leader>m', require('treesj').toggle)
    end,
  },
}
