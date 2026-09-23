const BACK="rnbqkbnr";
const WHITE={p:"♙",r:"♖",n:"♘",b:"♗",q:"♕",k:"♔"};
const BLACK={p:"♟",r:"♜",n:"♞",b:"♝",q:"♛",k:"♚"};

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
function cloneBoard(b){return b.map(p=>p?{...p}:null)}
function opponent(c){return c==="w"?"b":"w"}
function colorName(c,names){return c==="w"?(names[0]||"White"):(names[1]||"Black")}

function pseudo(b,from,attack=false){
  const p=b[from],a=[],[r,f]=xy(from);
  if(!p)return a;
  const add=(rr,ff)=>{
    const i=idx(rr,ff);
    if(i<0)return false;
    if(!b[i]){a.push(i);return true}
    if(b[i].c!==p.c&&b[i].t!=="k")a.push(i);
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
    else ds.forEach(d=>{
      let rr=r+d[0],ff=f+d[1];
      while(add(rr,ff)){rr+=d[0];ff+=d[1]}
    });
  }
  return a;
}

function attacked(b,s,col){
  for(let i=0;i<64;i++){
    if(b[i]&&b[i].c===col&&pseudo(b,i,true).includes(s))return true;
  }
  return false;
}
function kingIndex(b,col){return b.findIndex(p=>p&&p.c===col&&p.t==="k")}
function inCheck(b,col){
  const k=kingIndex(b,col);
  return k<0||attacked(b,k,opponent(col));
}

function snapshot(s){
  return JSON.stringify({
    board:s.board,
    turn:s.turn,
    castling:s.castling,
    enPassant:s.enPassant,
    pendingPromotion:s.pendingPromotion,
    over:s.over,
    result:s.result
  });
}

function restore(s,x){
  const v=JSON.parse(x);
  s.board=v.board;
  s.turn=v.turn;
  s.castling=v.castling;
  s.enPassant=v.enPassant;
  s.pendingPromotion=v.pendingPromotion;
  s.over=v.over;
  s.result=v.result;
  s.selected=null;
}

function canCastle(s,from,to){
  const p=s.board[from];
  if(!p||p.t!=="k"||Math.abs(to-from)!==2)return false;
  if(inCheck(s.board,p.c))return false;
  const row=p.c==="w"?7:0;
  const kingStart=row*8+4;
  if(from!==kingStart)return false;
  const kingSide=to>from;
  const right=p.c==="w"?(kingSide?"wk":"wq"):(kingSide?"bk":"bq");
  if(!s.castling[right])return false;
  const rookFile=kingSide?7:0;
  const rook=s.board[row*8+rookFile];
  if(!rook||rook.c!==p.c||rook.t!=="r")return false;
  const emptyFiles=kingSide?[5,6]:[1,2,3];
  if(emptyFiles.some(f=>s.board[row*8+f]))return false;
  const transit=kingSide?[5,6]:[3,2];
  return transit.every(i=>!attacked(s.board,row*8+i,opponent(p.c)));
}

function simulate(s,from,to){
  const p=s.board[from];
  const b=cloneBoard(s.board);
  const n={
    board:b,
    turn:s.turn,
    castling:{...s.castling},
    enPassant:s.enPassant,
    pendingPromotion:null,
    over:false,
    result:null
  };
  b[to]=b[from];
  b[from]=null;

  if(p.t==="p"&&to===s.enPassant&&!s.board[to]){
    const [tr,tf]=xy(to);
    b[idx(tr+(p.c==="w"?1:-1),tf)]=null;
  }

  if(p.t==="k"&&Math.abs(to-from)===2){
    const row=p.c==="w"?7:0;
    const kingSide=to>from;
    const rookFrom=row*8+(kingSide?7:0);
    const rookTo=row*8+(kingSide?5:3);
    b[rookTo]=b[rookFrom];
    b[rookFrom]=null;
  }
  return n;
}

function legal(s,from,to){
  const p=s.board[from];
  if(!p||p.c!==s.turn||s.over||s.pendingPromotion!==null)return false;
  if(s.board[to]&&s.board[to].c===p.c)return false;
  if(s.board[to]&&s.board[to].t==="k")return false;

  const isCastle=p.t==="k"&&Math.abs(to-from)===2;
  if(isCastle){
    if(!canCastle(s,from,to))return false;
  }else{
    if(!pseudo(s.board,from).includes(to))return false;
  }

  const n=simulate(s,from,to);
  return !inCheck(n.board,p.c);
}

function moves(s,from){
  const p=s.board[from];
  if(!p||p.c!==s.turn||s.over||s.pendingPromotion!==null)return [];
  const result=pseudo(s.board,from).filter(to=>legal(s,from,to));
  if(p.t==="k"){
    const row=p.c==="w"?7:0;
    [row*8+2,row*8+6].forEach(to=>{if(canCastle(s,from,to))result.push(to)});
  }
  return [...new Set(result)];
}

function updateCastlingRights(s,from,to,p,captured){
  if(p.t==="k"){
    if(p.c==="w"){s.castling.wk=false;s.castling.wq=false}
    else{s.castling.bk=false;s.castling.bq=false}
  }
  if(p.t==="r"){
    if(from===56)s.castling.wq=false;
    if(from===63)s.castling.wk=false;
    if(from===0)s.castling.bq=false;
    if(from===7)s.castling.bk=false;
  }
  if(captured&&captured.t==="r"){
    if(to===56)s.castling.wq=false;
    if(to===63)s.castling.wk=false;
    if(to===0)s.castling.bq=false;
    if(to===7)s.castling.bk=false;
  }
}

