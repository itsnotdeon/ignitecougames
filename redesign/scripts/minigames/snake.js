const LADDERS={6:16,20:31,29:41,38:49,47:58,63:74,71:83};
const SNAKES={24:9,34:15,46:27,57:39,68:48,79:60,88:66,95:77};
const SPECIALS={
  5:"couple",12:"question",18:"playful",27:"intimate",33:"surprise",
  41:"couple",49:"question",55:"playful",61:"intimate",69:"surprise",
  73:"couple",81:"question",87:"playful",91:"intimate",97:"surprise"
};
const CHALLENGES={
  normal:{
    couple:["Tatap pasanganmu selama 10 detik, lalu katakan satu hal yang kamu suka darinya.","Berikan satu pujian yang benar-benar spesifik untuk pasanganmu."],
    question:["Apa momen kecil bersama pasangan yang akhir-akhir ini paling kamu ingat?","Hal sederhana apa yang membuatmu merasa dekat dengan pasanganmu?"],
    playful:["Buat ekspresi paling lucu yang bisa kamu tahan selama 5 detik.","Tirukan gaya pasanganmu saat sedang sangat serius."],
    intimate:["Pegang tangan pasanganmu selama satu giliran penuh.","Berikan pelukan singkat yang nyaman untuk kalian berdua."],
    surprise:["Pilih: ceritakan satu rahasia kecil atau beri pasanganmu satu pujian spontan.","Tentukan satu lagu yang cocok menggambarkan hubungan kalian saat ini."]
  },
  extreme:{
    couple:["Tatap pasanganmu dan sebutkan tiga hal yang membuatmu semakin tertarik kepadanya.","Ceritakan satu hal yang ingin lebih sering kalian lakukan berdua."],
    question:["Apa satu hal tentang hubungan kalian yang ingin kamu dalami lebih jauh?","Kapan terakhir kali pasanganmu membuatmu merasa benar-benar dipahami?"],
    playful:["Buat pasanganmu tertawa tanpa menyentuhnya selama 15 detik.","Peragakan cara pasanganmu menggoda atau merayumu."],
    intimate:["Berikan pelukan selama 20 detik jika kalian berdua nyaman.","Bisikkan satu kalimat romantis yang biasanya jarang kamu ucapkan."],
    surprise:["Pilih satu: ungkapkan satu keinginan romantis atau satu hal yang ingin kalian coba bersama.","Buat satu mini-date spontan untuk kalian lakukan setelah permainan selesai."]
  }
};
const SPECIAL_LABELS={couple:"Couple Challenge",question:"Question",playful:"Fun and Playful",intimate:"Intimate",surprise:"Surprise"};
const SPECIAL_ICONS={couple:"&#x1F49E;",question:"&#x2753;",playful:"&#x1F389;",intimate:"&#x1F497;",surprise:"&#x1F381;"};

