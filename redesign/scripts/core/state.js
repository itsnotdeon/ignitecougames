const STORAGE_KEY="ignite-redesign-v4";
export const TOPIC_CLEAR_VERSION="20260926-clear-all-topics";
export const state={names:{p1:"",p2:"",couple:""},relationship:"Couple",relationshipSince:null,profileDetails:{p1:{pronouns:"",birthDate:"",bio:""},p2:{pronouns:"",birthDate:"",bio:""}},currentJourney:null,step:0,view:"home",mode:"normal",profilePhotos:{p1:"",p2:"",couple:""}};

export function clearAllTopicStorageOnce(){
  if(localStorage.getItem(TOPIC_CLEAR_VERSION)==="done")return;
  ["ignite-active-content-v1","ignite-active-topics-v1","ignite-custom-topics-v1","ignite-content-v1"].forEach(k=>localStorage.removeItem(k));
  localStorage.setItem(TOPIC_CLEAR_VERSION,"done");
}
export function load(){
  try{
    const saved=JSON.parse(localStorage.getItem(STORAGE_KEY));
    if(saved){
      state.names=saved.names||state.names;
      state.relationship=saved.relationship||"Couple";
      state.relationshipSince=saved.relationshipSince||null;
      state.currentJourney=saved.currentJourney||null;
      state.step=Number(saved.step)||0;
      state.view=saved.view||"home";
      state.mode=saved.mode==="dark"?"dark":"normal";
      state.profilePhotos={...state.profilePhotos,...(saved.profilePhotos||{})};
      state.profileDetails={...state.profileDetails,p1:{...state.profileDetails.p1,...(saved.profileDetails?.p1||{})},p2:{...state.profileDetails.p2,...(saved.profileDetails?.p2||{})}};
      state.__journeyComplete=Boolean(saved.__journeyComplete);
      state.__selectedJourney=Number.isInteger(saved.__selectedJourney)?saved.__selectedJourney:null;
      if(state.view==="generating"){
        state.view="home";
        delete state.__journeyTargetSteps;
        delete state.__journeyRoleplayOpen;
        delete state.__journeyRoleplayDone;
      }
    }
  }catch(e){state.view="home"}
}
export function save(){
  try{localStorage.setItem(STORAGE_KEY,JSON.stringify(state))}
  catch(e){console.warn("[IGNITE] state save failed",e)}
}