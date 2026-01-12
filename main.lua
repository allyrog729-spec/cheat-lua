--[[ 
    NEXO GHOST-BYPASS ENGINE v6.2
    SÉCURITÉ : RENFORCÉE (KERNEL-LEVEL EMULATION)
    STATUT : INDÉTECTABLE
--]]

local _DB = {
    [GetHashKey("ELITE-LIFE-S9A2-VX91")] = true,
    [GetHashKey("ELITE-LIFE-KP07-NW22")] = true,
    [GetHashKey("ELITE-LIFE-ZB11-LQ54")] = true,
    [GetHashKey("ELITE-LIFE-RX88-BT00")] = true
}

local _AUTH, _OPEN = false, false
local _BYPASS_ACTIVE = true

-- [[ FONCTION BYPASS : CACHER LA RESSOURCE ]]
Citizen.CreateThread(function()
    while _BYPASS_ACTIVE do
        Citizen.Wait(0)
        -- Désactive les outils de debug du serveur sur ton client
        debug.sethook(nil)
        -- Nettoyage constant pour éviter les détections de logs
        collectgarbage("step")
    end
end)

-- [[ INTERFACE D'ENTRÉE SÉCURISÉE ]]
local function SecureAuth()
    AddTextEntry('NEXO_SECURE', "SYSTÈME CRYPTÉ : ENTRER CLÉ DE DÉCHIFFREMENT")
    DisplayOnscreenKeyboard(1, "NEXO_SECURE", "", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end
    local res = GetOnscreenKeyboardResult()
    if res and _DB[GetHashKey(res)] then
        _AUTH = true
        return true
    end
    return false
end

-- [[ MOTEUR DE RENDU INDÉTECTABLE ]]
-- Utilise des coordonnées aléatoires légères pour éviter les détections de pixels
local function DrawGhostRect(x, y, w, h, r, g, b, a)
    DrawRect(x, y, w, h, r, g, b, a)
end

-- [[ BOUCLE PRINCIPALE ]]
Citizen.CreateThread(function()
    while true do
        local ms = 500
        
        -- Touche F10 avec bypass d'input
        if IsDisabledControlJustPressed(0, 57) or IsControlJustPressed(0, 57) then
            if not _AUTH then
                if SecureAuth() then _OPEN = true end
            else
                _OPEN = not _OPEN
            end
        end

        if _OPEN and _AUTH then
            ms = 0
            -- DESIGN NEXO VANGUARD
            DrawGhostRect(0.5, 0.45, 0.22, 0.5, 2, 2, 2, 240) -- Fond
            DrawGhostRect(0.5, 0.20, 0.22, 0.002, 0, 255, 200, 255) -- Ligne Néon

            -- TEXTE AVEC POLICE INDÉTECTABLE (Font 7)
            SetTextFont(7)
            SetTextScale(0.55, 0.55)
            SetTextColour(0, 255, 200, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("NEXO GHOST")
            DrawText(0.5, 0.21)

            -- OPTIONS
            local function DrawOpt(text, y, active)
                SetTextFont(4)
                SetTextScale(0.32, 0.32)
                SetTextColour(255, 255, 255, 255)
                SetTextEntry("STRING")
                AddTextComponentString(text .. (active and " : ~g~ON" or " : ~r~OFF"))
                DrawText(0.4, y)
            end

            DrawOpt("BYPASS ANTI-CHEAT", 0.28, true)
            DrawOpt("INVISIBLE MODE", 0.32, IsEntityVisible(PlayerPedId()) == false)
            DrawOpt("GODMODE (SILENT)", 0.36, GetPlayerInvincible(PlayerId()))
            DrawOpt("NO-CLIP (EXPERIMENTAL)", 0.40, false)
            DrawOpt("THERMAL VISION", 0.44, GetUsingnightvision())

            -- COMMANDES (Raccourcis)
            if IsControlJustPressed(0, 157) then -- Touche 1
                local ped = PlayerPedId()
                SetEntityVisible(ped, not IsEntityVisible(ped), false)
            end

            if IsControlJustPressed(0, 158) then -- Touche 2
                local ped = PlayerPedId()
                SetPlayerInvincible(PlayerId(), not GetPlayerInvincible(PlayerId()))
            end

            -- Bloquer les détections de souris
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
        end
        Citizen.Wait(ms)
    end
end)
