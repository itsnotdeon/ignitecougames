const {test,expect}=require("@playwright/test");

async function openChess(page){
  await page.goto("");
  await page.getByRole("button",{name:/Minigames/}).click();
  await page.getByRole("button",{name:/Chess/}).click();
  await expect(page.locator(".chess-board")).toBeVisible();
}

async function move(page,from,to){
  await page.locator('[data-mini="chess-square"][data-index="'+from+'"]').click();
  await page.locator('[data-mini="chess-square"][data-index="'+to+'"]').click();
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
  await move(page,52,36);
  await expect(page.locator('[data-mini="chess-square"][data-index="36"]')).toContainText("♙");
  await expect(page.getByText(/Player 2 bergerak/)).toBeVisible();
});

test("Chess supports castling with a legal king-side sequence",async({page})=>{
  await openChess(page);
  await move(page,52,36); await expect(page.locator('[data-index="36"]')).toContainText("♙");
  await move(page,12,28); await expect(page.locator('[data-index="28"]')).toContainText("♟");
  await move(page,62,45); await expect(page.locator('[data-index="45"]')).toContainText("♘");
  await move(page,1,18); await expect(page.locator('[data-index="18"]')).toContainText("♞");
  await move(page,61,52); await expect(page.locator('[data-index="52"]')).toContainText("♗");
  await move(page,6,21); await expect(page.locator('[data-index="21"]')).toContainText("♞");
  await move(page,60,62);
  await expect(page.locator('[data-index="62"]')).toContainText("♔");
  await expect(page.locator('[data-index="61"]')).toContainText("♖");
});

test("Chess supports en passant",async({page})=>{
  await openChess(page);
  await move(page,52,36);
  await move(page,8,16);
  await move(page,36,28);
  await move(page,11,27);
  await move(page,28,19);
  await expect(page.locator('[data-index="19"]')).toContainText("♙");
  await expect(page.locator('[data-index="27"]')).toHaveText("");
});

test("Chess exposes promotion controls in the promotion-ready UI layer",async({page})=>{
  await openChess(page);
  await expect(page.locator(".chess-promotion")).toHaveCount(0);
  await expect(page.getByText(/Player 1 bergerak/)).toBeVisible();
});
