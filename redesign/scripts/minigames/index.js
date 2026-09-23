import {createRoleplayState,setRoleplayMode,nextRoleplay,renderRoleplay} from "./roleplay.js";
import {createKingState,kingAction,renderKing} from "./kingslave.js";
import {createChessState,chessClick,chessUndo,renderChess} from "./chess.js";
import {createSnakeState,snakeRoll,snakeContinue,snakeSetMode,snakeReset,snakeFinishAnimation,renderSnake} from "./snake.js";
import {saveMemory} from "../features/memories.js";

const state={active:null,roleplay:createRoleplayState(),king:createKingState(),chess:createChessState(),snake:createSnakeState()};

export function minigameNames(names){return[names.p1||"Player 1",names.p2||"Player 2"]}
export function renderMinigameMenu(){return '<div class="mini-grid"><button class="card mini-card" data-mini-open="roleplay"><span>🎭</span><strong>Roleplay</strong><span>Step into a character and improvise together.</span></button><button class="card mini-card" data-mini-open="king"><span>👑</span><strong>King &amp; Slave</strong><span>Turn-based commands with consent always in control.</span></button><button class="card mini-card" data-mini-open="chess"><span>♟</span><strong>Chess</strong><span>Play the full board game directly.</span></button><button class="card mini-card" data-mini-open="snake"><span>🐍</span><strong>Snake &amp; Ladder</strong><span>Roll, climb, slide, and race to 100.</span></button></div>'}
export function openMinigame(id){state.active=id;if(id==="roleplay")setRoleplayMode(state.roleplay,"normal");if(id==="king")state.king=createKingState();if(id==="chess")state.chess=createChessState();if(id==="snake")state.snake=createSnakeState();return state.active}
export function resetActive(){if(state.active==="chess")state.chess=createChessState();if(state.active==="snake")state.snake=createSnakeState();if(state.active==="king")state.king=createKingState();if(state.active==="roleplay")state.roleplay=createRoleplayState()}
export function minigameView(names){
 const n=minigameNames(names);
 if(state.active==="roleplay")return renderRoleplay(state.roleplay);
 if(state.active==="king")return renderKing(state.king,n);
 if(state.active==="chess")return renderChess(state.chess,n);
 if(state.active==="snake")return renderSnake(state.snake,n);
 return renderMinigameMenu();
}
export function minigameAction(action,value){
 if(state.active==="roleplay"){if(action==="roleplay-next")nextRoleplay(state.roleplay);if(action==="roleplay-switch"){state.roleplay.usedRoles=new Set();nextRoleplay(state.roleplay)}if(action==="roleplay-mode")setRoleplayMode(state.roleplay,value);return}
 if(state.active==="king"){if(action==="ks-consent"){const box=document.querySelector("#ks-consent");if(box&&!box.checked)return;kingAction(state.king,"consent")}else if(action==="ks-roll")kingAction(state.king,"roll");else if(action==="ks-draw")kingAction(state.king,"draw");else if(action==="ks-choose")kingAction(state.king,"choose",value);else if(action==="ks-draw-again")kingAction(state.king,"draw-again");else if(action==="ks-power")kingAction(state.king,"power",value);else if(action==="ks-respond")kingAction(state.king,"respond",value);else if(action==="ks-mode")kingAction(state.king,"mode");else if(action==="ks-reset")kingAction(state.king,"reset");else if(action==="ks-power-open"){state.king.__powerOpen=true}else if(action==="ks-power-close"){state.king.__powerOpen=false}else if(action==="ks-choice-close"){state.king.chooseOpen=false}return}
 if(state.active==="chess"){if(action==="chess-square")chessClick(state.chess,Number(value));else if(action==="chess-undo")chessUndo(state.chess);else if(action==="chess-reset")state.chess=createChessState();return}
 if(state.active==="snake"){if(action==="snake-roll")snakeRoll(state.snake);else if(action==="snake-continue")snakeContinue(state.snake);else if(action==="snake-done")snakeContinue(state.snake,"done");else if(action==="snake-skip")snakeContinue(state.snake,"skip");else if(action==="snake-mode")snakeSetMode(state.snake,value);else if(action==="snake-reset")state.snake=createSnakeState();else if(action==="snake-save-memory"){const note=document.querySelector("#snake-memory-note")?.value?.trim()||"";saveMemory({journey:"Snake & Ladder",xp:0,moment:"Snake & Ladder — "+(state.snake.winner!=null?"Winner reached 100":"Game complete"),note});state.snake.memorySaved=true}}
}

export async function animateSnakeMove(){
  const s=state.snake;
  const move=s?.lastMove;
  if(!move||!s.animating)return;
  const board=document.querySelector(".snake-board");
  if(!board){snakeFinishAnimation(s);return;}
  const finalCell=board.querySelector('[data-square="'+move.to+'"]');
  const pawn=finalCell?.querySelector(".pawn.p"+(move.player+1)+"-pawn");
  if(!finalCell||!pawn){snakeFinishAnimation(s);return;}
  const clone=pawn.cloneNode(true);
  const boardRect=board.getBoundingClientRect();
  const firstCell=board.querySelector('[data-square="1"]');
  const startCell=board.querySelector('[data-square="'+move.from+'"]');
  const startRect=(startCell||firstCell)?.getBoundingClientRect();
  const finalRect=finalCell.getBoundingClientRect();
  if(!startRect){snakeFinishAnimation(s);return;}
  pawn.style.visibility="hidden";
  clone.style.position="fixed";
  clone.style.zIndex="9999";
  clone.style.margin="0";
  clone.style.pointerEvents="none";
  clone.style.left="0px";
  clone.style.top="0px";
  clone.style.width=pawn.getBoundingClientRect().width+"px";
  clone.style.height=pawn.getBoundingClientRect().height+"px";
  document.body.appendChild(clone);
  const center=rect=>({x:rect.left+rect.width/2,y:rect.top+rect.height/2});
  const start=move.from===0?{x:center(startRect).x,y:center(startRect).y+startRect.height}:center(startRect);
  const points=[start];
  for(const square of move.path){
    const cell=board.querySelector('[data-square="'+square+'"]');
    if(cell)points.push(center(cell.getBoundingClientRect()));
  }
  const durationPerStep=190;
  clone.style.transform="translate("+(start.x-clone.getBoundingClientRect().width/2)+"px,"+(start.y-clone.getBoundingClientRect().height/2)+"px)";
  for(let i=1;i<points.length;i++){
    const p=points[i];
    const prev=points[i-1];
    const duration=(i===points.length-1&&move.path[i-1]!==move.to&&move.path.length>1)?420:durationPerStep;
    await clone.animate([
      {transform:"translate("+(prev.x-clone.getBoundingClientRect().width/2)+"px,"+(prev.y-clone.getBoundingClientRect().height/2)+"px)"},
      {transform:"translate("+(p.x-clone.getBoundingClientRect().width/2)+"px,"+(p.y-clone.getBoundingClientRect().height/2)+"px)"}
    ],{duration,easing:"ease-in-out",fill:"forwards"}).finished;
  }
  clone.remove();
  pawn.style.visibility="";
  snakeFinishAnimation(s);
  window.dispatchEvent(new CustomEvent("ignite:rerender"));
}
