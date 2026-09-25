import {allNormalTopics,allExplicitTopics,allTruthTopics,allDareTopics,allIntimateTruthTopics,allIntimateDareTopics} from "../data/topics.js?v=20260926-01";
export const starterNormalCards=allNormalTopics;
export const starterExplicitCards=allExplicitTopics;
export const starterTruth=allTruthTopics;
export const starterDare=allDareTopics;
export const starterIntimateTruth=allIntimateTruthTopics;
export const starterIntimateDare=allIntimateDareTopics;

const ACTIVE_CONTENT_KEY="ignite-active-content-v1";
const LEGACY_CUSTOM_KEY="ignite-custom-topics-v1";
const KEYS=["normalCards","explicitCards","truth","dare","intimateTruth","intimateDare"];
function clean(v){return Array.isArray(v)?v.filter(x=>typeof x==="string"&&x.trim()).map(x=>x.trim()):[]}
function readFull(){try{const raw=JSON.parse(globalThis.localStorage?.getItem(ACTIVE_CONTENT_KEY)||"null");if(!raw||typeof raw!=="object")return null;return Object.fromEntries(KEYS.map(k=>[k,clean(raw[k])]))}catch{return null}}
function readLegacy(k){try{const raw=JSON.parse(globalThis.localStorage?.getItem(LEGACY_CUSTOM_KEY)||"{}");return clean(raw[k])}catch{return[]}}
function live(base,k){const active=readFull();if(active)return active[k]||[];const extra=readLegacy(k);return[...base,...extra.filter(x=>!base.includes(x))]}
export const getNormalCards=()=>live(starterNormalCards,"normalCards");
export const getExplicitCards=()=>live(starterExplicitCards,"explicitCards");
export const getTruthTopics=()=>live(starterTruth,"truth");
export const getDareTopics=()=>live(starterDare,"dare");
export const getIntimateTruthTopics=()=>live(starterIntimateTruth,"intimateTruth");
export const getIntimateDareTopics=()=>live(starterIntimateDare,"intimateDare");
export function randomUnused(pool,used){const available=pool.filter((x,i)=>!used.has(i)&&x);const source=available.length?available:pool;if(!source.length)return"";return source[Math.floor(Math.random()*source.length)]}
