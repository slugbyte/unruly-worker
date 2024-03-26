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
--
-- TODO: refactor macro stuff into action
--  * make a get_macro_register fn (for lualine)
-- TODO: add cmp.insert and cmd presets
-- TODO: add lsp leader commands
-- TODO: add treesitter search commands
-- TODO: toggle delete mode own register
-- TODO: add luasnips completion
-- TODO: add healthcheck report

-- TODO: make cfg_basic somehow respect config so that maps can react to it
-- for exaple do you want marks to Jump by file of by buffer?
-- or should I just make a mark action ?

local util = require("unruly-worker.util")
local action = require("unruly-worker.action")
local hop = require("unruly-worker.hop")
local external = require("unruly-worker.external")

-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
-- 	pattern = { "*.lua", "*.zig", "*.cljs", "*.txt", "*.py", "*.go", "*.c", "*.h", "*.md", "*.html", "*.java" },
-- 	callback = function(ev)
-- 		print(string.format('event fired: %s ', vim.inspect(ev)) .. util.emoticon())
-- 	end
-- })

-- remap keys will recusively map meaning future keys will instead map to the new value
local no_remap = false
local remap = true

local silent = true
local no_silent = false

local function cfg_custom(value, is_remap, is_silent, desc)
	return {
		value = value,
		is_remap = is_remap,
		is_silent = is_silent,
		is_expr = false,
		desc = desc,
	}
end

local function cfg_custom_expr(value, is_remap, is_silent, desc)
	return {
		value = value,
		is_remap = is_remap,
		is_silent = is_silent,
		is_expr = true,
		desc = desc,
	}
end

local function cfg_basic(cmd, desc)
	return cfg_custom(cmd, no_remap, no_silent, desc)
end

local function cfg_basic_expr(cmd, desc)
	return cfg_custom_expr(cmd, no_remap, no_silent, desc)
end

local function cfg_noop()
	return cfg_basic("\\", "")
end

