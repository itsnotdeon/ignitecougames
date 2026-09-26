const KEY="ignite-context-v1";
export const MOODS=[
 {id:"romantic",label:"Romantic",icon:"♥",energy:"medium",intention:"connect"},
 {id:"playful",label:"Playful",icon:"✦",energy:"high",intention:"play"},
 {id:"calm",label:"Calm",icon:"○",energy:"low",intention:"relax"},
 {id:"deep",label:"Deep",icon:"◇",energy:"medium",intention:"talk"},
 {id:"spontaneous",label:"Spontaneous",icon:"↗",energy:"high",intention:"explore"},
 {id:"intimate",label:"Intimate",icon:"☾",energy:"medium",intention:"connect"}
];
const PERIODS=[{id:"morning",label:"Morning",start:5,end:11},{id:"midday",label:"Midday",start:11,end:15},{id:"afternoon",label:"Afternoon",start:15,end:18},{id:"evening",label:"Evening",start:18,end:23},{id:"night",label:"Night",start:23,end:5}];
function read(){try{const value=JSON.parse(localStorage.getItem(KEY)||"{}");return value&&typeof value==="object"?value:{}}catch{return{}}}
export function getTimeContext(date=new Date()){const hour=date.getHours();const period=PERIODS.find(p=>p.start<p.end?hour>=p.start&&hour<p.end:hour>=p.start||hour<p.end)||PERIODS[0];return{hour,minute:date.getMinutes(),period:period.id,periodLabel:period.label,isWeekend:[0,6].includes(date.getDay()),dateKey:[date.getFullYear(),String(date.getMonth()+1).padStart(2,"0"),String(date.getDate()).padStart(2,"0")].join("-")}}
export function getMood(){const mood=read().mood;return MOODS.some(item=>item.id===mood)?mood:null}
export function setMood(mood){if(!MOODS.some(item=>item.id===mood))return null;const next={...read(),mood,updatedAt:new Date().toISOString()};localStorage.setItem(KEY,JSON.stringify(next));return next}
export function clearMood(){localStorage.removeItem(KEY)}
export function getMoodMeta(mood=getMood()){return MOODS.find(item=>item.id===mood)||null}
export function buildContext({date=new Date(),mood=getMood(),level=1,preferences={},memories=[]}={}){const time=getTimeContext(date);const moodMeta=getMoodMeta(mood);const recent=Array.isArray(memories)?memories.slice(0,3):[];return{time,mood:moodMeta?{id:moodMeta.id,label:moodMeta.label,energy:moodMeta.energy,intention:moodMeta.intention}:null,level:Number(level)||1,preferences:{vibes:Array.isArray(preferences.vibes)&&preferences.vibes.length?[preferences.vibes[0]]:["Romantic"],steps:Math.max(3,Math.min(12,Number(preferences.steps)||5))},recentJourneys:recent.map(item=>item.journey).filter(Boolean)}}