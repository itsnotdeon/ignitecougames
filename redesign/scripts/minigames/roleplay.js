import {roleplayBuiltInRoles,roleplayCustomItems,roleplayCustomItemsExplicit} from "../data/topics.js?v=20260924-01";

function customRolePool(items){
  const groups=new Map();
  for(const item of items||[]){
    const id="custom-"+(item.roleName||"role").toLowerCase().replace(/[^a-z0-9]+/g,"-");
    if(!groups.has(id)) groups.set(id,{id,emoji:item.roleEmoji||"🎭",name:item.roleName||"Custom Roleplay",desc:item.roleDescription||"Imported roleplay scene.",items:[]});
    groups.get(id).items.push({context:item.context,challenge:item.challenge});
  }
  return [...groups.values()];
}
const NORMAL_ROLES=[...roleplayBuiltInRoles,...customRolePool(roleplayCustomItems)];
const DARK_ROLES=customRolePool(roleplayCustomItemsExplicit);

function pick(pool,used){const available=pool.filter(x=>!used.has(x.id));const source=available.length?available:pool;const role=source[Math.floor(Math.random()*source.length)];used.add(role.id);return role}
export function createRoleplayState(){return{mode:"normal",role:null,item:null,usedRoles:new Set(),usedItems:new Map()}}
export function setRoleplayMode(s,mode){s.mode=mode==="dark"?"dark":"normal";s.role=null;s.item=null;s.usedRoles=new Set();s.usedItems=new Map()}
export function nextRoleplay(s){const roles=s.mode==="dark"?DARK_ROLES:NORMAL_ROLES;const role=s.role&&((s.usedItems.get(s.role.id)||new Set()).size< s.role.items.length)?s.role:pick(roles,s.usedRoles);let used=s.usedItems.get(role.id)||new Set();if(used.size>=role.items.length){used=new Set();s.usedItems.set(role.id,used)}const idx=Math.floor(Math.random()*role.items.length);used.add(idx);s.usedItems.set(role.id,used);s.role=role;s.item=role.items[idx];return s}
export function renderRoleplay(s){if(!s.role)return '<div class="mini-intro"><span class="game-icon">🎭</span><h3>Roleplay</h3><p>Pilih karakter, masuk ke adegan, lalu biarkan percakapan berkembang.</p><button class="btn primary full" data-mini="roleplay-next">Draw Role</button></div>';return '<div class="game-active"><div class="game-meta">'+s.role.emoji+' '+s.role.name+'</div><h3>'+escapeHtml(s.role.name)+'</h3><p class="muted">'+escapeHtml(s.role.desc)+'</p><div class="game-prompt"><small>SCENE</small><strong>'+escapeHtml(s.item.context)+'</strong><small>YOUR MOVE</small><span>'+escapeHtml(s.item.challenge)+'</span></div><div class="btn-row"><button class="btn ghost" data-mini="roleplay-next">Next Scene</button><button class="btn primary" data-mini="roleplay-switch">Switch Role</button></div></div>'}
function escapeHtml(v){return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]))}
