--------------------------------
--- ManaBar.lua Version 0.4c ---
--------------------------------

local ManaBar = {
	OptionEnable = Menu.AddOption({"mlambers", "ManaBar"}, "1. Enable.", "Enable/Disable this script."),
	OffsetWidth = Menu.AddOption({"mlambers", "ManaBar"}, "2. Width", "", 20, 220, 2),
	OffsetHeight = Menu.AddOption({"mlambers", "ManaBar"}, "3. Height", "", 2, 30, 1),
	OffsetYPos = Menu.AddOption({"mlambers", "ManaBar"}, "4. Y position", "", -50, 50, 1),
	OffsetXPos = Menu.AddOption({"mlambers", "ManaBar"}, "5. X position", "", -120, 120, 1)
}

--[[
    Localize global function from _ENV
        math.ceil
--]]
local MathCeil = math.ceil

local MyHero = nil
local hero_object, hero_origin = nil, nil

local bar_width, bar_height = nil, nil
local bar_x_offset, bar_y_offset = nil, nil
local bar_x, bar_y = nil, nil

local x_w2s, y_w2s = nil, nil
local screen_width, screen_height = nil, nil

local extra_health_bar = -1


function ManaBar.OnMenuOptionChange(option, old, new)
	if MyHero == nil then return end
    
    if option == ManaBar.OptionEnable and old == 0 then
        bar_width = Menu.GetValue(ManaBar.OffsetWidth)
		bar_height = Menu.GetValue(ManaBar.OffsetHeight)
        bar_x_offset = Menu.GetValue(ManaBar.OffsetXPos)
		bar_y_offset = Menu.GetValue(ManaBar.OffsetYPos)
    end
    
    if 
		(option == ManaBar.OffsetWidth
		or option == ManaBar.OffsetHeight
		or option == ManaBar.OffsetYPos
		or option == ManaBar.OffsetXPos)
	then
		bar_width = Menu.GetValue(ManaBar.OffsetWidth)
		bar_height = Menu.GetValue(ManaBar.OffsetHeight)
        bar_x_offset = Menu.GetValue(ManaBar.OffsetXPos)
		bar_y_offset = Menu.GetValue(ManaBar.OffsetYPos)
    end
end

function ManaBar.OnScriptLoad()
	MyHero = nil
	hero_object, hero_origin = nil, nil
	
    bar_width, bar_height = nil, nil
    bar_x_offset, bar_y_offset = nil, nil
	bar_x, bar_y = nil, nil
    
    x_w2s, y_w2s = nil, nil
	screen_width, screen_height = nil, nil
    
    extra_health_bar = -1
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.4c ] Script load.")
end

function ManaBar.OnGameEnd()
	MyHero = nil
	hero_object, hero_origin = nil, nil
	
	bar_width, bar_height = nil, nil
    bar_x_offset, bar_y_offset = nil, nil
	bar_x, bar_y = nil, nil
    
    x_w2s, y_w2s = nil, nil
	screen_width, screen_height = nil, nil
    
    extra_health_bar = -1
	
	Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.4c ] Game end. Reset all variable.")
end

function ManaBar.IsOnScreen(x_position, y_position)
	if (x_position < 1) or (y_position < 1) or (x_position > screen_width) or (y_position > screen_height) then 
		return false 
	end
	
	return true
end

function ManaBar.OnUpdate()
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	
	if MyHero == nil or MyHero ~= Heroes.GetLocal() then
		bar_width = Menu.GetValue(ManaBar.OffsetWidth)
		bar_height = Menu.GetValue(ManaBar.OffsetHeight)
        bar_x_offset = Menu.GetValue(ManaBar.OffsetXPos)
		bar_y_offset = Menu.GetValue(ManaBar.OffsetYPos)
		bar_x, bar_y = nil, nil
        
        x_w2s, y_w2s = nil, nil
		screen_width, screen_height = Renderer.GetScreenSize()
        
        hero_object, hero_origin = nil, nil
        extra_health_bar = -1
        
        MyHero = Heroes.GetLocal()
		
		Console.Print("[" .. os.date("%I:%M:%S %p") .. "] - - [ ManaBar.lua ] [ Version 0.4c ] Game started, init script done.")
		return
	end
end

function ManaBar.OnDraw()
	if Menu.IsEnabled(ManaBar.OptionEnable) == false then return end
	
	if MyHero == nil then return end
    
	for i = 1, Heroes.Count() do
		hero_object = Heroes.Get(i)
		
		if 
			hero_object ~= nil
			and Entity.IsDormant(hero_object) == false
			and Entity.IsAlive(hero_object)
			and Entity.IsSameTeam(MyHero, hero_object) == false
			and Entity.GetField(hero_object, "m_bIsIllusion") == false
			and NPC.IsIllusion(hero_object) == false
			and Entity.IsPlayer(Entity.GetOwner(hero_object)) 
		then
            
			hero_origin = Entity.GetAbsOrigin(hero_object)
            extra_health_bar = Entity.GetField(hero_object, "m_nHealthBarOffsetOverride")
            
            if extra_health_bar > -1 then
                hero_origin:SetZ(hero_origin:GetZ() + extra_health_bar)
            else
                hero_origin:SetZ(hero_origin:GetZ() + NPC.GetHealthBarOffset(hero_object))
            end
            
            x_w2s, y_w2s = Renderer.WorldToScreen(hero_origin)
			
			--[[
				Need to check if target object on our screen or not.
			--]]
			if ManaBar.IsOnScreen(x_w2s, y_w2s) then
				bar_x = x_w2s + bar_x_offset
				bar_y = y_w2s + bar_y_offset
				
				--[[
					Draw black background.
				--]]
				Renderer.SetDrawColor(0, 0, 0, 255)
				Renderer.DrawFilledRect(bar_x, bar_y, bar_width, bar_height)
				
				--[[
					Draw the actual mana bar.
				--]]
				Renderer.SetDrawColor(79, 120, 249, 255)
				Renderer.DrawFilledRect((1 + bar_x), (1 + bar_y), MathCeil((bar_width - 2) * (NPC.GetMana(hero_object) /  NPC.GetMaxMana(hero_object))), (bar_height - 2))
			end
		end
	end
end

return ManaBar