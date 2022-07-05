---------------------------------------
---------------------------------------
--        Star Trek Utilities        --
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
--         Benchmark | Shared        --
---------------------------------------

local currentTimes = {}

local times = {}
local iTimes = 1
local AV = 32
local N = 100 * AV

function TakeTime()
	table.insert(currentTimes, SysTime())
end

function CalcDiffs()
	for i = 1, #currentTimes - 1 do
		times[i] = times[i] or {}
		times[i][iTimes] = currentTimes[i + 1] - currentTimes[i]
	end

	iTimes = (iTimes + 1) % N

	currentTimes = {}
end

hook.Add("HUDPaint", "Testing", function()
	local h = ScrH()

	local nColor = #times
	local colorPart = 255 / nColor

	for i, lineData in pairs(times) do
		local lastX = 0
		local lastY = 0

		for x = 1, N / AV do
			local y = 0
			for j = 1, AV do
				local id = (x * AV) + j - 1
				if lineData[id] == nil then break end

				y = y + lineData[id] * 1000 * 1000 * 10
			end
			y = y / AV

			if lastY ~= 0 and y ~= 0 then
				surface.SetDrawColor(i * colorPart, 255 - i * colorPart, 0, 255)
				surface.DrawLine(lastX, h - lastY, x, h - y)
			end

			lastX = x
			lastY = y
		end
	end
end)