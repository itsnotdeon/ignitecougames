import {app} from "./dom.js";
export function syncModeTheme(mode){
  const normalized=mode==="dark"?"dark":"normal";
  app.dataset.igniteMode=normalized;
  document.body.dataset.igniteMode=normalized;
  const meta=document.querySelector('meta[name="theme-color"]');
  if(meta)meta.setAttribute("content",normalized==="dark"?"#030203":"#170a11");
}