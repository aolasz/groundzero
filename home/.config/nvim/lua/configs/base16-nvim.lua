return function()
  local colorscheme = vim.env.MY_BASE16_COLORSCHEME
  if not require('utils').is_legacy_mode() and colorscheme then
    local function hex2rgb(hex)
      hex = hex:gsub("#","")
      return {
        r = tonumber("0x"..hex:sub(1,2)),
        g = tonumber("0x"..hex:sub(3,4)),
        b = tonumber("0x"..hex:sub(5,6)),
      }
    end

    vim.cmd.colorscheme('base16-' .. colorscheme)

    local c = require('base16-colorscheme').colors
    local base00 = hex2rgb(c.base00)
    if base00.r < 128 and base00.g < 128 and base00.b < 128 then
      vim.opt.background = 'dark'
    else
      vim.opt.background = 'light'
    end
  end
end

-- vim: ts=2:sw=2:et:fen:fdm=marker
