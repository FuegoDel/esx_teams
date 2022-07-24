local CreationNpc = nil
local CreationBlip = nil
local PlayerData = nil

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerData = ESX.GetPlayerData()

	SetupNpc()
end)

Citizen.CreateThread(function ()
	while PlayerData == nil do
		Wait(1000)
	end
	while true do
		Wait(2)
		if isClientInTeam(PlayerData.job.name) then
			if IsControlJustReleased(0,Config.MenuKey) then
				SetNuiFocus(true,true)
				SendNUIMessage({
					action = 'teammenu',
					teamData = {
						level = getClientTeamLevel(PlayerData.job.name),
						experience = getClientTeamExperience(PlayerData.job.name),
						maxExperience = Config.TeamSettings.MaxLevelXp[tonumber(getClientTeamLevel(PlayerData.job.name))],
						maxLevel = #Config.TeamSettings.MaxLevelXp,
						teamName = PlayerData.job.label,
					}
				})
			end
		else
			Wait(3000)
		end
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_teams:ActivatePrivilages')
AddEventHandler('esx_teams:ActivatePrivilages', function (myPrivilages) --That is just an example please dont write so bad code
    local privilageFound = false

	for k,v in pairs(myPrivilages)do
		if v == true then
			privilageFound = true
		end
	end

	if not privilageFound then
		return
	end

	if myPrivilages['stamina'] then
		activateUnlimitedStamina()
	end

	if myPrivilages['healthreg'] then
		activateHealthRegen()
	end

	if myPrivilages['vestreg'] then
		activateVestRegen()
	end
	
end)

RegisterNetEvent('esx_teams:receivedInvitation')
AddEventHandler('esx_teams:receivedInvitation', function (jobName,jobLabel)
	ESX.UI.Menu.CloseAll()
	ESX.ShowNotification('You have been invited to '..jobLabel)
    elements = {
		{label = 'Accept Invitation', value = 'accept'},
		{label = 'Decline Invitation', value = 'decline'}
	}
	ESX.UI.Menu.Open('default',GetCurrentResourceName(),'invitation_menu',{
        title = 'Invited to '..jobLabel,
		align = 'right',
		elements = elements
	}, function (data,menu)
		TriggerServerEvent('esx_teams:answerInvitation',data.current.value)
		ESX.UI.Menu.CloseAll()
	end)
end)

RegisterNUICallback('leaveTeam', function (data,cb)
	Wait(500)
	TriggerServerEvent('esx_teams:onMemberLeave')
end)

RegisterNUICallback('onMemberAction', function (data,cb)
	Wait(500)
	TriggerServerEvent('esx_teams:onMemberAction',data.object.targetId,data.object.action)
end)

RegisterNUICallback('onMemberInvite', function (data,cb)
	Wait(500)
	TriggerServerEvent('esx_teams:onMemberInvite',data.targetId)
end)

RegisterNUICallback('GetClosestPlayers', function ()
	Wait(800)

	SendNUIMessage({
		action = 'ClosePlayers',
		closePlayers = getClosePlayers()
	})

end)

RegisterNUICallback('onTeamUpgrade', function (data,cb)
	Wait(500)
	TriggerServerEvent('esx_teams:onTeamUpgrade',PlayerData.job.name)
end)

RegisterNUICallback('onTeamDelete', function (data,cb)
	Wait(500)
	TriggerServerEvent('esx_teams:onTeamDelete',PlayerData.job.name)
end)

RegisterNUICallback('onBuyingPrivilage', function (data,cb)
	Wait(500)
	TriggerServerEvent('esx_teams:onBuyingPrivilage',data.privilage,PlayerData.job.name)
end)

RegisterNUICallback('GetTeamPrivilages', function (data,cb)
	ESX.TriggerServerCallback('esx_teams:getPrivilages', function (privilages)
		Wait(500)
		SendNUIMessage({
			action = 'teamPrivilages',
			privilages = privilages
		})
	end, PlayerData.job.name)
end)

RegisterNUICallback('GetTeamMembers', function (data,cb)
	ESX.TriggerServerCallback('esx_teams:getOnlineTeamMembers', function(members,isBoss)

		if not isBoss then
			ESX.ShowNotification('You dont have access to this feature')
			return
		end

		Wait(500) 
		SendNUIMessage({
			action = 'teamMembers',
			teamMembers = members,
			gradeIcons = Config.Icons
		})

	end, PlayerData.job.name)
end)

RegisterNUICallback('onTeamCreation', function (data,cb)

	Wait(500)

	local teamName = data.teamName

	TriggerServerEvent('esx_teams:onTeamCreation', data.teamName)
end)

RegisterNUICallback('closeMenu', function ()
	SetNuiFocus(false,false)
end)

function SetupNpc()
	CreationNpc = CreateNPC(Config.NPC.Model, Config.NPC.Coords, Config.NPC.Heading)
	if Config.NPC.UsesBlip then
		CreateBlip(Config.NPC.Coords,Config.NPC.BlipName,Config.NPC.BlipSprite,Config.NPC.BlipColour)
	end
	StartCreationThread()
end

function StartCreationThread()
	while CreationNpc == nil do
		Wait(500)
	end

	Citizen.CreateThread(function ()
		while true do
			Wait(2)
			local coords = GetEntityCoords(PlayerPedId())
			local tCoords = GetEntityCoords(CreationNpc)
			local dist = #(coords - tCoords)
			if dist < Config.NPC.DrawingDistance then
				if Config.NPC.UsesDrawText then
					DrawText3D(tCoords.x,tCoords.y,tCoords.z,Config.NPC.DrawingNotification)
				end
				if Config.NPC.UsesHelpNotification then
					ESX.ShowHelpNotification(Config.NPC.DrawingNotification)
				end
				if IsControlJustReleased(0,38) and dist < 2.0 then
					OpenMenu('creation')
				end
			else
				Wait(1500)
			end
		end
	end)
end

function CreateBlip(coords,name,sprite,colour)
	local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
	SetBlipSprite(blip,sprite)
	SetBlipScale(blip,0.9)
	SetBlipColour(blip,colour)
	SetBlipAsShortRange(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(name)
	EndTextCommandSetBlipName(blip)
end

function OpenMenu(action)
	SetNuiFocus(true,true)
	SendNUIMessage({
		action = action
	})
end

function getClosePlayers()
	local returningTable = {}

	local closePlayers = GetActivePlayers()

	for k,v in pairs(closePlayers)do

		local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(v)))
		
			if dist < 10.0 then
				
				if PlayerId() ~= v then

					local playerMugshotId = RegisterPedheadshot(GetPlayerPed(v))

					while not IsPedheadshotReady(playerMugshotId) do
						Wait(0)
					end
			
					local playerMugshot = GetPedheadshotTxdString(playerMugshotId)

					returningTable[k] = {PlayerServerId = GetPlayerServerId(v), PlayerName = GetPlayerName(v), PlayerMugshot = playerMugshot}
				end
			end
	end
	
    Citizen.CreateThread(function ()
		Wait(2000)
		for k,v in pairs(returningTable)do
			UnregisterPedheadshot(v.PlayerMugshot)
		end
	end)
	
	return returningTable
