const NORMAL=["Beri pasanganmu satu pujian spesifik yang jarang kamu ucapkan.","Tentukan satu aktivitas kecil yang harus kalian lakukan bersama selama 3 menit.","Pilih lagu untuk pasanganmu dan jelaskan kenapa lagu itu cocok.","Minta pasanganmu memilih: pelukan 20 detik atau tatapan mata 20 detik.","Buat satu aturan playful untuk ronde ini, lalu jalankan bersama.","Tatap mata pasanganmu selama 20 detik sebelum melakukan command ini.","Buat pasanganmu tersenyum dalam waktu 30 detik.","Ceritakan satu hal kecil yang paling kamu sukai dari pasanganmu hari ini."];
const DARK=["Tentukan suasana malam ini dengan satu pilihan musik atau pencahayaan.","Berikan pasanganmu satu tantangan playful yang bisa ditolak tanpa perlu alasan.","Pilih satu pertanyaan berani namun tetap nyaman untuk dijawab pasangan.","Tukar peran selama satu menit dan improvise adegan singkat.","Minta pasanganmu memilih satu gesture affection yang terasa nyaman.","Bisikkan satu pujian spesifik kepada pasanganmu.","Pegang tangan pasanganmu selama 30 detik tanpa berbicara.","Pilih satu cara romantis untuk membuat pasanganmu merasa diperhatikan malam ini."];
const POWERS=[
{id:"pc1",name:"Titah Ganda",icon:"🃏",desc:"Ambil satu Command Card tambahan pada ronde ini."},
{id:"pc2",name:"Hak Pilih",icon:"📖",desc:"Pilih sendiri Command Card, bukan mengambilnya secara acak."},
{id:"pc3",name:"Perpanjangan Takhta",icon:"👑",desc:"Tetap menjadi King/Queen pada ronde berikutnya. Lempar ulang dilewati."},
{id:"pc4",name:"Tukar Takdir",icon:"↔️",desc:"Tukar King dan Slave untuk satu Command Card ini."},
{id:"pc5",name:"Waktu Milikku",icon:"⏳",desc:"Gandakan durasi command yang memiliki hitungan waktu."}
];
const fresh=()=>({stage:"consent",round:1,mode:"normal",king:null,slave:null,rolled:false,rollP1:null,rollP2:null,rolling:false,command:null,commandDrawn:false,currentCommands:[],responded:false,chooseOpen:false,drawAgain:false,extendThrone:false,swapFate:false,originalKing:null,originalSlave:null,doubleTime:false,usedCommands:[],usedPowers:{0:[],1:[]},kingCount:{0:0,1:0},slaveCount:{0:0,1:0}});
export function createKingState(){return fresh()}
const esc=v=>String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]));
const pool=s=>s.mode==="dark"?DARK:NORMAL;
const pname=(names,i)=>names[i]||"Player "+(i+1);
function timeBoost(s,t){return s.doubleTime?t.replace(/(\d+)\s*(detik|menit|jam)/gi,(m,n,u)=>(Number(n)*2)+" "+u):t}
function assign(s){s.king=s.rollP1>s.rollP2?0:1;s.slave=1-s.king;s.rolled=true;s.kingCount[s.king]++;s.slaveCount[s.slave]++}
function next(s){
 if(s.swapFate){s.king=s.originalKing;s.slave=s.originalSlave;s.swapFate=false;s.originalKing=null;s.originalSlave=null}
 const keep=s.extendThrone;s.round++;s.command=null;s.commandDrawn=false;s.currentCommands=[];s.responded=false;s.chooseOpen=false;s.drawAgain=false;s.doubleTime=false;
 if(keep){s.extendThrone=false;s.kingCount[s.king]++;s.slaveCount[s.slave]++;s.rolled=true}
 else{s.rolled=false;s.king=null;s.slave=null;s.rollP1=null;s.rollP2=null}
}
function randomCommand(s){
 const p=pool(s),avail=p.map((x,i)=>s.usedCommands.includes(i)?null:i).filter(x=>x!==null),source=avail.length?avail:p.map((_,i)=>i),i=source[Math.floor(Math.random()*source.length)];
 if(!s.usedCommands.includes(i))s.usedCommands.push(i);s.currentCommands=[timeBoost(s,p[i])];s.command=s.currentCommands[0];s.commandDrawn=true;s.chooseOpen=false;s.responded=false
}
function chooseCommand(s,i){const p=pool(s);if(!Number.isInteger(i)||!p[i])return;if(!s.usedCommands.includes(i))s.usedCommands.push(i);s.currentCommands=[timeBoost(s,p[i])];s.command=s.currentCommands[0];s.commandDrawn=true;s.chooseOpen=false}
function usePower(s,id){
 if(s.king===null)return;const used=s.usedPowers[s.king];if(used.includes(id))return;if(id==="pc2"&&s.commandDrawn)return;used.push(id);
 if(id==="pc1")s.drawAgain=true;
 if(id==="pc2")s.chooseOpen=true;
 if(id==="pc3")s.extendThrone=true;
 if(id==="pc4"){s.originalKing=s.king;s.originalSlave=s.slave;s.king=s.originalSlave;s.slave=s.originalKing;s.swapFate=true}
 if(id==="pc5")s.doubleTime=true
}
export function kingAction(s,a,v){
 if(a==="consent"){s.stage="game";return}
 if(a==="mode"){s.mode=s.mode==="normal"?"dark":"normal";s.usedCommands=[];s.command=null;s.currentCommands=[];s.commandDrawn=false;return}
 if(a==="roll"){if(s.rolling)return;s.rolling=true;s.rollP1=1+Math.floor(Math.random()*6);s.rollP2=1+Math.floor(Math.random()*6);if(s.rollP1===s.rollP2){s.rollP1=null;s.rollP2=null;s.rolling=false;return}assign(s);s.rolling=false;return}
 if(a==="draw"){if(s.chooseOpen)return;randomCommand(s);return}
 if(a==="choose"){chooseCommand(s,Number(v));return}
 if(a==="draw-again"){if(!s.drawAgain||s.currentCommands.length!==1)return;randomCommand(s);s.currentCommands=[s.currentCommands[0],s.command];s.command=s.currentCommands.join("\\n\\n");s.drawAgain=false;return}
 if(a==="power"){usePower(s,v);return}
 if(a==="respond"){if(!s.commandDrawn||s.responded)return;s.responded=true;next(s);return}
 if(a==="reset"){Object.assign(s,fresh())}
}
function powerSheet(s){
 const used=s.king===null?[]:s.usedPowers[s.king],locked=id=>id==="pc2"&&s.commandDrawn;
 return '<div class="ks-modal-backdrop"><div class="ks-sheet"><button class="ks-sheet-close" data-mini="ks-power-close">×</button><span class="ks-kicker">POWER CARDS</span><h3>King controls the round.</h3><p>Each player owns 5 cards. Each card can be used once per session.</p><div class="ks-power-list">'+POWERS.map(p=>{const u=used.includes(p.id),l=locked(p.id);return '<div class="ks-power-item '+(u?"used":"")+'"><div><b>'+p.icon+" "+esc(p.name)+'</b><small>'+esc(p.desc)+'</small></div><button data-mini="ks-power" data-value="'+p.id+'" '+(u||l?"disabled":"")+'>'+(u?"Used":l?"Locked":"Use")+'</button></div>'}).join("")+'</div></div></div>'
}
export function renderKing(s,names){
 const p1=pname(names,0),p2=pname(names,1);
 if(s.stage==="consent")return '<section class="ks-screen ks-consent-screen"><div class="ks-title-mark">👑</div><span class="ks-kicker">KING &amp; SLAVE</span><h2>Power stays playful.</h2><p class="ks-lead">Satu orang memegang mahkota. Satu orang menerima command. Kalian selalu boleh berhenti.</p><div class="ks-consent-list"><div><span>01</span><p><b>Consent selalu menang.</b> Command bukan kewajiban di luar batas yang kalian sepakati.</p></div><div><span>02</span><p><b>Role hanya untuk ronde ini.</b> Mahkota berpindah setiap ronde kecuali King memakai Power tertentu.</p></div><div><span>03</span><p><b>Slave punya dua pilihan.</b> Jalankan atau skip. Tidak perlu memberi alasan.</p></div></div><label class="ks-consent-check"><input id="ks-consent" type="checkbox"><span>Kami berdua setuju bermain dan tahu bahwa kami dapat berhenti kapan saja.</span></label><button class="ks-main-btn" data-mini="ks-consent">Mulai Sesi</button></section>';
 const king=s.king===0?p1:p2,slave=s.slave===0?p1:p2, mode=s.mode==="normal"?"Normal":"After Dark";
 let body="";
 if(!s.rolled)body='<section class="ks-draw-stage"><div class="ks-dice-pair"><div><span>'+(s.rollP1||"?")+'</span><small>'+esc(p1)+'</small></div><div><span>'+(s.rollP2||"?")+'</span><small>'+esc(p2)+'</small></div></div><p class="ks-fair-note">'+(s.rollP1===null?"Tie. Roll again — both players get a fresh die roll.":"Satu dadu untuk setiap pemain. Nilai tertinggi memegang mahkota.")+'</p><button class="ks-main-btn" data-mini="ks-roll">'+(s.rollP1===null?"Roll Again":"Reveal King")+'</button></section>';
 else if(!s.commandDrawn)body='<section class="ks-ready-stage"><div class="ks-crown"><span>👑</span><b>'+esc(king)+'</b><small>KING / QUEEN</small></div><div class="ks-slave-note">⛓️ '+esc(slave)+' menerima Command</div><button class="ks-main-btn" data-mini="ks-draw">'+(s.chooseOpen?"Choose Command":"Draw Command Card")+'</button></section>';
 else {
   const cards=s.currentCommands.map((c,i)=>'<div class="ks-command-part"><small>COMMAND '+(i+1)+'</small><strong>'+esc(c)+'</strong></div>').join("");
   body='<section class="ks-result-focus"><span class="ks-result-label">ACTION</span><div class="ks-command-card-main">'+cards+'</div><div class="ks-command-target">⛓️ '+esc(slave)+' · your move</div><div class="ks-response"><button class="ks-response-run" data-mini="ks-respond" data-value="run">Jalankan</button><button class="ks-response-skip" data-mini="ks-respond" data-value="skip">Skip</button></div>'+(s.drawAgain&&s.currentCommands.length===1?'<button class="ks-draw-again" data-mini="ks-draw-again">🃏 Draw Again</button>':"")+'</section>';
 }
 const used=s.king===null?0:s.usedPowers[s.king].length;
 const roles=s.rolled?'<div class="ks-role-strip"><div class="ks-role-person '+(s.king===0?"king":"slave")+'"><span>'+(s.king===0?"👑":"⛓️")+'</span><b>'+esc(p1)+'</b><small>'+(s.king===0?"KING / QUEEN":"SLAVE")+'</small></div><div class="ks-vs">VS</div><div class="ks-role-person '+(s.king===1?"king":"slave")+'"><span>'+(s.king===1?"👑":"⛓️")+'</span><b>'+esc(p2)+'</b><small>'+(s.king===1?"KING / QUEEN":"SLAVE")+'</small></div></div>':"";
 const scores=s.rolled?'<p class="ks-scoreline">'+esc(p1)+" "+s.kingCount[0]+"K · "+s.slaveCount[0]+"S / "+esc(p2)+" "+s.kingCount[1]+"K · "+s.slaveCount[1]+"S</p>":"";
 const powers=s.rolled?'<button class="ks-power-trigger" data-mini="ks-power-open">♠ <b>Power Cards</b><small>'+(5-used)+'/5 available</small></button>':"";
 const choose=s.chooseOpen&&!s.commandDrawn?'<div class="ks-modal-backdrop"><div class="ks-sheet"><button class="ks-sheet-close" data-mini="ks-choice-close">×</button><span class="ks-kicker">HAK PILIH</span><h3>Choose the command.</h3><p>King memilih card yang akan dibacakan.</p><div class="ks-choice-list">'+pool(s).map((c,i)=>'<button data-mini="ks-choose" data-value="'+i+'"><span>'+String(i+1).padStart(2,"0")+"</span>"+esc(c)+"</button>").join("")+"</div></div></div>':"";
 return '<section class="ks-screen"><header class="ks-header"><button class="ks-back" data-action="minigames-menu">← Games</button><div><b>King &amp; Slave</b><small>'+mode+'</small></div><button class="ks-reset" data-mini="ks-reset">Reset</button></header><div class="ks-progress"><span>ROUND '+s.round+'</span><i></i><span>'+(s.rolled?esc(king):"CROWN DRAW")+'</span></div>'+roles+body+powers+scores+choose+(s.rolled&&!s.commandDrawn?'<button class="ks-mode-switch" data-mini="ks-mode">Switch to '+(s.mode==="normal"?"After Dark":"Normal")+'</button>':"")+(s.rolled&&s.commandDrawn&&s.doubleTime?'<p class="ks-active-note">⏳ Time power active this round.</p>':"")+((s.rolled&&s.commandDrawn&&s.swapFate)?'<p class="ks-active-note">↔️ Fate swapped for this command.</p>':"")+(s.rolled&&!s.commandDrawn&&!s.chooseOpen&&s.extendThrone?'<p class="ks-active-note">👑 Throne extended: same King this round.</p>':"")+'</section>'+(s.__powerOpen?powerSheet(s):"")
}
