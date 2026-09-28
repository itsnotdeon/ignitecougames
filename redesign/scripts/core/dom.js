export const app=document.querySelector("#app");
export function esc(v){return String(v).replace(/[&<>"']/g,function(c){return{"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]})}
export function resetViewport(){
  try{window.scrollTo({top:0,left:0,behavior:"auto"})}catch{window.scrollTo(0,0)}
  if(document.documentElement)document.documentElement.scrollTop=0;
  if(document.body)document.body.scrollTop=0;
}