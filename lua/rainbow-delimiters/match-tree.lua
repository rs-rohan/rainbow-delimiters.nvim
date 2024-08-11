---Functions for dealing with match trees.  This library is only relevant to
---strategy authors.  A match tree is the tree-like structure we use to
---organize a subset of the buffer's node tree for highlighting.
local M = {}

local lib = require 'rainbow-delimiters.lib'
local Set = require 'rainbow-delimiters.set'

---A single match from the query.  All matches contain the same fields, which
---correspond to the captures from the query.  Matches are hierarchical and can
---be arranged in a tree where the container of a parent match contains all the
---nodes of the descendant matches.
---@class rainbow_delimiters.Match
---The container node.
---@field container vim.treesitter.TSNode
---Sentinel node, marks the last delimiter of the match.
---@field sentinel vim.treesitter.TSNode
---The actual delimiters we want to highlight, there can be any number of them.
---@field delimiters rainbow_delimiters.Set

---A hierarchical structure of nested matches.  Each node of the tree consists
---of exactly one match and a set of any number of child matches.  Terminal
---matches have no children.
---@class rainbow_delimiters.MatchTree
---The match object
---@field public match rainbow_delimiters.Match
---The children of the match
---@field public children rainbow_delimiters.Set


---Instantiate a new match tree node without children based on the results of
---the `iter_matches` method of a query.
---@param query vim.treesitter.Query
---@param match Table<integer, vim.treesitter.TSNode[]>
---@return rainbow_delimiters.MatchTree
function M.assemble(query, match)
	local result = {delimiters = Set.new()}
	for id, nodes in pairs(match) do
		local capture = query.captures[id]
		if capture == 'delimiter' then
			-- It is expected for a match to contain any number of delimiters
			for _, node in ipairs(nodes) do
				result.delimiters:add(node)
			end
		else
			-- We assume that there is only ever exactly one node per
			-- non-delimiter capture
			result[capture] = nodes[1]
		end
	end

	---@type rainbow_delimiters.MatchTree
	return {
		match = result,
		children = Set.new(),
	}
end

---Apply highlighting to a given match tree at a given level
---@param bufnr integer
---@param lang  string
---@param tree  rainbow_delimiters.MatchTree
---@param level integer  Highlight level of this tree
function M.highlight(tree, bufnr, lang, level)
	local hlgroup = lib.hlgroup_at(level)
	for delimiter in tree.match.delimiters:items() do
		lib.highlight(bufnr, lang, delimiter, hlgroup)
	end
	for child in tree.children:items() do
		M.highlight(child, bufnr, lang, level + 1)
	end
end

return M
