-- My own config file to get the Hyper Key working again with my current setup.
-- All credit goes to @prenagha and @ttscoff for their awesome original code that I tweaked for my own devices.
-- Credit 1: https://gist.github.com/ttscoff/cce98a711b5476166792d5e6f1ac5907
-- Credit 2: https://gist.github.com/prenagha/1c28f71cb4d52b3133a4bff1b3849c3e

-- Specify Spoons which will be loaded
hspoon_list = {
  -- "AClock",
  -- "BingDaily",
  -- "CircleClock",
  -- "ClipShow",
  -- "CountDown",
  -- "HCalendar",
  -- "HSaria2",
  -- "HSearch",
  "SpeedMenu",
  -- "_win_win",
  -- "_fnMate",
}

-- appM environment keybindings. Bundle `id` is prefered, but application `name` will be ok.
hsapp_list = {
  -- {key = 'i', name = 'iTerm'},
}

-- A global variable for the sub-key Hyper Mode
k = hs.hotkey.modal.new({}, 'f17')

-- Hyper-key for all the below are setup somewhere... Usually Keyboard Maestro or similar. Alfred doesn't handle them very well, so will set up separate bindings for individual apps below.
hyper_bindings = {
  'ESCAPE',
  'SPACE',
  'TAB',
  ',',
  '-',
  '.',
  '/',
  ';',
  '=',
  ']',
  '[',
  '\'',
  '\\',
  '`',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  'O',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'i',
  'h',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z'
}

for i,key in ipairs(hyper_bindings) do
  k:bind({}, key, nil, function() hs.eventtap.keyStroke({'cmd','alt','ctrl'}, key)
      k.triggered = true
  end)
end

-- Enter Hyper Mode when _f18 is pressed
pressed_f18 = function()
  k.triggered = false
  k:enter()
end

-- Leave Hyper Mode when _f18 is pressed,
--   send ESCAPE if no other keys are pressed.
released_f18 = function()
  k:exit()
  if not k.triggered then
    hs.eventtap.keyStroke({}, 'ESCAPE')
  end
end

-- Bind the Hyper key
f19 = hs.hotkey.bind({}, 'F18', pressed_f18, released_f18)

-- _reload config when any lua file in config directory changes, to save having to manually reload.
function reload_config(files)
  do_reload = false
  for _,file in pairs(files) do
    if file:sub(-4) == '.lua' then
      do_reload = true
    end
  end
  if do_reload then
    hs.reload()
  end
end

local my_watcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reload_config):start()
