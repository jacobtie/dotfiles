return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim',    opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local Snacks = require 'snacks'
          vim.keymap.set('n', 'gd', Snacks.picker.lsp_definitions, { desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', 'gD', Snacks.picker.lsp_declarations, { desc = '[G]oto [D]eclaration' })
          vim.keymap.set('n', 'gr', Snacks.picker.lsp_references, { desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', 'gI', Snacks.picker.lsp_implementations, { desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', 'gt', Snacks.picker.lsp_type_definitions, { desc = '[G]oto [T]ype Definition' })
          vim.keymap.set('n', 'gs', Snacks.picker.lsp_symbols, { desc = '[D]ocument [S]ymbols' })
          vim.keymap.set('n', 'gW', Snacks.picker.lsp_workspace_symbols, { desc = '[W]orkspace [S]ymbols' })
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })

          -- Highlight references on cursor hold
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local eslint_base_on_attach = vim.lsp.config.eslint.on_attach
      local servers = {
        gopls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        vtsls = {
          settings = {
            vtsls = {
              tsserver = {
                globalPlugins = {
                  -- Vue setup
                  {
                    name = '@vue/typescript-plugin',
                    location = vim.fn.stdpath 'data' ..
                        '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                    languages = { 'vue' },
                    configNamespace = 'typescript',
                  },
                },
              },
            },
          },
          filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
        },
        vue_ls = {},
        eslint = {
          on_attach = function(client, bufnr)
            if eslint_base_on_attach then
              eslint_base_on_attach(client, bufnr)
            end
            -- Automatically run eslint --fix on save
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = bufnr,
              command = 'LspEslintFixAll',
            })
          end,
        },
        pyright = {},
        ruff = {
          init_options = {
            settings = {
              configuration = '~/.config/ruff/pyproject.toml',
            },
          },
        },
        yamlls = {},
        helm_ls = {
          settings = {
            ['helm-ls'] = {
              yamlls = {
                path = 'yaml-language-server',
              },
            },
          },
        },
      }

      for server_name, opts in pairs(servers) do
        opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, opts.capabilities or {})
        vim.lsp.config(server_name, opts)
      end

      require('mason').setup()

      local ensure_installed = vim.list_extend(vim.tbl_keys(servers or {}), {
        -- 'jdtls',
      })
      require('mason-lspconfig').setup { ensure_installed = ensure_installed }
    end,
  },
  {
    'ray-x/go.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('go').setup {
        tag_transform = 'camelcase',
      }
      local format_sync_grp = vim.api.nvim_create_augroup('GoFormat', {})
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.go',
        callback = function()
          require('go.format').goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
  {
    'towolf/vim-helm',
    ft = 'helm',
  },
  {
    'dmmulroy/ts-error-translator.nvim',
    config = function()
      require('ts-error-translator').setup {}
    end,
  },
  {
    'scalameta/nvim-metals',
    ft = { 'scala', 'sbt', 'java' },
    dependencies = {
      'saghen/blink.cmp',
    },
    opts = function()
      local metals_config = require('metals').bare_config()

      metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()

      metals_config.settings = {
        serverVersion = '2.0.0-M10',
        serverProperties = { '-Xmx4g' },
        showImplicitArguments = true,
        showImplicitConversionsAndClasses = true,
        showInferredType = true,
        superMethodLensesEnabled = true,
        excludedPackages = {},
      }

      metals_config.init_options = {
        statusBarProvider = 'off',
      }

      metals_config.on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Metals: ' .. desc })
        end

        map('<leader>ws', function()
          require('metals').hover_worksheet()
        end, 'Hover Worksheet')
        map('<leader>mc', '<cmd>MetalsCompileCascade<cr>', 'Compile Cascade')
        map('<leader>mi', '<cmd>MetalsInfo<cr>', 'Info')
        map('<leader>md', '<cmd>MetalsRunDoctor<cr>', 'Run Doctor')
        map('<leader>mo', '<cmd>MetalsOrganizeImports<cr>', 'Organize Imports')
        map('<leader>msb', '<cmd>MetalsSwitchBuildServer<cr>', 'Switch Build Server')
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        callback = function()
          require('metals').initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  }
  -- {
  --   'mfussenegger/nvim-jdtls',
  --   ft = 'java',
  --   dependencies = { 'mason-org/mason.nvim' },
  --   config = function()
  --     local function start_jdtls()
  --       local jdtls = require('jdtls')
  --       local jdtls_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
  --       local os_config = vim.fn.has('mac') == 1 and 'config_mac' or 'config_linux'
  --       local launcher = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
  --       local root_dir = jdtls.setup.find_root({ 'pom.xml', 'build.gradle', '.git', 'mvnw' })
  --       local workspace = vim.fn.expand('~/.local/share/nvim/jdtls-workspaces/')
  --           .. vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ':t')
  --
  --       jdtls.start_or_attach({
  --         cmd = {
  --           'java',
  --           '-Declipse.application=org.eclipse.jdt.ls.core.id1',
  --           '-Dosgi.bundles.defaultStartLevel=4',
  --           '-Declipse.product=org.eclipse.jdt.ls.core.product',
  --           '-Xms256m',
  --           '-Xmx2g',
  --           '-XX:+UseG1GC',
  --           '-XX:GCTimeRatio=4',
  --           '-XX:AdaptiveSizePolicyWeight=90',
  --           '-Dsun.zip.disableMemoryMapping=true',
  --           '-XX:+UseStringDeduplication',
  --           '--add-modules=ALL-SYSTEM',
  --           '--add-opens', 'java.base/java.util=ALL-UNNAMED',
  --           '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
  --           '-jar', launcher,
  --           '-configuration', jdtls_path .. '/' .. os_config,
  --           '-data', workspace,
  --         },
  --         root_dir = root_dir,
  --         capabilities = require('blink.cmp').get_lsp_capabilities(),
  --         settings = {
  --           java = {
  --             configuration = { updateBuildConfiguration = 'automatic' },
  --             maven = { downloadSources = true },
  --             format = { enabled = false },
  --           },
  --         },
  --         init_options = { bundles = {} },
  --       })
  --     end
  --
  --     start_jdtls()
  --     vim.api.nvim_create_autocmd('FileType', {
  --       pattern = 'java',
  --       group = vim.api.nvim_create_augroup('jdtls-attach', { clear = true }),
  --       callback = start_jdtls,
  --     })
  --   end,
  -- }
}
