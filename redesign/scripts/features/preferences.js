const KEY="ignite-preferences-v1";
const DEFAULT={vibes:["Romantic"],duration:"medium",intensity:"balanced"};
export const VIBES=["Romantic","Playful","Deep","Competitive","Spontaneous","Intimate"];
function read(){try{const raw=JSON.parse(localStorage.getItem(KEY)||"{}");const vibe=Array.isArray(raw.vibes)&&raw.vibes.length?raw.vibes[0]:DEFAULT.vibes[0];return {...DEFAULT,...raw,vibes:[VIBES.includes(vibe)?vibe:DEFAULT.vibes[0]}}catch{return{...DEFAULT}}}
export function getPreferences(){const p=read();return{...p,vibes:Array.isArray(p.vibes)&&p.vibes.length?[p.vibes[0]]:DEFAULT.vibes}}
export function savePreferences(next){const requested=Array.isArray(next?.vibes)&&next.vibes.length?next.vibes[0]:DEFAULT.vibes[0];const vibe=VIBES.includes(requested)?requested:DEFAULT.vibes[0];const p={...DEFAULT,...next,vibes:[vibe]};localStorage.setItem(KEY,JSON.stringify(p));return p}
