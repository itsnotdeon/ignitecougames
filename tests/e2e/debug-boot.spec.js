const {test}=require("@playwright/test");
test("debug boot imports",async({page})=>{
  page.on("console",m=>console.log("[browser console]",m.type(),m.text()));
  page.on("pageerror",e=>console.log("[browser pageerror]",e.stack||e.message));
  page.on("requestfailed",r=>console.log("[request failed]",r.url(),r.failure()?.errorText));
  page.on("response",r=>{if(r.url().includes("/redesign/scripts/"))console.log("[script response]",r.status(),r.url())});
  await page.goto("");
  await page.waitForTimeout(2000);
  console.log("[body]",await page.locator("body").innerText());
});