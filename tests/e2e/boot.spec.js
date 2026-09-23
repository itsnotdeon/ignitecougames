const {test,expect}=require("@playwright/test");

test.describe("IGNITE boot",()=>{
  test("loads the app shell without a module boot error",async({page})=>{
    const errors=[];
    page.on("pageerror",error=>errors.push(String(error)));
    await page.goto("./");
    await expect(page.locator("#app")).toContainText("Let’s spend");
    await expect(page.locator("text=IGNITE sedang memuat ulang")).toHaveCount(0);
    expect(errors).toEqual([]);
  });
});
