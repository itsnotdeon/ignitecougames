const {test}=require("@playwright/test");

test("IGNITE boot diagnostics",async({page})=>{
  const pageErrors=[];
  const consoleErrors=[];
  const failedRequests=[];
  page.on("pageerror",e=>pageErrors.push(String(e?.stack||e)));
  page.on("console",m=>{if(m.type()==="error")consoleErrors.push(m.text())});
  page.on("requestfailed",r=>failedRequests.push(r.url()+" :: "+String(r.failure()?.errorText||"unknown")));
  await page.goto("./");
  await page.waitForTimeout(5000);
  console.log("[BOOT-DIAGNOSTIC] URL:",page.url());
  console.log("[BOOT-DIAGNOSTIC] APP TEXT:",await page.locator("#app").innerText().catch(e=>"INNER_TEXT_ERROR "+e));
  console.log("[BOOT-DIAGNOSTIC] APP HTML:",(await page.locator("#app").innerHTML().catch(e=>"INNER_HTML_ERROR "+e)).slice(0,12000));
  console.log("[BOOT-DIAGNOSTIC] PAGE ERRORS:",JSON.stringify(pageErrors));
  console.log("[BOOT-DIAGNOSTIC] CONSOLE ERRORS:",JSON.stringify(consoleErrors));
  console.log("[BOOT-DIAGNOSTIC] FAILED REQUESTS:",JSON.stringify(failedRequests));
});
