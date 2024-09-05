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


-- Neovim 0.10 changed the (undocumented) behaviour of Query:iter_captures(),
-- so we need a different implementation for that version.
--
-- https://github.com/neovim/neovim/issues/27296

---@type rainbow_delimiters.strategy
local strategy

if vim.fn.has 'nvim-0.10' ~= 0 then
	strategy = require 'rainbow-delimiters.strategy.global2'
else
	strategy = require 'rainbow-delimiters.strategy.global1'
end

return strategy
