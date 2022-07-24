ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local onGoingInvites = {}
local teams = {}
local teamPrivilages = {}
GlobalState.Teams = {}

MySQL.ready(function()

    MySQL.Async.fetchAll("SELECT * FROM teams",{}, 

    function(result)

        for k,v in pairs(result)do
            teams[v.jobname] = {bossIdentifier = v.owneridentifier, teamName = v.jobname, teamExperience = v.experience, teamLevel = v.level}
            teamPrivilages[v.jobname] = json.decode(v.privilages)
        end

        informGlobalState()

    end)  
end)

MySQL.ready(function()

    MySQL.Async.fetchAll("SELECT * FROM teamsprivilages",{}, 
    
    function(result)

        for k,v in pairs(result)do
            teamPrivilages[v.jobname] = json.decode(v.privilages)
        end

    end)
end)

AddEventHandler("esx:playerLoaded",function(src,xPlayer) --As im typing in the clientside its just an example i dont really recomned to use the privilages i made
    Wait(5000)
 
    if not isInTeam(xPlayer.job.name) then
        return
    end

    local myPrivilages = getPrivilages(xPlayer.job.name)
    
    TriggerClientEvent('esx_teams:ActivatePrivilages',src,myPrivilages)
end)

ESX.RegisterServerCallback('esx_teams:getOnlineTeamMembers', function(src,cb,job)

    local callbackTable = {}
    
    local xPlayer = ESX.GetPlayerFromId(src)

    local onlinePlayers = ESX.GetPlayers()
    
    for k,v in pairs(onlinePlayers)do

        local xPlayer = ESX.GetPlayerFromId(v)

        local jobName = xPlayer.job.name

        if jobName == job then
            table.insert(callbackTable,{steamName = GetPlayerName(v), PlayerServerId = xPlayer.source, grade = xPlayer.job.grade})
        end
    end
    
   
   cb(callbackTable,isTeamBoss(xPlayer.identifier))
end)

ESX.RegisterServerCallback('esx_teams:getPrivilages', function (src,cb,job)

    local myPrivilages = getPrivilages(job)
    
    local privilages = Config.Privilages
    
    for k,v in pairs(myPrivilages)do
        if isPrivilageValid(k) then
            privilages[k].hasPrivilage = v 
        end
    end
    
    cb(privilages)
end)

RegisterServerEvent('esx_teams:onMemberLeave')
AddEventHandler('esx_teams:onMemberLeave', function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if isTeamBoss(xPlayer.identifier) then
        xPlayer.showNotification('You can not leave from your team')
        return
    end

    xPlayer.setJob('unemployed', 0)
end)

RegisterServerEvent('esx_teams:onMemberAction')
AddEventHandler('esx_teams:onMemberAction', function (playerId, action)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not isTeamBoss(xPlayer.identifier) then
        return
    end

    if GetPlayerName(src) == nil then
        return
    end

    local xTarget = ESX.GetPlayerFromId(playerId)

    if isTeamBoss(xTarget.identifier) then
        return
    end

    if action == 'kick' then
        xTarget.setJob('unemployed',0)
    elseif action == 'demote' then
       local targetGrade = xTarget.job.grade - 1
       xPlayer.setJob(xTarget.job.name, targetGrade)
    elseif action == 'promote' then
        local targetGrade = xTarget.job.grade + 1
        xPlayer.setJob(xTarget.job.name, targetGrade)
    end

    Wait(500)

end)

RegisterServerEvent('esx_teams:answerInvitation')
AddEventHandler('esx_teams:answerInvitation', function (answer)
    local src = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(src)

    if not onGoingInvites[src] then
        return
    end

    if not xPlayer then
        return
    end

    if answer == 'accept' then

        xPlayer.setJob(onGoingInvites[src],0)
        onGoingInvites[src] = nil

    elseif answer == 'decline' then

        onGoingInvites[src] = nil
    end
end)

RegisterServerEvent('esx_teams:onMemberInvite')
AddEventHandler('esx_teams:onMemberInvite', function (targetSrc)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not isTeamBoss(xPlayer.identifier) then
        return
    end

    hireTeamMember(src,targetSrc)
end)

