const {test,expect}=require("@playwright/test");

async function enterIgniteWelcome(page){
  await expect(page.getByRole("button",{name:"Enter IGNITE"})).toBeVisible();
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("Let’s spend")).toBeVisible();
}

async function startNormal(page){
 await page.goto("");
  await enterIgniteWelcome(page);
 await expect(page.getByText("Let’s spend")).toBeVisible();
 await page.getByRole("button",{name:"Normal",exact:true}).click();
 await expect(page.getByRole("button",{name:"Normal",exact:true})).toHaveAttribute("aria-pressed","true");
 await page.getByRole("button",{name:"Play"}).click();
 await expect(page.getByRole("heading",{name:"Choose a game.",exact:true})).toBeVisible();
 await page.getByRole("button",{name:"Start Journey →"}).click();
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
 for(let i=0;i<5;i++){ await page.getByRole("button",{name:/Merah/}).click(); await expect(page.locator(".mechanic-result")).toBeVisible(); if(i<4) await page.getByRole("button",{name:"Next Round"}).click(); }
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
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:"After Dark",exact:true}).click();
 await page.getByRole("button",{name:"Play"}).click();
 await page.getByRole("button",{name:"Start Journey →"}).click();
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
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:/Play/}).click();
 await page.getByRole("button",{name:/Roleplay/}).click();
 await expect(page.getByText("Roleplay")).toBeVisible();
 await page.getByRole("button",{name:"Draw Role"}).click();
 await expect(page.getByText("SCENE",{exact:true})).toBeVisible();
 await page.getByRole("button",{name:"Next Scene"}).click();
 await expect(page.getByText("YOUR MOVE")).toBeVisible();
});

test("Phase 3 King & Slave requires consent and reveals a fair round",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:/Play/}).click();
 await page.getByRole("button",{name:/King & Slave/}).click();
 await expect(page.getByText("KING & SLAVE",{exact:true})).toBeVisible();
 await page.locator("#ks-consent").check();
 await page.getByRole("button",{name:"Mulai Sesi"}).click();
 await expect(page.getByText("ROUND 1",{exact:true})).toBeVisible();
 for(let attempt=0;attempt<10;attempt+=1){
  const roles=page.locator(".ks-role-person.king");
  if(await roles.count())break;
  await page.getByRole("button",{name:/Reveal King|Roll Again/}).click();
 }
 await expect(page.locator(".ks-role-person.king small")).toBeVisible();
 await page.getByRole("button",{name:"Draw Command Card"}).click();
 await expect(page.locator(".ks-command-card-main")).toBeVisible();
 await expect(page.getByRole("button",{name:"Jalankan"})).toBeVisible();
 await expect(page.getByRole("button",{name:"Skip"})).toBeVisible();
});

test("Phase 3 Chess renders board, keeps square geometry, distinguishes piece colors, and accepts legal moves",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:/Play/}).click();
 await page.getByRole("button",{name:/Chess/}).click();
 const board=page.locator(".chess-board");
 await expect(board).toBeVisible();
 await expect(page.locator('[data-mini="chess-square"]')).toHaveCount(64);
 const firstBox=await page.locator('[data-mini="chess-square"]').first().boundingBox();
 const lastBox=await page.locator('[data-mini="chess-square"]').nth(7).boundingBox();
 expect(firstBox).not.toBeNull();
 expect(lastBox).not.toBeNull();
 expect(Math.abs(firstBox.height-firstBox.width)).toBeLessThanOrEqual(1);
 expect(Math.abs(lastBox.height-lastBox.width)).toBeLessThanOrEqual(1);
 await expect(page.locator(".chess-square.piece-w").first()).toHaveCSS("color","rgb(255, 255, 255)");
 await expect(page.locator(".chess-square.piece-b").first()).toHaveCSS("color","rgb(36, 16, 26)");
 await page.locator('[data-mini="chess-square"][data-index="52"]').click();
 await page.locator('[data-mini="chess-square"][data-index="36"]').click();
 await expect(page.getByText(/bergerak/).first()).toBeVisible();
});

test("Chess supports castling after the required squares are cleared",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:/Play/}).click();
 await page.getByRole("button",{name:/Chess/}).click();
 const sq=(i)=>page.locator('[data-mini="chess-square"][data-index="'+i+'"]');
 await sq(52).click(); await sq(36).click(); // e4
 await sq(12).click(); await sq(28).click(); // ...e5
 await sq(62).click(); await sq(45).click(); // Nf3
 await sq(6).click(); await sq(21).click(); // ...Nf6
 await sq(61).click(); await sq(34).click(); // Bc4
 await sq(5).click(); await sq(26).click(); // ...Bc5
 await expect(sq(60)).toHaveClass(/piece-w/);
 await sq(60).click();
 await expect(sq(62)).toHaveClass(/legal/);
 await sq(62).click();
 await expect(sq(62)).toHaveClass(/piece-w/);
 await expect(sq(61)).toHaveClass(/piece-w/);
 await expect(sq(60)).toHaveText("");
});

