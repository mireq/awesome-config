local capi = { dbus = dbus }

-- https://github.com/pavouk/lgi/


function rescan_devices()
	print("Scanning devices")
end


rescan_devices()


if capi.dbus then
	capi.dbus.add_match("system", "interface='org.freedesktop.DBus.ObjectManager', member='InterfacesAdded'")
	capi.dbus.add_match("system", "interface='org.freedesktop.DBus.ObjectManager', member='InterfacesRemoved'")
	capi.dbus.connect_signal("org.freedesktop.DBus.ObjectManager",
		function (data, text)
			if data.path == "/org/freedesktop/UDisks2" then
				rescan_devices()
			end
		end
	);
end
