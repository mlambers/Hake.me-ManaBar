-------------------------------
--- ManaBar.lua Version 0.3 ---
-------------------------------

local ManaBar = {
	OptionEnable = Menu.AddOption({"mlambers", "ManaBar"}, "1. Enable.", "Enable/Disable this script."),
	OffsetWidth = Menu.AddOption({"mlambers", "ManaBar"}, "2. Width", "", 20, 200, 2),
	OffsetHeight = Menu.AddOption({"mlambers", "ManaBar"}, "3. Height", "", 5, 20, 1),
	OffsetYPos = Menu.AddOption({"mlambers", "ManaBar"}, "4. Y position", "", -20, 20, 1),
	NeedInit = true
}

local MyHero = nil
local gObject, gObjectOrigin = nil, nil
local w2sX, w2sY = nil, nil
local oWidth, oHeight, oYPos = nil, nil, nil
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
	then
		oWidth = Menu.GetValue(ManaBar.OffsetWidth)
		oHeight = Menu.GetValue(ManaBar.OffsetHeight)
		oYPos = Menu.GetValue(ManaBar.OffsetYPos)
    end
end

function ManaBar.OnScriptLoad()
	MyHero = nil
	gObject, gObjectOrigin = nil, nil
	w2sX, w2sY = nil, nil
	oWidth, oHeight, oYPos = nil, nil, nil
	xBox, yBox = nil, nil
	TopMost, RightMost = nil, nil
	ManaBar.NeedInit = true
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.3 ] Script load.")
end

function ManaBar.OnGameEnd()
	MyHero = nil
	gObject, gObjectOrigin = nil, nil
	w2sX, w2sY = nil, nil
	oWidth, oHeight, oYPos = nil, nil, nil
	xBox, yBox = nil, nil
	TopMost, RightMost = nil, nil
	ManaBar.NeedInit = true
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.3 ] Game end. Reset all variable.")
end

function ManaBar.IsOnScreen(tempX, tempY)
	if (tempX < 1) or (tempY < 1) or (tempX > RightMost) or (tempY > TopMost) then 
		return false 
	end
	
	return true
end

function ManaBar.OnDraw()
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	if Engine.IsInGame() == false then return end
	if GameRules.GetGameState() < 4 then return end
	
	if MyHero == nil then 
		MyHero = Heroes.GetLocal()
	end

	if ManaBar.NeedInit == true then
		gObject, gObjectOrigin = nil, nil
		w2sX, w2sY = nil, nil
		oWidth = Menu.GetValue(ManaBar.OffsetWidth)
		oHeight = Menu.GetValue(ManaBar.OffsetHeight)
		oYPos = Menu.GetValue(ManaBar.OffsetYPos)
		xBox, yBox = nil, nil
		RightMost, TopMost = Renderer.GetScreenSize()
		ManaBar.NeedInit = false
		
		Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.3 ] Game started, init script done.")
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
				
				xBox = w2sX - mCeil(oWidth * 0.5)
				yBox = w2sY - mCeil(oHeight * 0.5) - oYPos
				
				--[[
					Draw black background.
				--]]
				Renderer.SetDrawColor(0, 0, 0, 255)
				Renderer.DrawFilledRect(xBox, yBox, oWidth, oHeight)
				
				--[[
					Draw the actual mana bar.
				--]]
				Renderer.SetDrawColor(79, 120, 249, 255)
				Renderer.DrawFilledRect(xBox, yBox, mCeil(oWidth * (NPC.GetMana(gObject) /  NPC.GetMaxMana(gObject))), oHeight)
				
				--[[
					Draw black border.
				--]]
				Renderer.SetDrawColor(0, 0, 0, 255)
				Renderer.DrawOutlineRect(xBox, yBox, oWidth, oHeight)
			end
		end
	end
end

return ManaBar