local mapping = {
	general = {
		m = {
			-- alphabet
			a = cfg_custom("a", remap, no_silent, "append cursor"),
			A = cfg_basic("A", "append line"),
			["<c-a>"] = cfg_basic(function()
				vim.fn.feedkeys("'a", "n")
				print("GOTO MARK a")
			end, "goto mark a"),
			b = cfg_basic("%", "brace match"),
			B = cfg_basic("<C-o>", "Back Jump"),
			["<c-b>"] = cfg_basic(function()
				vim.fn.feedkeys("'b", "n")
				print("GOTO MARK b")
			end, "goto mark b"),
			c = cfg_basic(action.kopy.create_delete_cmd("c"), "change content, store old in reg 0"),
			cc = cfg_basic(action.kopy.create_delete_cmd("cc"), "changle lines, store old in reg 0"),
			C = cfg_basic(action.kopy.create_delete_cmd("C"), "change to EOL, store old in reg 0"),
			d = cfg_basic(action.kopy.create_delete_cmd("d"), "delete motion into reg 0"),
			dd = cfg_basic(action.kopy.create_delete_cmd("dd"), "delete motion into reg 0"),
			D = cfg_basic(action.kopy.create_delete_cmd("D"), "delete motion into reg 0"),
			-- dd = cfg_basic('"0dd', "delete lines into reg x"),
			-- D = cfg_basic('"0D', "delete to EOL into reg x"),
			e = cfg_basic("k", "up"),
			E = cfg_basic(vim.lsp.buf.hover, "lsp hover"),
			f = cfg_basic("n", "find next"),
			F = cfg_basic("N", "find prev"),
			-- ["<c-f>"] = cfg_basic('&', "repeat substitue"),
			g = cfg_basic("g", "g command"),
			G = cfg_basic("G", "goto line"),
			h = cfg_basic(";", "hop to repeat"),
			H = cfg_basic(",", "hop to reverse"),
			i = cfg_basic("i", "insert"),
			I = cfg_basic("I", "insert BOL"),
			j = cfg_noop(),
			J = cfg_noop(),
			["<c-j>"] = cfg_basic(action.telescope.jump_list, "jump list"),
			-- ["<c-j>"] = cfg_basic("J", "join lines"),
			k = cfg_basic_expr(action.kopy.expr_yank, "kopy"),
			K = cfg_basic_expr(action.kopy.expr_yank_line, "kopy line"),
			["<C-k>"] = cfg_basic(action.kopy.register_select, "select kopy register"),
			-- K = cfg_basic("Y", "kopy line"),
			l = cfg_basic("o", "line insert below"),
			L = cfg_basic("O", "line insert above"),
			-- m = cfg_basic("mA", "mark A"),
			-- M = cfg_basic("mB", "mark B"),
			m = cfg_basic(function()
				vim.fn.feedkeys("ma", "n")
				print("SET MARK a")
			end, "set mark a"),
			M = cfg_basic(function()
				vim.fn.feedkeys("mb", "n")
				print("set mark b")
			end, "goto mark b"),
			n = cfg_basic("j", "down"),
			N = cfg_basic("J", "join lines"),
			o = cfg_basic("l", "right"),
			O = cfg_basic("$", "right to EOL"),
			p = cfg_basic_expr(action.kopy.expr_paste_below, "paste after"),
			P = cfg_basic_expr(action.kopy.expr_paste_above, "paste before"),
			["<C-p>"] = cfg_basic_expr(action.kopy.expr_paste_transform_below, "paste transform"),
			q = cfg_basic(action.unruly.write_all, "write all"),
			Q = cfg_basic(":qall<cr>", "quit all"),
			["<C-q>"] = cfg_basic(":qall!<cr>", "quit all force"),
			r = cfg_basic("r", "replace"),
			R = cfg_basic("R", "replace mode"),
			s = cfg_noop(),
			S = cfg_noop(),
			t = cfg_basic("f", "to char"),
			T = cfg_basic("F", "to char reverse"),
			u = cfg_basic("u", "undo"),
			U = cfg_basic("<C-r>", "redo"),
			v = cfg_basic("v", "visual mode"),
			V = cfg_basic("V", "visual line mode"),
			w = cfg_basic("w", "word forward"),
			W = cfg_basic("b", "word backward"),
			x = cfg_basic(action.kopy.create_delete_cmd("x"), "delete char into reg 0"),
			X = cfg_basic(action.kopy.create_delete_cmd("X"), "delete previous char into reg 0"),
			y = cfg_basic("h", "left"),
			Y = cfg_basic("^", "left to BOL"),
			z = cfg_basic(action.macro.record, "macro record"),
			Z = cfg_basic(action.macro.play, "macro play"),
			["<c-z>"] = cfg_basic(action.macro.select_register, "select macro register"),
			-- mark maintanence
			["<leader>ma"] = cfg_basic(":delm A<CR>", "[M]ark Delete [A]"),
			["<leader>mb"] = cfg_basic(":delm B<CR>", "[M]ark Delete [B]"),
			["<leader>mz"] = cfg_basic(":delm Z<CR>", "[M]ark Delete [Z]"),
			["<leader>mA"] = cfg_basic(":delm A B Z<CR>", "[M]ark Delete [A]ll"),

			-- parens
			[")"] = cfg_basic(")", "next sentence"),
			["("] = cfg_basic("(", "prev sentence"),

			["}"] = cfg_basic("}", "next paragraph"),
			["{"] = cfg_basic("{", "prev paragraph"),

			["["] = cfg_basic("<C-o>", "jumplist back"),
			["]"] = cfg_basic("<C-i>", "jumplist forward"),

			["<"] = cfg_basic("<", "nudge left"),
			[">"] = cfg_basic(">", "nudge right"),

			-- case swap
			["~"] = cfg_basic("~", "case swap"),

			-- command
			[":"] = cfg_basic(":", "command mode"),
			["'"] = cfg_basic(":", "command mode"),
			["/"] = cfg_basic("/", "search down"),
			["?"] = cfg_basic("?", "search up"),

			-- paste delete
			[","] = cfg_basic('"0P', "paste register x above"),
			["."] = cfg_basic('"0p', "paste register x below"),

			-- register
			['"'] = cfg_basic(action.kopy.register_select, "register select"),
			["`"] = cfg_basic(action.kopy.register_peek, "register_peek"),

			-- window nav
			["<C-w>y"] = cfg_basic("<C-w>h", "focus left"),
			["<C-w>n"] = cfg_basic("<C-w>j", "focus down"),
			["<C-w>e"] = cfg_basic("<C-w>k", "focus up"),
			["<C-w>o"] = cfg_basic("<C-w>l", "focus right"),
			["<C-w>x"] = cfg_basic(":close<CR>", "close pane"),
			["<C-w>f"] = cfg_basic(":on<CR>", "full screen"),
			["<C-w>h"] = cfg_basic(":sp<CR>", "split horizontal"),
			["<C-w>s"] = cfg_basic(":vs<CR>", "split verticle"),

			["<C-x>"] = cfg_basic(":close<CR>", "close pane"),
			["<C-f>"] = cfg_basic(":on<CR>", "full screen"),
			["<C-h>"] = cfg_basic(":sp<CR>", "split horizontal"),
			["<C-s>"] = cfg_basic(":vs<CR>", "split verticle"),

			["<leader>]"] = cfg_basic("o<esc>^d$<Up>", "[]) empty line below"),
			["<leader>["] = cfg_basic("O<esc>^d$<Down>", "([) empty line above"),

			["<C-w>j"] = cfg_noop(),
			["<C-w>k"] = cfg_noop(),
			["<C-w>l"] = cfg_noop(),

			-- cursor align
			["@"] = cfg_basic("zt", "align top"),
			["$"] = cfg_basic("zz", "align middle"),
			["#"] = cfg_basic("zb", "align bottom"),

			-- noop
			["%"] = cfg_noop(),
			["^"] = cfg_noop(),
			["&"] = cfg_basic("&", "repeat subsitute"),
			["*"] = cfg_noop(),
			["-"] = cfg_noop(),
			["_"] = cfg_noop(),
			["+"] = cfg_noop(),
			["="] = cfg_noop(),
			["|"] = cfg_noop(),
			[";"] = cfg_noop(),
		},
		n = {
			-- swap lines normal
			["<C-Down>"] = cfg_basic(":m .+1<CR>==", "swap down"),
			["<C-Up>"] = cfg_basic(":m .-2<CR>==", "swap up"),
		},
		v = {
			["<C-Down>"] = cfg_basic(":m '>+1<CR>gv=gv", "swap down"),
			["<C-Up>"] = cfg_basic(":m '<-2<CR>gv=gv", "swap up"),
		},
		c = {
			["<C-a>"] = cfg_basic("<home>", "goto BOL"),
			["<C-e>"] = cfg_basic("<end>", "goto EOL"),
		},
	},
	easy_comment = {
		n = {
			["<C-c>"] = cfg_custom("gcc", remap, no_silent, "comment"),
		},
		v = {
			["<C-c>"] = cfg_custom("gc", remap, no_silent, "comment"),
		},
	},
	easy_lsp = {
		m = {
			["_"] = cfg_basic(vim.diagnostic.goto_next, "diagnostic next"),
			["-"] = cfg_basic(vim.diagnostic.goto_prev, "diagnostic prev"),
			[";"] = cfg_basic(vim.lsp.buf.hover, "lsp hover"),
			["<C-r>"] = cfg_basic(vim.lsp.buf.rename, "lsp rename"),
			["<C-d>"] = cfg_basic(action.telescope.lsp_definiton, "lsp rename"),
		},
	},
	easy_move = {
		m = {
			y = cfg_basic("<Left>", "left wrap"),
			n = cfg_basic("gj", "down"),
			e = cfg_basic("gk", "up"),
			o = cfg_basic("<Right>", "right wrap"),
		},
	},
	easy_tmux = {
		m = {
			["<C-y>"] = cfg_custom(action.tmux.focus_left, no_remap, silent, "focus left (vim/tmux)"),
			["<C-n>"] = cfg_custom(action.tmux.focus_down, no_remap, silent, "focus down (vim/tmux)"),
			["<C-e>"] = cfg_custom(action.tmux.focus_up, no_remap, silent, "focus up (vim/tmux)"),
			["<C-o>"] = cfg_custom(action.tmux.focus_right, no_remap, silent, "focus right (vim/tmux)"),
			-- ["<C-y>"] = cfg_custom(":TmuxNavigateLeft<CR>", no_remap, silent, "focus left (vim/tmux)"),
			-- ["<C-n>"] = cfg_custom(":TmuxNavigateDown<CR>", no_remap, silent, "focus down (vim/tmux)"),
			-- ["<C-e>"] = cfg_custom(":TmuxNavigateUp<CR>", no_remap, silent, "focus up (vim/tmux)"),
			-- ["<C-o>"] = cfg_custom(":TmuxNavigateRight<CR>", no_remap, silent, "focus right (vim/tmux)"),
		},
	},
	easy_source = {
		m = {
			["%"] = cfg_custom(":source %<CR>", no_remap, silent, "source current buffer"),
		},
	},
	easy_jump = {
		m = {
			j = cfg_basic(action.telescope.find_files, "jump files"),
			J = cfg_basic(action.telescope.live_grep, "jump files"),
		}
	},
	easy_textobject = {
		n = {
			s = cfg_basic(action.text_object.seek_forward, "seek textobject forward"),
			S = cfg_basic(action.text_object.seek_reverse, "seek textobject reverse")
		},
		x = {
			s = cfg_basic(action.text_object.seek_forward, "seek textobject forward"),
			S = cfg_basic(action.text_object.seek_reverse, "seek textobject reverse")
		},
		o = {
			s = cfg_basic(action.text_object.seek_forward, "seek textobject forward"),
			S = cfg_basic(action.text_object.seek_reverse, "seek textobject reverse")
		},
	},
	easy_luasnip = {
		i = {
			["<C-Right>"] = cfg_basic(action.luasnip.jump_forward, "luasnip jump next"),
			["<C-Left>"] = cfg_basic(action.luasnip.jump_reverse, "luasnip jump prev"),
		},
		s = {
			["<C-Right>"] = cfg_basic(action.luasnip.jump_forward, "luasnip jump next"),
			["<C-Left>"] = cfg_basic(action.luasnip.jump_reverse, "luasnip jump prev"),
		},
	},
	easy_hop = {
		m = {
			["<leader>uhm"] = cfg_basic(hop.HopModeSetMark, "homp mode mark"),
			["<leader>uht"] = cfg_basic(hop.HopModeSetTextObject, "homp mode text object"),
			["<leader>uhq"] = cfg_basic(hop.HopModeSetQuickFix, "homp mode quick fix"),
			-- ["<C-b>"] = cfg_basic(hop.HopModeRotate, "rotate hop mode"),
			N = cfg_basic(hop.HopReverse, "hop reverse"),
			E = cfg_basic(hop.HopForward, "hop forward"),
		},
	},
}

