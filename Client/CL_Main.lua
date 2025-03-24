local QBCore = exports['qb-core']:GetCoreObject()
local cooldown = 0
local usingThirdEye = TDPD.Config.ThirdEye

lib.callback.register('td-policedesk:getStreetName', function(_, coords)
    if not coords then
        print('^1[td-policedesk] No coords received in callback.^0')
        return 'Unknown Location'
    end

    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash)
end)


RegisterNetEvent('td-policedesk:client:requestAssistance')
AddEventHandler('td-policedesk:client:requestAssistance', function()
    QBCore.Functions.TriggerCallback('tdpd:server:getCops', function(cops)
        if cops >= 1 then
            if cooldown ~= 0 then
                QBCore.Functions.Notify(TDPD.Config.PleaseWait, 'error')
            else
                TriggerServerEvent('tdpd:server:requestPD', '')
                QBCore.Functions.Notify(TDPD.Config.SuccessMessage, 'success')
                cooldown = TDPD.Config.RequestCooldown * 1000
                Citizen.SetTimeout(TDPD.Config.RequestCooldown * 1000, function()
                    cooldown = 0
                end)
            end
        else
            QBCore.Functions.Notify(TDPD.Config.FailureMessage, 'error')
        end
    end)
end)

RegisterNetEvent('td-policedesk:client:sendDispatch', function(data)
    local alert = {
        coords = data.coords,
        displayCode = "10-90",
        message = "Assistance Requested - Front Desk",
        description = string.format("Location: %s | A citizen is requesting assistance.", data.locationName or "Police Dept"),
        name = data.callerName, -- shown in dispatch
        callsign = "CIV",       -- optional tag to show up in dispatch list
        priority = 2,           -- 1 = High, 2 = Medium, 3 = Low
        recipientList = { "police" },
        blipSprite = 60,
        blipColour = 1,
        blipScale = 1.2,
        blipLength = 60,
        blipflash = true,
        radius = 0,
    }

    exports["ps-dispatch"]:CustomAlert(alert)
end)

CreateThread(function()
    setupTargetExport()

	while true do
        if not usingThirdEye then
            for key, value in pairs(TDPD.Config.Locations) do
                for name, coords in pairs (TDPD.Config.Locations[key]) do
                    local blipName = TDPD.Config.Locations[key].name
                    local blipCoords = TDPD.Config.Locations[key].coords

                    local ped = PlayerPedId()
                    local pos = GetEntityCoords(ped)
                    local dist = #(pos - blipCoords)
                    if dist < 15 then
                        if dist < 1.5 then
                            if cooldown == 0 then
                                TDPD.Utils.DrawText3Ds(blipCoords, TDPD.Config.PopupText)
                                if IsControlJustPressed(0, 38) then
                                    QBCore.Functions.TriggerCallback('tdpd:server:getCops', function(cops)
                                        if cops >= 1 then
                                            TriggerServerEvent('tdpd:server:requestPD', blipName)
                                            QBCore.Functions.Notify(TDPD.Config.SuccessMessage, 'success')
                                            cooldown = TDPD.Config.RequestCooldown * 1000
                                            Citizen.SetTimeout(TDPD.Config.RequestCooldown * 1000, function()
                                                cooldown = 0
                                            end)
                                        else
                                            QBCore.Functions.Notify(TDPD.Config.FailureMessage, 'error')
                                        end
                                    end)
                                end
                            else
                                TDPD.Utils.DrawText3Ds(blipCoords, TDPD.Config.PleaseWait)
                            end
                        end
                    end
                end
            end
        end

		Wait(0)
	end
end)

function setupTargetExport()
    if usingThirdEye then
        exports['qb-target']:AddBoxZone("MissionRowDutyClipboard", vector3(441.7989, -982.0529, 30.67834), 0.45, 0.35, {
            name = "MissionRowDutyClipboard",
            heading = 11.0,
            debugPoly = false,
            minZ = 30.77834,
            maxZ = 30.87834,
            }, {
                options = {
                    {
                        type = "client",
                        event = "td-policedesk:client:requestAssistance",
                        icon = "fas fa-clipboard",
                        label = "Request an officer",
                    },
                },
                distance = 2.5
            }
        )
    end
end
