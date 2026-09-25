import {allNormalTopics,allExplicitTopics,allTruthTopics,allDareTopics,allIntimateTruthTopics,allIntimateDareTopics} from "../data/topics.js?v=20260925-20";
export const starterNormalCards=allNormalTopics;
export const starterExplicitCards=allExplicitTopics;
export const starterTruth=allTruthTopics;
export const starterDare=allDareTopics;
export const starterIntimateTruth=allIntimateTruthTopics;
export const starterIntimateDare=allIntimateDareTopics;
const CUSTOM_TOPICS_KEY="ignite-custom-topics-v1";
function custom(key){try{const raw=JSON.parse(localStorage.getItem(CUSTOM_TOPICS_KEY)||"{}");return Array.isArray(raw[key])?raw[key].filter(v=>typeof v==="string"&&v.trim()):[]}catch{return[]}}
function live(base,key){const extra=custom(key);return[...base,...extra.filter(v=>!base.includes(v))]}
export const getNormalCards=()=>live(starterNormalCards,"normalCards");
export const getExplicitCards=()=>live(starterExplicitCards,"explicitCards");
export const getTruthTopics=()=>live(starterTruth,"truth");
export const getDareTopics=()=>live(starterDare,"dare");
export const getIntimateTruthTopics=()=>live(starterIntimateTruth,"intimateTruth");
export const getIntimateDareTopics=()=>live(starterIntimateDare,"intimateDare");
export function randomUnused(pool,used){const available=pool.filter(x=>!used.has(x));const source=available.length?available:pool;if(!source.length)return"";const value=source[Math.floor(Math.random()*source.length)];used.add(value);return value}
