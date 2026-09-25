-- Fallback if the FileType autocmd in init.lua has not run yet.
if not vim.b.ts_highlight then
  pcall(vim.treesitter.start, 0, "prisma")
end
