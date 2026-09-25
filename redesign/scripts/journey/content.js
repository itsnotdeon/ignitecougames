import {allNormalTopics,allExplicitTopics,allTruthTopics,allDareTopics,allIntimateTruthTopics,allIntimateDareTopics} from "../data/topics.js?v=20260925-20";
export const starterNormalCards=allNormalTopics;
export const starterExplicitCards=allExplicitTopics;
export const starterTruth=allTruthTopics;
export const starterDare=allDareTopics;
export const starterIntimateTruth=allIntimateTruthTopics;
export const starterIntimateDare=allIntimateDareTopics;
const CUSTOM_TOPICS_KEY="ignite-custom-topics-v1";
const ACTIVE_TOPICS_KEY="ignite-active-topics-v1";
const TOPIC_KEYS=["normalCards","explicitCards","truth","dare","intimateTruth","intimateDare"];
const starterMap={normalCards:starterNormalCards,explicitCards:starterExplicitCards,truth:starterTruth,dare:starterDare,intimateTruth:starterIntimateTruth,intimateDare:starterIntimateDare};
function cleanList(value){return Array.isArray(value)?value.filter(v=>typeof v==="string"&&v.trim()).map(v=>v.trim()):[]}
function readActive(){try{const raw=JSON.parse(globalThis.localStorage?.getItem(ACTIVE_TOPICS_KEY)||"null");if(!raw||typeof raw!=="object")return null;return Object.fromEntries(TOPIC_KEYS.map(key=>[key,cleanList(raw[key])]))}catch{return null}}
function custom(key){try{const storage=globalThis.localStorage;const raw=JSON.parse(storage?.getItem(CUSTOM_TOPICS_KEY)||"{}");return cleanList(raw[key])}catch{return[]}}
function live(base,key){const active=readActive();if(active)return active[key]||[];const extra=custom(key);return[...base,...extra.filter(v=>!base.includes(v))]}
export const getNormalCards=()=>live(starterNormalCards,"normalCards");
export const getExplicitCards=()=>live(starterExplicitCards,"explicitCards");
export const getTruthTopics=()=>live(starterTruth,"truth");
export const getDareTopics=()=>live(starterDare,"dare");
export const getIntimateTruthTopics=()=>live(starterIntimateTruth,"intimateTruth");
export const getIntimateDareTopics=()=>live(starterIntimateDare,"intimateDare");
export function randomUnused(pool,used){const available=pool.filter(x=>!used.has(x));const source=available.length?available:pool;if(!source.length)return"";const value=source[Math.floor(Math.random()*source.length)];used.add(value);return value}
