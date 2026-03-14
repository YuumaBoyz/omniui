--[[
    FICHIER : OmniSaveManager.lua
    UTILITÉ : Gestionnaire de configuration (JSON)
    SYSTÈME : Sauvegarde automatique sur le client
]]

local HttpService = game:GetService("HttpService")
local SaveManager = {}
local FILE_NAME = "OmniElite_Config.json"

-- [ SAUVEGARDE ] -- 💾
function SaveManager:Save(data)
    local success, err = pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        writefile(FILE_NAME, jsonData)
    end)
    
    if not success then
        warn("❌ [OMNI-SAVE] : Erreur lors de la sauvegarde -> " .. tostring(err))
    end
end

-- [ CHARGEMENT ] -- 📂
function SaveManager:Load()
    if not isfile(FILE_NAME) then 
        print("ℹ️ [OMNI-SAVE] : Aucun fichier de config trouvé, création d'une base.")
        return nil 
    end

    local success, result = pcall(function()
        local fileContent = readfile(FILE_NAME)
        return HttpService:JSONDecode(fileContent)
    end)

    if success then
        print("✅ [OMNI-SAVE] : Configuration chargée avec succès.")
        return result
    else
        warn("❌ [OMNI-SAVE] : Fichier corrompu, réinitialisation...")
        return nil
    end
end

_G.SaveManager = SaveManager
return SaveManager