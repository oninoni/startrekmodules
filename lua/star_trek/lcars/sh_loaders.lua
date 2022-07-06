---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
--       LCARS Loaders | Shared      --
---------------------------------------

------------------------
--      Elements      --
------------------------

-- Load the given element class.
--
-- @param String elementDirectory
-- @param String elementName
-- @return Boolean success
-- @return? String error
function Star_Trek.LCARS:LoadElement(elementDirectory, elementName)
	ELEMENT = {}
	ELEMENT.Class = elementName

	local success = pcall(function()
		if SERVER then
			local elementFiles, _ = file.Find(elementDirectory .. elementName .. "/*", "LUA")
			for _, elementFile in pairs(elementFiles) do
				AddCSLuaFile(elementDirectory .. elementName .. "/" .. elementFile)
			end
		end

		if CLIENT then
			include(elementDirectory .. elementName .. "/cl_init.lua")
		end
	end)
	if not success then
		return false, "Cannot load LCARS Element Class \"" .. elementName .. "\""
	end

	self.Elements[elementName] = ELEMENT
	ELEMENT = nil

	return true
end

-- Reload all element classes.
--
-- @param String moduleDirectory
function Star_Trek.LCARS:LoadElements(moduleDirectory)
	self.Elements = self.Elements or {}

	local elementDirectory = moduleDirectory .. "elements/"
	local _, elementDirectories = file.Find(elementDirectory .. "*", "LUA")

	for _, elementName in pairs(elementDirectories) do
		self.Elements[elementName] = nil

		local success, error = self:LoadElement(elementDirectory, elementName)
		if success then
			Star_Trek:Message("Loaded LCARS Element Class \"" .. elementName .. "\"")
		else
			Star_Trek:Message(error)
		end
	end
end

-- Link all the elements with their dependencies.
function Star_Trek.LCARS:LinkElements()
	for elementName, element in pairs(self.Elements) do
		local baseElementClass = element.BaseElement
		if isstring(baseElementClass) then
			local baseElement = self.Elements[baseElementClass]
			if istable(baseElement) then
				element.Base = baseElement
				setmetatable(element, {__index = baseElement})
			else
				Star_Trek:Message("Failed, to find Base Element Class \"" .. baseElementClass .. "\" for \"" .. elementName .. "\"")
			end
		end
	end
end

------------------------
--       Windows      --
------------------------

-- Load the given window class.
--
-- @param String windowDirectory
-- @param String windowName
-- @return Boolean success
-- @return? String error
function Star_Trek.LCARS:LoadWindow(windowDirectory, windowName)
	WINDOW = {}
	WINDOW.Class = windowName
	WINDOW.IsLCARSWindow = true

	local success = pcall(function()
		if SERVER then
			AddCSLuaFile(windowDirectory .. windowName .. "/shared.lua")
			AddCSLuaFile(windowDirectory .. windowName .. "/cl_init.lua")

			include(windowDirectory .. windowName .. "/shared.lua")
			include(windowDirectory .. windowName .. "/init.lua")
		end

		if CLIENT then
			include(windowDirectory .. windowName .. "/shared.lua")
			include(windowDirectory .. windowName .. "/cl_init.lua")
		end
	end)
	if not success then
		return false, "Cannot load LCARS Window Class \"" .. windowName .. "\""
	end

	self.Windows[windowName] = WINDOW
	WINDOW = nil

	return true
end

-- Reload all window classes.
--
-- @param String moduleDirectory
function Star_Trek.LCARS:LoadWindows(moduleDirectory)
	self.Windows = self.Windows or {}

	local windowDirectory = moduleDirectory .. "windows/"
	local _, windowDirectories = file.Find(windowDirectory .. "*", "LUA")

	for _, windowName in pairs(windowDirectories) do
		self.Windows[windowName] = nil

		local success, error = self:LoadWindow(windowDirectory, windowName)
		if success then
			Star_Trek:Message("Loaded LCARS Window Class \"" .. windowName .. "\"")
		else
			Star_Trek:Message(error)
		end
	end
