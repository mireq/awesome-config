---[[                                          ]]--
--                                               -
--          Inspired from WM 3.5.+ config        --
--           github.com/copycat-killer           --
--                                               -
--[[                                           ]]--

-- {{{ Required Libraries

gears           = require("gears")
awful           = require("awful")
awful.rules     = require("awful.rules")
awful.autofocus = require("awful.autofocus")
wibox           = require("wibox")
beautiful       = require("beautiful")
naughty         = require("naughty")
vicious         = require("vicious")
scratch         = require("scratch")
blingbling      = require("blingbling")

-- }}}

-- {{{ Error Handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = err
		})
		in_error = false
	end)
end

-- }}}


-- {{{ Variable Definitions

-- Useful Paths
home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
active_theme = themes .. "/powerarrow-darker"

-- Themes define colours, icons, and wallpapers
beautiful.init(active_theme .. "/theme.lua")

terminal = "urxvtc"
editor = os.getenv("EDITOR")
gui_editor = "kwrite"
browser = "firefox-bin"
browser2 = "google-chrome-unstable"
mail = terminal .. " -e mutt "
chat = terminal .. " -e irssi "
tasks = terminal .. " -e htop "
iptraf = terminal .. " -g 180x54-20+34 -e sudo iptraf-ng -i all "
musicplr = terminal .. " -g 130x34-320+16 -e ncmpcpp "

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
	awful.layout.suit.floating,             -- 1
	awful.layout.suit.tile,                 -- 2
	awful.layout.suit.tile.left,            -- 3
	awful.layout.suit.tile.bottom,          -- 4
	awful.layout.suit.tile.top,             -- 5
	awful.layout.suit.fair,                 -- 6
	awful.layout.suit.fair.horizontal,      -- 7
	awful.layout.suit.spiral,               -- 8
	awful.layout.suit.spiral.dwindle,       -- 9
	awful.layout.suit.max,                  -- 10
	awful.layout.suit.max.fullscreen,       -- 11
	awful.layout.suit.magnifier             -- 12
}

-- }}}

-- {{{ Wallpaper

if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end

-- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {
	names = { "1", "2", "3", "4", "5", "6", "7", "8", "9"},
	layout = {
		layouts[1],
		layouts[1],
		layouts[1],
		layouts[1],
		layouts[1],
		layouts[1],
		layouts[1],
		layouts[1],
		layouts[2]
	}
}
for s = 1, screen.count() do
	tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- }}}

-- {{{ Menu
myaccessories = {
	{ "archives", "ark" },
	{ "file manager", "konqueror" },
	{ "editor", gui_editor },
}
myinternet = {
	{ "browser", browser },
}
mygames = {
	{ "PSX", "pcsxr" },
	{ "Super NES", "zsnes" },
}
mygraphics = {
	{ "gimp" , "gimp" },
	{ "inkscape", "inkscape" },
	{ "darktable" , "darktable" }
}
myoffice = {
	{ "writer" , "lowriter" },
	{ "impress" , "loimpress" },
}
mysystem = {
	{ "htop" , terminal .. " -e htop " },
}
mymainmenu = awful.menu({
	items = {
		{ "accessories" , myaccessories },
		{ "graphics" , mygraphics },
		{ "internet" , myinternet },
		{ "games" , mygames },
		{ "office" , myoffice },
		{ "system" , mysystem },
	}
})
mylauncher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = mymainmenu
})
-- }}}


-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)
-- }}}

-- {{{ Layout
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
	awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
		end
	end),
	awful.button({ }, 3, function ()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ width=250 })
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end)
)

