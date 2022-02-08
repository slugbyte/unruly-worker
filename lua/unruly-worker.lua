--                       __                         __
--   __ _____  ______ __/ /_ _______    _____  ____/ /_____ ____
--  / // / _ \/ __/ // / / // /___/ |/|/ / _ \/ __/  '_/ -_) __/
--  \_,_/_//_/_/  \_,_/_/\_, /    |__,__/\___/_/ /_/\_\\__/_/
--                      /___/
--
--  Name: unruly-worker
--  License: Unlicense
--  Maintainer: Duncan Marsh (slugbyte@slugbyte.com)
--  Repository: https://github.com/slugbyte/unruly-worker

local create_map = function(mode, noremap)
  return function(lhs, rhs)
    if lhs == rhs then
     return
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, {noremap = noremap})
  end
end

-- noremap
local map = create_map('', true)
local nmap = create_map('n', true)
local imap = create_map('i', true)
local cmap = create_map('c', true)
local vmap = create_map('v', true)
-- remap
local remap_vmap = create_map('v', false)
local remap_map = create_map('', false)

local map_undisputed = function()
  map('a', 'a')
  map('A', 'A')
  map('b', '%')
  map('B', '"')
  map('c', 'c')
  map('C', 'C')
  map('d', 'd')
  map('D', 'D')
  map('e', 'k')
  map('E', 'e')
  map('<C-w>e', '<C-w>k')
  map('f', 'n')
  map('F', 'N')
  map('g', 'g')
  map('G', 'G')
  map('h', ';')
  map('H', ',')
  map('i', 'i')
  map('I', 'I')
  map('j', '\\')
  map('J', '\\')
  map('k', 'y')
  map('K', 'Y')
  map('l', 'o')
  map('L', 'O')
  map('m', "'")
  map('M', 'm')
  map('n', 'j')
  map('N', 'J')
  map('o', 'l')
  map('O', '$')
  map('<C-w>o', '<C-w>l')
  map('<C-w>n', '<C-w>j')
  map('p', 'p')
  map('P', 'P')
  map('q', 'q')
  map('Q', '@')
  map('r', 'r')
  map('R', 'R')
  map('s', 's')
  map('S', 'S')
  map('t', 'f')
  map('T', 'F')
  map('u', 'u')
  map('U', '<c-r>')
  map('v', 'v')
  map('V', 'V')
  map('w', 'w')
  map('W', 'b')
  map('x', 'x')
  map('X', 'X')
  map('y', 'h')
  map('Y', '^')
  map('<C-w>y', '<C-w>h')
  map('z', 'z')
  map('Z', 'Z')
  map(':', ':')
  map("'", ':')
  map(',', '.')
  map('.', '&')
  map('/', '/')
  map('?', '?')
  map('@', 'zt')
  map('#', 'zz')
  map('$', 'zb')
  map('~', '~')
  map('%', '\\')
  map('^', '\\')
  map('&', '\\')
  map('*', '\\')
  map('-', '\\')
  map('_', '\\')
  map('+', '\\')
  map('=', '\\')
  map('|', '\\')
  map(';', '\\')
  map('(', '(')
  map(')', ')')
  map('[', '[')
  map(']', ']')
  map('>', '>')
  map('<', '<')
  nmap('<C-Down>', ':m .+1<CR>==')
  nmap('<C-Up>', ':m .-2<CR>==')
  imap('<C-Down>', ':m .+1<CR>==gi')
  imap('<C-Up>', ':m .-2<CR>==gi')
  vmap('<C-Down>', ":m '>+1<CR>gv=gv")
  vmap('<C-Up>', ":m '<-2<CR>gv=gv")
  cmap('<C-a>', '<home>')
  cmap('<C-e>', '<end>')
end

local map_lsp = function(enable)
  if enable then
    map('-', ':lua vim.diagnostic.goto_prev()<CR>')
    map('_', ':lua vim.diagnostic.goto_next()<CR>')
    map('&', ':lua vim.lsp.buf.formatting()<CR>')
    map(';', ':split<CR>:lua vim.lsp.buf.definition()<CR>')
    map('=', ':lua vim.lsp.buf.code_action()<CR>')
    map('!', ':lua vim.lsp.buf.rename()<CR>')
  end
end

local map_comment = function(enable)
  if enable then
    remap_map('c', 'gcc')
    remap_map('C', 'gcip')
    remap_vmap('c', 'gc')
    remap_vmap('C', 'gc')
  end
end

local map_select = function(enable)
  if enable then
    map('s', 'viw')
    map('S', 'vip')
  end
end

local map_visual_navigate = function(enable)
  if enable then
    map('e', 'gk')
    map('n', 'gj')
  else
    map('ge', 'gk')
    map('gn', 'gj')
  end
end

local map_wrap_navigate = function(enable)
  if enable then
    vim.cmd('set ww+=<,>')
    map('y', '<left>')
    map('o', '<right>')
  end
end

local map_quote_command = function(enable)
  if enable then
    map("'", ':')
  end
end

local map_alt_jump_scroll = function(enable)
  if enable then
    map("@", 'zt')
    map("$", 'zz')
    map("#", 'zb')
  end
end

local map_easy_window_navigate = function(enable)
  if enable then
    map('<c-n>', '<c-w>j')
    map('<c-e>', '<c-w>k')
    map('<c-y>', '<c-w>h')
    map('<c-o>', '<c-w>l')
  end
end

local function setup(config)
  if vim.g.unruly_worker then
    return
  end
  vim.g.unruly_worker = true

  local context = {
    enable_lsp_map = false,
    enable_select_map = false,
    enable_comment_map = false,
    enable_wrap_navigate = false,
    enable_quote_command = false,
    enable_alt_jump_scroll = false,
    enable_visual_navigate = false,
    enable_easy_window_navigate = false,
  }

  if config then
    context = vim.tbl_extend("force", context, config)
  end

  vim.g.unruly_worker_context = context

  map_undisputed()
  map_lsp(context.enable_lsp_map)
  map_select(context.enable_select_map)
  map_comment(context.enable_comment_map)
  map_wrap_navigate(context.enable_wrap_navigate)
  map_quote_command(context.enable_quote_command)
  map_alt_jump_scroll(context.enable_alt_jump_scroll)
  map_visual_navigate(context.enable_visual_navigate)
  map_easy_window_navigate(context.enable_easy_window_navigate)
end

return {
  setup = setup,
}
