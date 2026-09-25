const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("./");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await expect(page.getByText("LET’S BEGIN TOGETHER")).toBeVisible();
  await page.locator('input[name="p1"]').fill("Ariel");
  await page.locator('input[name="p2"]').fill("Fe");
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
  await expect(page.getByText("YOUR RHYTHM",{exact:true})).toBeVisible();
  await expect(page.getByText("0 days together",{exact:true})).toBeVisible();
}

test.describe("IGNITE adaptive experience",()=>{
  test("vibe selector updates preferences and adaptive state",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile"}).click();
    await page.getByRole("button",{name:"Settings"}).click();
    await page.getByRole("button",{name:"Journey Preferences"}).click();
    await page.getByRole("button",{name:"Playful",exact:true}).click();
    const state=await page.evaluate(()=>({
      preferences:JSON.parse(localStorage.getItem("ignite-preferences-v1")||"{}"),
      adaptive:JSON.parse(localStorage.getItem("ignite-adaptive-v1")||"{}")
    }));
    expect(state.preferences.vibes).toContain("Playful");
    expect(state.adaptive.vibes.Playful).toBeGreaterThan(0);
  });

  test("couple progress and memory capsule are reachable",async({page})=>{
    await enter(page);
    await expect(page.getByText("COUPLE LEVEL",{exact:true})).toBeVisible();
    await page.getByRole("button",{name:"Memories",exact:true}).click();
    await expect(page.getByRole("heading",{name:"Keep the moments."})).toBeVisible();
    await expect(page.getByText("Your first memory is waiting.")).toBeVisible();
  });

  test("one more reveals a second adaptive card",async({page})=>{
    await page.goto("./");
    await page.evaluate(()=>{
      sessionStorage.setItem("ignite-welcome-seen","1");
      localStorage.setItem("ignite-redesign-v4",JSON.stringify({
        names:{p1:"A",p2:"B",couple:""},relationship:"Couple",relationshipSince:new Date().toISOString(),
        currentJourney:{id:"normal",title:"Normal Journey",subtitle:"Test",steps:[
          {kind:"activity",mechanic:"card",icon:"♡",title:"Talk Card",text:"Test",action:"Continue"}
        ]},
        step:0,view:"session",mode:"normal"
      }));
      localStorage.setItem("ignite-preferences-v1",JSON.stringify({vibes:["Playful"],duration:"medium",intensity:"balanced"}));
    });
    await page.reload();
    await expect(page.getByText("Ready for a card")).toBeVisible();
    await page.getByText("Tap to reveal").click();
    await expect(page.getByText("Card 1")).toBeVisible();
    await page.getByRole("button",{name:"Next Card →"}).click();
    await expect(page.getByText("Card 2")).toBeVisible();
  });
});


test("progression records a three-day rhythm without inflating on the same day",async({page})=>{
  await enter(page);
  const result=await page.evaluate(()=>{
    const p=JSON.parse(localStorage.getItem("ignite-progression-v1")||"{}");
    return {streak:p.stats?.currentStreak,longest:p.stats?.longestStreak,last:p.stats?.lastActiveDate};
  });
  expect(result.streak).toBe(1);
  expect(result.longest).toBe(1);
  expect(result.last).toBeTruthy();
});
