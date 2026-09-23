export function buildJourney({level=1,preferences={},memories=[],context=null}={}){
 const vibes=preferences.vibes||[];
 const recent=context?.recentJourneys?.length?context.recentJourneys:memories.slice(0,3).map(m=>m.journey);
 const timePeriod=context?.time?.period;
 const mood=context?.mood?.id;
 let id="normal";
 if(vibes.includes("Intimate")&&level>=5)id="dark";
 if(mood==="intimate"&&level>=5)id="dark";
 if(vibes.includes("Spontaneous")&&recent.length)id=recent[0]==="normal"?"dark":"normal";
 if(mood==="spontaneous"&&timePeriod==="evening"&&recent.length)id=recent[0]==="normal"?"dark":"normal";
 if(vibes.includes("Romantic")&&level<5)id="normal";
 const duration=preferences.duration||"medium";
 const target=duration==="short"?4:duration==="long"?6:5;
 return{journeyId:id,targetSteps:target,reason:buildReason({vibes,mood,timePeriod}),context:{mood:mood||null,timePeriod:timePeriod||null}};
}
function buildReason({vibes,mood,timePeriod}){if(mood&&timePeriod)return"Built around your "+mood+" mood and "+timePeriod+" context.";if(vibes.length)return"Built around your saved vibe preferences.";return"Built from your current IGNITE level and recent moments."}
export function chooseSurprise(input){return{...buildJourney(input),surprise:true}}