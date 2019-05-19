--- Configuration file for AwesomeWM v4.3
--- https://github.com/serialoverflow/dotfiles/blob/master/.config/awesome/rc.lua

-- =====================================================================
-- {{{ s_libs
-- =====================================================================
-- Internal libraries

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local drop      = require("scratchdrop")
local lain      = require("lain")
local revelation = require("revelation")
-- }}}

-- =====================================================================
-- {{{ s_error
-- =====================================================================
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- =====================================================================
-- {{{ s_utilities
-- =====================================================================
-- Toggle the wibox
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

-- Execute a command once at start of awesome
function run_once(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace-1)
    end
    sexec("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end
-- }}}

-- =====================================================================
-- {{{ s_vars
-- =====================================================================
-- Apps
terminal   = "urxvt" or "xterm"
terminal_tmux = terminal .. " -e tmux"
editor     = os.getenv("EDITOR") or "vim" or "vi"
editor_cmd = terminal .. " -e " .. editor
gui_editor = "gvim"
browser    = "firefox"
mail       = "thunderbird"
graphics   = "gimp"

-- Environment
hostname       = io.lines("/proc/sys/kernel/hostname")()
home_dir       = os.getenv("HOME")
config_dir     = awful.util.getdir("config")
screenshot_dir = home_dir .. "/box/bilder/screenshots"

-- Appearance
wibox_height = 20
wibox_position = "top"
border_width   = 0

-- Widgets
weather_city = 2857807 -- Find out via http://openweathermap.org/find

-- Lain
lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol    = 1

-- Shortcuts
exec       = awful.util.spawn
sexec      = awful.util.spawn_with_shell
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey     = "Mod4"
altkey     = "Mod1"
k_m        = { modkey }
k_ms       = { modkey, "Shift" }
k_mc       = { modkey, "Control" }
k_mcs      = { modkey, "Control", "Shift" }
k_a        = { altkey }
k_ac       = { altkey, "Control" }
k_as       = { altkey, "Shift" }
k_acs      = { altkey, "Control", "Shift" }
k_am       = { altkey, modkey }
k_ams      = { altkey, modkey, "Shift" }
-- }}}

-- =====================================================================
-- {{{ s_theme
-- =====================================================================
theme     = "default/theme.lua"
if hostname == "htpc" then
    theme = "rainbow/theme.lua"
end

-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. theme)
revelation.init()
-- }}}

-- =====================================================================
-- {{{ s_autostart
-- =====================================================================
--run_once("urxvtd")
--run_once("unclutter -root")
-- }}}

-- =====================================================================
-- {{{ s_layouts
-- =====================================================================
local layouts = {
    awful.layout.suit.tile, --1
    awful.layout.suit.tile.left, --2
    awful.layout.suit.tile.top, --3
    awful.layout.suit.fair.horizontal, --4
    lain.layout.termfair, --5
    lain.layout.cascade, --6
    awful.layout.suit.floating, --7
    lain.layout.uselesstile, --8
}

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = layouts
    --awful.layout.suit.floating,
    --awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
--}
-- }}}

-- =====================================================================
-- {{{ s_menu
-- =====================================================================
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))
-- }}}

-- =====================================================================
-- {{{ s_wallpaper
-- =====================================================================
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
-- }}}

-- =====================================================================
-- {{{ s_tags
-- =====================================================================
gold_factor = 0.618
tags = {
    {
        name = "web", layout = layouts[1], master_width_factor = 0.5, master_count = 1, column_count = 1, selected = true
        --master_count = 1, column_count = 2, gap = 0, gap_single_client  = false, screen = s, activated = true, selected = true
    },
    {
        name = "dev", layout = layouts[1], master_width_factor = 0.5, master_count = 1, column_count = 1, selected = true
        --master_count = 1, column_count = 2, gap = 0, gap_single_client  = false, screen = s, activated = true, selected = true
    },
    {
        name = "term", layout = layouts[4], master_width_factor = 0.4, master_count = 1, column_count = 2,
        --master_count = 2, column_count = 2, gap = 1, gap_single_client  = false, screen = s, activated = true
    },
    {
        name = "vlc", layout = layouts[3], master_width_factor = gold_factor, master_count = 1, column_count = 2,
        --master_count = 2, column_count = 2, gap = 0, gap_single_client  = false, screen = s, activated = true
    },
    {
        name = "vm", layout = layouts[5], master_width_factor = 0.7, master_count = 1, column_count = 2,
        --master_count = 1, column_count = 2, gap = 0, gap_single_client  = false, screen = s, activated = true
    },
    {
        name = "doc", layout = layouts[4], master_width_factor = gold_factor, master_count = 1, column_count = 2,
        --master_count = 1, column_count = 2, gap = 0, gap_single_client  = false, screen = s, activated = true
    },
    {
        name = "play", layout = layouts[5], master_fill_policy = "master_width_factor", master_width_factor = 0.8,
        master_count = 1, column_count = 2, gap = 0, gap_single_client  = false, screen = s, activated = true
    }

}
-- }}}