export function createSnakeState(){
  return {pos:[0,0],turn:Math.random()<0.5?0:1,finished:false,lastRoll:null,event:null,mode:"normal",challenge:null,memorySaved:false,winner:null,animating:false,lastMove:null};
}
function pickChallenge(kind,mode){
  const list=CHALLENGES[mode][kind]||CHALLENGES.normal[kind];
  return list[Math.floor(Math.random()*list.length)];
}
export function snakeSetMode(s,mode){
  if(s.finished||s.event?.type==="challenge") return;
  s.mode=mode==="extreme"?"extreme":"normal";
}
export function snakeRoll(s){
  if(s.finished||s.event||s.animating) return;
  s.lastRoll=Math.floor(Math.random()*6)+1;
  const p=s.turn;
  const from=s.pos[p];
  const target=from+s.lastRoll;
  s.event=null;
  s.challenge=null;
  s.lastMove=null;
  if(target>100){
    s.event={type:"overshoot",from,to:from,roll:s.lastRoll};
    return;
  }
  const landing=LADDERS[target]||SNAKES[target]||target;
  const path=[];
  for(let step=from+1;step<=target;step++) path.push(step);
  if(landing!==target) path.push(landing);
  s.pos[p]=landing;
  s.lastMove={player:p,from,to:landing,path};
  s.animating=true;
  if(LADDERS[target]) s.event={type:"ladder",from:target,to:landing};
  else if(SNAKES[target]) s.event={type:"snake",from:target,to:landing};
  else if(SPECIALS[target]){
    const kind=SPECIALS[target];
    s.challenge={kind,level:s.mode,text:pickChallenge(kind,s.mode)};
    s.event={type:"challenge",square:target,kind};
  } else if(s.pos[p]===100){
    s.finished=true;
    s.winner=p;
  }
}
export function snakeContinue(s,outcome){
  if(s.finished) return;
  const p=s.turn;
  if(s.event?.type==="challenge"&&outcome==="skip"){
    const from=s.pos[p];
    const to=Math.max(0,from-3);
    const path=[];
    for(let step=from-1;step>=to;step--) path.push(step);
    s.pos[p]=to;
    s.lastMove={player:p,from,to,path};
    s.animating=true;
    s.event={type:"skip",to};
    return;
  }
  if(s.event?.type==="overshoot"){
    s.event=null;
    s.turn=1-p;
    return;
  }
  if(s.event?.type==="ladder"||s.event?.type==="snake"){
    if(s.pos[p]===100){
      s.finished=true;
      s.winner=p;
      return;
    }
  }
  if(s.event?.type==="skip"){
    s.event=null;
    s.turn=1-p;
    return;
  }
  s.event=null;
  s.challenge=null;
  if(s.pos[p]===100){
    s.finished=true;
    s.winner=p;
    return;
  }
  s.turn=1-p;
}
export function snakeReset(s){Object.assign(s,createSnakeState());}
export function snakeFinishAnimation(s){
  const move=s.lastMove;
  s.animating=false;
  if(move&&!s.finished&&!s.event) s.turn=1-move.player;
  s.lastMove=null;
}
function escapeHtml(v){
  return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#039;"}[c]));
}
function renderBoard(s,names){
  const cells=Array.from({length:100},(_,i)=>100-i);
  return '<div class="snake-board">'+cells.map(n=>{
    const p1=s.pos[0]===n;
    const p2=s.pos[1]===n;
    const special=SPECIALS[n];
    return '<div class="snake-cell '+(p1?"p1 ":"")+(p2?"p2 ":"")+(special?"special ":"")+(LADDERS[n]?"ladder ":"")+(SNAKES[n]?"snake ":"")+'" data-square="'+n+'">'+
      '<span>'+n+'</span>'+
      (LADDERS[n]?'<b class="snake-marker ladder-marker" aria-label="Ladder">&#x1FA9C;</b>':"")+
      (SNAKES[n]?'<b class="snake-marker snake-marker" aria-label="Snake">&#x1F40D;</b>':"")+
      (special?'<i class="special-marker" aria-label="'+escapeHtml(SPECIAL_LABELS[special])+'">'+SPECIAL_ICONS[special]+'</i>':"")+
      (p1?'<em class="pawn p1-pawn">'+escapeHtml((names[0]||"P").charAt(0).toUpperCase())+'</em>':"")+
      (p2?'<em class="pawn p2-pawn">'+escapeHtml((names[1]||"P").charAt(0).toUpperCase())+'</em>':"")+
    '</div>';
  }).join('')+'</div>';
}
export function renderSnake(s,names){
  const turnName=names[s.turn]||"Player";
  const winnerName=names[s.winner]||"Player";
  const status=s.finished?"Game Complete":s.event?.type==="challenge"?SPECIAL_LABELS[s.event.kind]:s.event?.type==="ladder"?"Ladder":s.event?.type==="snake"?"Snake":s.event?.type==="overshoot"?"Too Far":s.event?.type==="skip"?"Skipped":"Your Turn";
  let panel="";
  if(s.finished){
    panel='<section class="snake-winner card"><div class="winner-mark">&hearts;</div><div class="eyebrow">Winner</div><h2>'+escapeHtml(winnerName)+' reached 100.</h2><p>Game selesai tepat di kotak terakhir. Simpan momen ini sebelum bermain lagi.</p><div class="memory-form"><label for="snake-memory-note">Memory &amp; Moment</label><textarea id="snake-memory-note" data-snake-note placeholder="Tulis satu kalimat tentang momen ini..."></textarea><button class="btn primary full" data-mini="snake-save-memory" '+(s.memorySaved?"disabled":"")+'>'+(s.memorySaved?"Memory Saved &#10003;":"Save Memory & Moment")+'</button></div><button class="btn ghost full" data-mini="snake-reset">Play Again</button></section>';
  }else if(s.event?.type==="challenge"){
    panel='<section class="snake-challenge card"><div class="eyebrow">'+escapeHtml(SPECIAL_LABELS[s.event.kind])+' - '+s.mode.toUpperCase()+'</div><h2>Do it together.</h2><p class="snake-challenge-text">'+escapeHtml(s.challenge.text)+'</p><div class="btn-row"><button class="btn primary" data-mini="snake-done">Done</button><button class="btn ghost" data-mini="snake-skip">Skip -3</button></div></section>';
  }else if(s.event?.type==="ladder"||s.event?.type==="snake"||s.event?.type==="overshoot"||s.event?.type==="skip"){
    const message=s.event.type==="ladder"?"You found a shortcut. Up you go.":s.event.type==="snake"?"A slide down. Keep going.":s.event.type==="overshoot"?"That roll goes past 100. No move this turn.":"Challenge skipped. Move back 3 squares.";
    panel='<section class="snake-event card"><div class="event-icon">'+(s.event.type==="ladder"?"&#8599;":s.event.type==="snake"?"&#8600;":s.event.type==="skip"?"-3":"6")+'</div><div class="eyebrow">'+escapeHtml(status)+'</div><h2>'+escapeHtml(message)+'</h2><p>Current position: <strong>'+s.pos[s.turn]+'</strong></p><button class="btn primary full" data-mini="snake-continue">Continue</button></section>';
  }
  return '<div class="ks-screen snake-screen '+(s.animating?"is-animating":"")+'">'+
    '<div class="ks-header"><button class="ks-back" data-action="minigames-menu">&larr; Games</button><div><b>Snake &amp; Ladder</b><small>IGNITE COUPLE GAME</small></div><button class="ks-reset" data-mini="snake-reset">Reset</button></div>'+
    '<div class="snake-hud"><div class="snake-player '+(s.turn===0&&!s.finished?"active":"")+'"><strong>'+escapeHtml(names[0])+'</strong><span>'+s.pos[0]+' / 100</span></div><div class="snake-turn">TURN</div><div class="snake-player '+(s.turn===1&&!s.finished?"active":"")+'"><strong>'+escapeHtml(names[1])+'</strong><span>'+s.pos[1]+' / 100</span></div></div>'+
    '<div class="snake-mode"><span>Challenge</span><div><button class="btn '+(s.mode==="normal"?"primary":"ghost")+'" data-mini="snake-mode" data-value="normal">Normal</button><button class="btn '+(s.mode==="extreme"?"primary":"ghost")+'" data-mini="snake-mode" data-value="extreme">Extreme</button></div></div>'+
    renderBoard(s,names)+
    '<div class="snake-control"><div class="dice-result">'+(s.lastRoll?s.lastRoll:"&mdash;")+'</div><div class="snake-turn-copy">'+(s.finished?"Winner: "+escapeHtml(winnerName):"Turn: "+escapeHtml(turnName))+'</div>'+(!s.finished&&!s.event?'<button class="btn primary snake-roll" data-mini="snake-roll" '+(s.animating?"disabled":"")+'>ROLL DICE</button>':"")+'</div>'+
    panel+
  '</div>';
}
