return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    local Snacks = require 'snacks'
    Snacks.setup {
      bigfile = { enabled = true },
      gh = { enabled = true },
      picker = {
        enabled = true,
        matcher = {
          frecency = true,
        },
        win = {
          input = {
            keys = {
              ['<c-w>'] = { 'cycle_win', mode = { 'i', 'n' } },
            },
          },
        },
      },
      quickfile = { enabled = true },
      rename = { enabled = true },
    }
    vim.keymap.set('n', '<leader>sf', function()
      Snacks.picker.files { hidden = true, exclude = { 'vendor' } }
    end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sg', function()
      Snacks.picker.grep { hidden = true }
    end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', function()
      Snacks.picker.diagnostics { hidden = true }
    end, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>gp', function()
      Snacks.picker.gh_pr()
    end, { desc = '[G]it [P]r' })
  end,
}
