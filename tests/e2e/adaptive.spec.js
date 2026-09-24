const {test,expect}=require("@playwright/test");

test.describe("IGNITE adaptive experience",()=>{
  test("vibe selector updates preferences and adaptive state",async({page})=>{
    await page.goto("./");
    await page.getByRole("button",{name:"Enter IGNITE"}).click();
    await expect(page.getByText("What feels right tonight?")).toBeVisible();
    await page.getByRole("button",{name:"Playful"}).click();
    const state=await page.evaluate(()=>({
      preferences:JSON.parse(localStorage.getItem("ignite-preferences-v1")||"{}"),
      adaptive:JSON.parse(localStorage.getItem("ignite-adaptive-v1")||"{}")
    }));
    expect(state.preferences.vibes).toContain("Playful");
    expect(state.adaptive.vibes.Playful).toBeGreaterThan(0);
  });

  test("couple progress and memory capsule are reachable",async({page})=>{
    await page.goto("./");
    await page.getByRole("button",{name:"Enter IGNITE"}).click();
    await expect(page.getByText("Couple Progress")).toBeVisible();
    await page.getByRole("button",{name:"Open Memories"}).click();
    await expect(page.getByRole("heading",{name:"Keep the moments."})).toBeVisible();
    await expect(page.getByText("No moments yet.")).toBeVisible();
  });

  test("one more reveals a second adaptive card",async({page})=>{
    await page.goto("./");
    await page.evaluate(()=>{
      localStorage.setItem("ignite-redesign-v4",JSON.stringify({
        names:{p1:"A",p2:"B",couple:""},
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
