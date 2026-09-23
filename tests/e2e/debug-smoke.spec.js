const {test,expect}=require("@playwright/test");

test("debug browser startup",async({page})=>{
 const errors=[];
 page.on("pageerror",e=>errors.push(e.stack||e.message));
 page.on("console",m=>{if(m.type()==="error") errors.push("CONSOLE: "+m.text())});
 await page.goto("");
 await page.waitForTimeout(1000);
 console.log("BROWSER_ERRORS_START\n"+errors.join("\n---\n")+"\nBROWSER_ERRORS_END");
 console.log("BODY_TEXT_START\n"+await page.locator("body").innerText()+"\nBODY_TEXT_END");
 expect(errors).toEqual([]);
 await expect(page.getByText("Let’s spend")).toBeVisible();
});
