--[[
   Copyright 2024 Alejandro "HiPhish" Sanchez

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--]]


local lib   = require 'rainbow-delimiters.lib'
local util  = require 'rainbow-delimiters.util'
local log   = require 'rainbow-delimiters.log'


---@param bufnr integer
---@param settings rainbow_delimiters.buffer_settings
local function on_attach(bufnr, settings)
	log.trace('global strategy on_attach for buffer %d', bufnr)
	local parser = settings.parser
	setup_parser(bufnr, parser, nil)
end

---@param bufnr integer
local function on_detach(bufnr)
	log.trace('global strategy on_detach for buffer %d', bufnr)
end

---@param bufnr integer
---@param settings rainbow_delimiters.buffer_settings
local function on_reset(bufnr, settings)
	log.trace('global strategy on_reset for buffer %d', bufnr)
end

---Sets up all the callbacks and performs an initial highlighting
---@param bufnr integer # Buffer number
---@param parser vim.treesitter.LanguageTree
---@param start_parent_lang string? # Parent language or nil
local function setup_parser(bufnr, parser, start_parent_lang)
	log.debug('Setting up parser for buffer %d', bufnr)

	---Sets up an individual parser for a particular language
	---@param p vim.treesitter.LanguageTree   Parser for that language
	---@param lang string  The language
	local function f(p, lang, parent_lang)
		log.debug("Setting up parser for '%s' in buffer %d", lang, bufnr)
		-- Skip languages which are not supported, otherwise we get a
		-- nil-reference error
		if not lib.get_query(lang, bufnr) then return end

		local function on_changedtree(changes, tree)
			log.trace('Changed tree in buffer %d with languages %s', bufnr, lang)
			-- HACK: As of Neovim v0.9.1 there is no way of unregistering a
			-- callback, so we use this check to abort
			if not lib.buffers[bufnr] then return end

			-- TODO
			-- Collect changes to pass on to the next step; might have to treat
			-- injected languages differently.
			--
			-- Clear extmarks if a line has been moved across languages
			--
			-- Update the range
		end

		---New languages can be added into the text at some later time, e.g.
		---code snippets in Markdown
		---@param child vim.treesitter.LanguageTree
		local function on_child_added(child)
			setup_parser(bufnr, child, lang)
		end

		p:register_cbs {
			on_changedtree = on_changedtree,
			on_child_added = on_child_added,
		}
		log.trace("Done with setting up parser for '%s' in buffer %d", lang, bufnr)
	end

	-- A buffer has one primary language and potentially many child languages
	-- which may have child languages of their own.  We need to set up the
	-- parser for each of them.
	util.for_each_child(start_parent_lang, parser:lang(), parser, f)
end

---Update highlights for a range. Called every time text is changed.
---@param bufnr   integer  Buffer number
---@param changes table   List of node ranges in which the changes occurred
---@param tree    vim.treesitter.TSTree  TS tree
---@param lang    string  Language
local function update_range(bufnr, changes, tree, lang)
end

---Strategy which highlights all delimiters in the current buffer.
---@type rainbow_delimiters.strategy
return {
	on_attach = on_attach,
	on_detach = on_detach,
	on_reset = on_reset,
}
