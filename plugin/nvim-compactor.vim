" Title:        Nvim-Compactor
" Description:  A plugin to Hide Lines based on a Regex Match.
" Last Change:  2023-04-26
" Maintainer:   Dominik Schlack <https://github.com/domsch1988>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_nvimcompactor")
    finish
endif
let g:loaded_nvimcompactor = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/nvim-compactor/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 HideLines lua require("nvim-compactor").hide_lines()
