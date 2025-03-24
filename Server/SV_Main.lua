local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('tdpd:server:getCops', function(source, cb)
	amount = 0
    for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if TDPD.Utils.hasJob(v.PlayerData.job.name) and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)

RegisterServerEvent('tdpd:server:requestPD')
AddEventHandler('tdpd:server:requestPD', function(blipName)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local playerData = player.PlayerData
    local callerName = ("%s %s"):format(playerData.charinfo.firstname, playerData.charinfo.lastname)

    local location = TDPD.Config.Locations[1]
    local coords = location.coords

    -- Move dispatch trigger to client
    TriggerClientEvent("td-policedesk:client:sendDispatch", src, {
        callerName = callerName,
        locationName = location.name,
        coords = coords
    })
end)
