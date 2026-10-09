// @ts-nocheck
// Transitional migration copy; types are added as this module is audited.
import {chooseSurprise} from "./dynamicJourney.ts";
export function createSurpriseContext({level,preferences,memories,context=null}){return chooseSurprise({level,preferences,memories,context})}
