const {test,expect}=require("@playwright/test");

async function enter(page){
 await page.goto("");
 await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
 await expect(page.getByText("LET’S BEGIN TOGETHER")).toBeVisible();
 await page.locator('input[name="p1"]').fill("Ariel");
 await page.locator('input[name="p2"]').fill("Fe");
 await page.getByRole("button",{name:/Start Our Journey/}).click();
 await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}
async function setupJourney(page,mode="normal",steps=6){
 await enter(page);
 if(mode==="dark") await page.getByRole("button",{name:"After Dark",exact:true}).click();
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await page.getByRole("button",{name:"Journey Preferences",exact:true}).click();
 await page.locator('input[name="steps"]').evaluate((el,value)=>{el.value=String(value);el.dispatchEvent(new Event("input",{bubbles:true}));},steps);
 await page.getByRole("button",{name:"Save Preferences",exact:true}).click();
 await page.getByRole("button",{name:"Start Journey →"}).click();
 await expect(page.getByRole("heading",{name:mode==="dark"?"After Dark":"Normal Journey",exact:true})).toBeVisible();
 await page.getByRole("button",{name:/Begin Journey/}).click();
}
test("Normal Journey can complete",async({page})=>{
 await setupJourney(page);
 await expect(page.getByText("Warm Up")).toBeVisible();
 for(let i=0;i<5;i++){await page.getByRole("button",{name:/Merah/}).click();if(i<4)await page.getByRole("button",{name:"Next Round"}).click();}
 await page.getByRole("button",{name:"Continue →"}).click();
 for(let i=0;i<4;i++)await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await expect(page.getByText("Journey Complete")).toBeVisible();
});

test("Normal Journey exposes card and Truth or Dare mechanics",async({page})=>{
 await setupJourney(page, "normal", 6);
 const generated=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")||"{}").currentJourney);
 expect(generated.steps.map(s=>s.title)).toEqual(expect.arrayContaining(["Talk Card","Truth or Dare"]));
 const cardIndex=generated.steps.findIndex(s=>s.title==="Talk Card");
 const rpsIndex=generated.steps.findIndex(s=>s.title==="Change the Energy");
 expect(cardIndex).toBeGreaterThan(0);
 expect(rpsIndex).toBeGreaterThan(0);

 for(let i=0;i<cardIndex;i++){
   await expect.poll(async()=>JSON.parse(await page.evaluate(()=>localStorage.getItem("ignite-redesign-v4")||"{}")).step).toBe(i);
   await page.getByRole("button",{name:"Skip"}).click();
 }
 await expect(page.getByText("Talk Card",{exact:true})).toBeVisible();
 await page.getByText("Tap to reveal").click();
 await expect(page.locator(".reveal-card")).toContainText(/./);
 await page.getByRole("button",{name:"Continue →"}).click();

 for(let i=cardIndex+1;i<rpsIndex;i++){
   await expect.poll(async()=>JSON.parse(await page.evaluate(()=>localStorage.getItem("ignite-redesign-v4")||"{}")).step).toBe(i);
   await page.getByRole("button",{name:"Skip"}).click();
 }
 await expect(page.getByText("Change the Energy",{exact:true})).toBeVisible();
 await page.getByRole("button",{name:"Batu"}).click();
 await page.getByRole("button",{name:"Kertas"}).click();
 await page.getByRole("button",{name:"Next Round"}).click();
 await expect(page.getByText("Change the Energy",{exact:true})).toBeVisible();
});

test("After Dark requires consent before entering",async({page})=>{
 await enter(page);
 await page.getByRole("button",{name:"After Dark",exact:true}).click();
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await page.getByRole("button",{name:"Start Journey →"}).click();
 await expect(page.getByRole("heading",{name:"After Dark",exact:true})).toBeVisible();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).not.toBeVisible();
 await page.locator("#consent").check();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).toBeVisible();
});

test("Roleplay opens and advances scenes",async({page})=>{
 await enter(page);
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await page.getByRole("button",{name:/Roleplay/}).click();
 await expect(page.getByText("Roleplay")).toBeVisible();
 await page.getByRole("button",{name:"Draw Role"}).click();
 await expect(page.getByText("SCENE",{exact:true})).toBeVisible();
 await page.getByRole("button",{name:"Next Scene"}).click();
 await expect(page.getByText("YOUR MOVE")).toBeVisible();
});

test("Journey history records a completed Journey",async({page})=>{
 await setupJourney(page);
 for(let i=0;i<5;i++){await page.getByRole("button",{name:/Merah/}).click();if(i<4)await page.getByRole("button",{name:"Next Round"}).click();}
 await page.getByRole("button",{name:"Continue →"}).click();
 for(let i=0;i<4;i++)await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await page.getByRole("button",{name:"Done for now"}).click();
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await expect(page.getByRole("button",{name:"View Journey History"})).toBeVisible();
 await page.getByRole("button",{name:"View Journey History"}).click();
 await expect(page.getByText("Normal Journey",{exact:true})).toBeVisible();
});
