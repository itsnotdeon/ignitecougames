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
    if(attack)[-1,1].forEach(x=>{const i=idx(r+d,f+x);if(i>=0)a.push(i)});
    else{
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
function attacked(b,s,col){for(let i=0;i<64;i++)if(b[i]&&b[i].c===col&&pseudo(b,i,true).includes(s))return true;return false}
function inCheck(b,col){
  const k=b.findIndex(p=>p&&p.c===col&&p.t==="k");
  return k>=0&&attacked(b,k,col==="w"?"b":"w");
}
function legal(b,from,to){
  const p=b[from];
  if(!p||p.c!==b.turn||b[to]&&b[to].c===p.c||b[to]&&b[to].t==="k"||!pseudo(b,from).includes(to))return false;
  const n=b.map(x=>x&&{...x});
  n[to]=n[from];n[from]=null;
  return !inCheck(n,p.c);
}
function moves(b,f){return pseudo(b,f).filter(t=>legal(b,f,t))}

const PIECE={w:WHITE,b:BLACK};
export function createChessState(){return{board:initBoard(),turn:"w",selected:null,over:false,history:[]}}

export function chessClick(s,i){
  if(s.over)return;
  if(s.selected===null){
    if(s.board[i]&&s.board[i].c===s.turn)s.selected=i;
  }else if(legal(s.board,s.selected,i)){
    const f=s.selected,p=s.board[f];
    s.history.push(JSON.stringify({board:s.board,turn:s.turn}));
    s.board[i]=p;s.board[f]=null;
    if(p.t==="p"&&Math.floor(i/8)===(p.c==="w"?0:7))p.t="q";
    s.turn=s.turn==="w"?"b":"w";
    s.selected=null;
    let any=false;
    for(let x=0;x<64;x++)if(s.board[x]&&s.board[x].c===s.turn&&moves(s.board,x).length){any=true;break}
    if(!any)s.over=true;
  }else{
    s.selected=s.board[i]&&s.board[i].c===s.turn?i:null;
  }
}
export function chessUndo(s){
  if(!s.history.length)return;
  const x=JSON.parse(s.history.pop());
  s.board=x.board;s.turn=x.turn;s.selected=null;s.over=false;
}
export function renderChess(s,names){
  const turn=s.over
    ?"Game selesai"
    :(s.turn==="w"?(names[0]||"White"):(names[1]||"Black"))+" bergerak";
  const board='<div class="chess-board" role="grid" aria-label="Chess board">'+s.board.map((p,i)=>{
    const tone=((Math.floor(i/8)+i)%2)?"dark":"light";
    const legalMove=s.selected!==null&&moves(s.board,s.selected).includes(i);
    const piece=p?PIECE[p.c][p.t]:"";
    return '<button class="chess-square '+tone+(s.selected===i?" selected":"")+(legalMove?" legal":"")+(p?" piece-"+p.c:"")+'" data-mini="chess-square" data-index="'+i+'" role="gridcell" aria-label="'+(p?(p.c==="w"?"White ":"Black ")+p.t:"Empty square")+'">'+piece+'</button>';
  }).join("")+'</div>';
  return '<div class="game-active"><div class="game-meta">♟ Chess · '+escapeHtml(turn)+'</div>'+board+'<div class="btn-row"><button class="btn ghost" data-mini="chess-undo">Undo</button><button class="btn primary" data-mini="chess-reset">Restart</button></div></div>';
}
function escapeHtml(v){return String(v).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[c]))}
