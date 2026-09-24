const {test,expect}=require("@playwright/test");

test.describe("IGNITE boot",()=>{
  test("loads the app shell without a module boot error",async({page})=>{
    const errors=[];
    page.on("console",msg=>console.log("BROWSER CONSOLE:",msg.type(),msg.text()));
    page.on("pageerror",error=>{console.log("PAGE ERROR:",String(error),String(error.stack||""));errors.push(String(error))});
    page.on("console",msg=>console.log("BROWSER CONSOLE:",msg.type(),msg.text(),JSON.stringify(msg.location())));
    await page.goto("./");
    const diagnostic=await page.evaluate(async()=>{
      const paths=["./scripts/journey/mechanics.js","./scripts/minigames/index.js","./scripts/progression.js","./scripts/journey/content.js","./scripts/features/ui.js","./scripts/features/memories.js","./scripts/features/adaptive.js","./scripts/ui/accessibility.js","./scripts/app.js"];
      const out=[];
      for(const path of paths){try{await import(path+"?diag=1");out.push(path+" OK")}catch(e){out.push(path+" ERROR "+String(e)+" STACK "+String(e?.stack||""))}}
      return out;
    });
    console.log("IMPORT DIAGNOSTIC:",diagnostic.join("\n"));
    await page.waitForTimeout(1200);
    console.log("BOOT SNAPSHOT:",await page.locator("#app").innerText());
    await expect(page.getByRole("button",{name:"Enter IGNITE"})).toBeVisible();
    await page.getByRole("button",{name:"Enter IGNITE"}).click();
    await expect(page.locator("#app")).toContainText("YOUR SPACE FOR TWO");
    await expect(page.locator("text=IGNITE sedang memuat ulang")).toHaveCount(0);
    expect(errors).toEqual([]);
  });
});

test("Welcome screen stays visible before entering Home",async({page})=>{
  await page.goto("./");
  await expect(page.getByRole("button",{name:"Enter IGNITE"})).toBeVisible();
  await expect(page.getByRole("heading",{name:"Your time. Your story."})).toBeVisible();
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("TOGETHER",{exact:true})).toBeVisible();
});
