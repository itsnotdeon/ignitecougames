import {getAdaptive} from "./adaptive.js?v=20260924-05";

export function buildJourney({level=1,preferences={},memories=[],context=null}={}){
 const vibes=Array.isArray(preferences.vibes)?preferences.vibes:[];
 const recent=context?.recentJourneys?.length?context.recentJourneys:memories.slice(0,3).map(m=>m.journey);
 const timePeriod=context?.time?.period||"";
 const mood=context?.mood?.id||"";
 const learned=Object.entries(getAdaptive().vibes||{}).sort((a,b)=>b[1]-a[1]);
 const learnedTop=learned[0]?.[0]||"";
 const previous=recent[0]||"";
 let id="normal";
 let reason="Built from your current level and recent moments.";

 if((vibes.includes("Intimate")||mood==="intimate"||learnedTop==="Intimate")&&level>=5){
   id="dark";
   reason="Your recent preferences suggest a deeper, more intimate pace.";
 }else if(mood==="playful"||vibes.includes("Playful")||learnedTop==="Playful"){
   id="normal";
   reason="Your current vibe leans playful, so tonight stays light and active.";
 }else if(mood==="deep"||vibes.includes("Deep")||learnedTop==="Deep"){
   id="normal";
   reason="Your current vibe leans toward a slower, more meaningful conversation.";
 }else if((mood==="spontaneous"||vibes.includes("Spontaneous"))&&previous){
   id=previous==="normal"?"dark":"normal";
   reason="A small change of pace keeps the experience from feeling repetitive.";
 }else if(timePeriod==="evening"&&previous){
   id=previous==="normal"?"dark":"normal";
   reason="Tonight's timing and your recent Journey history suggest a change of pace.";
 }else if(vibes.includes("Romantic")||learnedTop==="Romantic"){
   id="normal";
   reason="Your saved vibe leans romantic and warm.";
 }

 const duration=preferences.duration||"medium";
 const target=duration==="short"?4:duration==="long"?6:5;
 const safeTarget=Math.max(2,Math.min(target,6));
 return{
   journeyId:id,
   targetSteps:safeTarget,
   reason,
   context:{
     mood:mood||null,
     timePeriod:timePeriod||null,
     learnedVibe:learnedTop||null,
     previousJourney:previous||null
   }
 };
}

export function chooseSurprise(input){
 const base=buildJourney(input);
 const recent=input?.context?.recentJourneys?.[0]||input?.memories?.[0]?.journey||"";
 const surpriseJourney=recent==="normal"?"dark":"normal";
 return{
   ...base,
   journeyId:recent?surpriseJourney:base.journeyId,
   surprise:true,
   reason:recent
     ?"Surprise Mode changes the pace from your most recent Journey."
     :base.reason
 };
}
