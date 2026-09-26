import {chooseSurprise} from "./dynamicJourney.js?v=20260927-04";
export function createSurpriseContext({level,preferences,memories,context=null}){return chooseSurprise({level,preferences,memories,context})}
