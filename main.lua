-- [[ NEXO VANGUARD ELITE - V3.3 FINAL ]]
local menu_open, freecam_on, is_authenticated = false, false, false
local cam, lastShotTick, speed = nil, 0, 0.5

-- [[ BASE DE DONNEES DES CLES ]]
local access_keys = {
    ["nexo-free-123"] = true,
    ["elite-life-s9a2-vx91"] = true,
    ["elite-life-kp07-nw22"] = true,
    ["admin"] = true
}

-- STYLE VISUEL "DIAMOND"
local NexoBaseColor = {255, 0, 150} 
local BgColor = {15, 15, 20, 245} 
local BorderColor = {255, 0, 200, 255} 

local function DrawRectPro(x, y, w, h, r, g, b, a) DrawRect(x, y, w, h, r, g, b, a) end
local function PlayMenuSound(s) PlaySoundFrontend(-1, s, "HUD_FRONTEND_DEFAULT_SOUNDSET", 1) end

-- [[ SYSTEME DE SAUVEGARDE (KVP) ]]
local function SaveKeyLocally(key) SetResourceKvp("nexo_auth_key", key) end
local function GetSavedKey() return GetResourceKvpString("nexo_auth_key") end

-- Vérification automatique au lancement
Citizen.CreateThread(function()
    local saved = GetSavedKey()
    if saved and access_keys[string.lower(saved)] then
        is_authenticated = true
        print("^2[NEXO] Licence reconnue automatiquement.^7")
    end
end)

