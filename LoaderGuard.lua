--[[
    MODULE : LoaderGuard.lua
    LOGIQUE : Protected External Loading (pcall encapsulation)
]]

local function SafeLoadExternal(url, moduleName)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success and result then
        local loadSuccess, loadError = pcall(function()
            loadstring(result)()
        end)
        
        if not loadSuccess then
            warn("⚠️ [OMNI] Erreur d'exécution dans " .. moduleName .. " : " .. tostring(loadError))
        end
    else
        -- Avertissement propre sans crash
        warn("🚫 [OMNI] Source indisponible pour " .. moduleName .. " (Erreur réseau ou 404)")
        
        -- Optionnel : Charger une interface de secours locale ici
        -- LoadBackupUI()
    end
end

-- Exemple : SafeLoadExternal("https://api.site.com/script", "MainModule")