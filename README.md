# esx_teams
A Script designed to help servers achieve achieve creating their own criminal/team/organization system

#Features

* Team Creation
* Team Menu
* Privilages System
* Responsive NUI for all those stuff
* Amazing Handling :)

#Server Exports 

* isInTeam(jobName)
* isTeamBoss(identifier)
* getPrivilage(team,privilage)
* getTeamPrivilages(team)
* addPrivilage(team,privilage)
* removePrivilage(team,privilage)
* getTeamLevel(team)
* getTeamExperience(team)
* addTeamExperience(team)
* removeTeamExperience(team)
* upgradeTeamLevel(team)
* downgradeTeamLevel(team)
* setTeamLevel(team,level)
* deleteTeam(team)
* createTeam(jobname,playerid)
* setTeamOwner(team,playerid)

#Client Exports

* getClientTeamExperience(job)
* getClientTeamLevel(job)
* isClientInTeam(job)

#Availabe Commands
* /setteamlevel [team] [level]
* /upgradeteamlevel [team]
* /downgradeteamlevel [team]
* /setteamowner [team] [id]
* /createteam [teamname]
* /delteam [teamname]
* /addprivilage [teamname] [privilage]
* /removeprivilage [teamname] [privilage]
* /addteamxp [teamname] [exp]
* /removeteamxp [teamname] [exp]

#Dependencies 
* es_extended
* mysql-async
* Note that script is build and tested on ESX 1.1 i beleive
