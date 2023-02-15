
function GHtmlHud_hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"}) do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "GHtmlHud_HideHL2HUD", GHtmlHud_hidehud)

function GHtmlHudLoadFunction()
    if not IsValid(LocalPlayer()) then timer.Simple(1, GHtmlHudLoadFunction) return end
    GHtmlHud()
end

function GHtmlHud()
    if ghtmlhud ~= nil then ghtmlhud:Remove() end
    ghtmlhud = vgui.Create("DHTML")
    if ghtmlhud == nil then timer.Simple(1, HtmlHud) end

    ghtmlhud:ParentToHUD()
    ghtmlhud:Dock(FILL)
    ghtmlhud:SetAllowLua(true)
    ghtmlhud:OpenURL("http://tkidawn.gitee.io/online_font/ghud")

    function ghtmlhud:Think()
        if not IsValid(LocalPlayer()) then return end
        if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera" then
            ghtmlhud:SetAlpha(0)
        elseif ghtmlhud:GetAlpha() == 0 then
            ghtmlhud:SetAlpha(255)
        end

        local plyh = LocalPlayer():Health()
        local speed

        if LocalPlayer():InVehicle() then
            speed = LocalPlayer():GetVehicle():GetVelocity():Length() * 0.04
        else
            speed = LocalPlayer():GetVelocity():Length() * 0.04
        end

        if speed > 0.1 then
            speed = math.floor(speed * 25)
            ghtmlhud:RunJavascript("document.getElementById('speed').innerHTML ='"..speed.." u/s';")
            ghtmlhud:RunJavascript([[
            setTimeout(function() {
                document.querySelector('sp').style.opacity = 1;
            }, 20);
            ]])
        
            if plyh >= 100 then
                ghtmlhud:RunJavascript("document.documentElement.style.setProperty('--dynamic-hight', '"..(speed/2).."px');")
            else
                ghtmlhud:RunJavascript("document.documentElement.style.setProperty('--dynamic-hight', '0px');")
            end
        else
            ghtmlhud:RunJavascript("document.getElementById('speed').innerHTML ='0 u/s';")
            ghtmlhud:RunJavascript("document.documentElement.style.setProperty('--dynamic-hight', '0px');")
            ghtmlhud:RunJavascript([[
                setTimeout(function() {
                    document.querySelector('sp').style.opacity = 0;
                }, 40);
            ]])
        end

        ghtmlhud:RunJavascript("document.getElementById('playername').innerHTML ='".."❤️"..LocalPlayer():Health().." |🛡️"..LocalPlayer():Armor().."';")
        ghtmlhud:RunJavascript("document.getElementById('name').innerHTML ='"..LocalPlayer():SteamID().."';")
    
        local n = LocalPlayer():GetActiveWeapon()
        local n1 = ""
        local n2 = ""
    
        if IsValid(n) then
            n1 = LocalPlayer():GetActiveWeapon():GetPrintName()
            n2 = language.GetPhrase(LocalPlayer():GetActiveWeapon():GetClass())
            if string.find(n2,LocalPlayer():GetActiveWeapon():GetClass()) ~= nil then
                ghtmlhud:RunJavascript("document.getElementById('weapon_name').innerHTML ='"..n1.."';")
            else
                ghtmlhud:RunJavascript("document.getElementById('weapon_name').innerHTML ='"..n2.."';")
            end
        else
            ghtmlhud:RunJavascript("document.getElementById('weapon_name').innerHTML =' ';")
            return
        end

        if LocalPlayer():GetActiveWeapon():Clip1() > 0 then
            if LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()) ~= 0 then
                ghtmlhud:RunJavascript("document.getElementById('clip1').innerHTML ='"..LocalPlayer():GetActiveWeapon():Clip1().."/"..LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()).."  "..LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()).."';")
            else
                ghtmlhud:RunJavascript("document.getElementById('clip1').innerHTML ='"..LocalPlayer():GetActiveWeapon():Clip1().."/"..LocalPlayer():GetAmmoCount(LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()).."';")
            end
        else
            ghtmlhud:RunJavascript("document.getElementById('clip1').innerHTML ='';")
        end
    end
end
GHtmlHudLoadFunction()

hook.Add("HUDPaint", "GHtmlHud_RoundedBox", function()
    local plyh = LocalPlayer():Health()
    draw.RoundedBox(0, 0, ScrH()-70, ScrW(),100, Color(0,0,0,150))
    
    if plyh < 100 then
        draw.RoundedBox(0, 0, ScrH()-5, plyh*(ScrW()/100),5, Color(255 - plyh * 2.55,plyh * 2.55,0))
    end
end)