const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("");
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

test.describe("IGNITE memories and preferences",()=>{
  test("Memories empty state and navigation work",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Memories",exact:true}).click();
    await expect(page.getByRole("heading",{name:"Keep the moments."})).toBeVisible();
    await expect(page.getByText("Your first memory is waiting.")).toBeVisible();
  });

  test("Preferences persist",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await page.getByRole("button",{name:"Settings",exact:true}).click();
    await page.getByRole("button",{name:"Journey Preferences"}).click();
    await page.getByRole("button",{name:"Spontaneous",exact:true}).click();
    await page.locator('select[name="duration"]').selectOption("long");
    await page.locator('select[name="intensity"]').selectOption("bold");
    await page.getByRole("button",{name:"Save Preferences"}).click();
    const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-preferences-v1")));
    expect(stored.vibes).toContain("Spontaneous");
    expect(stored.duration).toBe("long");
    expect(stored.intensity).toBe("bold");
  });

  test("Dynamic Journey is reachable from Settings",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await page.getByRole("button",{name:"Settings",exact:true}).click();
    await page.getByRole("button",{name:"Build Dynamic Journey"}).click();
    await page.locator('input[name="p1"]').fill("Deon");
    await page.locator('input[name="p2"]').fill("Partner");
    await page.getByRole("button",{name:"Start Our Journey →"}).click();
    await expect(page.getByRole("heading",{name:"Normal Journey",exact:true})).toBeVisible();
  });

  test("Profile reflects progression data",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await expect(page.getByText(/Level \d+ ·/)).toBeVisible();
    await expect(page.getByText("YOUR PROGRESS",{exact:true})).toBeVisible();
    await expect(page.getByText("ACHIEVEMENTS",{exact:true})).toBeVisible();
    await expect(page.getByText("First Spark",{exact:true})).toBeVisible();
  });
});
