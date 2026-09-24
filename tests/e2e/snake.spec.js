const {test,expect}=require("@playwright/test");

async function enterIgniteWelcome(page){
  await expect(page.getByRole("button",{name:/ENTER TOGETHER/})).toBeVisible();
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

async function openSnake(page){
  await page.goto("./");
  await enterIgniteWelcome(page);
  await page.evaluate(()=>localStorage.clear());
  await page.reload();
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await page.locator('[data-mini-open="snake"]').click();
}

test.describe("Snake & Ladder",()=>{
  test("opens with 100-cell board, player HUD, dice and challenge modes",async({page})=>{
    await openSnake(page);
    await expect(page.locator(".snake-board .snake-cell")).toHaveCount(100);
    await expect(page.locator(".snake-player")).toHaveCount(2);
    await expect(page.locator(".snake-control .dice-result")).toBeVisible();
    await expect(page.getByRole("button",{name:"Normal"})).toBeVisible();
    await expect(page.getByRole("button",{name:"Extreme"})).toBeVisible();
  });

  test("roll changes turn or shows a board event without breaking the game",async({page})=>{
    await openSnake(page);
    await page.locator('[data-mini="snake-roll"]').click();
    await expect(page.locator(".snake-control .dice-result")).not.toHaveText("—");
    await expect(page.locator(".snake-board")).toBeVisible();
    const actionCount=await page.locator('[data-mini="snake-continue"], [data-mini="snake-done"], [data-mini="snake-roll"]').count();
    expect(actionCount).toBeGreaterThan(0);
  });

  test("challenge skip moves the player back three squares",async({page})=>{
    await openSnake(page);
    const result=await page.evaluate(async()=>{
      const url=new URL("./scripts/minigames/snake.js",location.href).href;
      const m=await import(url);
      const s=m.createSnakeState();
      s.turn=0;s.pos=[5,0];s.event={type:"challenge",square:5,kind:"couple"};s.challenge={kind:"couple",level:"normal",text:"x"};
      m.snakeContinue(s,"skip");
      return {position:s.pos[0],event:s.event?.type};
    });
    expect(result.position).toBe(2);
    expect(result.event).toBe("skip");
  });

  test("exact 100 wins and overshoot does not move",async({page})=>{
    await openSnake(page);
    const result=await page.evaluate(async()=>{
      const url=new URL("./scripts/minigames/snake.js",location.href).href;
      const m=await import(url);
      const original=Math.random;
      Math.random=()=>0;
      const s=m.createSnakeState();s.turn=0;s.pos=[99,0];
      m.snakeRoll(s);
      const win={pos:s.pos[0],finished:s.finished,winner:s.winner};
      const o=m.createSnakeState();o.turn=0;o.pos=[98,0];
      Math.random=()=>0.34;
      m.snakeRoll(o);
      Math.random=()=>0;
      const overshoot={pos:o.pos[0],event:o.event?.type};
      Math.random=original;
      return {win,overshoot};
    });
    expect(result.win).toEqual({pos:100,finished:true,winner:0});
    expect(result.overshoot).toEqual({pos:98,event:"overshoot"});
  });
});