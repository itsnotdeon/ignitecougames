const {test,expect}=require("@playwright/test");

test.describe("IGNITE boot",()=>{
  test("loads the app shell without a module boot error",async({page})=>{
    const errors=[];
    page.on("pageerror",error=>errors.push(String(error)));
    await page.goto("./");
    await expect(page.getByRole("button",{name:/ENTER TOGETHER/})).toBeVisible();
    await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
    await expect(page.getByText("LET’S BEGIN TOGETHER")).toBeVisible();
    await page.locator('input[name="p1"]').fill("Ariel");
    await page.locator('input[name="p2"]').fill("Fe");
    await page.getByRole("button",{name:/Start Our Journey/}).click();
    await expect(page.locator("#app")).toContainText("YOUR SPACE FOR TWO");
    await expect(page.locator("text=IGNITE sedang memuat ulang")).toHaveCount(0);
    expect(errors).toEqual([]);
  });
  test("Welcome screen stays visible before entering Home",async({page})=>{
    await page.goto("./");
    await expect(page.getByRole("button",{name:/ENTER TOGETHER/})).toBeVisible();
    await expect(page.getByRole("heading",{name:"IGNITE",exact:true})).toBeVisible();
    await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
    await expect(page.getByText("LET’S BEGIN TOGETHER")).toBeVisible();
  });
});