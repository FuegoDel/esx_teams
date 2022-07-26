let data;
let teamMembers = undefined;
let teamPrivilages = undefined;
let closePlayers = undefined;
let gradeIcons = undefined;
let inAnotherMenu = false;

window.addEventListener('message', function (event) {
  if (event.data.action === 'creation') {
    buildCreationPange();
  } else if (event.data.action === 'teammenu') {
    data = event.data;
    buildMenuPage();
  } else if (event.data.action === 'teamMembers') {
    teamMembers = event.data.teamMembers;
    gradeIcons = event.data.gradeIcons
    buildManageMenu()
  } else if (event.data.action === 'teamPrivilages') {
    inAnotherMenu = true;
    teamPrivilages = event.data.privilages;
    buildTeamPrivilages();
  } else if (event.data.action === 'ClosePlayers') {
    closePlayers = event.data.closePlayers;
    buildHireMenu()
  }

});

document.onkeyup = function (event) {
  if (event.key == 'Escape') {
    closeMenu()
  }
}

closeMenu = function (force) {
  if (force) {
    $('#body').fadeOut()
    $.post('https://esx_teams/closeMenu', JSON.stringify({}));
    setTimeout(function () {
      window.location.reload()
    }, 500);
    return
  }
  if (!inAnotherMenu) {
    $('#body').fadeOut()
    $.post('https://esx_teams/closeMenu', JSON.stringify({}));
    setTimeout(function () {
      window.location.reload()
    }, 500);
  } else {
    buildMenuPage()
  }
}

function buildManageMenu() {
  document.getElementById('body').style.display = 'none';
  document.getElementById('body').innerHTML = `
  <div class="center">
  <div class="hire-header">
    MANAGE <span id="glowing-text"> MEMBERS</span>
  </div>
</div>

<div class="center">
  <i style="right:2vw" id="hire-icon" class="fal fa-user-circle"></i>
  <div class="border-hire"></div>
  <i style="left:2vw; transform: rotateY(180deg);" id="hire-icon" class="fal fa-user-circle"></i>
</div>

<div class="center">
  <div id="container-hire">

  </div>
</div>`


  for (let i in teamMembers) {
    if (teamMembers[i].grade == 2) {
      document.getElementById('container-hire').innerHTML += `
      <div class="hire-item">
      <div class="hire-title" id="glowing-text">
        ${teamMembers[i].steamName}
      </div>
      <div class="center">
        <i id="hire-font-icon" class="${gradeIcons[teamMembers[i].grade]}"></i>
      </div>
      <div class="center">
        <div class="hire-btn-manage">
          <span id="hovering-hire-text" onclick = "manageMember(${teamMembers[i].PlayerServerId},'demote')">DEMOTE /</span>
          <span id="hovering-hire-text" onclick = "manageMember(${teamMembers[i].PlayerServerId},'kick')">KICK</span>
        </div>
      </div>
    </div>`
    } else if (teamMembers[i].grade == 0) {
      document.getElementById('container-hire').innerHTML += `
      <div class="hire-item">
      <div class="hire-title" id="glowing-text">
        ${teamMembers[i].steamName}
      </div>
      <div class="center">
          <i id="hire-font-icon" class="${gradeIcons[teamMembers[i].grade]}"></i>
      </div>
      <div class="center">
        <div class="hire-btn-manage">
          <span id="hovering-hire-text" onclick = "manageMember(${teamMembers[i].PlayerServerId},'kick')">KICK /</span>
          <span id="hovering-hire-text" onclick = "manageMember(${teamMembers[i].PlayerServerId},'promote')">PROMOTE</span>
        </div>
      </div>
    </div>`
    } else if (teamMembers[i].grade == 1) {
      document.getElementById('container-hire').innerHTML += `
      <div class="hire-item">
      <div class="hire-title" id="glowing-text">
        ${teamMembers[i].steamName}
      </div>
      <div class="center">
          <i id="hire-font-icon" class="${gradeIcons[teamMembers[i].grade]}"></i>
      </div>
      <div class="center">
        <div class="hire-btn-manage">
          <span id="hovering-hire-text" onclick = "manageMember(${teamMembers[i].PlayerServerId},'demote')">DEMOTE /</span>
          <span id="hovering-hire-text" onclick = "manageMember(${teamMembers[i].PlayerServerId},'kick')">KICK /</span>
          <span id="hovering-hire-text" onclick = "manageMember(${teamMembers[i].PlayerServerId},'promote')">PROMOTE</span>
        </div>
      </div>
    </div>`
    }
  }

  $('#body').fadeIn()
  inAnotherMenu = true
}