test("Phase 3 Snake & Ladder rolls and updates game state",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:/Play/}).click();
 await page.getByRole("button",{name:/Snake & Ladder/}).click();
 await expect(page.locator(".snake-board")).toBeVisible();
 await page.getByRole("button",{name:"Roll Dice"}).click();
 await expect(page.locator(".dice-result")).toBeVisible();
});

test("Phase 5 progression tracks XP, level stats, and achievements",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await expect(page.locator(".progression-card strong")).toContainText("Spark");
 await page.getByRole("button",{name:/Play/}).click();
 await page.getByRole("button",{name:"Start Journey →"}).click();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await page.getByRole("button",{name:/Begin Journey/}).click();
 for(let i=0;i<5;i++){await page.getByRole("button",{name:/Merah/}).click();if(i<4)await page.getByRole("button",{name:"Next Round"}).click();}
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Tap to reveal"}).click();
 await page.getByRole("button",{name:"Continue →"}).click();
 for(let i=0;i<5;i++){await page.getByRole("button",{name:"Batu"}).click();await page.getByRole("button",{name:"Kertas"}).click();if(i<4)await page.getByRole("button",{name:"Next Round"}).click();}
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await page.getByRole("button",{name:"←"}).click();
 await expect(page.locator(".progression-card strong")).toContainText("Closer");
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await expect(page.getByText("First Journey")).toBeVisible();
 await expect(page.getByText(/Journeys/)).toBeVisible();
});

test("Phase 5 direct minigame access records Game Night progress",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:/Play/}).click();
 await page.getByRole("button",{name:/Roleplay/}).click();
 await page.getByRole("button",{name:"← All Minigames"}).click();
 await page.getByRole("button",{name:"←"}).click();
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await expect(page.getByText("Game Night")).toBeVisible();
});

test("Phase 4 Profile and Settings are separated",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await expect(page.getByText("Couple Profile")).toBeVisible();
 await expect(page.getByText("Content Library")).not.toBeVisible();
 await expect(page.getByText("Data Management")).not.toBeVisible();
 await page.getByRole("button",{name:"Settings",exact:true}).click();
 await expect(page.getByText("App Settings")).toBeVisible();
 await expect(page.getByText("Personalization")).toBeVisible();
 await expect(page.locator(".content-manager")).toContainText("Content Library");
 await expect(page.locator(".data-manager")).toContainText("Data Management");
 await expect(page.getByRole("button",{name:"Export Content"})).toBeVisible();
 await expect(page.getByRole("button",{name:"Export Backup"})).toBeVisible();
});

test("Phase 9 Journey is a story timeline and opens completed Journey details",async({page})=>{
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await page.getByRole("button",{name:"View Journey History"}).click();
 await expect(page.locator(".hero").getByText("Your Story",{exact:true})).toBeVisible();
 await expect(page.getByText("The story starts here")).toBeVisible();
 await expect(page.getByText("What are you up for?")).not.toBeVisible();

 await page.getByRole("button",{name:"Home",exact:true}).click();
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await page.getByRole("button",{name:"Start Journey →"}).click();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await page.getByRole("button",{name:/Begin Journey/}).click();
 for(let i=0;i<5;i++){await page.getByRole("button",{name:/Merah/}).click();if(i<4)await page.getByRole("button",{name:"Next Round"}).click();}
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await page.getByRole("button",{name:"←"}).click();
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await page.getByRole("button",{name:"View Journey History"}).click();
 await expect(page.getByText("Normal Journey",{exact:true})).toBeVisible();
 await expect(page.getByText("+60 XP",{exact:true})).toBeVisible();
 await page.getByRole("button",{name:/Normal Journey/}).click();
 await expect(page.getByText("Completed Journey")).toBeVisible();
 await expect(page.getByText("Warm Up",{exact:true})).toBeVisible();
 await expect(page.getByText("Close the Journey",{exact:true})).toBeVisible();
 await page.reload();
 await expect(page.getByText("Completed Journey")).toBeVisible();
 await expect(page.getByText("Warm Up",{exact:true})).toBeVisible();
});
