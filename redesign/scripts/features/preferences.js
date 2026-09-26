const KEY="ignite-preferences-v1";
const DEFAULT={vibes:["Romantic"],steps:5};
export const VIBES=["Romantic","Playful","Deep","Competitive","Spontaneous","Intimate"];
function read(){try{const raw=JSON.parse(localStorage.getItem(KEY)||"{}");const vibe=Array.isArray(raw.vibes)&&raw.vibes.length?raw.vibes[0]:DEFAULT.vibes[0];const legacy=raw.steps??(raw.duration==="short"?4:raw.duration==="long"?6:5);const steps=Math.max(3,Math.min(12,Number(legacy)||DEFAULT.steps));return {...DEFAULT,...raw,vibes:[VIBES.includes(vibe)?vibe:DEFAULT.vibes[0]],steps}}catch{return{...DEFAULT}}}
export function getPreferences(){const p=read();return{...p,vibes:Array.isArray(p.vibes)&&p.vibes.length?[p.vibes[0]]:DEFAULT.vibes,steps:Math.max(3,Math.min(12,Number(p.steps)||DEFAULT.steps))}}
export function savePreferences(next){const requested=Array.isArray(next?.vibes)&&next.vibes.length?next.vibes[0]:DEFAULT.vibes[0];const vibe=VIBES.includes(requested)?requested:DEFAULT.vibes[0];const steps=Math.max(3,Math.min(12,Number(next?.steps)||DEFAULT.steps));const p={vibes:[vibe],steps};localStorage.setItem(KEY,JSON.stringify(p));return p}
