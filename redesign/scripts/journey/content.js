import {allNormalTopics,allExplicitTopics,allTruthTopics,allDareTopics,allIntimateTruthTopics,allIntimateDareTopics} from "../data/topics.js?v=20260925-20";
export const starterNormalCards=allNormalTopics;
export const starterExplicitCards=allExplicitTopics;
export const starterTruth=allTruthTopics;
export const starterDare=allDareTopics;
export const starterIntimateTruth=allIntimateTruthTopics;
export const starterIntimateDare=allIntimateDareTopics;
export function randomUnused(pool,used){const available=pool.filter(x=>!used.has(x));const source=available.length?available:pool;if(!source.length)return"";const value=source[Math.floor(Math.random()*source.length)];used.add(value);return value}
