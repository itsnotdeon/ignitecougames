const {test}=require("@playwright/test");

test("IGNITE boot diagnostics",async({page})=>{
  const pageErrors=[];
  const consoleErrors=[];
  const failedRequests=[];
  page.on("pageerror",e=>pageErrors.push(String(e?.stack||e)));
  page.on("console",m=>{if(m.type()==="error")consoleErrors.push(m.text())});
  page.on("requestfailed",r=>failedRequests.push(r.url()+" :: "+String(r.failure()?.errorText||"unknown")));

  await page.goto("./");
  await page.waitForTimeout(1500);

  const modules=[
    "./scripts/journey/mechanics.js",
    "./scripts/journey/rituals.js",
    "./scripts/data/topics.js",
    "./scripts/progression.js",
    "./scripts/journey/content.js",
    "./scripts/features/ui.js",
    "./scripts/features/memories.js",
    "./scripts/features/adaptive.js",
    "./scripts/features/preferences.js",
    "./scripts/features/unlocks.js",
    "./scripts/features/surprise.js",
    "./scripts/features/dynamicJourney.js",
    "./scripts/features/context.js",
    "./scripts/ui/accessibility.js",
    "./scripts/minigames/roleplay.js",
    "./scripts/minigames/kingslave.js",
    "./scripts/minigames/chess.js",
    "./scripts/minigames/snake.js",
    "./scripts/minigames/index.js",
    "./scripts/app.js"
  ];

  for(const path of modules){
    try{
      await page.evaluate(async path=>{
        await import(path+"?diagnostic="+Date.now());
      },path);
      console.log("[MODULE-DIAGNOSTIC] OK",path);
    }catch(error){
      console.log("[MODULE-DIAGNOSTIC] FAIL",path,String(error?.stack||error));
    }
  }

  await page.waitForTimeout(1000);
  console.log("[BOOT-DIAGNOSTIC] APP TEXT:",await page.locator("#app").innerText().catch(e=>"INNER_TEXT_ERROR "+e));
  console.log("[BOOT-DIAGNOSTIC] APP HTML:",(await page.locator("#app").innerHTML().catch(e=>"INNER_HTML_ERROR "+e)).slice(0,12000));
  console.log("[BOOT-DIAGNOSTIC] PAGE ERRORS:",JSON.stringify(pageErrors));
  console.log("[BOOT-DIAGNOSTIC] CONSOLE ERRORS:",JSON.stringify(consoleErrors));
  console.log("[BOOT-DIAGNOSTIC] FAILED REQUESTS:",JSON.stringify(failedRequests));
});
