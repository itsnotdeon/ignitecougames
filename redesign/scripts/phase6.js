/* IGNITE Phase 6 — resilient UI semantics */
const app=document.querySelector("#app");

function annotateInteractiveUI(){
  if(!app)return;

  app.querySelectorAll("button").forEach((button)=>{
    if(button.disabled) button.setAttribute("aria-disabled","true");
  });

  const progressBars=app.querySelectorAll(".progress span,.progression-bar span");
  progressBars.forEach((bar)=>{
    const width=bar.style.width||"0%";
    bar.setAttribute("role","progressbar");
    bar.setAttribute("aria-valuemin","0");
    bar.setAttribute("aria-valuemax","100");
    bar.setAttribute("aria-valuenow",String(parseInt(width,10)||0));
  });

  app.querySelectorAll(".reveal-card").forEach((card)=>{
    if(!card.getAttribute("aria-live")) card.setAttribute("aria-live","polite");
  });
}

const observer=new MutationObserver(()=>requestAnimationFrame(annotateInteractiveUI));
observer.observe(app,{childList:true,subtree:true});
annotateInteractiveUI();

window.addEventListener("keydown",(event)=>{
  if(event.key==="Escape"){
    const back=app.querySelector('[data-action="home"],[data-action="minigames-menu"]');
    if(back && !event.target.matches("input,textarea")) back.click();
  }
});
