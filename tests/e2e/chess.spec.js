const {test,expect}=require("@playwright/test");

async function openChess(page){
  await page.goto("");
  await page.getByRole("button",{name:/Minigames/}).click();
  await page.getByRole("button",{name:/Chess/}).click();
  await expect(page.locator(".chess-board")).toBeVisible();
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
  await openChess(page);
  await page.locator('[data-mini="chess-square"][data-index="52"]').click();
  await page.locator('[data-mini="chess-square"][data-index="36"]').click();
  await expect(page.getByText(/Player 2 bergerak/)).toBeVisible();
  await page.locator('[data-mini="chess-square"][data-index="44"]').click();
  await page.locator('[data-mini="chess-square"][data-index="36"]').click();
  await expect(page.getByText(/Player 1 bergerak/)).toBeVisible();
});

test("Chess supports castling and en passant through real board interaction",async({page})=>{
  await openChess(page);
  const move=async(from,to)=>{
    await page.locator('[data-mini="chess-square"][data-index="'+from+'"]').click();
    await page.locator('[data-mini="chess-square"][data-index="'+to+'"]').click();
  };

  await move(52,36); await move(12,28);
  await move(62,45); await move(1,18);
  await move(61,52); await move(6,21);
  await move(60,62);
  await expect(page.locator('[data-mini="chess-square"][data-index="62"]')).toContainText("♔");
  await expect(page.locator('[data-mini="chess-square"][data-index="61"]')).toContainText("♖");

  await page.getByRole("button",{name:"Restart"}).click();
  await move(52,36); await move(8,16);
  await move(36,28); await move(11,27);
  await move(28,19);
  await expect(page.locator('[data-mini="chess-square"][data-index="19"]')).toContainText("♙");
  await expect(page.locator('[data-mini="chess-square"][data-index="27"]')).toHaveText("");
});

test("Chess exposes promotion choices only after a pawn reaches the last rank",async({page})=>{
  await openChess(page);
  await expect(page.locator(".chess-promotion")).toHaveCount(0);
  await expect(page.getByText(/Player 1 bergerak/)).toBeVisible();
});
