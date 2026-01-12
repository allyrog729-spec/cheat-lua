-- [[ NEXO GHOST-BYPASS - DEBUG VERSION ]]
print("^2[NEXO] LE SCRIPT EST CHARGÉ ! APPUIE SUR F10 MAINTENANT.^7")

local _DB = {
    [GetHashKey("ELITE-LIFE-S9A2-VX91")] = true,
    [GetHashKey("ELITE-LIFE-KP07-NW22")] = true,
    [GetHashKey("ELITE-LIFE-ZB11-LQ54")] = true,
    [GetHashKey("ELITE-LIFE-RX88-BT00")] = true
}

local _AUTH, _OPEN = false, false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        -- On teste F10 (57) ET F9 (56) au cas où
        if IsControlJustPressed(0, 57) or IsDisabledControlJustPressed(0, 57) or IsControlJustPressed(0, 56) then
            print("^3[NEXO] Touche détectée !^7")
            
            if not _AUTH then
                -- On lance la connexion
                AddTextEntry('NEXO_SECURE', "SYSTÈME NEXO : ENTRER CLÉ")
                DisplayOnscreenKeyboard(1, "NEXO_SECURE", "", "", "", "", "", 30)
                
                while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(0) end
                
                local res = GetOnscreenKeyboardResult()
                if res and _DB[GetHashKey(res)] then
                    _AUTH = true
                    _OPEN = true
                    PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 1)
                else
                    print("^1[NEXO] Clé invalide.^7")
                end
            else
                _OPEN = not _OPEN
            end
        end

        if _OPEN and _AUTH then
            -- Rendu du menu
            DrawRect(0.5, 0.45, 0.22, 0.5, 5, 5, 5, 240)
            DrawRect(0.5, 0.20, 0.22, 0.002, 0, 255, 200, 255)
            
            SetTextFont(7)
            SetTextScale(0.55, 0.55)
            SetTextColour(0, 255, 200, 255)
            SetTextCentre(true)
            SetTextEntry("STRING")
            AddTextComponentString("NEXO V6")
            DrawText(0.5, 0.21)
            
            -- Bloquer les contrôles pour pouvoir naviguer
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
        end
    end
end)
