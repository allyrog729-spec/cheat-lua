--[[ 
    NEXO VANGUARD v10.0 - SUPRÉMACIE FINALE
    MODULES : BYPASS + SILENT-AIM FREECAM + GHOST NOCLIP
--]]

local _DB = { [GetHashKey("ELITE-LIFE-S9A2-VX91")] = true, [GetHashKey("ELITE-LIFE-KP07-NW22")] = true }
local _AUTH, _OPEN = false, false
local freecam_on, noclip_on = false, false
local cam = nil
local speed = 0.5
local lastShotTick = 0

-- PALETTE NEXO PRESTIGE
local NexoColor = {255, 0, 150} 
local BgColor = {10, 10, 15, 230}

local function DrawNexoRect(x, y, w, h, r, g, b, a) DrawRect(x, y, w, h, r, g, b, a) end
local function PlayMenuSound(s) PlaySoundFrontend(-1, s, "HUD_FRONTEND_DEFAULT_SOUNDSET", 1) end

-- [[ MODULE NOCLIP GHOST ]]
local function HandleNoclip()
    local ped = PlayerPedId()
    if noclip_on then
        local x,y,z = table.unpack(GetEntityCoords(ped))
        local dx, dy = 0, 0
        if IsControlPressed(0, 32) then -- Z
            local h = GetEntityHeading(ped)
            dx = dx - math.sin(math.rad(h)) * 1.2
            dy = dy + math.cos(math.rad(h)) * 1.2
        end
        SetEntityCoordsNoOffset(ped, x+dx, y+dy, z, false, false, false)
        SetEntityCollision(ped, false, false)
    else
        SetEntityCollision(ped, true, true)
    end
end

-- [[ INTERFACE NEXO CENTRALISÉE ]]
function DrawNexoMenu()
    if _OPEN and _AUTH then
        -- Cadre Principal
        DrawNexoRect(0.12, 0.25, 0.16, 0.30, BgColor[1], BgColor[2], BgColor[3], BgColor[4])
        DrawNexoRect(0.041, 0.25, 0.002, 0.30, NexoColor[1], NexoColor[2], NexoColor[3], 255)
        
        -- Header
        DrawNexoRect(0.12, 0.10, 0.16, 0.025, NexoColor[1], NexoColor[2], NexoColor[3], 200)
        SetTextFont(7)
        SetTextScale(0.38, 0.38)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString("NEXO VANGUARD V10")
        DrawText(0.12, 0.088)

        local function DrawTechOpt(label, state, y, key)
            local status = state and "~g~ON" or "~r~OFF"
            SetTextFont(4)
            SetTextScale(0.26, 0.26)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(label .. " ["..key.."] : " .. status)
            DrawText(0.045, y)
        end

        DrawTechOpt("SILENT-AIM FREECAM", freecam_on, 0.14, "1")
        DrawTechOpt("GHOST NOCLIP", noclip_on, 0.17, "2")
        DrawTechOpt("GODMODE INVISIBLE", GetPlayerInvincible(PlayerId()), 0.20, "3")
        
        -- Barre de Flux (Vitesse)
        DrawNexoRect(0.12, 0.35, 0.14, 0.001, 255, 255, 255, 50)
        local speedW = (speed / 10.0) * 0.14
        DrawNexoRect(0.05 + (speedW/2), 0.35, speedW, 0.003, NexoColor[1], NexoColor[2], NexoColor[3], 255)
    end

    if freecam_on then
        -- Viseur Target
        DrawRect(0.5, 0.5, 0.001, 0.012, NexoColor[1], NexoColor[2], NexoColor[3], 255)
        DrawRect(0.5, 0.5, 0.007, 0.001, NexoColor[1], NexoColor[2], NexoColor[3], 255)
    end
end

-- [[ LOGIQUE PRINCIPALE ]]
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        -- F10 Login/Menu
        if IsDisabledControlJustPressed(0, 57) then 
            if not _AUTH then
                AddTextEntry('NEXO', "SYSTEM LOGIN : ENTRER CLÉ")
                DisplayOnscreenKeyboard(1, "NEXO", "", "", "", "", "", 30)
                while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end
                local res = GetOnscreenKeyboardResult()
                if res and _DB[GetHashKey(res)] then _AUTH = true; _OPEN = true; PlayMenuSound("SELECT") end
            else
                _OPEN = not _OPEN
                PlayMenuSound(_OPEN and "SELECT" or "BACK")
            end
        end

        if _OPEN and _AUTH then
            -- Touche 1 : Freecam
            if IsDisabledControlJustPressed(0, 157) then
                freecam_on = not freecam_on
                if freecam_on then
                    local pC = GetEntityCoords(ped)
                    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                    SetCamCoord(cam, pC.x, pC.y, pC.z + 1.2)
                    SetCamRot(cam, GetGameplayCamRot(2), 2)
                    SetCamActive(cam, true)
                    RenderScriptCams(true, true, 800, true, true)
                else
                    RenderScriptCams(false, true, 800, true, true)
                    DestroyCam(cam, false)
                    ClearPedTasks(ped)
                end
                PlayMenuSound("Toggle_On")
            end

            -- Touche 2 : Noclip
            if IsDisabledControlJustPressed(0, 158) then
                noclip_on = not noclip_on
                PlayMenuSound("Toggle_On")
            end
        end

        -- Caméra & Silent Aim Logic
        if freecam_on and cam then
            local rot = GetCamRot(cam, 2)
            local lookX, lookY = GetDisabledControlNormal(0, 1), GetDisabledControlNormal(0, 2)
            SetCamRot(cam, rot.x + (lookY * -10.0), 0.0, rot.z + (lookX * -10.0), 2)

            local coords = GetCamCoord(cam)
            local rz, rx = math.rad(rot.z), math.rad(rot.x)
            local fwd = vector3(-math.sin(rz) * math.abs(math.cos(rx)), math.cos(rz) * math.abs(math.cos(rx)), math.sin(rx))

            if IsDisabledControlPressed(0, 32) then coords = coords + (fwd * speed) end
            if IsDisabledControlPressed(0, 33) then coords = coords - (fwd * speed) end
            SetCamCoord(cam, coords.x, coords.y, coords.z)
            SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)

            -- Tir Silent Aim
            if IsDisabledControlPressed(0, 24) then 
                local t = GetGameTimer()
                if (t - lastShotTick) > 450 then 
                    local w = GetSelectedPedWeapon(ped)
                    ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, coords.x + (fwd.x * 200.0), coords.y + (fwd.y * 200.0), coords.z + (fwd.z * 200.0), 25, true, w, ped, true, false, -1.0)
                    lastShotTick = t
                end
            end
            for i = 0, 360 do if i ~= 57 then DisableControlAction(0, i, true) end end
        end

        if noclip_on then HandleNoclip() end
        DrawNexoMenu()
    end
end)
