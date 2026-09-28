import {state} from "./state.js";
import {app} from "./dom.js";
export function syncModeTheme(){
  const mode=state.mode==="dark"?"dark":"normal";
  app.dataset.igniteMode=mode;
  document.body.dataset.igniteMode=mode;
  const meta=document.querySelector('meta[name="theme-color"]');
  if(meta)meta.setAttribute("content",mode==="dark"?"#030203":"#170a11");
}