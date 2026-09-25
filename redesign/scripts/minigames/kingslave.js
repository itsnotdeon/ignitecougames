import {allKingNormalCommands,allKingDarkCommands} from "../data/topics.js?v=20260926-01";

const ACTIVE_KEY="ignite-active-content-v1";
function poolForMode(mode){try{const raw=JSON.parse(localStorage.getItem(ACTIVE_KEY)||"null");const list=raw?.[mode==="dark"?"kingDark":"kingNormal"];if(Array.isArray(list)&&list.length)return list}catch{}return mode==="dark"?allKingDarkCommands:allKingNormalCommands}

const POWERS = [
  { id: "pc1", name: "Titah Ganda", icon: "P1", desc: "Ambil satu Command Card tambahan pada ronde ini." },
  { id: "pc2", name: "Hak Pilih", icon: "P2", desc: "Pilih sendiri Command Card, bukan mengambilnya secara acak." },
  { id: "pc3", name: "Perpanjangan Takhta", icon: "P3", desc: "Tetap menjadi King atau Queen pada ronde berikutnya." },
  { id: "pc4", name: "Tukar Takdir", icon: "P4", desc: "Tukar King dan Slave untuk satu Command Card ini." },
  { id: "pc5", name: "Waktu Milikku", icon: "P5", desc: "Gandakan durasi command yang memiliki hitungan waktu." }
];

function freshState() {
  return {
    stage: "consent",
    round: 1,
    mode: "normal",
    king: null,
    slave: null,
    rolled: false,
    rollP1: null,
    rollP2: null,
    rollStarted: false,
    command: null,
    commandDrawn: false,
    currentCommands: [],
    responded: false,
    chooseOpen: false,
    drawAgain: false,
    extendThrone: false,
    swapFate: false,
    originalKing: null,
    originalSlave: null,
    doubleTime: false,
    usedCommands: [],
    usedPowers: { 0: [], 1: [] },
    kingCount: { 0: 0, 1: 0 },
    slaveCount: { 0: 0, 1: 0 },
    __powerOpen: false,
    rolling: false
  };
}

export function createKingState() {
  return freshState();
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, function (char) {
    const map = {
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#039;"
    };
    return map[char];
  });
}

function pool(state) {
  return poolForMode(state.mode);
}

function playerName(names, index) {
  return names[index] || "Player " + (index + 1);
}

function applyTimePower(state, text) {
  if (!state.doubleTime) return text;
  return text.replace(/(\d+)\s*(detik|menit|jam)/gi, function (match, number, unit) {
    return String(Number(number) * 2) + " " + unit;
  });
}

function assignRoles(state) {
  state.king = state.rollP1 > state.rollP2 ? 0 : 1;
  state.slave = 1 - state.king;
  state.rolled = true;
  state.kingCount[state.king] += 1;
  state.slaveCount[state.slave] += 1;
}

function resetRound(state) {
  if (state.swapFate) {
    state.king = state.originalKing;
    state.slave = state.originalSlave;
    state.swapFate = false;
    state.originalKing = null;
    state.originalSlave = null;
  }

  const keepKing = state.extendThrone;
  state.round += 1;
  state.command = null;
  state.commandDrawn = false;
  state.currentCommands = [];
  state.responded = false;
  state.chooseOpen = false;
  state.drawAgain = false;
  state.doubleTime = false;
  state.__powerOpen = false;

  if (keepKing) {
    state.extendThrone = false;
    state.kingCount[state.king] += 1;
    state.slaveCount[state.slave] += 1;
    state.rolled = true;
  } else {
    state.rolled = false;
    state.king = null;
    state.slave = null;
    state.rollP1 = null;
    state.rollP2 = null;
  }
}

function drawRandomCommand(state) {
  const commands = pool(state);
  const available = [];

  for (let i = 0; i < commands.length; i += 1) {
    if (!state.usedCommands.includes(i)) available.push(i);
  }

  const source = available.length ? available : commands.map(function (_, index) { return index; });
  const selected = source[Math.floor(Math.random() * source.length)];

  if (!state.usedCommands.includes(selected)) state.usedCommands.push(selected);

  const command = applyTimePower(state, commands[selected]);
  state.currentCommands = [command];
  state.command = command;
  state.commandDrawn = true;
  state.chooseOpen = false;
  state.responded = false;
}

