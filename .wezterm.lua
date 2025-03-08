-- Pull in the wezterm API
local wezterm = require("wezterm")


-- This will hold the configuration.
local config = wezterm.config_builder()

-- Program
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	--Default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }
	local wsl_domains = wezterm.default_wsl_domains()

	for _, dom in ipairs(wsl_domains) do
		if dom.name == 'WSL:Debian' then
			dom.default_cwd = "/mnt/c/Users/Douglas"
		end
	end

	config.default_domain = 'WSL:Debian'
	config.wsl_domains = wsl_domains
end

-- config.default_prog = Default_prog

-- Window
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.enable_scroll_bar = true
config.initial_cols = 125
config.initial_rows = 35

-- wezterm.on('window-focus-changed', function(window, pane)
--   local overrides = window:get_config_overrides() or {}
--   if window:is_focused() then
--     overrides.window_background_opacity = 1
--   else
--     overrides.window_background_opacity = 0.8
--   end
--   window:set_config_overrides(overrides)
-- end)

-- Color scheme & font:
config.color_scheme = "Gruvbox dark, medium (base16)"
config.font = wezterm.font('JetBrains Mono', {})
-- config.font = wezterm.font_with_fallback({
-- 	"CommitMono Nerd Font",
-- 	"Cousine Nerd Font",
-- 	{ family = "JetBrains Mono", weight = "Medium" },
-- })
config.font_size = 10.0

-- tab bar
config.enable_tab_bar = true
config.tab_bar_at_bottom = false
config.switch_to_last_active_tab_when_closing_tab = true
config.use_fancy_tab_bar = true

-- Dim inactive panes
--config.inactive_pane_hsb = {
--  saturation = 0.24,
--  brightness = 0.5
--}

-- -- Tabs bar icons
-- wezterm.on("update-status", function(window, pane)
--   -- Workspace name
--   local stat = window:active_workspace()
--   local stat_color = "#f7768e"
--   -- It's a little silly to have workspace name all the time
--   -- Utilize this to display LDR or current key table name
--   if window:active_key_table() then
--     stat = window:active_key_table()
--     stat_color = "#7dcfff"
--   end
--   if window:leader_is_active() then
--     stat = "LDR"
--     stat_color = "#bb9af7"
--   end

--   local basename = function(s)
--     return string.gsub(s, "(.*[/\\])(.*)", "%2")
--   end

--   -- Current working directory
--   local cwd = pane:get_current_working_dir()
--   if cwd then
--     if type(cwd) == "userdata" then
--       -- Wezterm introduced the URL object in 20240127-113634-bbcac864
--       cwd = basename(cwd.file_path)
--     else
--       -- 20230712-072601-f4abf8fd or earlier version
--       cwd = basename(cwd)
--     end
--   else
--     cwd = ""
--   end

--   -- Current command
--   local cmd = pane:get_foreground_process_name()
--   -- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
--   cmd = cmd and basename(cmd) or ""

--   -- Time
--   local time = wezterm.strftime("%H:%M")

--   -- Left status (left of the tab line)
--   window:set_left_status(wezterm.format({
--     { Foreground = { Color = stat_color } },
--     { Text = "  " },
--     { Text = wezterm.nerdfonts.oct_table .. "  " .. stat },
--     { Text = " |" },
--   }))

--   -- Right status
--   window:set_right_status(wezterm.format({
--     -- Wezterm has a built-in nerd fonts
--     -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
--     { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
--     { Text = " | " },
--     { Foreground = { Color = "#e0af68" } },
--     { Text = wezterm.nerdfonts.fa_code .. "  " .. cmd },
--     "ResetAttributes",
--     { Text = " | " },
--     { Text = wezterm.nerdfonts.md_clock .. "  " .. time },
--     { Text = "  " },
--   }))
-- end)

return config
