dofile(vim.fn.getcwd() .. "/init.lua")

assert(
  vim.g.clipboard == "osc52",
  "SSH Neovim must use OSC 52 when no graphical clipboard is available"
)

print("clipboard fallback test passed")
