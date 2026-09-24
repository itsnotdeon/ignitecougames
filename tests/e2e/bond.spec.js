const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("./");
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

test.describe("IGNITE Bond hub",()=>{
  test("Home exposes Play, Bond, and Memories shortcuts",async({page})=>{
    await enter(page);
    await expect(page.locator('button.home-action-card.play')).toBeVisible();
    await expect(page.locator('button.home-action-card.bond')).toBeVisible();
    await expect(page.locator('button.home-action-card.memories')).toBeVisible();
  });

  test("Bond hub can rotate and save a daily question",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"BOND"}).click();
    await expect(page.getByRole("heading",{name:"Make space for each other."})).toBeVisible();
    const before=await page.locator(".bond-v1-card.featured h3").innerText();
    await page.getByRole("button",{name:"Another"}).click();
    const after=await page.locator(".bond-v1-card.featured h3").innerText();
    expect(after).not.toBe(before);
    await page.getByRole("button",{name:"Save"}).click();
    await expect(page.getByText("1 saved")).toBeVisible();
  });

  test("Relationship goals persist in Bond",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"BOND"}).click();
    await page.locator('input[name="goal"]').fill("Date night setiap Jumat");
    await page.getByRole("button",{name:"Add Goal"}).click();
    await expect(page.getByText("Date night setiap Jumat")).toBeVisible();
    await page.locator('input[data-bond-goal="0"]').check();
    await page.reload();
    await page.getByRole("button",{name:"BOND"}).click();
    await expect(page.getByText("Date night setiap Jumat")).toBeVisible();
    await expect(page.locator('input[data-bond-goal="0"]')).toBeChecked();
  });

  test("Bond tolerates malformed stored data and avoids duplicate favorites",async({page})=>{
    await page.goto("./");
    await page.evaluate(()=>localStorage.setItem("ignite-bond-v1",JSON.stringify({favorites:null,goals:null,dailyCurrent:"Saved prompt"})));
    await page.reload();
    await page.getByRole("button",{name:"Enter IGNITE"}).click();
    await page.getByRole("button",{name:"BOND"}).click();
    await expect(page.getByText("0 saved")).toBeVisible();
    await page.getByRole("button",{name:"Save"}).click();
    await page.getByRole("button",{name:"Save"}).click();
    await expect(page.getByText("1 saved")).toBeVisible();
    await expect(page.locator(".bond-favorites p")).toHaveCount(1);
  });
});
