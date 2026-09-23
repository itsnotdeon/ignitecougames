const {test}=require("@playwright/test");
test("diagnostic page errors",async({page})=>{const errors=[];page.on("pageerror",e=>errors.push("PAGEERROR: "+e.stack));page.on("console",m=>{if(m.type()==="error")errors.push("CONSOLE: "+m.text())});await page.goto("");await page.waitForTimeout(1000);console.log("DIAGNOSTIC_ERRORS\n"+errors.join("\n"));});
