const {test,expect}=require("@playwright/test");

async function openChess(page){
  await page.goto("");
  await page.getByRole("button",{name:/Minigames/}).click();
  await page.getByRole("button",{name:/Chess/}).click();
  await expect(page.locator(".chess-board")).toBeVisible();
}

test("Chess board uses equal squares and renders distinct white and black pieces",async({page})=>{
  await openChess(page);
  const geometry=await page.locator(".chess-square").evaluateAll(els=>els.map(el=>{
    const r=el.getBoundingClientRect();
    return {width:r.width,height:r.height};
  }));
  expect(geometry).toHaveLength(64);
  for(const g of geometry) expect(Math.abs(g.width-g.height)).toBeLessThanOrEqual(0.5);
  await expect(page.locator(".chess-square.piece-w")).toHaveCount(16);
  await expect(page.locator(".chess-square.piece-b")).toHaveCount(16);
  await expect(page.locator('[data-index="60"]')).toContainText("♔");
  await expect(page.locator('[data-index="4"]')).toContainText("♚");
});

test("Chess accepts a legal pawn move and switches turn",async({page})=>{
  await openChess(page);
  await page.locator('[data-mini="chess-square"][data-index="52"]').click();
  await page.locator('[data-mini="chess-square"][data-index="36"]').click();
  await expect(page.locator('[data-mini="chess-square"][data-index="36"]')).toContainText("♙");
  await expect(page.getByText(/Player 2 bergerak/)).toBeVisible();
});

test("Chess rejects an illegal move and supports undo",async({page})=>{
  await openChess(page);
  await page.locator('[data-mini="chess-square"][data-index="52"]').click();
  await page.locator('[data-mini="chess-square"][data-index="36"]').click();
  await page.locator('[data-mini="chess-square"][data-index="44"]').click();
  await page.locator('[data-mini="chess-square"][data-index="36"]').click();
  await expect(page.locator('[data-mini="chess-square"][data-index="36"]')).toContainText("♙");
  await page.getByRole("button",{name:"Undo"}).click();
  await expect(page.locator('[data-mini="chess-square"][data-index="52"]')).toContainText("♙");
  await expect(page.locator('[data-mini="chess-square"][data-index="36"]')).toHaveText("");
});
