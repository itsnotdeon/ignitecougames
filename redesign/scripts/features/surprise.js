import {chooseSurprise} from "./dynamicJourney.js?v=20260926-01";
export function createSurpriseContext({level,preferences,memories,context=null}){const ctx=chooseSurprise({level,preferences,memories,context});return{...ctx,targetSteps:Math.max(3,Math.min(12,Number(preferences?.steps)||5))}}
