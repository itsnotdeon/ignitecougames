const BACK="rnbqkbnr";
const WHITE={p:"♙︎",r:"♖︎",n:"♘︎",b:"♗︎",q:"♕︎",k:"♔︎"};
const BLACK={p:"♟︎",r:"♜︎",n:"♞︎",b:"♝︎",q:"♛︎",k:"♚︎"};

function initBoard(){
  const b=Array(64).fill(null);
  for(let i=0;i<8;i++){
    b[i]={c:"b",t:BACK[i]};
    b[8+i]={c:"b",t:"p"};
    b[48+i]={c:"w",t:"p"};
    b[56+i]={c:"w",t:BACK[i]};
  }
  return b;
}
function xy(i){return[Math.floor(i/8),i%8]}
function idx(r,f){return r>=0&&r<8&&f>=0&&f<8?r*8+f:-1}

function pseudo(b,from,attack=false){
  const p=b[from],a=[],[r,f]=xy(from);
  if(!p)return a;
  const add=(rr,ff)=>{
    const i=idx(rr,ff);
    if(i<0)return false;
    if(!b[i]){a.push(i);return true}
    if(b[i].c!==p.c&&(attack||b[i].t!=="k"))a.push(i);
    return false;
  };
  if(p.t==="p"){
    const d=p.c==="w"?-1:1;
    if(attack){
      [-1,1].forEach(x=>{const i=idx(r+d,f+x);if(i>=0)a.push(i)});
    }else{
      const i=idx(r+d,f);
      if(i>=0&&!b[i]){
        a.push(i);
        const j=idx(r+2*d,f);
        if((p.c==="w"?r===6:r===1)&&j>=0&&!b[j])a.push(j);
      }
      [-1,1].forEach(x=>{
        const j=idx(r+d,f+x);
        if(j>=0&&b[j]&&b[j].c!==p.c&&b[j].t!=="k")a.push(j);
      });
    }
  }else if(p.t==="n"){
    [[2,1],[2,-1],[-2,1],[-2,-1],[1,2],[1,-2],[-1,2],[-1,-2]].forEach(x=>add(r+x[0],f+x[1]));
  }else{
    const ds=p.t==="b"
      ?[[1,1],[1,-1],[-1,1],[-1,-1]]
      :p.t==="r"
        ?[[1,0],[-1,0],[0,1],[0,-1]]
        :[[1,1],[1,-1],[-1,1],[-1,-1],[1,0],[-1,0],[0,1],[0,-1]];
    if(p.t==="k")ds.forEach(d=>add(r+d[0],f+d[1]));
    else ds.forEach(d=>{let rr=r+d[0],ff=f+d[1];while(add(rr,ff)){rr+=d[0];ff+=d[1]}});
  }
  return a;
}
function attacked(b,s,col){
  for(let i=0;i<64;i++)if(b[i]&&b[i].c===col&&pseudo(b,i,true).includes(s))return true;
  return false;
}
function inCheck(b,col){
  const k=b.findIndex(p=>p&&p.c===col&&p.t==="k");
  return k>=0&&attacked(b,k,col==="w"?"b":"w");
}
function cloneBoard(b){return b.map(p=>p&&{...p})}
function snapshot(s){
  return JSON.stringify({
    board:s.board,turn:s.turn,castling:s.castling,enPassant:s.enPassant,
    over:s.over,result:s.result,winner:s.winner,lastMove:s.lastMove
  });
}
function restore(s,json){
  const x=JSON.parse(json);
  s.board=x.board;s.turn=x.turn;s.castling=x.castling;s.enPassant=x.enPassant;
  s.over=x.over;s.result=x.result;s.winner=x.winner;s.lastMove=x.lastMove;s.selected=null;
}
function canCastle(s,from,to){
  const p=s.board[from];
  if(!p||p.t!=="k"||inCheck(s.board,p.c))return false;
  const row=p.c==="w"?7:0;
  if(from!==idx(row,4))return false;
  const enemy=p.c==="w"?"b":"w";
  if(to===idx(row,6)){
    if(!s.castling[p.c+"K"]||s.board[idx(row,5)]||s.board[idx(row,6)])return false;
    const rook=s.board[idx(row,7)];
    return !!(rook&&rook.c===p.c&&rook.t==="r")&&!attacked(s.board,idx(row,5),enemy)&&!attacked(s.board,idx(row,6),enemy);
  }
  if(to===idx(row,2)){
    if(!s.castling[p.c+"Q"]||s.board[idx(row,1)]||s.board[idx(row,2)]||s.board[idx(row,3)])return false;
    const rook=s.board[idx(row,0)];
    return !!(rook&&rook.c===p.c&&rook.t==="r")&&!attacked(s.board,idx(row,3),enemy)&&!attacked(s.board,idx(row,2),enemy);
  }
  return false;
}
function legal(s,from,to){
  const p=s.board[from],target=s.board[to];
  if(!p||p.c!==s.turn||target&&target.c===p.c||target&&target.t==="k")return false;
  const ep=s.enPassant===to&&p.t==="p"&&Math.abs(to-from)===9||s.enPassant===to&&p.t==="p"&&Math.abs(to-from)===7;
  const castle=p.t==="k"&&Math.abs((to%8)-(from%8))===2;
  if(castle)return canCastle(s,from,to);
  const normal=pseudo(s.board,from).includes(to);
  if(!normal&&!ep)return false;
  const n=cloneBoard(s.board);
  n[to]=n[from];n[from]=null;
  if(ep&&!target){
    const capture=to+(p.c==="w"?8:-8);
    if(!n[capture]||n[capture].c===p.c||n[capture].t!=="p")return false;
    n[capture]=null;
  }
  return !inCheck(n,p.c);
}
function moves(s,from){
  const p=s.board[from];
  if(!p||p.c!==s.turn)return [];
  const out=pseudo(s.board,from).filter(t=>legal(s,from,t));
  if(p.t==="p"&&s.enPassant!==null&&!out.includes(s.enPassant)&&legal(s,from,s.enPassant))out.push(s.enPassant);
  if(p.t==="k"){
    [idx(p.c==="w"?7:0,6),idx(p.c==="w"?7:0,2)].forEach(t=>{if(legal(s,from,t))out.push(t)});
  }
  return out;
}
function hasAnyMove(s,col){
  const old=s.turn;s.turn=col;
  let any=false;
  for(let i=0;i<64&&!any;i++)if(s.board[i]&&s.board[i].c===col&&moves(s,i).length)any=true;
  s.turn=old;
  return any;
}
function updateRights(s,p,from,to,captured){
  if(p.t==="k"){
    s.castling[p.c+"K"]=false;s.castling[p.c+"Q"]=false;
  }
  if(p.t==="r"){
    if(from===56)s.castling.wQ=false;
    if(from===63)s.castling.wK=false;
    if(from===0)s.castling.bQ=false;
    if(from===7)s.castling.bK=false;
  }
  if(captured&&captured.t==="r"){
    if(to===56)s.castling.wQ=false;
    if(to===63)s.castling.wK=false;
    if(to===0)s.castling.bQ=false;
    if(to===7)s.castling.bK=false;
  }
}
function makeMove(s,from,to){
  const p=s.board[from],target=s.board[to];
  s.history.push(snapshot(s));
  const isCastle=p.t==="k"&&Math.abs((to%8)-(from%8))===2;
  const isEp=p.t==="p"&&s.enPassant===to&&!target;
  s.board[to]=p;s.board[from]=null;
  if(isEp)s.board[to+(p.c==="w"?8:-8)]=null;
  updateRights(s,p,from,to,target);
  if(isCastle){
    const row=p.c==="w"?7:0;
    const rookFrom=to%8===6?idx(row,7):idx(row,0);
    const rookTo=to%8===6?idx(row,5):idx(row,3);
    s.board[rookTo]=s.board[rookFrom];s.board[rookFrom]=null;
  }
  if(p.t==="p"&&Math.abs(to-from)===16)s.enPassant=(from+to)/2;
  else s.enPassant=null;
  if(p.t==="p"&&Math.floor(to/8)===(p.c==="w"?0:7))p.t="q";
  s.lastMove={from,to};
  s.turn=s.turn==="w"?"b":"w";
  const any=hasAnyMove(s,s.turn);
  const check=inCheck(s.board,s.turn);
  if(!any){
    s.over=true;
    s.result=check?"checkmate":"stalemate";
    s.winner=check?(s.turn==="w"?"b":"w"):null;
  }else{
    s.result=check?"check":"playing";
    s.winner=null;
  }
  s.selected=null;
}
const PIECE={w:WHITE,b:BLACK};
const LABEL={p:"pawn",r:"rook",n:"knight",b:"bishop",q:"queen",k:"king"};
export function createChessState(){
  return{
    board:initBoard(),turn:"w",selected:null,over:false,result:"playing",winner:null,
    history:[],castling:{wK:true,wQ:true,bK:true,bQ:true},enPassant:null,lastMove:null
  };
}
export function chessClick(s,i){
  if(s.over)return;
  if(s.selected===null){
    if(s.board[i]&&s.board[i].c===s.turn)s.selected=i;
    return;
  }
  if(legal(s,s.selected,i))makeMove(s,s.selected,i);
  else s.selected=s.board[i]&&s.board[i].c===s.turn?i:null;
}
export function chessUndo(s){
  if(!s.history.length)return;
  restore(s,s.history.pop());
}
export function renderChess(s,names){
  const player=s.turn==="w"?(names[0]||"White"):(names[1]||"Black");
  const status=s.over
    ?(s.result==="checkmate"?"Checkmate": "Stalemate")
    :s.result==="check"
      ?player+" in check"
      :player+" bergerak";
  const board='<div class="chess-board" role="grid" aria-label="Chess board">'+s.board.map((p,i)=>{
    const tone=((Math.floor(i/8)+i)%2)?"dark":"light";
    const legalMove=s.selected!==null&&moves(s,s.selected).includes(i);
    const piece=p?PIECE[p.c][p.t]:"";
    return '<button class="chess-square '+tone+(s.selected===i?" selected":"")+(legalMove?" legal":"")+(p?" piece-"+p.c:"")+'" data-mini="chess-square" data-index="'+i+'" role="gridcell" aria-label="'+(p?(p.c==="w"?"White ":"Black ")+LABEL[p.t]:"Empty square")+'"><span class="chess-piece" aria-hidden="true">'+piece+'</span></button>';
  }).join("")+'</div>';
  const turnLabel=s.over
    ?(s.winner?(s.winner==="w"?(names[0]||"White"):(names[1]||"Black"))+" wins":"Draw")
    :status;
  return '<div class="game-active"><div class="game-meta">♟ Chess · '+escapeHtml(turnLabel)+'</div>'+board+'<div class="btn-row"><button class="btn ghost" data-mini="chess-undo" '+(!s.history.length?"disabled":"")+'>Undo</button><button class="btn primary" data-mini="chess-reset">Restart</button></div></div>';
}
function escapeHtml(v){return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]))}