function chooseCommand(state, index) {
  const commands = pool(state);
  if (!Number.isInteger(index) || !commands[index]) return;

  if (!state.usedCommands.includes(index)) state.usedCommands.push(index);

  const command = applyTimePower(state, commands[index]);
  state.currentCommands = [command];
  state.command = command;
  state.commandDrawn = true;
  state.chooseOpen = false;
  state.responded = false;
}

function usePower(state, id) {
  if (state.king === null) return;

  const used = state.usedPowers[state.king];
  if (used.includes(id)) return;
  if (id === "pc2" && state.commandDrawn) return;

  used.push(id);

  if (id === "pc1") state.drawAgain = true;
  if (id === "pc2") state.chooseOpen = true;
  if (id === "pc3") state.extendThrone = true;

  if (id === "pc4") {
    state.originalKing = state.king;
    state.originalSlave = state.slave;
    state.king = state.originalSlave;
    state.slave = state.originalKing;
    state.swapFate = true;
  }

  if (id === "pc5") state.doubleTime = true;
  state.__powerOpen = false;
}

export function kingAction(state, action, value) {
  if (action === "consent") {
    state.stage = "game";
    return;
  }

  if (action === "mode") {
    state.mode = state.mode === "normal" ? "dark" : "normal";
    state.usedCommands = [];
    state.command = null;
    state.currentCommands = [];
    state.commandDrawn = false;
    state.chooseOpen = false;
    return;
  }

  if (action === "roll") {
    if (state.rolling) return;
    state.rollStarted = true;
    do {
      state.rollP1 = 1 + Math.floor(Math.random() * 6);
      state.rollP2 = 1 + Math.floor(Math.random() * 6);
    } while (state.rollP1 === state.rollP2);

    assignRoles(state);
    return;
  }

  if (action === "draw") {
    if (state.chooseOpen) return;
    drawRandomCommand(state);
    return;
  }

  if (action === "choose") {
    chooseCommand(state, Number(value));
    return;
  }

  if (action === "draw-again") {
    if (!state.drawAgain || state.currentCommands.length !== 1) return;

    const first = state.currentCommands[0];
    drawRandomCommand(state);
    state.currentCommands = [first, state.command];
    state.command = state.currentCommands.join("\n\n");
    state.drawAgain = false;
    return;
  }

  if (action === "power") {
    usePower(state, value);
    return;
  }

  if (action === "respond") {
    if (!state.commandDrawn || state.responded) return;
    if (value !== "run" && value !== "skip") return;

    state.responded = true;
    resetRound(state);
    return;
  }

  if (action === "reset") {
    Object.assign(state, freshState());
  }
}

function renderPowerSheet(state) {
  const used = state.king === null ? [] : state.usedPowers[state.king];

  const items = POWERS.map(function (power) {
    const isUsed = used.includes(power.id);
    const locked = power.id === "pc2" && state.commandDrawn;
    const disabled = isUsed || locked;
    const label = isUsed ? "Used" : locked ? "Locked" : "Use";

    return (
      '<div class="ks-power-item ' + (isUsed ? "used" : "") + '">' +
        '<div><b>' + escapeHtml(power.icon + " " + power.name) + '</b>' +
        '<small>' + escapeHtml(power.desc) + '</small></div>' +
        '<button data-mini="ks-power" data-value="' + power.id + '" ' +
          (disabled ? "disabled" : "") + '>' + label + '</button>' +
      '</div>'
    );
  }).join("");

  return (
    '<div class="ks-modal-backdrop">' +
      '<div class="ks-sheet">' +
        '<button class="ks-sheet-close" data-mini="ks-power-close">X</button>' +
        '<span class="ks-kicker">POWER CARDS</span>' +
        '<h3>King controls the round.</h3>' +
        '<p>Each player owns 5 cards. Each card can be used once per session.</p>' +
        '<div class="ks-power-list">' + items + '</div>' +
      '</div>' +
    '</div>'
  );
}

