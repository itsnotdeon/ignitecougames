const KEY="ignite-adaptive-v1";
const DEFAULT={vibes:{Romantic:0,Playful:0,Deep:0,Competitive:0,Spontaneous:0,Intimate:0},seen:0,actions:0};
const VIBE_RULES={
  Romantic:["cinta","sayang","romantis","rindu","kangen","peluk","cium","kasih","pasangan","hubungan","kencan","date","manis","mesra","jodoh","bahagia","senyum"],
  Playful:["lucu","tertawa","ketawa","seru","game","permainan","kuis","tebak","konyol","receh","slogan","nama panggilan","tantangan","bermain","fun","musik","menari","dansa"],
  Deep:["kenapa","mengapa","mimpi","masa depan","ketakutan","takut","harapan","tujuan","makna","arti","belajar","jujur","penting","kenangan","ingat","perasaan","syukur","nasihat","paham","berubah","percaya","aman"],
  Competitive:["tantangan","challenge","menang","kalah","lomba","adu","kompetisi","skor","nilai","tebak","uji","berani","perlombaan"],
  Spontaneous:["kejutan","dadakan","random","acak","pilih","coba","baru","petualangan","tanpa rencana","mendadak","bebas","improvisasi","unik"],
  Intimate:["sentuh","cium","peluk","tubuh","leher","bahu","tangan","rambut","dekat","mesra","bisik","tatap","paha","sensual","gairah","intim","ranjang","malam"]
};
const MODE_RULES={
  normal:{Romantic:1,Playful:1,Deep:1,Competitive:1,Spontaneous:1,Intimate:0.5},
  dark:{Romantic:1,Playful:0.8,Deep:0.8,Competitive:0.7,Spontaneous:1.1,Intimate:1.8}
};
function read(){try{const v=JSON.parse(localStorage.getItem(KEY)||"{}");return{...DEFAULT,...v,vibes:{...DEFAULT.vibes,...(v.vibes||{})}}}catch{return{...DEFAULT,vibes:{...DEFAULT.vibes}}}}
function write(v){localStorage.setItem(KEY,JSON.stringify(v));return v}
function normalize(text){return String(text||"").toLowerCase().normalize("NFKD").replace(/[\u0300-\u036f]/g,"")}
function profile(text){const t=normalize(text),scores={};for(const [vibe,words] of Object.entries(VIBE_RULES))scores[vibe]=words.reduce((n,w)=>n+(t.includes(normalize(w))?1:0),0);return scores}
function topicVibes(text){const scores=profile(text),max=Math.max(...Object.values(scores));if(max===0)return["Spontaneous"];return Object.entries(scores).filter(([,n])=>n>=Math.max(1,max*0.5)).map(([v])=>v)}
function preferredVibes(preferences={}){const s=read(),base=Array.isArray(preferences.vibes)?preferences.vibes:[],learned=Object.entries(s.vibes).sort((a,b)=>b[1]-a[1]).map(([v])=>v).filter(v=>s.vibes[v]>0);return[...new Set([...base,...learned])].slice(0,4)}
export function getAdaptive(){return read()}
export function recordVibe(vibe,weight=1){if(!vibe)return read();const s=read();if(!(vibe in s.vibes))s.vibes[vibe]=0;s.vibes[vibe]+=weight;s.actions+=1;s.seen+=1;return write(s)}
export function recordInteraction(kind,vibe){const s=read();s.actions+=1;if(vibe&&s.vibes[vibe]!==undefined)s.vibes[vibe]+=1;if(kind==="one-more")s.seen+=1;return write(s)}
export function scoreTopic(text,{preferences={},mode="normal",used=false,previous=""}={}){const vibes=preferredVibes(preferences),p=profile(text),weights=MODE_RULES[mode]||MODE_RULES.normal;let score=vibes.reduce((n,v)=>n+(p[v]||0)*2*(weights[v]||1),0);const learned=read().vibes;for(const[v,n]of Object.entries(learned))if(n>0)score+=(p[v]||0)*Math.min(n,6)*0.35;if(previous){const pv=topicVibes(previous),cv=topicVibes(text);score+=pv.filter(v=>cv.includes(v)).length*0.8;if(pv.some(v=>v==="Playful"||v==="Spontaneous")&&cv.includes("Deep"))score+=1.5}if(used)score-=100;return score}
export function chooseAdaptive(pool,{preferences={},mode="normal",used=new Set(),vibes=[],previous=""}={}){const requested=[...new Set([...preferredVibes(preferences),...vibes])],candidates=pool.map((text,index)=>({text,index,score:scoreTopic(text,{preferences:{...preferences,vibes:requested},mode,used:used.has(index),previous})})).filter(x=>!used.has(x.index));if(!candidates.length)return pool[0]||"";candidates.sort((a,b)=>b.score-a.score);const topScore=candidates[0].score,top=candidates.filter(x=>x.score>=topScore-1.25);return top[Math.floor(Math.random()*top.length)].text}
export function topicProfile(text){return{vibes:topicVibes(text),scores:profile(text)}}
export function resetAdaptive(){localStorage.removeItem(KEY)}
