const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("./");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await expect(page.getByText("LET’S BEGIN TOGETHER")).toBeVisible();
  await page.locator('input[name="p1"]').fill("Ariel");
  await page.locator('input[name="p2"]').fill("Fe");
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

async function snapshot(page){
  return page.evaluate(()=>{
    const app=document.querySelector("#app");
    const hero=document.querySelector(".ignite-home-hero");
    const body=getComputedStyle(document.body);
    const appStyle=getComputedStyle(app);
    const heroStyle=hero?getComputedStyle(hero):null;
    return {
      mode:app?.dataset.igniteMode,
      bodyMode:document.body.dataset.igniteMode,
      bodyBackground:body.backgroundImage+"|"+body.backgroundColor,
      appBackground:appStyle.backgroundImage+"|"+appStyle.backgroundColor,
      heroBackground:heroStyle?.backgroundImage+"|"+heroStyle?.backgroundColor,
      themeColor:document.querySelector('meta[name="theme-color"]')?.content
    };
  });
}

test.describe("IGNITE mode theming",()=>{
  test("Normal and After Dark visibly switch in both directions",async({page})=>{
    await enter(page);

    const normal=await snapshot(page);
    expect(normal.mode).toBe("normal");
    expect(normal.bodyMode).toBe("normal");
    expect(normal.themeColor).toBe("#170a11");

    await page.getByRole("button",{name:"After Dark"}).click();
    await expect(page.locator("#app[data-ignite-mode=dark]")).toBeVisible();
    const dark=await snapshot(page);
    expect(dark.mode).toBe("dark");
    expect(dark.bodyMode).toBe("dark");
    expect(dark.themeColor).toBe("#030203");
    expect(dark.bodyBackground).not.toBe(normal.bodyBackground);
    expect(dark.heroBackground).not.toBe(normal.heroBackground);

    await page.getByRole("button",{name:"Normal"}).click();
    await expect(page.locator("#app[data-ignite-mode=normal]")).toBeVisible();
    const normalAgain=await snapshot(page);
    expect(normalAgain.mode).toBe("normal");
    expect(normalAgain.bodyMode).toBe("normal");
    expect(normalAgain.themeColor).toBe("#170a11");
    expect(normalAgain.bodyBackground).toBe(normal.bodyBackground);
    expect(normalAgain.heroBackground).toBe(normal.heroBackground);
  });

  test("selected mode persists after reload",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"After Dark"}).click();
    await page.reload();
    await expect(page.locator("#app[data-ignite-mode=dark]")).toBeVisible();
    const dark=await snapshot(page);
    expect(dark.bodyMode).toBe("dark");
    expect(dark.themeColor).toBe("#030203");

    await page.getByRole("button",{name:"Normal"}).click();
    await page.reload();
    await expect(page.locator("#app[data-ignite-mode=normal]")).toBeVisible();
    const normal=await snapshot(page);
    expect(normal.bodyMode).toBe("normal");
    expect(normal.themeColor).toBe("#170a11");
  });
});
