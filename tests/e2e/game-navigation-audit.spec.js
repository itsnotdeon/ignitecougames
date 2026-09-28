const {test,expect}=require("@playwright/test");

async function enterApp(page){
  await page.goto("");
  await expect(page.getByRole("button",{name:/ENTER TOGETHER/})).toBeVisible();
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await page.locator('input[name="p1"]').fill("Ariel");
  await page.locator('input[name="p2"]').fill("Fe");
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
  await page.getByRole("button",{name:"Play",exact:true}).click();
}

test("active minigames use one navigation control and one primary heading",async({page})=>{
  await enterApp(page);
  for(const game of ["roleplay","king","chess","snake"]){
    await page.locator('[data-mini-open="'+game+'"]').click();
    await expect(page.locator(".play-active-head")).toBeVisible();
    await expect(page.locator('.play-active-head [data-action="minigames-menu"]')).toHaveCount(1);
    await expect(page.getByRole("button",{name:/All Games/})).toHaveCount(1);
    await expect(page.locator(".game-screen-title h2, .ks-header h2")).toHaveCount(1);
    await page.locator('[data-action="minigames-menu"]').click();
    await expect(page.locator(".mini-grid")).toBeVisible();
  }
});

test("embedded Journey Roleplay has no redundant game navigation",async({page})=>{
  await enterApp(page);
  await page.getByRole("button",{name:"Home",exact:true}).click();
  await page.getByRole("button",{name:/After Dark/}).click();
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await page.locator('[data-action="start"][data-journey="dark"]').click();
  await expect(page.getByText("BUILDING YOUR JOURNEY",{exact:true})).toBeVisible();
  await page.waitForTimeout(750);
  const enter=page.getByRole("button",{name:/Enter After Dark|Begin Journey/}).last();
  await expect(enter).toBeVisible();
  if(await page.locator("#consent").count()) await page.locator("#consent").check();
  await enter.click();
  for(let i=0;i<12;i++){
    if(await page.getByRole("button",{name:/Open Roleplay/}).count()) break;
    const next=page.getByRole("button",{name:/Continue/}).last();
    if(await next.count()&&await next.isEnabled()) await next.click(); else break;
  }
  if(await page.getByRole("button",{name:/Open Roleplay/}).count()){
    await page.getByRole("button",{name:/Open Roleplay/}).click();
    await expect(page.locator('.journey-roleplay [data-action="minigames-menu"]')).toHaveCount(0);
  }
});


test("history and completion screens do not duplicate their exit action",async({page})=>{
  await enterApp(page);
  await page.locator('[data-action="journey"]').click();
  await expect(page.getByText("JOURNEY HISTORY",{exact:true})).toBeVisible();
  await expect(page.locator('[data-action="minigames"]')).toHaveCount(1);

  await page.evaluate(()=>{
    localStorage.setItem("ignite-redesign-v4",JSON.stringify({
      names:{p1:"Ariel",p2:"Fe"},relationship:"Couple",relationshipSince:null,
      currentJourney:null,step:0,view:"complete",mode:"normal"
    }));
  });
  await page.reload();
  await expect(page.getByText("How was tonight?",{exact:true})).toBeVisible();
  await expect(page.locator('[data-action="home"]')).toHaveCount(1);
});
