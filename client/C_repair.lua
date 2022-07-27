local QBCore = exports['qb-core']:GetCoreObject()
local pedSpawned = false
local entity = {}

local function createBlips()
    if Config.Blips then
        for k, v in pairs(Config.VehicleRepairLocation) do
            local Rep = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(Rep, 446)
            SetBlipAsShortRange(Rep, true)
            SetBlipScale(Rep, 0.8)
            SetBlipColour(Rep, 59)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Name)
            EndTextCommandSetBlipName(Rep)
        end
    end
end

RegisterNetEvent('qb-repair:fixCarS', function()
    if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
        QBCore.Functions.TriggerCallback('qb-repair:mechanic', function(mechanic)
            if mechanic then
                TriggerEvent('qb-repair:fixCar')
            else
                QBCore.Functions.Notify("There is too many mechanics online", "error")
            end
        end)
    else
        QBCore.Functions.Notify("You are not in a vehicle", "error")
    end
end)



RegisterNetEvent('qb-repair:fixCar', function()
	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	FreezeEntityPosition(vehicle, true)
    TriggerEvent('animations:client:EmoteCommandStart', {"jcarlowrider2"})
    QBCore.Functions.Progressbar("jcarlowrider2", "Repairing", Config.RepairTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
    }, {}, {}, {}, function()
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        TriggerServerEvent('qb-repair:costRepair')
        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'airwrench', 0.4)
        SetVehicleDeformationFixed(vehicle)
        FreezeEntityPosition(vehicle, false)
        SetVehicleEngineHealth(vehicle, 9999)
        SetVehiclePetrolTankHealth(vehicle, 9999)
        SetVehicleFixed(vehicle)
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        QBCore.Functions.Notify('Cancelled preparing equipement', 'error')
    end)

end)

local function createPeds()
    if pedSpawned then return end
    for k, v in pairs(Config.VehicleRepairLocation) do
        local model = "s_m_y_armymech_01"
        RequestModel(model)
        while not HasModelLoaded(model) do
          Wait(0)
        end
        entity[k] = CreatePed(0, model, vector4(v.coords.x, v.coords.y, v.coords.z-0.9,v.Heading), false, false)
        TaskStartScenarioInPlace(entity[k], "WORLD_HUMAN_CLIPBOARD_FACILITY", true)
        FreezeEntityPosition(entity[k], true)
        SetEntityInvincible(entity[k], true)
        SetBlockingOfNonTemporaryEvents(entity[k], true)
 
        exports['qb-target']:AddTargetEntity(entity[k], {
            options = {
            {
                type = "client",
                event = "qb-repair:fixCarS",
                icon = 'fas fa-example',
                label = 'Repair Vehicle',
            }
            },
            distance = 3.5,
        })
    end
    pedSpawned = true
end

local function deletePeds()
    if pedSpawned then
        for _, v in pairs(entity) do
            DeletePed(v)
        end
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createBlips()
    createPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deletePeds()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        createBlips()
        createPeds()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        deletePeds()
    end
end)