-- {{{ Widgets

-- Music widget
-- mpdwidget = wibox.widget.textbox()
-- mpdicon = wibox.widget.imagebox()
-- mpdicon:set_image(beautiful.widget_music)
-- mpdicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
-- 
-- vicious.register(mpdwidget, vicious.widgets.mpd,
-- function(widget, args)
-- 	-- play
-- 	if (args["{state}"] == "Play") then
--     mpdicon:set_image(beautiful.widget_music_on)
-- 		return "<span background='#313131' font='Terminus 13' rise='2000'> <span font='Terminus 9'>" .. red .. args["{Title}"] .. coldef .. colwhi .. " - " .. coldef .. colwhi  .. args["{Artist}"] .. coldef .. " </span></span>"
-- 	-- pause
-- 	elseif (args["{state}"] == "Pause") then
--     mpdicon:set_image(beautiful.widget_music)
-- 		return "<span background='#313131' font='Terminus 13' rise='2000'> <span font='Terminus 9'>" .. colwhi .. "mpd in pausa" .. coldef .. " </span></span>"
-- 	else
--     mpdicon:set_image(beautiful.widget_music)
-- 		return ""
-- 	end
-- end, 1)

-- Volume widget

-- Volume widget logic
cardid  = 0
channel = "Master"
function volume (mode, widget)
	if mode == "up" then
		awful.util.spawn("amixer set Master playback 1%+", false )
		vicious.force({ widget })
	elseif mode == "down" then
		awful.util.spawn("amixer set Master playback 1%-", false )
		vicious.force({ widget })
	else
		awful.util.spawn("amixer set Master playback toggle", false )
		vicious.force({ widget })
	end
end

volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
volumewidget = wibox.widget.textbox()
volumewidget:buttons(awful.util.table.join(
	awful.button({ }, 4, function () volume("up", volumewidget) end),
	awful.button({ }, 5, function () volume("down", volumewidget) end),
	awful.button({ }, 1, function () volume("mute", volumewidget) end)
))
vicious.register(volumewidget, vicious.widgets.volume,
	function (widget, args)
		if (args[2] ~= "♩" ) then
			if (args[1] == 0) then
				volicon:set_image(beautiful.widget_vol_no)
			elseif (args[1] <= 50) then
				volicon:set_image(beautiful.widget_vol_low)
			else
				volicon:set_image(beautiful.widget_vol)
			end
		else
			volicon:set_image(beautiful.widget_vol_mute)
		end
 		return '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9">' .. args[1] .. '% </span></span>'
	end, 15, "Master")


-- Mail widget
--mygmail = wibox.widget.textbox()
--notify_shown = false
--gmail_t = awful.tooltip({ objects = { mygmail },})
mygmailimg = wibox.widget.imagebox(beautiful.widget_mail)
--vicious.register(mygmail, vicious.widgets.gmail,
--function (widget, args)
--  notify_title = "Hai un nuovo messaggio"
--  notify_text = '"' .. args["{subject}"] .. '"'
--  gmail_t:set_text(args["{subject}"])
--  gmail_t:add_to_object(mygmailimg)
--  if (args["{count}"] > 0) then
--	if (notify_shown == false) then
--	  if (args["{count}"] > 1) then 
--		  notify_title = "Hai " .. args["{count}"] .. " nuovi messaggi"
--		  notify_text = 'Ultimo: "' .. args["{subject}"] .. '"'
--	  else
--		  notify_title = "Hai un nuovo messaggio"
--		  notify_text = args["{subject}"]
--	  end
--	  naughty.notify({ title = notify_title, text = notify_text,
--	  timeout = 7,
--	  position = "top_left",
--	  icon = beautiful.widget_mail_notify,
--	  fg = beautiful.fg_urgent,
--	  bg = beautiful.bg_urgent })
--	  notify_shown = true
--	end
--	return '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9">' .. args["{count}"] .. ' </span></span>'
--  else
--	notify_shown = false
--	return ""
--  end
--end, 60)
--mygmail:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail, false) end)))

-- MEM widget
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, function(widget, args) return ' <span font="Terminus 9">' .. string.format("%4d", args[2]) .. "MB </span>" end, 3)

-- CPU widget
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, function(widget, args) return '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9">' .. string.format("%2d", args[1]) .. "% </span></span>" end, 3)
cpuicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(tasks, false) end)))

blingbling.popups.htop(cpuwidget, {
	title_color = "#ffffff",
	user_color = "#00ff00",
	root_color = "#ffff00",
	terminal = "urxvt"
})

-- Temp widget
tempicon = wibox.widget.imagebox()
tempicon:set_image(beautiful.widget_temp)
tempwidget = wibox.widget.textbox()
vicious.register(tempwidget, vicious.widgets.thermal, '<span font="Terminus 12"> <span font="Terminus 9">$1°C </span></span>', 15, {"thermal_zone0", "sys"} )

