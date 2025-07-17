print("Script started")
print("PlaceId:", game.PlaceId)

local allowedPlaceIds = {
    [96342491571673] = true,
    [109983668079237] = true,
}

if allowedPlaceIds[game.PlaceId] and not _G._hasRunRejoinStuff then
    print("Correct place detected")
    _G._hasRunRejoinStuff = true

    task.spawn(function()
        print("Loading Luarmor loader")
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/235288a4bbf8909104e7285d3f3dbad3.lua"))()
        end)
        if not ok then warn("Luarmor error:", err) end
    end)

    task.spawn(function()
        print("Loading Rejoin Button")
        local success, result = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/w4luvv/rejoin-button/refs/heads/main/main.lua")
        end)

        if success and result then
            loadstring(result)()
        else
            warn("Failed to load rejoin button script:", result)
        end
    end)
else
    warn("Wrong PlaceId or already ran")
end
