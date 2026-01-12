--[[ 
    NEXO VANGUARD v12.0 - SUPRÊMACIE PRIVÉE
    MODULES : BYPASS + SILENT-AIM FREECAM + GHOST NOCLIP + GODMODE
    STATUS : INDÉTECTABLE
--]]

local _DB = { 
    [GetHashKey("ELITE-LIFE-S9A2-VX91")] = true, 
    [GetHashKey("ELITE-LIFE-KP07-NW22")] = true,
    [GetHashKey("ELITE-LIFE-ZB11-LQ54")] = true,
    [GetHashKey("ELITE-LIFE-RX88-BT00")] = true
}

local _AUTH, _OPEN = false, false
local freecam_on, noclip_on = false, false
local cam = nil
local speed = 0.5
local lastShotTick = 0

-- PALETTE NEXO PRESTIGE
local NexoColor = {255, 0, 150} -- Rose Cyber
local BgColor = {10, 10, 15, 230}

-- [[ FONCTIONS DE DESSIN ]]
local function DrawNexoRect(x, y, w, h, r, g, b, a) DrawRect(x, y, w, h, r, g, b, a) end
local function PlayMenuSound(s) PlaySoundFrontend(-1, s, "HUD_FRONTEND_DEFAULT_SOUNDSET", 1) end

-- [[ MODULE NOCLIP GHOST ]]
local function HandleNoclip()
    local ped = PlayerPedId()
    if noclip_on then
        local x,y,z = table.unpack(GetEntityCoords(ped))
        local dx, dy = 0, 0
        local h = GetEntityHeading(ped)
        if IsDisabledControlPressed(0, 32) then -- Z
            dx = dx - math.sin(math.rad(h)) * (speed * 2)
            dy = dy + math.cos(math.rad(h)) * (speed * 2)
        end
        if IsDisabledControlPressed(0, 33) then -- S
            dx = dx + math.sin(math.rad(h)) * (speed * 2)
            dy = dy - math.cos(math.rad(h)) * (speed * 2)
        end
        SetEntityCoordsNoOffset(ped, x+dx, y+dy, z, false, false, false)
        SetEntityCollision(ped, false, false)
    else
        SetEntityCollision(ped, true, true)
    end
end

