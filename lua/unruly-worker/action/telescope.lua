-- TODO: should this have a find config (files/grep)?
local util = require("unruly-worker.util")
local telescope_status, telescope_builtin = pcall(require, "telescope.builtin")
local _, telescope_themes = pcall(require, "telescope.themes")

local M = {}

local function create_telescope_action(builtin_fn)
	return function()
		if telescope_status and (telescope_builtin ~= nil) then
			telescope_builtin[builtin_fn]()
			return
		end
		util.error("telescope not found")
	end
end

function M.buffer_fuzzy_search()
	if telescope_status and (telescope_builtin ~= nil) then
		telescope_builtin.current_buffer_fuzzy_find(telescope_themes.get_dropdown({
			previewer = false,
		}))
		return
	end
	util.error("telescope not found")
end

function M.find_files()
	if telescope_status and (telescope_builtin ~= nil) then
		telescope_builtin.find_files({
			hidden = true,
		})
		return
	end
	util.error("telescope not found")
end

function M.live_grep()
	if telescope_status and (telescope_builtin ~= nil) then
		telescope_builtin.live_grep({
			hidden = true,
		})
		return
	end
	util.error("telescope not found")
end

-- this will work without telescope
function M.lsp_definiton()
	if telescope_status and (telescope_builtin ~= nil) then
		telescope_builtin.lsp_definitions()
		return
	else
		vim.lsp.buf.definition()
	end
end

function M.jump_list()
	if telescope_status and (telescope_builtin ~= nil) then
		telescope_builtin.jumplist()
		return
	else
		vim.cmd("jumps")
	end
end

M.help_tags = create_telescope_action("help_tags")
M.buffers = create_telescope_action("buffers")
M.keymaps = create_telescope_action("keymaps")
M.resume = create_telescope_action("resume")
M.oldfiles = create_telescope_action("oldfiles")
M.quickfix = create_telescope_action("quickfix")
M.registers = create_telescope_action("registers")
M.spell_suggest = create_telescope_action("spell_suggest")
M.tags = create_telescope_action("tags")
M.man_pages = create_telescope_action("man_pages")
M.loclist = create_telescope_action("loclist")
M.commands = create_telescope_action("commands")
M.registers = create_telescope_action("registers")

return M
