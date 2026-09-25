import {allRoleplayNormalRoles,allRoleplayDarkRoles,roleplayCustomItems,roleplayCustomItemsExplicit} from "../data/topics.js?v=20260926-01";

function customRolePool(items){
  const groups=new Map();
  for(const item of items||[]){
    const id="custom-"+(item.roleName||"role").toLowerCase().replace(/[^a-z0-9]+/g,"-");
    if(!groups.has(id)) groups.set(id,{id,emoji:item.roleEmoji||"🎭",name:item.roleName||"Custom Roleplay",desc:item.roleDescription||"Imported roleplay scene.",items:[]});
    groups.get(id).items.push({context:item.context,challenge:item.challenge});
  }
  return [...groups.values()];
}
const ACTIVE_KEY="ignite-active-content-v1";
function rolePool(key,fallback){try{const raw=JSON.parse(localStorage.getItem(ACTIVE_KEY)||"null");const list=raw?.[key];if(Array.isArray(list))return list}catch{}return fallback}
function normalRoles(){return rolePool("roleplayNormal",[...allRoleplayNormalRoles,...customRolePool(roleplayCustomItems)])}
function darkRoles(){return rolePool("roleplayDark",[...allRoleplayDarkRoles,...customRolePool(roleplayCustomItemsExplicit)])}

function pick(pool,used){const available=pool.filter(x=>!used.has(x.id));const source=available.length?available:pool;const role=source[Math.floor(Math.random()*source.length)];used.add(role.id);return role}
export function createRoleplayState(){return{mode:"normal",role:null,item:null,usedRoles:new Set(),usedItems:new Map()}}
export function setRoleplayMode(s,mode){s.mode=mode==="dark"?"dark":"normal";s.role=null;s.item=null;s.usedRoles=new Set();s.usedItems=new Map()}
export function nextRoleplay(s){
 const roles=(s.mode==="dark"?darkRoles():normalRoles()).filter(role=>Array.isArray(role?.items)&&role.items.length);
 if(!roles.length){s.role=null;s.item=null;return s}
 const role=s.role&&((s.usedItems.get(s.role.id)||new Set()).size< s.role.items.length)?s.role:pick(roles,s.usedRoles);
 if(!role||!Array.isArray(role.items)||!role.items.length){s.role=null;s.item=null;return s}
 let used=s.usedItems.get(role.id)||new Set();
 if(used.size>=role.items.length){used=new Set();s.usedItems.set(role.id,used)}
 const idx=Math.floor(Math.random()*role.items.length);
 used.add(idx);s.usedItems.set(role.id,used);s.role=role;s.item=role.items[idx];return s
}
export function renderRoleplay(s){
 if(!s.role){
  const roles=(s.mode==="dark"?darkRoles():normalRoles()).filter(role=>Array.isArray(role?.items)&&role.items.length);
  return '<div class="mini-intro"><span class="game-icon">🎭</span><h3>Roleplay</h3><p>Pilih karakter, masuk ke adegan, lalu biarkan percakapan berkembang.</p>'+
    (roles.length?'<button class="btn primary full" data-mini="roleplay-next">Draw Role</button>':'<p class="muted">No roleplay content is available in this mode. Add roles and scenes in Topic Library.</p>')+
    '</div>'
 }
 return '<div class="game-active"><div class="game-meta">'+s.role.emoji+' '+s.role.name+'</div><h3>'+escapeHtml(s.role.name)+'</h3><p class="muted">'+escapeHtml(s.role.desc)+'</p><div class="game-prompt"><small>SCENE</small><strong>'+escapeHtml(s.item.context)+'</strong><small>YOUR MOVE</small><span>'+escapeHtml(s.item.challenge)+'</span></div><div class="btn-row"><button class="btn ghost" data-mini="roleplay-next">Next Scene</button><button class="btn primary" data-mini="roleplay-switch">Switch Role</button></div></div>'}
function escapeHtml(v){return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]))}