end

-- Link all the windows with their dependencies.
function Star_Trek.LCARS:LinkWindows()
	for windowName, window in pairs(self.Windows) do
		local baseWindowClass = window.BaseWindow
		if isstring(baseWindowClass) then
			local baseWindow = self.Windows[baseWindowClass]
			if istable(baseWindow) then
				window.Base = baseWindow
				setmetatable(window, {__index = baseWindow})
			else
				Star_Trek:Message("Failed, to find Base Window Class \"" .. baseWindowClass .. "\" for \"" .. windowName .. "\"")
			end
		end
	end
end

------------------------
--     Interfaces     --
------------------------

if SERVER then
	-- Load the given interface class.
	--
	-- @param String interfaceDirectory
	-- @param String interfaceName
	-- @return Boolean success
	-- @return? String error
	function Star_Trek.LCARS:LoadInterface(interfaceDirectory, interfaceName)
		INTERFACE = {}
		INTERFACE.Class = interfaceName
		INTERFACE.IsLCARSInterface = true

		local success = pcall(function()
			include(interfaceDirectory .. interfaceName .. "/init.lua")
		end)
		if not success then
			return false, "Cannot load LCARS Interface Class \"" .. interfaceName .. "\""
		end

		local interface = INTERFACE
		INTERFACE = nil

		self.Interfaces[interfaceName] = interface

		return true
	end

	-- Reload all interface classes.
	--
	-- @param String moduleDirectory
	function Star_Trek.LCARS:LoadInterfaces(moduleDirectory)
		self.Interfaces = self.Interfaces or {}

		local interfaceDirectory = moduleDirectory .. "interfaces/"
		local _, interfaceDirectories = file.Find(interfaceDirectory .. "*", "LUA")

		for _, interfaceName in pairs(interfaceDirectories) do
			self.Interfaces[interfaceName] = nil

			local success, error = self:LoadInterface(interfaceDirectory, interfaceName)
			if success then
				Star_Trek:Message("Loaded LCARS Interface Class \"" .. interfaceName .. "\"")
			else
				Star_Trek:Message(error)
			end
		end
	end

	-- Link all the interfaces with their dependencies.
	function Star_Trek.LCARS:LinkInterfaces()
		for interfaceName, interface in pairs(self.Interfaces) do
			local baseInterfaceClass = interface.BaseInterface
			if isstring(baseInterfaceClass) then
				local baseInterface = self.Interfaces[baseInterfaceClass]
				if istable(baseInterface) then
					interface.Base = baseInterface
					setmetatable(interface, {__index = baseInterface})
				else
					Star_Trek:Message("Failed, to find Base Interface Class \"" .. baseInterfaceClass .. "\" for \"" .. interfaceName .. "\"")
				end
			end
		end
	end
end

------------------------
--        Hooks       --
------------------------

-- Reload all Element-, Window- and Interface-Classes of a module.
--
-- @param String moduleDirectory
function Star_Trek.LCARS:Reload(moduleDirectory)
	self:LoadElements(moduleDirectory)

	self:LoadWindows(moduleDirectory)

	if SERVER then
		self:LoadInterfaces(moduleDirectory)
	end
end

hook.Add("Star_Trek.ModuleLoaded", "Star_Trek.LCARS.ReloadOnModuleLoaded", function(_, moduleDirectory)
	Star_Trek.LCARS:Reload(moduleDirectory)
end)

-- Link all the Element-, Window- and Interface-Classes to their Base Classes. 
function Star_Trek.LCARS:LinkDependencies()
	self:LinkElements()

	self:LinkWindows()

	if SERVER then
		self:LinkInterfaces()
	end
end

hook.Add("Star_Trek.ModulesLoaded", "Star_Trek.LCARS.ReloadOnModulesLoaded", function()
	Star_Trek.LCARS:LinkDependencies()
end)