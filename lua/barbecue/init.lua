local global = require("barbecue.global")
local ui = require("barbecue.ui")

local M = {}

---@deprecated
function M.update(winnr)
  vim.notify(
    "require(\"barbecue\").update is deprecated now, use require(\"barbecue.ui\").update instead",
    vim.log.levels.WARN
  )

  ui.update(winnr)
end

---@deprecated
function M.toggle(shown)
  vim.notify(
    "require(\"barbecue\").toggle is deprecated now, use require(\"barbecue.ui\").toggle instead",
    vim.log.levels.WARN
  )

  ui.toggle(shown)
end

---configures and starts the plugin
---@param config BarbecueConfig
function M.setup(config)
  global.config = vim.tbl_deep_extend("force", global.defaults.CONFIG, config or {})

  -- resorts to built-in and nvim-cmp highlight groups if nvim-navic highlight groups are not defined
  for from, to in pairs(global.defaults.HIGHLIGHTS) do
    vim.api.nvim_set_hl(0, from, {
      link = to,
      default = true,
    })
  end

  if global.config.create_autocmd then
    vim.api.nvim_create_autocmd({
      "BufWinEnter",
      "BufWritePost",
      "CursorMoved",
      "TextChanged",
      "TextChangedI",
    }, {
      group = vim.api.nvim_create_augroup("barbecue", {}),
      callback = function(a)
        for _, winnr in ipairs(vim.api.nvim_list_wins()) do
          if a.buf == vim.api.nvim_win_get_buf(winnr) then
            ui.update(winnr)
          end
        end
      end,
    })
  end

  vim.api.nvim_create_user_command("Barbecue", function(params)
    if #params.fargs < 1 then
      return
    end

    local action = params.fargs[1]
    if action == "hide" then
      ui.toggle(false)
    elseif action == "show" then
      ui.toggle(true)
    elseif action == "toggle" then
      ui.toggle()
    else
      vim.notify(("'%s' is not a subcommand"):format(action), vim.log.levels.ERROR)
    end
  end, {
    nargs = "*",
    complete = function(_, line)
      local args = vim.split(line, "%s+")
      if #args ~= 2 then
        return {}
      end

      return vim.tbl_filter(function(subcommand)
        return vim.startswith(subcommand, args[2])
      end, { "show", "hide", "toggle" })
    end,
  })
end

return M
