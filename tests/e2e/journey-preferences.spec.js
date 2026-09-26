const {test,expect}=require("@playwright/test");

async function enter(page,p1="Ariel",p2="Fe"){
  await page.goto("");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await page.locator('input[name="p1"]').fill(p1);
  await page.locator('input[name="p2"]').fill(p2);
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

async function openPreferences(page){
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await page.getByRole("button",{name:"Journey Preferences",exact:true}).click();
  await expect(page.getByRole("heading",{name:"How do you want to connect?"})).toBeVisible();
}

async function buildWithSteps(page,steps,vibe){
  await openPreferences(page);
  await page.getByRole("button",{name:vibe,exact:true}).click();
  const input=page.locator('input[name="steps"]');
  await input.fill(String(steps));
  await page.getByRole("button",{name:"Save Preferences",exact:true}).click();
  await expect(page.getByText("Make the next Journey yours.",{exact:true})).toBeVisible();
  await page.getByRole("button",{name:"Build Dynamic Journey",exact:true}).click();
  await expect(page.getByText("BUILDING YOUR JOURNEY",{exact:true})).toBeVisible();
  await expect(page.getByText(new RegExp(`IGNITE sedang menyusun ${steps} steps`))).toBeVisible();
  await page.waitForFunction((steps)=>{try{return JSON.parse(localStorage.getItem("ignite-redesign-v4"))?.currentJourney?.steps?.length===steps}catch{return false}},steps,{timeout:5000});
  return page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")));
}

test.describe("Journey Preferences and dynamic generation",()=>{
  test("saves a single vibe and custom step count",async({page})=>{
    await enter(page);
    await openPreferences(page);
    await page.getByRole("button",{name:"Deep",exact:true}).click();
    await page.locator('input[name="steps"]').evaluate((el)=>{el.value="9";el.dispatchEvent(new Event("input",{bubbles:true}));});
    await page.getByRole("button",{name:"Save Preferences",exact:true}).click();

    const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-preferences-v1")));
    expect(stored).toEqual({vibes:["Deep"],steps:9});
    await openPreferences(page);
    await expect(page.locator('input[name="steps"]')).toHaveValue("9");
    await expect(page.getByRole("button",{name:"Deep",exact:true})).toHaveAttribute("aria-pressed","true");
    await expect(page.getByText(/intensity/i)).toHaveCount(0);
  });


  test("direct Journey start uses the saved step count",async({page})=>{
    await enter(page);
    await openPreferences(page);
    await page.locator('input[name="steps"]').evaluate((el)=>{el.value="7";el.dispatchEvent(new Event("input",{bubbles:true}));});
    await page.getByRole("button",{name:"Save Preferences",exact:true}).click();
    await page.getByRole("button",{name:"Home",exact:true}).click();
    await page.locator('[data-action="start"][data-journey="normal"]').click();
    await expect(page.getByText("BUILDING YOUR JOURNEY",{exact:true})).toBeVisible();
    await expect(page.getByText(/IGNITE sedang menyusun 7 steps/)).toBeVisible();
    await page.waitForFunction(()=>{try{return JSON.parse(localStorage.getItem("ignite-redesign-v4"))?.currentJourney?.steps?.length===7}catch{return false}},{timeout:5000});
    const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")));
    expect(stored.currentJourney.steps).toHaveLength(7);
  });

  test("engine generates exactly 3 requested steps",async({page})=>{
    await enter(page);
    const stored=await buildWithSteps(page,3,"Playful");
    expect(stored.currentJourney.steps).toHaveLength(3);
    expect(stored.currentJourney.steps[0].kind).toBe("ritual");
    expect(stored.currentJourney.steps.at(-1).kind).toBe("closing");
  });

  test("engine generates exactly 12 requested steps and preserves loading state",async({page})=>{
    await enter(page);
    const stored=await buildWithSteps(page,12,"Romantic");
    expect(stored.currentJourney.steps).toHaveLength(12);
    expect(stored.currentJourney.steps[0].kind).toBe("ritual");
    expect(stored.currentJourney.steps.at(-1).kind).toBe("closing");
  });
});