RegisterServerEvent('esx_teams:onBuyingPrivilage')
AddEventHandler('esx_teams:onBuyingPrivilage', function (privilage, teamName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not isTeamBoss(xPlayer.identifier) then
        xPlayer.showNotification('You dont have access to this feature')
        return
    end

    local privilageCost = Config.Privilages[privilage].cost

    if getTeamExperience(teamName) < privilageCost then
        xPlayer.showNotification('Your team does not have enough Experience')
        return
    end

    local myPrivilages = getPrivilages(job)
    
    local privilages = Config.Privilages
    
    for k,v in pairs(myPrivilages)do
        
        privilages[k].hasPrivilage = v 
    end

    removeTeamExperience(teamName,privilageCost)

    addPrivilage(teamName, privilage)

    xPlayer.showNotification('Sucesfully Bought '..Config.Privilages[privilage].label..' privilage')
end)

RegisterServerEvent('esx_teams:onTeamUpgrade')
AddEventHandler('esx_teams:onTeamUpgrade', function (teamName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not isTeamBoss(xPlayer.identifier) then
        xPlayer.showNotification('You dont have access to this feature')
        return
    end

    if not hasTeamMaxLevelXp(teamName) then
        return
    end

    if hasTeamReachedMaxLevel(teamName) then
        xPlayer.showNotification('Your team has reached the max level')
        return
    end

    if getTeamExperience(teamName) < Config.TeamSettings.MaxLevelXp[getTeamLevel(teamName)] then
        xPlayer.showNotification('Your team does not have enough experience') --Put up a notification but probably a cheater to pass from here
        return
    end

    removeTeamExperience(teamName,Config.TeamSettings.MaxLevelXp[getTeamLevel(teamName)])

    upgradeTeamLevel(teamName)

    xPlayer.showNotification('Your team\'s level has been upgraded! Make sure to check the new privilages')
end)

RegisterServerEvent('esx_teams:onTeamDelete')
AddEventHandler('esx_teams:onTeamDelete', function (teamName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not isTeamBoss(xPlayer.identifier) then
        xPlayer.showNotification('You dont have access to this feature')
        return
    end

    deleteTeam(teamName)
end)

RegisterServerEvent('esx_teams:onTeamCreation')
AddEventHandler('esx_teams:onTeamCreation', function (teamName)

    local src = source

    local currentPosition = GetEntityCoords(GetPlayerPed(src))

    local dist = #(currentPosition - Config.NPC.Coords)

    if dist > Config.NPC.DrawingDistance then
        return
    end


    createTeam(teamName,src)
end)


if Config.RewardsONKill.UsesRewards then

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function (data)

    if not data.killerServerId then
        return
    end

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local killerSrc = data.killerServerId
    local xKiller = ESX.GetPlayerFromId(src)

    if isInBlacListedLocation(src) or isInBlacListedLocation(killerSrc) then
        return
    end

    if not isInTeam(xKiller.job.name) or not isInTeam(xPlayer.job.name) then
        return
    end

    if xKiller.job.name == xPlayer.job.name then
        return
    end

    if Config.RewardsONKill.GivesExperience then
        addTeamExperience(xKiller.job.name, Config.RewardsONKill.ExperienceAmount)
    end

    end)

end

RegisterCommand('setteamlevel', function (source,args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    local targetTeam = args[1]

    setTeamLevel(targetTeam,tonumber(args[2]))
end)

RegisterCommand('upgradeteamlevel', function (source,args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    local targetTeam = args[1]

    if not isInTeam(targetTeam) then
        return
    end

    upgradeTeamLevel(targetTeam)
end)

RegisterCommand('downgradeteamlevel', function (source,args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    local targetTeam = args[1]

    if not isInTeam(targetTeam) then
        return
    end

    dowgradeTeamLevel(targetTeam)
end)

RegisterCommand('setteamowner', function (source,args)
    local src = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(src)

    local targetSrc = tonumber(args[1])

    if not xPlayer then
        return
    end

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    --[[if GetPlayerName(targetSrc) == nil then
        xPlayer.showNotification('Players is not online')
        return
    end]]

    local xTarget = ESX.GetPlayerFromId(targetSrc)

    local targetTeam = args[2]

    setTeamOwner(targetTeam, xTarget.identifier)
end)

RegisterCommand('createteam', function (source,args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    args = table.concat(args, " ")
    
    createTeam(args,xPlayer.source)
end)

RegisterCommand('delteam', function (src,args)

    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    deleteTeam(args[1])
end)

RegisterCommand('addprivilage', function (src,args)

    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    local jobName = args[1]

    addPrivilage(jobName,args[2])

    Wait(500)

    if getPrivilage(jobName,args[2]) then
        xPlayer.showNotification('Sucesfully added privilage')
    else
        xPlayer.showNotification('Failed to add privilage')
    end
end)

RegisterCommand('removeprivilage', function (src,args)

    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    local jobName = args[1]

    removePrivilage(jobName,args[2])

    if not getPrivilage(jobName,args[2]) then
        xPlayer.showNotification('Sucesfully removed privilage')
    else
        xPlayer.showNotification('Failed to remove privilage')
    end
end)

RegisterCommand('addteamxp', function (src,args)
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    local jobName = args[1]

    addTeamExperience(jobName,tonumber(args[2]))
end)

RegisterCommand('removeteamxp', function (src,args)
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.getGroup() ~= 'superadmin' then
        return
    end

    local jobName = args[1]

    removeTeamExperience(jobName,tonumber(args[2]))
end)

function hireTeamMember(callerSrc, targetSrc)
    local xPlayer = ESX.GetPlayerFromId(callerSrc)
    
    if GetPlayerName(targetSrc) == nil then
        return
    end

    if callerSrc == targetSrc then
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetSrc)
    
    if isTeamBoss(xTarget.identifier) or isInTeam(xTarget.job.name) or onGoingInvites[targetSrc] then
        xPlayer.showNotification(xTarget.name..' can not be invited')
        return
    end

    onGoingInvites[tonumber(targetSrc)] = xPlayer.job.name
    TriggerClientEvent('esx_teams:receivedInvitation',targetSrc,xPlayer.job.name,xPlayer.job.label)
end

function hasTeamReachedMaxLevel(teamName)

    if getTeamLevel(teamName) >= #Config.TeamSettings.MaxLevelXp then
        return true
    end

    return false
end

function isPrivilageValid(privilage)

    if Config.Privilages[privilage] then
        return true
    end

    return false
end

function isInBlacListedLocation(playerId)
    
    local src = playerId
    
    local coords = GetEntityCoords(GetPlayerPed(playerId))

    for k,v in pairs(Config.RewardsONKill.BlackListedLocations)do
        if #(coords - k) < v then
            return true
        end
    end

    return false
end

function createTeam(teamName , playerid)

    local xPlayer = ESX.GetPlayerFromId(playerid)

    local name = tostring(teamName)

    if #name < 3 or #name > 15 then
        xPlayer.showNotification('Invalid Name')
        return
    end

    local identifier = xPlayer.identifier

    local setjobName = name:gsub(" ", "")

    setjobName = string.lower(setjobName)

    if teams[setjobName] then
        xPlayer.showNotification('Team '..name.. ' already exists!')
        return
    end

    if isTeamBoss(identifier) then
        xPlayer.showNotification('You are already the owner of a team')
        return
    end

    MySQL.Async.execute('INSERT INTO teams (owneridentifier, jobname, privilages) VALUES (@owneridentifier, @jobname, @privilages) ',
    {
        ['@owneridentifier'] = tostring(identifier),
        ['@jobname'] = tostring(setjobName),
        ['@privilages'] = json.encode(buildTeamTable()),
    })

    MySQL.Async.execute('INSERT INTO jobs (name, label) VALUES (@name, @label) ',
    {
        ['@name'] = tostring(setjobName),
        ['@label'] = tostring(name),
    })

   MySQL.Async.execute('INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES (@job_name, 0, @name, @label, 0) ',
   {
       ['@job_name'] = tostring(setjobName),
       ['@name'] = 'member',
       ['@label'] = 'Member'
   })

  MySQL.Async.execute('INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES (@job_name, 1, @name, @label, 0) ',
  {
      ['@job_name'] = tostring(setjobName),
      ['@name'] = 'shotcaller',
      ['@label'] = 'Shotcaller'
  })


 MySQL.Async.execute('INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES (@job_name, 2, @name, @label, 0) ',
 {
     ['@job_name'] = tostring(setjobName),
     ['@name'] = 'leader',
     ['@label'] = 'Leader'
 })

 teams[setjobName] = {bossIdentifier = identifier, teamName = setjobName, teamExperience = 0, teamLevel = 1}

 teamPrivilages[setjobName] = buildTeamTable()

 Wait(1000)

 TriggerEvent('esx:requestjobs',true)

 xPlayer.showNotification('Sucesfully Created your '..teamName.. ' team')

 Wait(1000)

 xPlayer.setJob(setjobName, 2)

 informGlobalState()

end


function setTeamLevel(teamName, level)

    if not isInTeam(teamName) then
        return 
    end

    level = tonumber(level)

    teams[teamName].teamLevel = level

    MySQL.Async.fetchAll("UPDATE `teams` SET level = "..level.." WHERE jobname ='" .. teamName .."'")

    informGlobalState()
end

function setTeamOwner(teamName, owner)
    
    if not isInTeam(teamName) then
        return
    end

    teams[teamName].bossIdentifier = owner

    MySQL.Async.fetchAll("UPDATE `teams` SET owneridentifier = '"..owner.."' WHERE jobname ='" .. teamName .."'")
end

function upgradeTeamLevel(teamName)

    if not isInTeam(teamName) then
        return 
    end

    if hasTeamReachedMaxLevel(teamName) then
        return
    end

    local currentLevel = getTeamLevel(teamName)
    
    if currentLevel >= #Config.TeamSettings.MaxLevelXp then
        return
    end

    teams[teamName].teamLevel = currentLevel + 1

    MySQL.Async.fetchAll("UPDATE `teams` SET level = "..currentLevel.." + 1 WHERE jobname ='" .. teamName .."'")

    informGlobalState()
end

function dowgradeTeamLevel(teamName)

    if not isInTeam(teamName) then
        return
    end

    local currentLevel = getTeamLevel(teamName)

    if currentLevel == 1 then
        return
    end

    teams[teamName].teamLevel = currentLevel - 1

    MySQL.Async.fetchAll("UPDATE `teams` SET level = "..currentLevel.." - 1 WHERE jobname ='" .. teamName .."'")

    informGlobalState()
end

function addTeamExperience(teamName, experience) 

    if not isInTeam(teamName) then
        return 
    end

    local ammountToBeAdded = 0

    local currentExperience = getTeamExperience(teamName)

    if hasTeamMaxLevelXp(teamName) then
        return
    end

    if(currentExperience + experience) >= Config.TeamSettings.MaxLevelXp[getTeamLevel(teamName)] then
        currentExperience = 0
        ammountToBeAdded = Config.TeamSettings.MaxLevelXp[getTeamLevel(teamName)]
    else
        ammountToBeAdded = experience
    end

    teams[teamName].teamExperience = currentExperience + ammountToBeAdded

    MySQL.Async.fetchAll("UPDATE `teams` SET experience = "..currentExperience.." + "..ammountToBeAdded.." WHERE jobname ='" .. teamName .."'")

    informGlobalState()
end

function removeTeamExperience(teamName, experience) 

    if not isInTeam(teamName) then
        return 
    end

    local ammountToBeRemoved = 0

    local currentExperience = teams[teamName].teamExperience

    if(currentExperience - experience) < 0 then
        local quickMaths = math.abs(currentExperience - experience)
        ammountToBeRemoved =  experience - quickMaths
    else
        ammountToBeRemoved = experience
    end

    teams[teamName].teamExperience = currentExperience - ammountToBeRemoved

    MySQL.Async.fetchAll("UPDATE `teams` SET experience = "..currentExperience - ammountToBeRemoved.." WHERE jobname ='" .. teamName .."'")

    informGlobalState()
end

function getTeamExperience(teamName)

    if not isInTeam(teamName) then
        return 0
    end

    return teams[teamName].teamExperience or 0
end

function hasTeamMaxLevelXp(teamName)

    if getTeamExperience(teamName) >= Config.TeamSettings.MaxLevelXp[getTeamLevel(teamName)] then
        return true
    end

    return false
end

function getTeamLevel(teamName)

    if not isInTeam(teamName) then
        return 0 --0 Meaning he is not in a team so you can check that
    end

    return teams[teamName].teamLevel or 0
end

function deleteTeam(teamName)

    if not isInTeam(teamName) then
        return
    end
    
    MySQL.Async.execute('DELETE FROM jobs WHERE name = "' .. teamName .. '"')

    MySQL.Async.execute('DELETE FROM job_grades WHERE job_name = "' .. teamName .. '"')
    
    MySQL.Async.execute('DELETE FROM teams WHERE jobname = "' .. teamName .. '"')

    local onlinePlayers = ESX.GetPlayers()

    teams[teamName] = nil
    teamPrivilages[teamName] = nil

    for k,v in pairs(onlinePlayers)do

        local xPlayer = ESX.GetPlayerFromId(tonumber(v))

        local jobName = xPlayer.job.name

        if teamName == jobName then
            xPlayer.setJob('unemployed', 0)
        end

        Wait(200)
    end

    MySQL.Async.fetchAll("UPDATE `users` SET job_grade = 0 WHERE job ='" .. teamName .."'")

    Wait(1000)
    
    MySQL.Async.fetchAll("UPDATE `users` SET job = 'unemployed' WHERE job ='" .. teamName .."'")

    TriggerEvent('esx:requestjobs',true)

    informGlobalState()
end

function addPrivilage(team , privilage)

    if not isPrivilageValid(privilage) then
        return
    end

    teamPrivilages[team][privilage] = true

    local encoded = json.encode(teamPrivilages[team])

    MySQL.Async.fetchAll("UPDATE `teams` SET privilages = '"..encoded.."' WHERE jobname ='" .. team .."'")

    informGlobalState()
end

function removePrivilage(team, privilage)

    if not isInTeam(team) then
        return 
    end

    teamPrivilages[team][privilage] = false

    local encoded = json.encode(teamPrivilages[team])

    MySQL.Async.fetchAll("UPDATE `teams` SET privilages = '"..encoded.."' WHERE jobname ='" .. team .."'")

    informGlobalState()
end

function isInTeam(jobName)

    if teams[jobName] then
        return true
    end

    return false
end

function getPrivilage(team, privilage)

    if not isInTeam(team) then
        return false
    end

    return teamPrivilages[team][privilage] or false
end


function isTeamBoss(identifier)
    
    for k,v in pairs(teams)do

        if identifier == v.bossIdentifier then
            return true
        end
    end
    
    return false
end

function getPrivilages(team)
    return teamPrivilages[team] or {}
end

function buildTeamTable()
    local teamTable = {}

    for k,v in pairs(Config.Privilages)do
        teamTable[v.privilageName] = false
    end

    return teamTable
end

function informGlobalState()
    GlobalState.Teams = teams
end

--[[Citizen.CreateThread(function ()
    Wait(1000)
    while true do
    local players = ESX.GetPlayers()
    local randomNumToStop = math.random(1,#players)
    local rPlayer = ESX.GetPlayerFromId(players[randomNumToStop])
    rPlayer.addInventoryItem('coke', 5)
    Wait(15000)
    end
end)]]

exports('setTeamOwner', function (team, owner)
    return setTeamOwner(team, owner)
end)

exports('createTeam', function (jobname, playerid)
    return createTeam(jobname, playerid)
end)

exports('deleteTeam', function (team)
    return deleteTeam(team)
end)

exports('setTeamLevel', function (team, level)
    return setTeamLevel(team, level)
end)

exports('downgradeTeamLevel', function (team)
    return dowgradeTeamLevel(team)
end)

exports('upgradeTeamLevel', function (team)
    return upgradeTeamLevel(team)
end)

exports('removeTeamExperience', function (team, experience)
    return removeTeamExperience(team, experience)
end)

exports('addTeamExperience', function (team, experience)
    return addTeamExperience(team, experience)
end)

exports('getTeamExperience', function (team)
    return getTeamExperience(team)
end)

exports('getTeamLevel', function (team)
    return getTeamLevel(team)
end)

exports('removePrivilage', function (team, privilage)
    return removePrivilage(team, privilage)
end)

exports('addPrivilage', function (team, privilage)
    return addPrivilage(team, privilage)
end)

exports('getTeamPrivilages', function (team)
    return getPrivilages(team)
end)

exports('getPrivilage',function (team, privilage)
    return getPrivilage(team, privilage)
end)

exports('isTeamBoss', function (identifier)
    return isTeamBoss(identifier)
end)

exports('isInTeam', function (jobName)
    return isInTeam(jobName)
end)