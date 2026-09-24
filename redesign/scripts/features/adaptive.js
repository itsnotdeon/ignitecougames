const KEY="ignite-adaptive-v1";
const DEFAULT={vibes:{Romantic:0,Playful:0,Deep:0,Competitive:0,Spontaneous:0,Intimate:0},seen:0,actions:0};
function read(){try{const v=JSON.parse(localStorage.getItem(KEY)||"{}");return{...DEFAULT,...v,vibes:{...DEFAULT.vibes,...(v.vibes||{})}}}catch{return{...DEFAULT,vibes:{...DEFAULT.vibes}}}}
function write(v){localStorage.setItem(KEY,JSON.stringify(v));return v}
export function getAdaptive(){return read()}
export function recordVibe(vibe,weight=1){if(!vibe)return read();const s=read();if(!(vibe in s.vibes))s.vibes[vibe]=0;s.vibes[vibe]+=weight;s.actions+=1;s.seen+=1;return write(s)}
export function recordInteraction(kind,vibe){const s=read();s.actions+=1;if(vibe&&s.vibes[vibe]!==undefined)s.vibes[vibe]+=1;if(kind==="one-more")s.seen+=1;return write(s)}
export function preferredVibes(preferences={}){const s=read();const base=Array.isArray(preferences.vibes)?preferences.vibes:[];return Object.entries(s.vibes).sort((a,b)=>b[1]-a[1]).map(([v])=>v).filter(v=>s.vibes[v]>0).concat(base.filter(v=>!s.vibes[v])).slice(0,3)}
function score(text,vibes,mode){const t=String(text||"").toLowerCase();let n=0;const map={Romantic:["love","kiss","romantic","date","say","feel"],Playful:["fun","laugh","game","silly","funny","guess"],Deep:["why","future","fear","dream","remember","important","honest"],Competitive:["challenge","race","bet","win","lose"],Spontaneous:["surprise","random","choose","try","new"],Intimate:["touch","close","kiss","body","desire","intimate"]};for(const vibe of vibes){for(const word of map[vibe]||[])if(t.includes(word))n+=2}if(mode==="dark"&&t.includes("intimate"))n+=2;return n}
export function chooseAdaptive(pool,{preferences={},mode="normal",used=new Set(),vibes=[]}={}){const preferred=[...preferredVibes(preferences),...vibes];const candidates=pool.map((text,index)=>({text,index,score:score(text,preferred,mode)})).filter(x=>!used.has(x.index));if(!candidates.length)return pool[0]||"";candidates.sort((a,b)=>b.score-a.score||Math.random()-.5);const top=candidates.filter(x=>x.score===candidates[0].score);return top[Math.floor(Math.random()*top.length)].text}
export function resetAdaptive(){localStorage.removeItem(KEY)}