function hasAnyLegalMove(s,col){
  const prev=s.turn;
  s.turn=col;
  let any=false;
  for(let i=0;i<64&&!any;i++){
    if(s.board[i]&&s.board[i].c===col&&moves(s,i).length)any=true;
  }
  s.turn=prev;
  return any;
}

function updateGameStatus(s){
  const side=s.turn;
  if(hasAnyLegalMove(s,side))return;
  s.over=true;
  if(inCheck(s.board,side)){
    s.result={type:"checkmate",winner:opponent(side),loser:side};
  }else{
    s.result={type:"stalemate",winner:null,loser:null};
  }
}

function playMove(s,from,to){
  s.history.push(snapshot(s));
  const p=s.board[from];
  const captured=s.board[to];
  const isEnPassant=p.t==="p"&&to===s.enPassant&&!captured;
  const [toRow,toFile]=xy(to);

  s.board[to]=p;
  s.board[from]=null;

  if(isEnPassant){
    const captureIndex=idx(toRow+(p.c==="w"?1:-1),toFile);
    s.board[captureIndex]=null;
  }

  if(p.t==="k"&&Math.abs(to-from)===2){
    const row=p.c==="w"?7:0;
    const kingSide=to>from;
    const rookFrom=row*8+(kingSide?7:0);
    const rookTo=row*8+(kingSide?5:3);
    s.board[rookTo]=s.board[rookFrom];
    s.board[rookFrom]=null;
  }

  updateCastlingRights(s,from,to,p,captured);
  s.enPassant=null;

  if(p.t==="p"&&Math.abs(to-from)===16){
    s.enPassant=(from+to)/2;
  }

  s.turn=opponent(s.turn);
  s.selected=null;

  if(p.t==="p"&&(toRow===0||toRow===7)){
    s.pendingPromotion={index:to,color:p.c};
    return;
  }
  updateGameStatus(s);
}

export function createChessState(){
  return{
    board:initBoard(),
    turn:"w",
    selected:null,
    over:false,
    result:null,
    pendingPromotion:null,
    castling:{wk:true,wq:true,bk:true,bq:true},
    enPassant:null,
    history:[]
  };
}

export function chessClick(s,i){
  if(s.over||s.pendingPromotion!==null)return;
  if(s.selected===null){
    if(s.board[i]&&s.board[i].c===s.turn)s.selected=i;
  }else if(legal(s,s.selected,i)){
    playMove(s,s.selected,i);
  }else{
    s.selected=s.board[i]&&s.board[i].c===s.turn?i:null;
  }
}

export function chessPromote(s,type){
  if(!s.pendingPromotion)return;
  if(!["q","r","b","n"].includes(type))return;
  const p=s.board[s.pendingPromotion.index];
  if(!p||p.c!==s.pendingPromotion.color||p.t!=="p")return;
  p.t=type;
  s.pendingPromotion=null;
  updateGameStatus(s);
}

export function chessUndo(s){
  if(!s.history.length)return;
  restore(s,s.history.pop());
}

export function renderChess(s,names){
  const status=s.over
    ? s.result?.type==="checkmate"
      ? "Checkmate · "+escapeHtml(colorName(s.result.winner,names))+" menang"
      : "Stalemate · Remis"
    : s.pendingPromotion
      ? "Promosi · pilih bidak"
      : inCheck(s.board,s.turn)
        ? "Check · "+escapeHtml(colorName(s.turn,names))+" harus bergerak"
        : colorName(s.turn,names)+" bergerak";

  const board='<div class="chess-board" role="grid" aria-label="Chess board">'+s.board.map((p,i)=>{
    const tone=((Math.floor(i/8)+i)%2)?"dark":"light";
    const legalMove=s.selected!==null&&moves(s,s.selected).includes(i);
    const piece=p?(p.c==="w"?WHITE[p.t]:BLACK[p.t]):"";
    const pieceClass=p?" piece-"+p.c:"";
    return '<button class="chess-square '+tone+(s.selected===i?" selected":"")+(legalMove?" legal":"")+pieceClass+'" data-mini="chess-square" data-index="'+i+'" role="gridcell" aria-label="'+(p?(p.c==="w"?"White ":"Black ")+p.t:"Empty square")+'">'+piece+'</button>';
  }).join("")+'</div>';

  const promotion=s.pendingPromotion
    ? '<div class="chess-promotion"><span>Promote to</span><div class="choice-grid four"><button class="btn choice" data-mini="chess-promote" data-value="q">♕ Queen</button><button class="btn choice" data-mini="chess-promote" data-value="r">♖ Rook</button><button class="btn choice" data-mini="chess-promote" data-value="b">♗ Bishop</button><button class="btn choice" data-mini="chess-promote" data-value="n">♘ Knight</button></div></div>'
    :"";

  return '<div class="game-active"><div class="game-meta">♟ Chess · '+status+'</div>'+board+promotion+'<div class="btn-row"><button class="btn ghost" data-mini="chess-undo">Undo</button><button class="btn primary" data-mini="chess-reset">Restart</button></div></div>';
}

function escapeHtml(v){return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]))}