end

function activateUnlimitedStamina()
	Citizen.CreateThread(function ()
		while true do
			ResetPlayerStamina(PlayerId())
			Wait(3000)
		end
	end)
end

function activateHealthRegen()
	Citizen.CreateThread(function ()
		while true do
			Wait(20000)
			local maxHealth = GetEntityMaxHealth(PlayerPedId())
			local currentHealth = GetEntityHealth(PlayerPedId())
			if currentHealth >= maxHealth then
				SetEntityHealth(currentHealth + 20)
			end
		end
	end)
end

function activateVestRegen()
	Citizen.CreateThread(function ()
		while true do
			Wait(20000)
			local maxArmour = 100
			local currentArmour = GetPedArmour(PlayerPedId())
			if currentArmour >= maxArmour then
				SetPedArmour(currentArmour + 20)
			end
		end
	end)
end

function RequestAnim(anim)
	RequestAnimDict(anim)
	
	while not HasAnimDictLoaded(anim) do
		Wait(10)
	end
end

function CreateNPC(model, coords, heading)
	local hashModel = GetHashKey(model)
	RequestModel(hashModel)

	while not HasModelLoaded(hashModel) do
		Wait(100)
	end

	RequestAnim('mini@strip_club@idles@bouncer@base')

	local npc = CreatePed(5, hashModel, coords.x, coords.y, coords.z-1.0, heading, false, true)
	SetEntityHeading(npc, heading)
	FreezeEntityPosition(npc, true)
	SetEntityInvincible(npc, true)
	SetBlockingOfNonTemporaryEvents(npc, true)

	TaskPlayAnim(npc, 'mini@strip_club@idles@bouncer@base', 'base', 8.0, 0.0, -1, 1, 0, 0, 0, 0)

	SetModelAsNoLongerNeeded(hashModel)

	return npc
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(x, y, z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
	ClearDrawOrigin()
end

function getClientTeamExperience(job)
	if not isClientInTeam(job) then
		return 0
	end

	return GlobalState.Teams[job].teamExperience
end

function getClientTeamLevel(job)
	if not isClientInTeam(job) then
		return 0
	end

	return GlobalState.Teams[job].teamLevel
end

function isClientInTeam(job)
	if GlobalState.Teams[job] then
		return true
	end

	return false
end

exports('getClientTeamExperience', function (job)
	return getClientTeamExperience(job)
end)

exports('getClientTeamLevel', function (job)
	return getClientTeamLevel(job)
end)

exports('isClientInTeam', function (job)
	return isClientInTeam(job)
end)