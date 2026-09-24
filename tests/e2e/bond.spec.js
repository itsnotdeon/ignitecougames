const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("");
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("Let’s spend")).toBeVisible();
}

test.describe("IGNITE Bond hub",()=>{
  test("Home exposes Play, Bond, and Memories shortcuts",async({page})=>{
    await enter(page);
    await expect(page.getByRole("button",{name:"Play"})).toBeVisible();
    await expect(page.getByRole("button",{name:"Bond"})).toBeVisible();
    await expect(page.getByRole("button",{name:"Memories"})).toBeVisible();
  });

  test("Bond hub can rotate and save a daily question",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Bond"}).click();
    await expect(page.getByRole("heading",{name:"Make space for each other."})).toBeVisible();
    const before=await page.locator(".bond-feature h3").innerText();
    await page.getByRole("button",{name:"New Question"}).click();
    const after=await page.locator(".bond-feature h3").innerText();
    expect(after).not.toBe(before);
    await page.getByRole("button",{name:"Save"}).click();
    await expect(page.getByText("1 saved questions")).toBeVisible();
  });

  test("Relationship goals persist in Bond",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Bond"}).click();
    await page.locator('input[name="goal"]').fill("Date night setiap Jumat");
    await page.getByRole("button",{name:"Add Goal"}).click();
    await expect(page.getByText("Date night setiap Jumat")).toBeVisible();
    await page.locator('input[data-bond-goal="0"]').check();
    await page.reload();
    await expect(page.getByText("Date night setiap Jumat")).toBeVisible();
    await expect(page.locator('input[data-bond-goal="0"]')).toBeChecked();
  });
});