function buildHireMenu() {
  document.getElementById('body').style.display = 'none';
  document.getElementById('body').innerHTML = `
  <div class="center">
  <div class="hire-header">
    HIRE <span id="glowing-text"> MEMBERS</span>
  </div>
</div>

<div class="center">
  <i style="right:2vw" id="hire-icon" class="fal fa-allergies"></i>
  <div class="border-hire"></div>
  <i style="left:2vw; transform: rotateY(180deg);" id="hire-icon" class="fal fa-allergies"></i>
</div>

<div class="center">
  <div id="container-hire">

  </div>
</div>`

  for (let i in closePlayers) {
    let localImage = `https://nui-img/${closePlayers[i].PlayerMugshot}/${closePlayers[i].PlayerMugshot}?v=${Date.now()}`
    document.getElementById('container-hire').innerHTML += `
  <div class="hire-item">
  <div class="hire-title" id="glowing-text">
    ${closePlayers[i].PlayerName}
  </div>
  <div class="center">
    <div class="hire-icon" style = "background: url(${localImage}); background-position:center center; background-size: 100% 100%; background-repeat: no-repeat;"></div>
  </div>
  <div class="center">
    <div class="hire-btn" onclick = "invitePlayer('${closePlayers[i].PlayerServerId}')">
      SEND INVITATION
    </div>
  </div>
  </div>`
  }

  $('#body').fadeIn()
  inAnotherMenu = true
}


function buildTeamPrivilages() {
  document.getElementById('body').style.display = 'none'
  document.getElementById('body').innerHTML = `
    <div class="privilages-header">
    Manage <span id="glowing-text">Privilages</span>
  </div>

  <div class="center">
    <i id="privilage-icon" class="fal fa-mask"></i>
    <div class="privilages-border"></div>
    <i style="transform: rotateZ(90deg)" id="privilage-icon" class="fal fa-mask"></i>
  </div>

  <div class="center">
    <div id="privilages-container">

    </div>
  </div>
    `

  for (let i in teamPrivilages) {
    if (data.teamData.level >= teamPrivilages[i].requiredLevel) {
      if (teamPrivilages[i].hasPrivilage == false) {
        document.getElementById('privilages-container').innerHTML += `
      <div class="privilage-item" id = "unowned-privilage" onclick = "onBuyingPrivilage('${teamPrivilages[i].privilageName}')">
      <div class="privilage-title">
       ${teamPrivilages[i].label}
      </div>
      <div class="privilage-cost"><span id="glowing-text">${teamPrivilages[i].cost} EXP</span></div>
      <div class="privilage-item-icon">
        <i class="${teamPrivilages[i].fontIcon}"></i>
      </div>
    </div>`
      } else {
        document.getElementById('privilages-container').innerHTML += `
      <div class="privilage-item" id="owner-privilage">
      <div class="privilage-title">
       ${teamPrivilages[i].label}
      </div>
      <div class="privilage-cost"><span id="glowing-text">${teamPrivilages[i].cost} EXP</span></div>
      <div class="privilage-item-icon">
        <i class="${teamPrivilages[i].fontIcon}"></i>
      </div>
    </div>`
      }
    }
  }


  $('#body').fadeIn()
}

function buildMenuPage() {
  document.getElementById('body').style.display = 'none'
  document.getElementById('body').innerHTML = `
  <div class="center">
    <div class="container-team">
      <i id="border-steady-icon" class="fal fa-user-friends"></i>
      <i style="left: 64.5vw;" id="border-steady-icon" class="fal fa-user-friends"></i>
      <div class="border-steady"></div>
      <div class="border-steady" style="left: 51.5vw; top:3.1vh;"></div>
      <div class="container-team-header">
        <span id="glowing-text">${data.teamData.teamName}</span> Team
      </div>
      <div class="team-options-container">

        <div class="option-item" onclick = "getTeamMembers()">
          <div class="option-icon"><i class="fal fa-users-crown"></i></div>
          <div class="option-title">Manage Online Members</div>
        </div>
        <div class="option-item" onclick = "upgradeTeamLevel()">
          <div class="option-icon"><i class="fal fa-plus-octagon"></i></div>
          <div class="option-title">Upgrade Team Level</div>
        </div>
        <div class="option-item" onclick = "getClosestPlayers()">
          <div class="option-icon"><i class="fal fa-user-plus"></i></div>
          <div class="option-title">Add Members</div>
        </div>
        <div class="option-item" onclick = "getTeamPrivilages()">
          <div class="option-icon"><i class="fal fa-mask"></i></div>
          <div class="option-title">Manage Privilages</div>
        </div>
        <div class="option-item" onclick = "deleteTeam()">
          <div class="option-icon"><i class="fal fa-ban"></i></div>
          <div class="option-title" >Delete Team</div>
        </div>
        <div class="option-item" onclick = "leaveTeam()">
        <div class="option-icon"><i class="fal fa-portal-exit"></i></div>
        <div class="option-title" >Leave Team</div>
      </div>
      </div>
      <div class="container-info">
        <div class="center">
          <table class="table-info">
            <tbody>
              <tr>
                <td>Team Level</td>
                <td id="glowing-text">${data.teamData.level}/${data.teamData.maxLevel}</td>
              </tr>
              <tr>
                <td>Team Experience</td>
                <td id="glowing-text">${data.teamData.experience}/${data.teamData.maxExperience}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
  `

  $('#body').fadeIn()

  inAnotherMenu = false
}

