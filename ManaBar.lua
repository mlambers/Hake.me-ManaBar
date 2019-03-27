-------------------------------
--- ManaBar.lua Version 0.4 ---
-------------------------------

local ManaBar = {
	OptionEnable = Menu.AddOption({"mlambers", "ManaBar"}, "1. Enable.", "Enable/Disable this script."),
	OffsetWidth = Menu.AddOption({"mlambers", "ManaBar"}, "2. Width", "", 20, 200, 2),
	OffsetHeight = Menu.AddOption({"mlambers", "ManaBar"}, "3. Height", "", 5, 20, 1),
	OffsetYPos = Menu.AddOption({"mlambers", "ManaBar"}, "4. Y position", "", -20, 20, 1),
	OffsetXPos = Menu.AddOption({"mlambers", "ManaBar"}, "5. X position", "", -90, 90, 1)
}

local MyHero = nil
local gObject, gObjectOrigin = nil, nil
local w2sX, w2sY = nil, nil
local oWidth, oHeight, oYPos, oXPos = nil, nil, nil, nil
local xBox, yBox = nil, nil
local TopMost, RightMost = nil, nil
local mCeil = math.ceil

function ManaBar.OnMenuOptionChange(option, old, new)
	if Engine.IsInGame() == false then return end
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	if MyHero == nil then return end
	
	if not option then return end
	
    if 
		option == ManaBar.OffsetWidth
		or option == ManaBar.OffsetHeight
		or option == ManaBar.OffsetYPos
		or option == ManaBar.OffsetXPos
	then
		oWidth = Menu.GetValue(ManaBar.OffsetWidth)
		oHeight = Menu.GetValue(ManaBar.OffsetHeight)
		oYPos = Menu.GetValue(ManaBar.OffsetYPos)
		oXPos = Menu.GetValue(ManaBar.OffsetXPos)
    end
end

function ManaBar.OnScriptLoad()
	MyHero = nil
	gObject, gObjectOrigin = nil, nil
	w2sX, w2sY = nil, nil
	oWidth, oHeight, oYPos, oXPos = nil, nil, nil, nil
	xBox, yBox = nil, nil
	TopMost, RightMost = nil, nil
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.4 ] [ GameState : " .. GameRules.GetGameState() .. " ] Script load.")
end

function ManaBar.OnGameEnd()
	MyHero = nil
	gObject, gObjectOrigin = nil, nil
	w2sX, w2sY = nil, nil
	oWidth, oHeight, oYPos, oXPos = nil, nil, nil, nil
	xBox, yBox = nil, nil
	TopMost, RightMost = nil, nil
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.4 ] [ GameState : " .. GameRules.GetGameState() .. " ] Game end. Reset all variable.")
end

function ManaBar.IsOnScreen(tempX, tempY)
	if (tempX < 1) or (tempY < 1) or (tempX > RightMost) or (tempY > TopMost) then 
		return false 
	end
	
	return true
end

function ManaBar.OnUpdate()
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	
	if MyHero == nil or MyHero ~= Heroes.GetLocal() then 
		MyHero = Heroes.GetLocal()
		gObject, gObjectOrigin = nil, nil
		w2sX, w2sY = nil, nil
		oWidth = Menu.GetValue(ManaBar.OffsetWidth)
		oHeight = Menu.GetValue(ManaBar.OffsetHeight)
		oYPos = Menu.GetValue(ManaBar.OffsetYPos)
		oXPos = Menu.GetValue(ManaBar.OffsetXPos)
		xBox, yBox = nil, nil
		RightMost, TopMost = Renderer.GetScreenSize()
		
		Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.4 ] [ GameState : " .. GameRules.GetGameState() .. " ] Game started, init script done.")
		return
	end
end

function ManaBar.OnDraw()
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	
	if
		Engine.IsInGame() == false
		or GameRules.GetGameState() < 4 
		or GameRules.GetGameState() > 5
	then
		return
	end
	
	if MyHero == nil then return end

	for i = 1, Heroes.Count() do
		gObject = Heroes.Get(i)
		
		if 
			gObject ~= nil
			and Entity.IsDormant(gObject) == false
			and Entity.IsAlive(gObject)
			and Entity.IsSameTeam(MyHero, gObject) == false
			and Entity.GetField(gObject, "m_bIsIllusion") == false
			and NPC.IsIllusion(gObject) == false
			and Entity.IsPlayer(Entity.GetOwner(gObject)) 
		then
			gObjectOrigin = Entity.GetAbsOrigin(gObject)
			w2sX, w2sY = Renderer.WorldToScreen(gObjectOrigin)
			
			--[[
				Need to check if target object on our screen or not.
			--]]
			if ManaBar.IsOnScreen(w2sX, w2sY) then
				gObjectOrigin:SetZ(gObjectOrigin:GetZ() + NPC.GetHealthBarOffset(gObject))
				w2sX, w2sY = Renderer.WorldToScreen(gObjectOrigin)
				
				xBox = w2sX + oXPos
				yBox = w2sY + oYPos
				
				--[[
					Draw black background.
				--]]
				Renderer.SetDrawColor(0, 0, 0, 255)
				Renderer.DrawFilledRect(xBox, yBox, oWidth, oHeight)
				
				--[[
					Draw the actual mana bar.
				--]]
				Renderer.SetDrawColor(79, 120, 249, 255)
				Renderer.DrawFilledRect((1 + xBox), (1 + yBox), mCeil((oWidth - 2) * (NPC.GetMana(gObject) /  NPC.GetMaxMana(gObject))), (oHeight - 2))
			end
		end
	end
end

return ManaBar