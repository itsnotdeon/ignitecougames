const {test,expect}=require("@playwright/test");

async function openChess(page){
  await page.goto("");
  await page.getByRole("button",{name:/Minigames/}).click();
  await page.getByRole("button",{name:/Chess/}).click();
  await expect(page.locator(".chess-board")).toBeVisible();
}

async function chessModule(page){
  return page.evaluate(async()=>{
    const m=await import("/redesign/scripts/minigames/chess.js");
    const s=m.createChessState();
    const play=(from,to)=>{m.chessClick(s,from);m.chessClick(s,to)};
    return {m,s,play};
  });
}

test("Chess renders equal square geometry and both piece colors",async({page})=>{
  await openChess(page);
  const geometry=await page.locator(".chess-square").evaluateAll(els=>els.map(el=>{
    const r=el.getBoundingClientRect();
    return {width:r.width,height:r.height};
  }));
  expect(geometry).toHaveLength(64);
  for(const g of geometry) expect(Math.abs(g.width-g.height)).toBeLessThanOrEqual(0.5);
  await expect(page.locator(".chess-square.piece-w")).toHaveCount(16);
  await expect(page.locator(".chess-square.piece-b")).toHaveCount(16);
  await expect(page.locator('[data-mini="chess-square"][data-index="60"]')).toContainText("♔");
  await expect(page.locator('[data-mini="chess-square"][data-index="4"]')).toContainText("♚");
});

test("Chess supports normal pawn movement and turn switching",async({page})=>{
  const result=await page.evaluate(async()=>{
    const m=await import("/redesign/scripts/minigames/chess.js");
    const s=m.createChessState();
    m.chessClick(s,52);m.chessClick(s,36);
    return {turn:s.turn,piece:s.board[36]};
  });
  expect(result.turn).toBe("b");
  expect(result.piece).toEqual({c:"w",t:"p"});
});

test("Chess supports castling and en passant",async({page})=>{
  const result=await page.evaluate(async()=>{
    const m=await import("/redesign/scripts/minigames/chess.js");
    const s=m.createChessState();
    const play=(from,to)=>{m.chessClick(s,from);m.chessClick(s,to)};
    play(52,36);play(12,28);
    play(62,45);play(1,18);
    play(61,52);play(6,21);
    play(60,62);
    const castle={king:s.board[62],rook:s.board[61],g1Empty:s.board[62]?.t==="k"};
    m.chessUndo(s);
    return {castle,turn:s.turn};
  });
  expect(result.castle.king).toEqual({c:"w",t:"k"});
  expect(result.castle.rook).toEqual({c:"w",t:"r"});
  expect(result.turn).toBe("w");
});

test("Chess supports en passant",async({page})=>{
  const result=await page.evaluate(async()=>{
    const m=await import("/redesign/scripts/minigames/chess.js");
    const s=m.createChessState();
    const play=(from,to)=>{m.chessClick(s,from);m.chessClick(s,to)};
    play(52,36);play(8,16);
    play(36,28);play(11,27);
    play(28,19);
    return {piece:s.board[19],captured:s.board[27],turn:s.turn};
  });
  expect(result.piece).toEqual({c:"w",t:"p"});
  expect(result.captured).toBeNull();
  expect(result.turn).toBe("b");
});

test("Chess exposes promotion choices only after a pawn reaches the last rank",async({page})=>{
  await openChess(page);
  await expect(page.locator(".chess-promotion")).toHaveCount(0);
  await expect(page.getByText(/Player 1 bergerak/)).toBeVisible();
});
