import {topicPools,explicitTopicPool,truthPool,darePool} from "../data/topics.js?v=20260924-01";

export const starterNormalCards=topicPools;
export const starterExplicitCards=explicitTopicPool;
export const starterTruth=truthPool;
export const starterDare=darePool;

// Keep a smaller intimate set for the guided journey; the full exported library remains available to the app.
export const starterIntimateTruth=truthPool.slice(0,20);
export const starterIntimateDare=darePool.slice(0,20);

export function randomUnused(pool,used){
  const available=pool.filter(x=>!used.has(x));
  const source=available.length?available:pool;
  if(!source.length)return"";
  const value=source[Math.floor(Math.random()*source.length)];
  used.add(value);
  return value;
}
