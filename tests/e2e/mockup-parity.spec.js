const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await page.locator('input[name="p1"]').fill("Ariel");
  await page.locator('input[name="p2"]').fill("Fe");
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

test.describe("IGNITE mockup parity and dual themes",()=>{
  test("Normal keeps a sweet elegant dark theme",async({page})=>{
    await enter(page);
    const normal=await page.evaluate(()=>({
      mode:document.body.dataset.igniteMode,
      background:getComputedStyle(document.body).backgroundImage,
      accent:getComputedStyle(document.documentElement).getPropertyValue("--ignite-accent").trim()
    }));
    expect(normal.mode).toBe("normal");
    expect(normal.background).toContain("linear-gradient");
    expect(normal.accent).toBe("#e985a5");
  });

  test("After Dark switches to a distinct deep elegant theme",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"After Dark"}).click();
    await expect(page.locator("body")).toHaveAttribute("data-ignite-mode","dark");
    const dark=await page.evaluate(()=>({
      background:getComputedStyle(document.body).backgroundImage,
      accent:getComputedStyle(document.body).getPropertyValue("--rose").trim()
    }));
    expect(dark.background).toContain("linear-gradient");
    expect(dark.accent).toBe("#b94d70");
  });

  test("Memories hub matches the mockup information hierarchy",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Memories",exact:true}).click();
    await expect(page.getByRole("heading",{name:"MEMORIES",exact:true})).toBeVisible();
    await expect(page.getByText("OUR SPECIAL MOMENTS",{exact:true})).toBeVisible();
    await expect(page.getByText("Memory Categories",{exact:true})).toBeVisible();
    await expect(page.getByRole("button",{name:/Add Memory/})).toBeVisible();
  });

  test("Play exposes all mockup game entry points",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Play",exact:true}).click();
    for(const name of ["Truth or Dare","Roleplay","King & Slave","Chess","Snake & Ladder"]){
      await expect(page.getByRole("button",{name:new RegExp(name)})).toBeVisible();
    }
  });

  test("Profile exposes the mockup's three profile destinations",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await expect(page.getByText("PROFILES",{exact:true})).toBeVisible();
    await expect(page.getByText("Edit Profiles",{exact:true})).toBeVisible();
    await expect(page.getByText("Relationship Settings",{exact:true})).toBeVisible();
    await expect(page.getByText("Achievements",{exact:true})).toBeVisible();
  });
});