function buildCreationPange() {
  document.getElementById('body').innerHTML = `
  <div class="register-paige">
  <div class="center">
    <div class="register-container">
      <div class="register-header">
        CREATE YOUR <span id="glowing-text">TEAM</span>
      </div>
      <div id="border-down"></div>
      <div class="register-info-label">
        <i class="fal fa-unlock"></i>
        Gain <span id="glowing-text" style=" font-family: 'Neusa';">Acess</span> to special <span
          id="glowing-text">Privilages</span>
      </div>
      <div id="border-up"></div>
      <div class="register-info">
        <div class="center">
          <div class="register-circle">
            <i id="circle-icon" class="fal fa-heartbeat"></i>
            <div class="circle-text">Health Regen</div>
          </div>
          <div class="register-circle">
            <i id="circle-icon" class="fal fa-vest"></i>
            <div class="circle-text">Vest Regen</div>
          </div>
          <div class="register-circle">
            <i id="circle-icon" class="fal fa-dot-circle"></i>
            <div class="circle-text">No Recoil</div>
          </div>
          <div class="register-circle">
            <i id="circle-icon" class="fal fa-battery-full"></i>
            <div class="circle-text">UL Stamina</div>
          </div>
        </div>
      </div>
      <div id="border-down" style="width:25.9vw; margin-top: 4vh;"></div>
      <div class="border-down-text">
        <i id="border-down-icon" class="fal fa-users-class"></i>
        <span id="glowing-text">Play</span> with your <span id="glowing-text">Friends</span>
      </div>
      <div id="border-down" style="width:2.7vw; top: -1.1vh; left: 36vw;"></div>
      <div class="center">
        <div class="register-input">
          <div class="input-field-label">Fill in with your <span id="glowing-text">Team 's</span> name</div>
          <input id = 'teamname' name="teamname" type="text" maxlength="12" placeholder = "Enter Team Name">
        </div>
      </div>
      <div class="center">
        <button id="btn-create" onclick = "createTeam()">CREATE TEAM</button>
      </div>
    </div>
  </div>
</div>
  `

  $('#body').fadeIn()
}

function manageMember(playerid, action) {
  const object = {
    targetId: playerid,
    action: action
  }
  $.post('https://esx_teams/onMemberAction', JSON.stringify({ object }));
  closeMenu()
}

function leaveTeam() {
  $.post('https://esx_teams/leaveTeam', JSON.stringify({}));
  closeMenu()
}

function invitePlayer(playerid) {
  let targetId = playerid
  $.post('https://esx_teams/onMemberInvite', JSON.stringify({ targetId }));
  closeMenu()
}

function getTeamMembers() {
  $.post('https://esx_teams/GetTeamMembers', JSON.stringify({}));
}

function getClosestPlayers() {
  $.post('https://esx_teams/GetClosestPlayers', JSON.stringify({}));
}

function getTeamPrivilages() {
  $.post('https://esx_teams/GetTeamPrivilages', JSON.stringify({}));
}

function onBuyingPrivilage(privilage) {
  $.post('https://esx_teams/onBuyingPrivilage', JSON.stringify({ privilage }));
  closeMenu(true)
}

function upgradeTeamLevel() {
  if (!hasTeamEnoughXp()) {
    return
  }
  $.post('https://esx_teams/onTeamUpgrade', JSON.stringify({}));
  closeMenu()
}

function deleteTeam() {
  $.post('https://esx_teams/onTeamDelete', JSON.stringify({}));
  closeMenu()
}

function createTeam() {
  let teamName = document.getElementById('teamname').value;
  $.post('https://esx_teams/onTeamCreation', JSON.stringify({ teamName }));

  closeMenu()
}

function hasTeamReachedMaxLevel() {
  if (data.teamData.level == data.teamData.maxLevel) {
    return true
  }
  return false
}

function hasTeamEnoughXp() {
  if (data.teamData.experience == data.teamData.maxExperience) {
    return true
  }

  return false
}