function renderChoiceSheet(state) {
  if (!state.chooseOpen || state.commandDrawn) return "";

  const choices = pool(state).map(function (command, index) {
    return (
      '<button data-mini="ks-choose" data-value="' + index + '">' +
        '<span>' + String(index + 1).padStart(2, "0") + '</span>' +
        escapeHtml(command) +
      '</button>'
    );
  }).join("");

  return (
    '<div class="ks-modal-backdrop">' +
      '<div class="ks-sheet">' +
        '<button class="ks-sheet-close" data-mini="ks-choice-close">X</button>' +
        '<span class="ks-kicker">HAK PILIH</span>' +
        '<h3>Choose the command.</h3>' +
        '<p>King memilih card yang akan dibacakan.</p>' +
        '<div class="ks-choice-list">' + choices + '</div>' +
      '</div>' +
    '</div>'
  );
}

export function renderKing(state, names) {
  const p1 = playerName(names, 0);
  const p2 = playerName(names, 1);

  if (state.stage === "consent") {
    return (
      '<section class="ks-screen ks-consent-screen">' +
        '<div class="ks-title-mark">KING</div>' +
        '<span class="ks-kicker">KING &amp; SLAVE</span>' +
        '<h2>Power stays playful.</h2>' +
        '<p class="ks-lead">Satu orang memegang mahkota. Satu orang menerima command. Kalian selalu boleh berhenti.</p>' +
        '<div class="ks-consent-list">' +
          '<div><span>01</span><p><b>Consent selalu menang.</b> Command bukan kewajiban di luar batas yang kalian sepakati.</p></div>' +
          '<div><span>02</span><p><b>Role hanya untuk ronde ini.</b> Mahkota berpindah setiap ronde kecuali King memakai Power tertentu.</p></div>' +
          '<div><span>03</span><p><b>Slave punya dua pilihan.</b> Jalankan atau skip. Tidak perlu memberi alasan.</p></div>' +
        '</div>' +
        '<label class="ks-consent-check"><input id="ks-consent" type="checkbox"><span>Kami berdua setuju bermain dan tahu bahwa kami dapat berhenti kapan saja.</span></label>' +
        '<button class="ks-main-btn" data-mini="ks-consent">Mulai Sesi</button>' +
      '</section>'
    );
  }

  const hasRoles = state.rolled && state.king !== null && state.slave !== null;
  const king = hasRoles ? playerName(names, state.king) : "";
  const slave = hasRoles ? playerName(names, state.slave) : "";
  const mode = state.mode === "normal" ? "Normal" : "After Dark";
  const kingEmoji = "👑";
  const slaveEmoji = "🧎";

  let body = "";

  if (!state.rolled) {
    const note = "Satu dadu untuk setiap pemain. Nilai tertinggi memegang mahkota. Jika tie, dadu otomatis mengulang.";

    body =
      '<section class="ks-draw-stage">' +
        '<div class="ks-dice-pair '+(state.rolling?"is-rolling":"")+'">' +
          '<div><span>' + (state.rollP1 || "?") + '</span><small>' + escapeHtml(p1) + '</small></div>' +
          '<div><span>' + (state.rollP2 || "?") + '</span><small>' + escapeHtml(p2) + '</small></div>' +
        '</div>' +
        '<p class="ks-fair-note">' + note + '</p>' +
        '<button class="ks-main-btn" data-mini="ks-roll">' +
          (state.rollStarted ? "Roll Again" : "Roll Dice") +
        '</button>' +
      '</section>';
  } else if (!state.commandDrawn) {
    body =
      '<section class="ks-ready-stage">' +
        '<div class="ks-crown"><span>'+kingEmoji+'</span><b>' + escapeHtml(king) + '</b><small>KING / QUEEN</small></div>' +
        '<div class="ks-slave-note">'+slaveEmoji+' SLAVE: ' + escapeHtml(slave) + '</div>' +
        '<button class="ks-main-btn" data-mini="ks-draw">Draw Command Card</button>' +
      '</section>';
  } else {
    const cards = state.currentCommands.map(function (command, index) {
      return (
        '<div class="ks-command-part">' +
          '<small>COMMAND ' + (index + 1) + '</small>' +
          '<strong>' + escapeHtml(command) + '</strong>' +
        '</div>'
      );
    }).join("");

    body =
      '<section class="ks-result-focus">' +
        '<span class="ks-result-label">ACTION</span>' +
        '<div class="ks-command-card-main">' + cards + '</div>' +
        '<div class="ks-command-target">SLAVE: ' + escapeHtml(slave) + ' - your move</div>' +
        '<div class="ks-response">' +
          '<button class="ks-response-run" data-mini="ks-respond" data-value="run">Jalankan</button>' +
          '<button class="ks-response-skip" data-mini="ks-respond" data-value="skip">Skip</button>' +
        '</div>' +
        (state.drawAgain && state.currentCommands.length === 1
          ? '<button class="ks-draw-again" data-mini="ks-draw-again">Draw Again</button>'
          : "") +
      '</section>';
  }

  const usedPowerCount = state.king === null ? 0 : state.usedPowers[state.king].length;
  const roles = hasRoles
    ? '<div class="ks-role-strip">' +
        '<div class="ks-role-person ' + (state.king === 0 ? "king" : "slave") + '">' +
          '<span>' + (state.king === 0 ? "👑" : "🧎") + '</span><b>' + escapeHtml(p1) + '</b>' +
          '<small>' + (state.king === 0 ? "KING / QUEEN" : "SLAVE") + '</small>' +
        '</div>' +
        '<div class="ks-vs">VS</div>' +
        '<div class="ks-role-person ' + (state.king === 1 ? "king" : "slave") + '">' +
          '<span>' + (state.king === 1 ? "👑" : "🧎") + '</span><b>' + escapeHtml(p2) + '</b>' +
          '<small>' + (state.king === 1 ? "KING / QUEEN" : "SLAVE") + '</small>' +
        '</div>' +
      '</div>'
    : "";

  const scores = hasRoles
    ? '<p class="ks-scoreline">' +
        escapeHtml(p1) + " " + state.kingCount[0] + "K " + state.slaveCount[0] + "S / " +
        escapeHtml(p2) + " " + state.kingCount[1] + "K " + state.slaveCount[1] + "S" +
      '</p>'
    : "";

  const powers = hasRoles
    ? '<button class="ks-power-trigger" data-mini="ks-power-open"><b>Power Cards</b><small>' +
        (5 - usedPowerCount) + '/5 available</small></button>'
    : "";

  const switchMode = hasRoles && !state.commandDrawn && !state.chooseOpen
    ? '<button class="ks-mode-switch" data-mini="ks-mode">Switch to ' +
        (state.mode === "normal" ? "After Dark" : "Normal") + '</button>'
    : "";

  return (
    '<section class="ks-screen">' +
      '<header class="ks-header">' +
        '<button class="ks-back" data-action="minigames-menu">Back</button>' +
        '<div><b>King &amp; Slave</b><small>' + mode + '</small></div>' +
        '<button class="ks-reset" data-mini="ks-reset">Reset</button>' +
      '</header>' +
      '<div class="ks-progress"><span>ROUND ' + state.round + '</span><i></i><span>' +
        (hasRoles ? kingEmoji + ' ' + escapeHtml(king) : "CROWN DRAW") + '</span></div>' +
      roles +
      body +
      powers +
      scores +
      renderChoiceSheet(state) +
      switchMode +
      (state.doubleTime ? '<p class="ks-active-note">Time power active this round.</p>' : "") +
      (state.swapFate ? '<p class="ks-active-note">Fate swapped for this command.</p>' : "") +
    '</section>' +
    (state.__powerOpen ? renderPowerSheet(state) : "")
  );
}
