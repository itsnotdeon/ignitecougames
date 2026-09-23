const KEY="ignite-preferences-v1";
const DEFAULT={vibes:["Romantic"],duration:"medium",intensity:"balanced"};
export const VIBES=["Romantic","Playful","Deep","Competitive","Spontaneous","Intimate"];
function read(){try{return {...DEFAULT,...JSON.parse(localStorage.getItem(KEY)||"{}")}}catch{return{...DEFAULT}}}
export function getPreferences(){const p=read();return{...p,vibes:Array.isArray(p.vibes)?p.vibes.filter(v=>VIBES.includes(v)):DEFAULT.vibes}}
export function savePreferences(next){const p={...DEFAULT,...next,vibes:Array.isArray(next.vibes)?next.vibes.filter(v=>VIBES.includes(v)):DEFAULT.vibes};localStorage.setItem(KEY,JSON.stringify(p));return p}