local map_config = function(config, skip_list)
	for mode, mode_cfg in pairs(config) do
		if mode == "m" then
			mode = ""
		end
		for key, key_cfg in pairs(mode_cfg) do
			if util.should_map(key, skip_list) then
				vim.keymap.set(mode, key, key_cfg.value, {
					desc = key_cfg.desc,
					silent = key_cfg.is_silent,
					remap = key_cfg.is_remap,
					noremap = not key_cfg.is_remap,
					expr = key_cfg.is_expr,
				})
			end
		end
	end
end

local setup_force = function(config)
	if config == nil then
		config = {}
	end

	local context = {
		booster   = {
			easy_lsp        = true,
			easy_move       = true,
			easy_tmux       = true,
			easy_comment    = true,
			easy_source     = true,
			easy_jump       = true,
			easy_textobject = true,
			easy_luasnip    = true,
			easy_hop        = false,
		},
		skip_list = {},
	}

	if config then
		context = vim.tbl_extend("force", context, config)
	end

	map_config(mapping.general, context.skip_list)

	for booster, is_enabled in pairs(context.booster) do
		if is_enabled then
			map_config(mapping[booster], context.skip_list)
		end
	end
end

---  configure and map unruly worker keymap
--- @param config table
local function setup(config)
	-- dont reload if  loaded
	if vim.g.unruly_worker then
		return
	end
	vim.g.unruly_worker = true
	setup_force(config)

	-- TODO create a nice way to create autocmds
	-- add the TextYankPost autocmd

	-- TODO create a better config for creating userc comands
	vim.api.nvim_create_user_command("UnrulyMacroLock", action.macro.lock, {})
	vim.api.nvim_create_user_command("UnrulyMacroUnlock", action.macro.unlock, {})

	util.notify_info("UNRULY")
end

return {
	setup = setup,
	external = external,
	setup_force = setup_force,
	action = action,
	util = util,
}
