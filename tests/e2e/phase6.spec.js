const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("");
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
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
    await expect(page.getByRole("heading",{name:"Set it your way."})).toBeVisible();
    await expect(page.getByText("Journey Preferences",{exact:true})).toBeVisible();
    await expect(page.getByText("Your data stays with you.",{exact:true})).toBeVisible();
  });

  test("Setup saves names and relationship",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Play",exact:true}).click();
    await page.getByRole("button",{name:"Start Something →"}).click();
    await page.locator('input[name="p1"]').fill("Deon");
    await page.locator('input[name="p2"]').fill("Partner");
    await page.locator('select[name="relationship"]').selectOption("Dating");
    await page.getByRole("button",{name:"Start Our Journey →"}).click();
    const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")));
    expect(stored.names.p1).toBe("Deon");
    expect(stored.names.p2).toBe("Partner");
    expect(stored.relationship).toBe("Dating");
  });
});
