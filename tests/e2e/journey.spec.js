const {test,expect}=require("@playwright/test");

async function startNormal(page){
 await page.goto("");
 await expect(page.getByText("Let’s spend")).toBeVisible();
 await page.getByRole("button",{name:/Normal/}).click();
 await expect(page.getByText("Who is here?")).toBeVisible();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await expect(page.getByText("Normal Journey")).toBeVisible();
 await page.getByRole("button",{name:/Begin Journey/}).click();
 await expect(page.getByText("Warm Up")).toBeVisible();
}

test.beforeEach(async({page})=>{
 page.on("pageerror",error=>{throw error});
});

test("home renders and Normal Journey can complete",async({page})=>{
 await startNormal(page);
 await expect(page.getByText("Pilih warna kartu")).toBeVisible();
 for(let i=0;i<5;i++){ await page.getByRole("button",{name:/Merah/}).click(); await expect(page.getByText(/Kartu:/)).toBeVisible(); if(i<4) await page.getByRole("button",{name:"Next Round"}).click(); }
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await expect(page.getByText("Journey Complete")).toBeVisible();
});

test("Normal Journey exposes card and Truth or Dare mechanics",async({page})=>{
 await startNormal(page);
 await page.getByRole("button",{name:"Skip"}).click();
 await expect(page.getByText("Talk Card")).toBeVisible();
 await expect(page.getByText("Talk Card")).toBeVisible();
 await page.getByText("Tap to reveal").click();
 await expect(page.locator(".reveal-card")).toContainText(/./);
 await page.getByRole("button",{name:"Continue →"}).click();
 await expect(page.getByText("Change the Energy")).toBeVisible();
 for(let i=0;i<5;i++){ await page.getByRole("button",{name:"Batu"}).click(); await page.getByRole("button",{name:"Kertas"}).click(); if(i<4) await page.getByRole("button",{name:"Next Round"}).click(); }
 await page.getByRole("button",{name:"Continue →"}).click();
 await expect(page.getByText("Truth or Dare")).toBeVisible();
 await page.getByRole("button",{name:"Dare"}).click();
 await page.getByText("Tap to reveal").click();
 await expect(page.locator(".reveal-card")).toContainText(/./);
});

test("After Dark requires consent before entering",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:/After Dark/}).click();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await expect(page.getByRole("heading",{name:"After Dark",exact:true})).toBeVisible();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).not.toBeVisible();
 await page.locator("#consent").check();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).toBeVisible();
});


test("Phase 3 Roleplay opens and can advance scenes",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:/Minigames/}).click();
 await page.getByRole("button",{name:/Roleplay/}).click();
 await expect(page.getByText("Roleplay")).toBeVisible();
 await page.getByRole("button",{name:"Draw Role"}).click();
 await expect(page.getByText("SCENE",{exact:true})).toBeVisible();
 await page.getByRole("button",{name:"Next Scene"}).click();
 await expect(page.getByText("YOUR MOVE")).toBeVisible();
});

test("Phase 3 King & Slave requires consent and rolls a round",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:/Minigames/}).click();
 await page.getByRole("button",{name:/King & Slave/}).click();
 await expect(page.getByText("King & Slave")).toBeVisible();
 await page.locator("#ks-consent").check();
 await page.getByRole("button",{name:"Start Game"}).click();
 await expect(page.getByText("Who holds the crown?")).toBeVisible();
 await page.getByRole("button",{name:"Roll Dice"}).click();
 await expect(page.getByText("Your Command")).toBeVisible();
});

test("Phase 3 Chess renders board and accepts a legal move",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:/Minigames/}).click();
 await page.getByRole("button",{name:/Chess/}).click();
 await expect(page.locator(".chess-board")).toBeVisible();
 await page.locator('[data-mini="chess-square"][data-index="52"]').click();
 await page.locator('[data-mini="chess-square"][data-index="36"]').click();
 await expect(page.getByText(/bergerak/).first()).toBeVisible();
});

test("Phase 3 Snake & Ladder rolls and updates game state",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:/Minigames/}).click();
 await page.getByRole("button",{name:/Snake & Ladder/}).click();
 await expect(page.locator(".snake-board")).toBeVisible();
 await page.getByRole("button",{name:"Roll Dice"}).click();
 await expect(page.locator(".dice-result")).toBeVisible();
});


test("Phase 5 progression tracks XP, level stats, and achievements",async({page})=>{
 await page.goto("");
 await expect(page.getByText(/Level 1 · Spark/)).toBeVisible();
 await page.getByRole("button",{name:/Normal/}).click();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await page.getByRole("button",{name:/Begin Journey/}).click();
 for(let i=0;i<5;i++){await page.getByRole("button",{name:/Merah/}).click();if(i<4)await page.getByRole("button",{name:"Next Round"}).click();}
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Tap to reveal"}).click();
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await page.getByRole("button",{name:"Back to Journey"}).click();
 await expect(page.getByText(/Level 2 · Closer/)).toBeVisible();
 await page.getByRole("button",{name:/Deon & Partner/}).click();
 await expect(page.getByText("First Journey")).toBeVisible();
 await expect(page.getByText(/Journeys/)).toBeVisible();
});

test("Phase 5 direct minigame access records Game Night progress",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:/Minigames/}).click();
 await page.getByRole("button",{name:/Roleplay/}).click();
 await page.getByRole("button",{name:"← All Minigames"}).click();
 await page.getByRole("button",{name:/←/}).first().click();
 await expect(page.getByText("Game Night")).toBeVisible();
});