-- =====================================================================
-- {{{ s_widgets
-- =====================================================================
markup = lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = wibox.widget.textclock(markup("#7788af", "%A %d %B ") .. markup("#343639", ">") .. markup("#de5e1e", " %H:%M "))
--mytextclock = lain.widget.abase({
--    timeout  = 60,
--    cmd      = "date +'%A %d %B %R'",
--    settings = function()
--        local t_output = ""
--        local o_it = string.gmatch(output, "%S+")
--
--        for i=1,3 do t_output = t_output .. " " .. o_it(i) end
--
--        widget:set_markup(markup("#7788af", t_output) .. markup("#343639", " > ") .. markup("#de5e1e", o_it(1)) .. " ")
--    end
--})

-- Calendar
--lain.widget.cal:attach( mytextclock, { font_size = 8, followmouse = true } )

---- Weather
weathericon = wibox.widget.imagebox(beautiful.widget_weather)
myweather = lain.widget.weather({
    city_id = weather_city,
    settings = function()
        descr = weather_now["weather"][1]["description"]:lower()
        units = math.floor(weather_now["main"]["temp"])
        widget:set_markup(markup("#eca4c4", descr .. " @ " .. units .. "°C "))
    end
})

---- Filesystem
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widget.fs({
    --settings  = function()
    --    widget:set_markup(markup("#80d9d8", fs_now.used .. "% "))
    --end
})

---- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
    end
})

---- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widget.temp({
    settings = function()
        widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
    end
})

---- Battery
baticon = wibox.widget.imagebox(beautiful.widget_batt)
batwidget = lain.widget.bat({
    settings = function()
        if bat_now.perc == "N/A" then
            perc = "AC "
        else
            perc = bat_now.perc .. "% "
        end
        widget:set_text(perc)
    end
})

---- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
    end
})

---- Net
--netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
----netdownicon.align = "middle"
--netdowninfo = wibox.widget.textbox()
--netupicon = wibox.widget.imagebox(beautiful.widget_netup)
----netupicon.align = "middle"
--netupinfo = lain.widget.net({})

---- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widget.mem({
    settings = function()
        widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
    end
})

---- Spacer
spacer = wibox.widget.textbox(" ")
-- }}}

-- =====================================================================
-- {{{ s_screen
-- =====================================================================
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    for i = 1, 7 do
        awful.tag.add(i, tags[i])
    end

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- =====================================================================
    -- {{{ s_wibox
    -- =====================================================================
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            --netdownicon,
            --netdowninfo,
            --netupicon,
            --netupinfo,
            volicon,
            volumewidget,
            memicon,
            memwidget,
            cpuicon,
            cpuwidget,
            fsicon,
            fswidget,
            weathericon,
            myweather,
            tempicon,
            tempwidget,
            baticon,
            batwidget,
            clockicon,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- =====================================================================
-- {{{ s_mouse_bindings
-- =====================================================================
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- =====================================================================
-- {{{ s_globalkeys
-- =====================================================================
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),

    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    awful.key({modkey }, "a", function () drop("urxvt -name urxvt_drop_bl -e tmux", "bottom", "left", 0.5, 0.35 ) end,
            {description = "dropdown terminal at bottom left", group = "drop"}),
    awful.key({ modkey}, "s", function () drop("urxvt -name urxvt_drop_bc -e tmux", "bottom", "center", 1, 0.35 ) end,
            {description = "dropdown terminal at bottom center", group = "drop"}),
    awful.key({modkey}, "d", function () drop("urxvt -name urxvt_drop_br", "bottom", "right", 0.5, 0.35 ) end,
            {description = "dropdown terminal at bottom right", group = "drop"}),
    awful.key({modkey}, "f",       function () run_or_raise("firefox", { class = "Firefox" }) end,
            {description = "Run firefox", group = "apps"}),
    awful.key({modkey}, "e", revelation)
)
-- }}}

-- =====================================================================
-- {{{ s_clientkeys
-- =====================================================================
clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- =====================================================================
-- {{{ s_rules
-- =====================================================================
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
          "urxvt_drop.*",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
    -- 1:web
    { rule_any = { class = { "Firefox", "Chromium", "Dwb" } },
      properties = { screen = 1, tag = "1" }
    },
    { rule = { class = "Firefox" }, except = { instance = "Navigator" },
      properties = { floating = true },
      callback = awful.placement.centered
    },

    ---- 2:dev
    { rule_any = { class = { "jetbrains-.*", "Eclipse", "Gvim", "Geany", "Gedit", "medit" }, instance = { "urxvt_edit" } },
      properties = { screen = 1, tag = "2" }
    },

    ---- 3:edit/term
    { rule_any = { class = { "Gvim", "Geany", "Gedit", "medit" }, instance = { "urxvt_edit" } },
      properties = { screen = 1, tag = "3" }
    },

    ---- 4:vlc
    { rule_any = { class = { "Vlc", "Mplayer" } },
      properties = { screen = 1, tag = "4" }
    },

    ---- 5:vm
    { rule_any = { class = { "VirtualBox", "Wine", "Vncviewer", "Nxplayer.bin" } },
      properties = { screen = 1, tag = "5", floating = true }
    },
    { rule = { class = "VirtualBox" },
      callback = awful.placement.centered
    },
    { rule_any = { class = { "Vncviewer", "VirtualBox" } },
        --        properties = { switchtotag = true },
      callback = awful.placement.centered
    },

    ---- 6:docs
    { rule_any = { class = { "Gimp", "Zeal", "LibreOffice", "AbiWord" } },
      properties = { screen = 1, tag = "6", switchtotag = true }
    },
    { rule = { class = "Gimp", role = "gimp-image-window" },
      callback = awful.client.setmaster
    }
}
-- }}}

-- =====================================================================
-- {{{ s_signals
-- =====================================================================
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
     if not awesome.startup then
         awful.client.setslave(c)

         -- Put windows in a smart way, only if they do not set an initial position.
         if not c.size_hints.user_position and not c.size_hints.program_position then
             awful.placement.no_overlap(c)
             awful.placement.no_offscreen(c)
             -- Non-default
             --~ awful.placement.under_mouse(c)
         end
     end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
