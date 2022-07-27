local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-repair:costRepair', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.RemoveMoney('bank', Config.Money, "repair-bill")
        TriggerEvent('qb-bossmenu:server:addAccountMoney', 'mechanic', Config.Money)
        TriggerClientEvent('QBCore:Notify', src, 'Repair Done!!', 'success')
end)

QBCore.Functions.CreateCallback('qb-repair:mechanic', function(source,cb)
	local xPlayers = QBCore.Functions.GetPlayers()
	local mechanic = 0
    local state = false

    for i=1, #xPlayers, 1 do
		local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
		if xPlayer.PlayerData.job.name == 'mechanic' then
			mechanic = mechanic + 1
		end
	end
    if mechanic > Config.Mechanic then
        state = false
    else
        state = true
    end
    cb(state)
end)