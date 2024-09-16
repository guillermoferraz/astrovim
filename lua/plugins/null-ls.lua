---@type LazySpec
return {
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = { "prettier", "eslint" },
      handlers = {
        eslint = function()
          require("null-ls").register(require("null-ls").builtins.diagnostics.eslint.with {
            condition = function()
              return true -- Asegura que ESLint se ejecute sin archivo local
            end,
          })
        end,
        prettier = function()
          require("null-ls").register(require("null-ls").builtins.formatting.prettier.with {
            condition = function(utils) return utils.root_has_file "package.json" or utils.root_has_file ".prettierrc" end,
          })
        end,
      },
    },
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require "null-ls"
      null_ls.setup {
        sources = {
          null_ls.builtins.diagnostics.eslint.with {
            extra_args = { "--env", "es2021", "--parser-options", "{ ecmaVersion: 12 }" },
          },
          null_ls.builtins.formatting.prettier,
        },
        autostart = true, -- forzar autostart directamente en setup()
        on_attach = function(client, bufnr)
          -- Muestra los diagnósticos (errores/warnings)
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_create_user_command(
              bufnr,
              "Format",
              function() vim.lsp.buf.format { async = true } end,
              { desc = "Formatear archivo con LSP" }
            )
            vim.cmd [[
              augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ async = false })
              augroup END
            ]]
          end
        end,
      }

      -- Si no se inicia automáticamente, fuerza el autostart aquí
      require("lspconfig")["null-ls"].autostart = true
    end,
  },
}
