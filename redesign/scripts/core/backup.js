import {TOPIC_CLEAR_VERSION} from "./state.js";
export function appStorageSnapshot(){
  const data={};
  for(let i=0;i<localStorage.length;i++){
    const key=localStorage.key(i);
    if(key&&key.startsWith("ignite-")&&!new Set(["ignite-topic-clear-v1"]).has(key))data[key]=localStorage.getItem(key);
  }
  return data;
}
export function downloadText(filename,text,type="application/json"){
  const blob=new Blob([text],{type}),url=URL.createObjectURL(blob),a=document.createElement("a");
  a.href=url;a.download=filename;a.click();setTimeout(()=>URL.revokeObjectURL(url),500);
}
export function exportAppBackup(){
  downloadText("ignite-backup-"+new Date().toISOString().slice(0,10)+".json",JSON.stringify({format:"ignite-backup",version:1,exportedAt:new Date().toISOString(),data:appStorageSnapshot()},null,2));
}
export function restoreAppBackup(data){
  if(!data||data.format!=="ignite-backup"||!data.data||typeof data.data!=="object")throw new Error("Invalid IGNITE backup.");
  for(let i=localStorage.length-1;i>=0;i--){const key=localStorage.key(i);if(key&&key.startsWith("ignite-"))localStorage.removeItem(key)}
  for(const key of Object.keys(data.data))if(key.startsWith("ignite-")&&!new Set(["ignite-topic-clear-v1"]).has(key))localStorage.setItem(key,String(data.data[key]??""));
  localStorage.setItem(TOPIC_CLEAR_VERSION,"done");
  sessionStorage.setItem("ignite-welcome-seen","1");
  location.reload();
}
export function resetAllAppData(){
  if(!window.confirm("Reset all IGNITE data on this device? This cannot be undone."))return;
  for(let i=localStorage.length-1;i>=0;i--){const key=localStorage.key(i);if(key&&key.startsWith("ignite-"))localStorage.removeItem(key)}
  sessionStorage.removeItem("ignite-welcome-seen");
  location.reload();
}