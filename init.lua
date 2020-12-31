-- general func
-- send notify
function sendNotify(content, title)
  if title == nil then
    title = "Hammerspoon"
  end
  hs.notify.new({title=title, informativeText=content}):send()
end


-- auto reload when init.lua is changed
function reloadConfig(files)
  doReload = true
  for _, file in pairs(files) do
      if file:sub(-4) == ".lua" then
        doReload = true
      end
  end
  if doReload then
    hs.reload()
  end
end
configReloadWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configReloadWatcher:start()
sendNotify("Config loaded")


-- resize window
-- local variables
local frameCache = {}
local operationCache = {}

-- resize func
function moveWindow(direction)
  local win = hs.window.focusedWindow()
  local position
  local id = win:id()

  if frameCache[id] then
    if operationCache[id] == direction then
      win:setFrame(frameCache[id])
      frameCache[id] = nil
      operationCache[id] = nil
      return
    else
      operationCache[id] = direction
    end
  else
    frameCache[id] = win:frame()
    operationCache[id] = direction
  end

  if direction == "left" then
    position = {0, 0, 0.5, 1}
  elseif direction == "right" then
    position = {0.5, 0, 0.5, 1}
  elseif direction == "up" then
    position = {0, 0, 1, 0.5}
  elseif direction == "down" then
    position = {0, 0.5, 1, 0.5}
  elseif direction == "up_left" then
    position = {0, 0, 0.5, 0.5}
  elseif direction == "up_right" then
    position = {0.5, 0, 0.5, 0.5}
  elseif direction == "down_left" then
    position = {0, 0.5, 0.5, 0.5}
  elseif direction == "down_right" then
    position = {0.5, 0.5, 0.5, 0.5}
  elseif direction == "max" then
    position = {0, 0, 1, 1}
  end

  win:move(position)
end

hs.hotkey.bind({"ctrl", "shift"}, "Left", hs.fnutils.partial(moveWindow, "left"))
hs.hotkey.bind({"ctrl", "shift"}, "Right", hs.fnutils.partial(moveWindow, "right"))
hs.hotkey.bind({"ctrl", "shift"}, "Up", hs.fnutils.partial(moveWindow, "up"))
hs.hotkey.bind({"ctrl", "shift"}, "Down", hs.fnutils.partial(moveWindow, "down"))
hs.hotkey.bind({"ctrl", "shift"}, "[", hs.fnutils.partial(moveWindow, "up_left"))
hs.hotkey.bind({"ctrl", "shift"}, "]", hs.fnutils.partial(moveWindow, "up_right"))
hs.hotkey.bind({"ctrl", "shift"}, ";", hs.fnutils.partial(moveWindow, "down_left"))
hs.hotkey.bind({"ctrl", "shift"}, "'", hs.fnutils.partial(moveWindow, "down_right"))
hs.hotkey.bind({"ctrl", "shift"}, "\\", hs.fnutils.partial(moveWindow, "max"))

-- auto change input method
local appLanguage = {
  {"/Applications/Alfred.app", "ABC"},
  {"/Applications/iTerm.app", "ABC"},
  {"/Applications/Android Studio.app", "ABC"},
  {"/Applications/Visual Studio Code.app", "ABC"},
  {"/Applications/Google Chrome.app", "ABC"},
  {"/Applications/Lark.app", "Pinyin - Simplified"},
  {"/Applications/WeChat.app", "Pinyin - Simplified"}
}

function changeCurrentInput()
  local focusedAppPath = hs.window.focusedWindow():application():path()
  for index, app in pairs(appLanguage) do
      local appPath = app[1]
      local expectedLanguage = app[2]

      if focusedAppPath == appPath then
        if expectedLanguage == "ABC" then
          hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
        else
          hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC")
        end
      end

  end
end

function appLanguageWatcherFunc(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    changeCurrentInput()
  end
end

appLanguageWatcher = hs.application.watcher.new(appLanguageWatcherFunc)
appLanguageWatcher:start()
-- test
function test()
    hs.alert.show(hs.keycodes.currentSourceID())
end
hs.hotkey.bind({"ctrl", "shift", "alt"}, "t", hs.fnutils.partial(test))