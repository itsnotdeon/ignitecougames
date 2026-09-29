import {TOPIC_CLEAR_VERSION} from "./state.js";
const EXCLUDED_KEYS=new Set([TOPIC_CLEAR_VERSION]);

export function appStorageSnapshot(){
  const data={};
  for(let i=0;i<localStorage.length;i++){
    const key=localStorage.key(i);
    if(key&&key.startsWith("ignite-")&&!EXCLUDED_KEYS.has(key))data[key]=localStorage.getItem(key);
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

function validateBackup(data){
  if(!data||data.format!=="ignite-backup"||data.version!==1||!data.data||typeof data.data!=="object"||Array.isArray(data.data))throw new Error("Invalid IGNITE backup.");
  const entries=Object.entries(data.data);
  for(const [key,value] of entries){
    if(!key.startsWith("ignite-")||EXCLUDED_KEYS.has(key)||typeof value!=="string")throw new Error("Invalid IGNITE backup data.");
  }
  return entries;
}

export function restoreAppBackup(data){
  const entries=validateBackup(data);
  for(let i=localStorage.length-1;i>=0;i--){
    const key=localStorage.key(i);
    if(key&&key.startsWith("ignite-"))localStorage.removeItem(key);
  }
  for(const [key,value] of entries)localStorage.setItem(key,value);
  localStorage.setItem(TOPIC_CLEAR_VERSION,"done");
  sessionStorage.setItem("ignite-welcome-seen","1");
  location.reload();
}

export function resetAllAppData(){
  if(!window.confirm("Reset all IGNITE data on this device? This cannot be undone."))return;
  for(let i=localStorage.length-1;i>=0;i--){
    const key=localStorage.key(i);
    if(key&&key.startsWith("ignite-"))localStorage.removeItem(key);
  }
  sessionStorage.removeItem("ignite-welcome-seen");
  location.reload();
}