-- Battery widget
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_battery)

function batstate()
	local file = io.open("/sys/class/power_supply/BAT0/status", "r")

	if (file == nil) then
		return "Cable plugged"
	end

	local batstate = file:read("*line")
	file:close()

	if (batstate == 'Discharging' or batstate == 'Charging') then
		return batstate
	elseif (batstate == 'Unknown') then
		return "Cable plugged"
	else
		return "Fully charged"
	end
end

batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,
function (widget, args)
	-- plugged
	if (batstate() == 'Cable plugged') then
		baticon:set_image(beautiful.widget_ac)
		return '<span font="Terminus 12"> <span font="Terminus 9">' .. args[2] .. '% </span></span>'
	-- critical
	elseif (args[2] <= 5 and batstate() == 'Discharging') then
		baticon:set_image(beautiful.widget_battery_empty)
		naughty.notify({
			text = "Battery empty.",
			title = "Battery empty!",
			position = "top_right",
			timeout = 1,
			fg="#000000",
			bg="#ffffff",
			screen = 1,
			ontop = true,
		})
	-- low
	elseif (args[2] <= 10 and batstate() == 'Discharging') then
		baticon:set_image(beautiful.widget_battery_low)
		naughty.notify({
			text = "Battery status low.",
			title = "Battery low",
			position = "top_right",
			timeout = 1,
			fg="#ffffff",
			bg="#262729",
			screen = 1,
			ontop = true,
		})
	else baticon:set_image(beautiful.widget_battery)
	end
	return '<span font="Terminus 12"> <span font="Terminus 9">' .. args[2] .. '% </span></span>'
end, 15, 'BAT0')

function print_net(down_val, up_val)
	return '<span background="#313131" font="Terminus 13" rise="2000"> <span font="Terminus 9" color="#7AC82E">' .. down_val .. '</span> <span font="Terminus 7" color="#EEDDDD">↓↑</span> <span font="Terminus 9" color="#46A8C3">' .. up_val .. ' </span></span>'
end

-- Net widget
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net, function(widget, args)
	if args['{ppp0 down_kb}'] then
		return print_net(args['{ppp0 down_kb}'], args['{ppp0 up_kb}'])
	elseif args['{wlan0 down_kb}'] then
		return print_net(args['{wlan0 down_kb}'], args['{wlan0 up_kb}'])
	elseif args['{eth0 down_kb}'] then
		return print_net(args['{eth0 down_kb}'], args['{eth0 up_kb}'])
	end
	return print_net(0, 0)
end, 3)
neticon = wibox.widget.imagebox()
neticon:set_image(beautiful.widget_net)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
blingbling.popups.netstat(netwidget, {
	title_color = "#ffffff",
	established_color = "#ffff00",
	listen_color = "#00ff00"
})

-- Textclock widget
clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.widget_clock)
mytextclock = awful.widget.textclock("<span font=\"Terminus 12\"><span font=\"Terminus 9\" color=\"#DDDDFF\"> %a %d %b  %H:%M</span></span>")

calendar = blingbling.calendar()

-- Separators
spr = wibox.widget.textbox(' ')
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)


-- }}}


for s = 1, screen.count() do
	mypromptbox[s] = awful.widget.prompt()
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
	))

	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

	-- Upper left widgets
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mylauncher)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])
	left_layout:add(spr)

	-- Upper right widgets
	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(spr)
	right_layout:add(arrl)
	--right_layout:add(arrl_ld)
	--right_layout:add(mpdicon)
	--right_layout:add(mpdwidget)
	--right_layout:add(arrl_dl)
	right_layout:add(arrl_ld)
	right_layout:add(mygmailimg)
	--right_layout:add(mygmail)
	right_layout:add(arrl_dl)
	right_layout:add(memicon)
	right_layout:add(memwidget)
	right_layout:add(arrl_ld)
	right_layout:add(neticon)
	right_layout:add(netwidget)
	right_layout:add(arrl_dl)
	right_layout:add(tempicon)
	right_layout:add(tempwidget)
	right_layout:add(arrl_ld)
	right_layout:add(cpuicon)
	right_layout:add(cpuwidget)
	right_layout:add(arrl_dl)
	right_layout:add(baticon)
	right_layout:add(batwidget)
	right_layout:add(arrl_ld)
	right_layout:add(volicon)
	right_layout:add(volumewidget)
	right_layout:add(arrl_dl)
	if s == 1 then right_layout:add(wibox.widget.systray()) end
	right_layout:add(arrl)
	right_layout:add(calendar)
	right_layout:add(spr)
	right_layout:add(spr)
	right_layout:add(arrl_ld)
	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)
	mywibox[s]:set_widget(layout)
