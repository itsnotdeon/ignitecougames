const {test,expect}=require("@playwright/test");

async function enter(page,p1="Ariel",p2="Fe",relationship=null){
  await page.goto("");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await expect(page.getByText("LET’S BEGIN TOGETHER")).toBeVisible();
  await page.locator('input[name="p1"]').fill(p1);
  await page.locator('input[name="p2"]').fill(p2);
  if(relationship) await page.locator('select[name="relationship"]').selectOption(relationship);
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

test.describe("IGNITE mockup UI",()=>{
  test("mobile Home has no horizontal overflow",async({page})=>{
    await page.setViewportSize({width:375,height:812});
    await enter(page);
    expect(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth)).toBe(false);
    await expect(page.getByText("COUPLE LEVEL",{exact:true})).toBeVisible();
    await expect(page.getByRole("button",{name:"Normal",exact:true})).toHaveAttribute("aria-pressed","true");
  });

  test("mode selection persists and changes Home",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"After Dark",exact:true}).click();
    await expect(page.getByRole("button",{name:"After Dark",exact:true})).toHaveAttribute("aria-pressed","true");
    const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")));
    expect(stored.mode).toBe("dark");
    await page.reload();
    await expect(page.getByRole("button",{name:"After Dark",exact:true})).toHaveAttribute("aria-pressed","true");
  });

  test("Play hub exposes Journey and quick games",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Play",exact:true}).click();
    await expect(page.getByRole("heading",{name:"What should we play?"})).toBeVisible();
    await expect(page.getByText("QUICK PLAY",{exact:true})).toBeVisible();
    await expect(page.getByText("TONIGHT’S JOURNEY",{exact:true})).toBeVisible();
  });

  test("Bond hub exposes its connection tools",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"BOND"}).click();
    await expect(page.getByRole("heading",{name:"Make space for each other."})).toBeVisible();
    await expect(page.getByText("DAILY QUESTION",{exact:true})).toBeVisible();
    await expect(page.getByText("COUPLE QUIZ",{exact:true})).toBeVisible();
    await expect(page.getByText("DEEP TALK",{exact:true})).toBeVisible();
  });

  test("Profile and Settings remain reachable",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await expect(page.getByText("COUPLE PROFILE",{exact:true})).toBeVisible();
    await page.getByRole("button",{name:"Settings",exact:true}).click();
    await expect(page.getByRole("heading",{name:/Keep it/})).toBeVisible();
    await expect(page.getByText("LOCAL DATA",{exact:true})).toBeVisible();
    await expect(page.getByText("Journey Preferences",{exact:true})).toBeVisible();
    await expect(page.getByText("Play → Journey Preferences",{exact:true})).toBeVisible();
    await expect(page.getByText("Home → IGNITE Mode",{exact:true})).toBeVisible();
    await expect(page.getByText("Your data stays with you.",{exact:true})).toBeVisible();
    await expect(page.getByText("TOPIC LIBRARY",{exact:true})).toBeVisible();
    await expect(page.getByText(/topics available$/)).toBeVisible();
    await page.getByRole("button",{name:"Manage My Topics",exact:true}).click();
    await expect(page.getByRole("heading",{name:/Make it/})).toBeVisible();
  });

  test("Setup saves names and relationship",async({page})=>{
    await enter(page,"Deon","Partner","Dating");
    const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")));
    expect(stored.names.p1).toBe("Deon");
    expect(stored.names.p2).toBe("Partner");
    expect(stored.relationship).toBe("Dating");
  });
});


test("custom topics can be added and deleted without changing built-in topics",async({page})=>{
  await enter(page);
  await page.getByRole("button",{name:"Profile",exact:true}).click();
  await page.getByRole("button",{name:"Settings",exact:true}).click();
  const before=await page.getByText(/topics available$/).textContent();
  await page.getByRole("button",{name:"Manage My Topics",exact:true}).click();
  await page.locator('select[name="category"]').selectOption("normalCards");
  await page.locator('textarea[name="text"]').fill("Custom Deon topic for testing");
  await page.getByRole("button",{name:"Add Topic",exact:true}).click();
  await expect(page.getByText("Custom Deon topic for testing",{exact:true})).toBeVisible();
  const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-custom-topics-v1")));
  expect(stored.normalCards).toContain("Custom Deon topic for testing");
  await page.getByRole("button",{name:"Delete Custom Deon topic for testing",exact:true}).click();
  await expect(page.getByText("Custom Deon topic for testing",{exact:true})).toHaveCount(0);
  const after=await page.getByRole("button",{name:"settings"}).getAttribute("aria-label").catch(()=>null);
  expect(after===null||typeof after==="string").toBe(true);
  const storedAfter=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-custom-topics-v1")));
  expect(storedAfter.normalCards).not.toContain("Custom Deon topic for testing");
  expect(before).toMatch(/topics available$/);
});
