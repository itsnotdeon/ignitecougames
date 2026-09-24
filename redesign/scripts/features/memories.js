const KEY="ignite-memories-v1";
function read(){try{const v=JSON.parse(localStorage.getItem(KEY)||"[]");return Array.isArray(v)?v:[]}catch{return[]}}
function write(v){localStorage.setItem(KEY,JSON.stringify(v));return v}
export function getMemories(){return read()}
export function saveMemory(memory){const item={id:"memory-"+Date.now(),date:new Date().toISOString(),journey:memory.journey||"normal",xp:Number(memory.xp)||0,moment:String(memory.moment||"A moment together"),note:String(memory.note||"").trim(),photo:memory.photo||"",...memory};const list=[item,...read()].slice(0,100);write(list);return item}
export function getStreak(){const days=new Set(read().map(x=>String(x.date||"").slice(0,10)).filter(Boolean));let streak=0;const d=new Date();while(days.has(d.toISOString().slice(0,10))){streak++;d.setDate(d.getDate()-1)}return streak}
export function getMemoryStats(){const all=read();return{count:all.length,streak:getStreak(),latest:all[0]||null,photos:all.filter(x=>x.photo).length}}
export function getMemoryTimeline(){return read().slice(0,12).map(x=>({date:x.date,journey:x.journey,moment:x.moment,note:x.note||""}))}
export function clearMemories(){localStorage.removeItem(KEY)}
