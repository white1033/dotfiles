local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Auto switch theme based on system appearance (point 5)
local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Catppuccin Macchiato'
  else
    return 'Catppuccin Latte'
  end
end
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.font = wezterm.font({
  family = 'Monaspace Argon',
  weight = 'Regular',
  harfbuzz_features = { 'calt', 'liga', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
})
config.font_size = 16.0

config.window_padding = {
  left = '20px',
  right = '20px',
  top = '40px',
  bottom = '20px',
}

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.92
config.macos_window_background_blur = 20

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

config.window_close_confirmation = 'NeverPrompt'

config.default_cursor_style = 'BlinkingBar'
config.cursor_thickness = '2px'
config.cursor_blink_rate = 0

-- macOS Option key behavior
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Split pane behavior
config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.7 }
config.swallow_mouse_click_on_pane_focus = true
config.swallow_mouse_click_on_window_focus = true

-- Mouse: copy on select
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor('ClipboardAndPrimarySelection'),
  },
}

-- Environment
config.set_environment_variables = {
  PATH = '/opt/homebrew/bin:' .. os.getenv('PATH'),
}
config.scrollback_lines = 10000
config.use_dead_keys = false
config.enable_kitty_keyboard = true

-- Performance
config.front_end = 'OpenGL'
config.webgpu_power_preference = 'HighPerformance'
config.max_fps = 60
config.animation_fps = 60
config.enable_scroll_bar = false

-- Tab title with unseen output indicator
wezterm.on('format-tab-title', function(tab)
  local title = tab.active_pane.title
  if #title > 24 then
    title = title:sub(1, 23) .. '…'
  end

  local unseen = 0
  for _, p in ipairs(tab.panes) do
    if p.has_unseen_output then
      unseen = unseen + 1
    end
  end

  -- Nerd Font circled number icons (①-⑨) for unseen count
  local unseen_icons = { '①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨' }
  local suffix = ''
  if unseen > 0 then
    local icon = unseen <= 9 and unseen_icons[unseen] or '⑨⁺'
    suffix = ' ' .. icon
  end

  return (tab.tab_index + 1) .. ': ' .. title .. suffix
end)

-- Key bindings
config.keys = {
  { key = 'r', mods = 'CMD', action = wezterm.action.ClearScrollback('ScrollbackAndViewport') },
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'Enter', mods = 'CMD|SHIFT', action = wezterm.action.TogglePaneZoomState },

  -- macOS Option key word navigation (point 1)
  { key = 'LeftArrow', mods = 'OPT', action = wezterm.action.SendString '\x1bb' },
  { key = 'RightArrow', mods = 'OPT', action = wezterm.action.SendString '\x1bf' },

  -- Pane navigation (point 3)
  { key = 'h', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CMD|CTRL', action = wezterm.action.ActivatePaneDirection 'Down' },

  -- Open config in editor (point 4)
  { key = ',', mods = 'CMD', action = wezterm.action.SpawnCommandInNewTab {
    cwd = wezterm.home_dir,
    args = { '/opt/homebrew/bin/nvim', wezterm.config_file },
  }},

  -- Quick Select (point 10)
  { key = 's', mods = 'CMD|SHIFT', action = wezterm.action.QuickSelect },
  { key = 'o', mods = 'CMD|SHIFT', action = wezterm.action.QuickSelectArgs {
    label = 'open url',
    patterns = {
      -- bare URLs
      'https?://\\S+',
      -- markdown [text](url)
      '\\(https?://\\S+\\)',
      -- URLs inside brackets/braces/angles
      '\\[https?://\\S+\\]',
      '\\{https?://\\S+\\}',
      '<https?://\\S+>',
    },
    action = wezterm.action_callback(function(window, pane)
      local url = window:get_selection_text_for_pane(pane)
      -- strip surrounding delimiters and trailing punctuation
      url = url:gsub('^[%(%[%{<]+', ''):gsub('[%)%]%}>]+$', ''):gsub('[.,;:!?]+$', '')
      wezterm.open_with(url)
    end),
  }},
}

config.font_rules = {
  -- Italic (comments)
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font({
      family = 'Monaspace Argon',
      style = 'Italic',
      harfbuzz_features = { 'calt', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
    }),
  },
  -- Bold (highlighting)
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font({
      family = 'Monaspace Argon',
      weight = 'Bold',
      harfbuzz_features = { 'calt', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08' },
    }),
  },
}

return config
