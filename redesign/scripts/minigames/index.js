import {createRoleplayState,setRoleplayMode,nextRoleplay,renderRoleplay} from "./roleplay.js";
import {createKingState,kingAction,renderKing} from "./kingslave.js";
import {createChessState,chessClick,chessUndo,renderChess} from "./chess.js";
import {createSnakeState,snakeRoll,snakeContinue,renderSnake} from "./snake.js";

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
 if(state.active==="snake"){if(action==="snake-roll")snakeRoll(state.snake);else if(action==="snake-continue")snakeContinue(state.snake);else if(action==="snake-reset")state.snake=createSnakeState()}
}
