export const RPS_MOVES=[{id:"rock",symbol:"✊",name:"Batu"},{id:"paper",symbol:"✋",name:"Kertas"},{id:"scissors",symbol:"✌️",name:"Gunting"}];
export const RPS_BEATS={rock:"scissors",scissors:"paper",paper:"rock"};
export function createRpsState(){return{stage:"p1",p1Move:null,p2Move:null,roundsPlayed:0};}
export function rpsPick(state,move){if(state.stage==="p1"){state.p1Move=move;state.stage="p2";return null}if(state.stage==="p2"){state.p2Move=move;state.stage="result";state.roundsPlayed++;return rpsWinner(state)}return null}
export function rpsWinner(state){if(state.p1Move===state.p2Move)return null;return RPS_BEATS[state.p1Move]===state.p2Move?0:1}
export function createGuessColorState(){return{turn:0,roundsPlayed:0,currentSuit:pickSuit(),revealed:false};}
export const SUITS=[{symbol:"♠",name:"Sekop",color:"black"},{symbol:"♥",name:"Hati",color:"red"},{symbol:"♦",name:"Wajik",color:"red"},{symbol:"♣",name:"Keriting",color:"black"}];
export function pickSuit(){return SUITS[Math.floor(Math.random()*SUITS.length)]}
export function guessColor(state,color){if(state.revealed)return null;const correct=state.currentSuit.color===color;state.revealed=true;state.roundsPlayed++;return correct}
export function nextGuessRound(state){state.turn=state.turn===0?1:0;state.currentSuit=pickSuit();state.revealed=false}