end

vicious.suspend()
mytimer = timer({ timeout = 5 })
mytimer:connect_signal("timeout", function()
	vicious.force({ memwidget, netwidget, tempwidget, cpuwidget, batwidget, volumewidget })
end)
mytimer:start()


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Tab", awful.tag.history.restore   ),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ altkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    --awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "s",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Volume controls
    awful.key({ }, "XF86AudioRaiseVolume", function () volume("up", volumewidget) end),
    awful.key({ }, "XF86AudioLowerVolume", function () volume("down", volumewidget) end),
    awful.key({ }, "XF86AudioMute", function () volume("mute", volumewidget) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    --awful.key({ modkey,           }, "b",      function (c) if c.border_width != 0 then c.border_width = 0; else c.border_width = 2; end; end),
    awful.key({ modkey,           }, "b",
        function (c)
            if c.border_width == 0 then
                c.border_width = 1
            else
                c.border_width = 0
            end
        end),
    awful.key({ modkey,           }, "i",
        function (c)
            if (c:titlebar_top():geometry()['height'] > 0) then
                awful.titlebar(c, {size = 0})
            else
                awful.titlebar(c)
            end
        end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
--            c.maximized_horizontal = not c.maximized_horizontal
--            c.maximized_vertical   = not c.maximized_vertical
              if c.maxmized_horizontal or c.maximized_vertical then
                  c.maximized_horizontal = false
                  c.maximized_vertical = false
              else
                  c.maximized_horizontal = true
                  c.maximized_vertical = true
              end
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ altkey }, 1, awful.mouse.client.move),
    awful.button({ altkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Jbox"},
      properties = { floating = true, border_width = 0, x = 16, y = 128, width = 800, height = 608 } },
    { rule = { class = "Yakuake" },
      properties = { floating = true, border_width = 0 } },
    { rule = { class = "Uzbl-core" },
      properties = { tag = tags[1][2], border_width = 0 } },
    { rule = { class = "Kile" },
      properties = { maximized_horizontal = false, maximized_vertical = false} },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
	c:connect_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end

	local titlebars_enabled = true
	if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
		-- Widgets that are aligned to the left
		local left_layout = wibox.layout.fixed.horizontal()
		left_layout:add(awful.titlebar.widget.floatingbutton(c))
		--left_layout:add(awful.titlebar.widget.stickybutton(c))
		left_layout:add(awful.titlebar.widget.ontopbutton(c))
		left_layout:add(awful.titlebar.widget.iconwidget(c))

		-- Widgets that are aligned to the right
		local right_layout = wibox.layout.fixed.horizontal()
		right_layout:add(awful.titlebar.widget.minimizebutton(c))
		right_layout:add(awful.titlebar.widget.maximizedbutton(c))
		right_layout:add(awful.titlebar.widget.closebutton(c))

		-- The title goes in the middle
		local title = awful.titlebar.widget.titlewidget(c)
		local titleLayout = wibox.layout.align.horizontal()
		titleLayout:set_middle(title);
		titleLayout:buttons(awful.util.table.join(
				awful.button({ }, 1, function()
					client.focus = c
					c:raise()
					awful.mouse.client.move(c)
				end),
				awful.button({ }, 3, function()
					client.focus = c
					c:raise()
					awful.mouse.client.resize(c)
				end)
				))


		-- Now bring it all together
		local layout = wibox.layout.align.horizontal()
		layout:set_left(left_layout)
		layout:set_right(right_layout)
		layout:set_middle(titleLayout)

		awful.titlebar(c):set_widget(layout)
		if c.class == 'URxvt' or c.class == 'Firefox' or c.class == 'google-chrome-unstable' then
			awful.titlebar(c, {size = 0})
		end
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