-- [[ INTERFACE GRAPHIQUE ]]
function DrawNexoMenu()
    if _OPEN and _AUTH then
        -- Cadre de l'interface
        DrawNexoRect(0.12, 0.25, 0.16, 0.35, BgColor[1], BgColor[2], BgColor[3], BgColor[4])
        DrawNexoRect(0.041, 0.25, 0.002, 0.35, NexoColor[1], NexoColor[2], NexoColor[3], 255)
        
        -- Header Titre
        DrawNexoRect(0.12, 0.08, 0.16, 0.03, NexoColor[1], NexoColor[2], NexoColor[3], 200)
        SetTextFont(7)
        SetTextScale(0.4, 0.4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString("NEXO VANGUARD V12")
        DrawText(0.12, 0.065)

        local function DrawOpt(label, state, y, key)
            local status = state and "~g~ACTIVE" or "~r~OFF"
            SetTextFont(4)
            SetTextScale(0.28, 0.28)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(label .. " ["..key.."] : " .. status)
            DrawText(0.045, y)
        end

        DrawOpt("FREECAM SILENT-AIM", freecam_on, 0.13, "1")
        DrawOpt("GHOST NOCLIP", noclip_on, 0.17, "2")
        DrawOpt("GODMODE SILENT", GetPlayerInvincible(PlayerId()), 0.21, "3")
        
        -- Barre de Vitesse Flux
        SetTextFont(4)
        SetTextScale(0.22, 0.22)
        SetTextColour(200, 200, 200, 200)
        DrawText(0.045, 0.30)
        AddTextEntry("SP", "FLUX DE VITESSE : " .. string.format("%.1f", speed * 10))
        DrawText(0.045, 0.30)
        
        DrawNexoRect(0.12, 0.33, 0.14, 0.001, 255, 255, 255, 50)
        local speedW = (speed / 10.0) * 0.14
        DrawNexoRect(0.05 + (speedW/2), 0.33, speedW, 0.004, NexoColor[1], NexoColor[2], NexoColor[3], 255)
    end

    if freecam_on then
        -- Viseur de ta Freecam
        DrawRect(0.5, 0.5, 0.001, 0.015, NexoColor[1], NexoColor[2], NexoColor[3], 255)
        DrawRect(0.5, 0.5, 0.01, 0.001, NexoColor[1], NexoColor[2], NexoColor[3], 255)
    end
end

-- [[ BOUCLE DE CONTROLE ]]
Citizen.CreateThread(function()
    print("^5[NEXO] CHARGEMENT DU SYSTÈME V12 RÉUSSI. F10 POUR COMMENCER.^7")
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()

        -- Touche F10 : Login ou Ouverture
        if IsDisabledControlJustPressed(0, 57) or IsControlJustPressed(0, 57) then 
            if not _AUTH then
                PlayMenuSound("SELECT")
                AddTextEntry('NEXO', "ACCÈS SÉCURISÉ : ENTRER CLÉ")
                DisplayOnscreenKeyboard(1, "NEXO", "", "", "", "", "", 30)
                while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end
                local res = GetOnscreenKeyboardResult()
                if res and _DB[GetHashKey(res)] then 
                    _AUTH = true; _OPEN = true
                    print("^2[NEXO] CLÉ VALIDE. BIENVENUE.^7")
                else
                    print("^1[NEXO] CLÉ REFUSÉE.^7")
                end
            else
                _OPEN = not _OPEN
                PlayMenuSound(_OPEN and "SELECT" or "BACK")
            end
        end

        if _OPEN and _AUTH then
            -- Option 1 : Freecam
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

            -- Option 2 : Noclip
            if IsDisabledControlJustPressed(0, 158) then
                noclip_on = not noclip_on
                PlayMenuSound("Toggle_On")
            end

            -- Option 3 : Godmode
            if IsDisabledControlJustPressed(0, 160) then
                local st = not GetPlayerInvincible(PlayerId())
                SetPlayerInvincible(PlayerId(), st)
                PlayMenuSound("Toggle_On")
            end
        end

        -- LOGIQUE DE LA CAMÉRA (Ton code Freecam intégré)
        if freecam_on and cam then
            local rot = GetCamRot(cam, 2)
            local lookX, lookY = GetDisabledControlNormal(0, 1), GetDisabledControlNormal(0, 2)
            SetCamRot(cam, rot.x + (lookY * -10.0), 0.0, rot.z + (lookX * -10.0), 2)

            local coords = GetCamCoord(cam)
            local rz, rx = math.rad(rot.z), math.rad(rot.x)
            local fwd = vector3(-math.sin(rz) * math.abs(math.cos(rx)), math.cos(rz) * math.abs(math.cos(rx)), math.sin(rx))

            if IsDisabledControlPressed(0, 32) then coords = coords + (fwd * speed) end
            if IsDisabledControlPressed(0, 33) then coords = coords - (fwd * speed) end
            
            -- Vitesse avec la molette
            if IsDisabledControlPressed(0, 15) then speed = math.min(speed + 0.1, 10.0) end
            if IsDisabledControlPressed(0, 14) then speed = math.max(speed - 0.1, 0.05) end

            SetCamCoord(cam, coords.x, coords.y, coords.z)
            SetFocusPosAndVel(coords.x, coords.y, coords.z, 0.0, 0.0, 0.0)

            -- TIR AUTOMATIQUE (Silent Aim de ton code)
            if IsDisabledControlPressed(0, 24) then 
                local t = GetGameTimer()
                if (t - lastShotTick) > 400 then 
                    local w = GetSelectedPedWeapon(ped)
                    ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z, coords.x + (fwd.x * 250.0), coords.y + (fwd.y * 250.0), coords.z + (fwd.z * 250.0), 25, true, w, ped, true, false, -1.0)
                    lastShotTick = t
                end
            end
            -- Bloquer les contrôles du joueur quand on est en Freecam
            for i = 0, 360 do if i ~= 57 then DisableControlAction(0, i, true) end end
        end

        if noclip_on then HandleNoclip() end
        DrawNexoMenu()
    end
end)
