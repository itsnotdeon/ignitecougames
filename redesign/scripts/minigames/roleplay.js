const NORMAL_ROLES=[
{id:"date-director",emoji:"🎬",name:"Date Director",desc:"Satu orang memimpin suasana kencan.",items:[
{context:"Kalian punya 10 menit untuk membuat suasana terasa seperti first date.",challenge:"Pilih satu detail kecil—musik, tempat duduk, atau cara menyapa—lalu jalankan peranmu."},
{context:"Salah satu dari kalian adalah host acara kencan malam ini.",challenge:"Buat opening singkat yang membuat pasanganmu merasa benar-benar disambut."}
]},
{id:"mysterious-stranger",emoji:"🕯️",name:"Mysterious Stranger",desc:"Bertemu seolah kalian baru pertama kali.",items:[
{context:"Kalian duduk di tempat yang sama tetapi belum saling mengenal.",challenge:"Perkenalkan diri dengan tiga fakta, satu di antaranya harus terdengar tidak terduga."},
{context:"Kamu mendapat kesempatan menanyakan satu hal yang biasanya tidak kamu tanyakan.",challenge:"Ajukan pertanyaan itu dalam karakter dan dengarkan jawabannya tanpa memotong."}
]},
{id:"travel-partners",emoji:"✈️",name:"Travel Partners",desc:"Kalian sedang merencanakan perjalanan spontan.",items:[
{context:"Pesawat berangkat malam ini dan kalian belum punya itinerary.",challenge:"Dalam satu menit, sepakati destinasi dan satu aktivitas yang wajib dilakukan bersama."},
{context:"Salah satu koper tertukar.",challenge:"Buat adegan singkat tentang bagaimana kalian menyelesaikan masalah itu sebagai tim."}
]}
];
const DARK_ROLES=[
{id:"secret-agent",emoji:"🕶️",name:"Secret Agents",desc:"Misi rahasia membutuhkan kerja sama.",items:[
{context:"Kalian harus menyampaikan pesan rahasia tanpa membuat orang lain curiga.",challenge:"Buat kode sederhana dan gunakan untuk menyampaikan satu pesan pendek."},
{context:"Misi hampir gagal karena salah satu agen kehilangan fokus.",challenge:"Mainkan adegan 30 detik: satu agen menenangkan, satu agen menjelaskan situasi."}
]},
{id:"vip-hosts",emoji:"🥂",name:"VIP Hosts",desc:"Kalian menjadi pasangan tuan rumah malam ini.",items:[
{context:"Tamu penting akan datang sebentar lagi.",challenge:"Salah satu menjadi host, satu menjadi tamu. Lakukan sambutan yang playful selama 30 detik."},
{context:"Malam ini harus terasa berbeda dari biasanya.",challenge:"Ciptakan satu aturan kecil untuk suasana malam ini dan jalankan selama tiga menit."}
]}
];
function pick(pool,used){const available=pool.filter(x=>!used.has(x.id));const source=available.length?available:pool;const role=source[Math.floor(Math.random()*source.length)];used.add(role.id);return role}
export function createRoleplayState(){return{mode:"normal",role:null,item:null,usedRoles:new Set(),usedItems:new Map()}}
export function setRoleplayMode(s,mode){s.mode=mode==="dark"?"dark":"normal";s.role=null;s.item=null;s.usedRoles=new Set();s.usedItems=new Map()}
export function nextRoleplay(s){const roles=s.mode==="dark"?DARK_ROLES:NORMAL_ROLES;const role=s.role&&((s.usedItems.get(s.role.id)||new Set()).size< s.role.items.length)?s.role:pick(roles,s.usedRoles);let used=s.usedItems.get(role.id)||new Set();if(used.size>=role.items.length){used=new Set();s.usedItems.set(role.id,used)}const idx=Math.floor(Math.random()*role.items.length);used.add(idx);s.usedItems.set(role.id,used);s.role=role;s.item=role.items[idx];return s}
export function renderRoleplay(s){if(!s.role)return '<div class="mini-intro"><span class="game-icon">🎭</span><h3>Roleplay</h3><p>Pilih karakter, masuk ke adegan, lalu biarkan percakapan berkembang.</p><button class="btn primary full" data-mini="roleplay-next">Draw Role</button></div>';return '<div class="game-active"><div class="game-meta">'+s.role.emoji+' '+s.role.name+'</div><h3>'+escapeHtml(s.role.name)+'</h3><p class="muted">'+escapeHtml(s.role.desc)+'</p><div class="game-prompt"><small>SCENE</small><strong>'+escapeHtml(s.item.context)+'</strong><small>YOUR MOVE</small><span>'+escapeHtml(s.item.challenge)+'</span></div><div class="btn-row"><button class="btn ghost" data-mini="roleplay-next">Next Scene</button><button class="btn primary" data-mini="roleplay-switch">Switch Role</button></div></div>'}
function escapeHtml(v){return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]))}