function DrawNexoMenu()
    if menu_open and is_authenticated then
        -- CADRE PRINCIPAL CARRÉ
        local menuX, menuY, menuW, menuH = 0.13, 0.25, 0.18, 0.35
        DrawRectPro(menuX, menuY, menuW, menuH, BgColor[1], BgColor[2], BgColor[3], BgColor[4])

        -- BORDURES LUMINEUSES (DIAMOND)
        DrawRectPro(menuX, menuY - (menuH/2), menuW, 0.002, BorderColor[1], BorderColor[2], BorderColor[3], 255)
        DrawRectPro(menuX, menuY + (menuH/2), menuW, 0.002, BorderColor[1], BorderColor[2], BorderColor[3], 255)
        DrawRectPro(menuX - (menuW/2), menuY, 0.002, menuH, BorderColor[1], BorderColor[2], BorderColor[3], 255)
        DrawRectPro(menuX + (menuW/2), menuY, 0.002, menuH, BorderColor[1], BorderColor[2], BorderColor[3], 255)

        -- TITRE NEXO ELITE
        SetTextFont(7); SetTextScale(0.45, 0.45); SetTextColour(255, 255, 255, 255)
        SetTextCentre(true); SetTextEntry("STRING"); AddTextComponentString("NEXO ELITE CAM"); DrawText(menuX, menuY - (menuH/2) + 0.02)
        DrawRectPro(menuX, menuY - (menuH/2) + 0.045, menuW * 0.8, 0.001, 255, 50, 200, 150)

        -- OPTIONS
        local function DrawOption(label, key, y, status)
            SetTextFont(4); SetTextScale(0.3, 0.3); SetTextColour(220, 220, 220, 255)
            SetTextEntry("STRING"); AddTextComponentString(label .. " : " .. (status or ""))
            DrawText(menuX - (menuW/2) + 0.02, y)

            SetTextFont(4); SetTextScale(0.25, 0.25); SetTextColour(NexoBaseColor[1], NexoBaseColor[2], NexoBaseColor[3], 255)
            SetTextRightJustify(true); SetTextWrap(0.0, menuX + (menuW/2) - 0.02)
            SetTextEntry("STRING"); AddTextComponentString("[" .. key .. "]")
            DrawText(menuX + (menuW/2) - 0.02, y)
        end

        local startY = menuY - 0.08
        DrawOption("FREECAM", "1", startY, freecam_on and "~g~ACTIVE" or "~r~OFF")
        DrawOption("VITESSE", "MOL", startY + 0.04, string.format("%.1f", speed * 10))
        
        -- FOOTER
        SetTextFont(0); SetTextScale(0.2, 0.2); SetTextColour(150, 150, 150, 200); SetTextCentre(true)
        SetTextEntry("STRING"); AddTextComponentString("NEXO VANGUARD | LICENCE ACTIVE"); DrawText(menuX, menuY + (menuH/2) - 0.02)
    end

    if freecam_on then
        -- VISEUR D'ORIGINE
        DrawRectPro(0.5, 0.5, 0.001, 0.012, NexoBaseColor[1], NexoBaseColor[2], NexoBaseColor[3], 255)
        DrawRectPro(0.5, 0.5, 0.007, 0.001, NexoBaseColor[1], NexoBaseColor[2], NexoBaseColor[3], 255)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        -- TOUCHE F10 (IDENTIFICATION + OUVERTURE)
        if IsControlJustPressed(0, 57) or IsDisabledControlJustPressed(0, 57) then 
            if not is_authenticated then
                AddTextEntry('K', "CLE PRIVEE :")
                DisplayOnscreenKeyboard(1, "K", "", "", "", "", "", 30)
                while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end
                local res = GetOnscreenKeyboardResult()
                if res and access_keys[string.lower(res)] then 
                    is_authenticated = true; menu_open = true
                    SaveKeyLocally(res) -- On s'en souvient pour après le reboot
                    PlayMenuSound("SELECT") 
                else
                    PlayMenuSound("BACK")
                end
            else
                menu_open = not menu_open; PlayMenuSound("SELECT")
            end
        end

        if is_authenticated and menu_open then
            if IsDisabledControlJustPressed(0, 157) then -- Touche 1
                freecam_on = not freecam_on
                if freecam_on then
                    local pC = GetEntityCoords(ped)
                    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                    SetCamCoord(cam, pC.x, pC.y, pC.z + 1.2); SetCamRot(cam, GetGameplayCamRot(2), 2)
                    SetCamActive(cam, true); RenderScriptCams(true, true, 800, true, true)
                    TaskStandStill(ped, -1)
                else
                    RenderScriptCams(false, true, 800, true, true); DestroyCam(cam, false); cam = nil; ClearPedTasks(ped)
                end
                PlayMenuSound("Toggle_On")
            end
        end

        -- LOGIQUE DE MOUVEMENT (TES PARAMETRES)
        if freecam_on and cam then
            local rot = GetCamRot(cam, 2)
            local lookX, lookY = GetDisabledControlNormal(0, 1), GetDisabledControlNormal(0, 2)
            SetCamRot(cam, rot.x + (lookY * -10.0), 0.0, rot.z + (lookX * -10.0), 2)
            local coords = GetCamCoord(cam)
            local rz, rx = math.rad(rot.z), math.rad(rot.x)
            local fwd = vector3(-math.sin(rz)*math.abs(math.cos(rx)), math.cos(rz)*math.abs(math.cos(rx)), math.sin(rx))
            local rgt = vector3(math.cos(rz), math.sin(rz), 0)

            if IsDisabledControlPressed(0, 15) then speed = math.min(speed + 0.1, 10.0) end
            if IsDisabledControlPressed(0, 14) then speed = math.max(speed - 0.1, 0.05) end
            
            -- MOUVEMENTS ZQSD
            if IsDisabledControlPressed(0, 32) then coords = coords + (fwd * speed) end -- Z
            if IsDisabledControlPressed(0, 33) then coords = coords - (fwd * speed) end -- S
            if IsDisabledControlPressed(0, 34) then coords = coords - (rgt * speed) end -- Q
            if IsDisabledControlPressed(0, 35) then coords = coords + (rgt * speed) end -- D

            SetCamCoord(cam, coords.x, coords.y, coords.z)
            SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)

            -- TIR AUTOMATIQUE (TES PARAMETRES)
            if IsDisabledControlPressed(0, 24) then 
                local t = GetGameTimer()
                if (t - lastShotTick) > 450 then 
                    local w = GetSelectedPedWeapon(ped)
                    if w ~= `WEAPON_UNARMED` then
                        ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, coords.x + (fwd.x * 250.0), coords.y + (fwd.y * 250.0), coords.z + (fwd.z * 250.0), 25, true, w, ped, true, false, -1.0)
                        lastShotTick = t
                    end
                end
            end
            for i = 0, 360 do if i ~= 57 then DisableControlAction(0, i, true) end end
        end
        DrawNexoMenu()
    end
end)
