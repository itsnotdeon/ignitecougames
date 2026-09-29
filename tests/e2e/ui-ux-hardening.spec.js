const {test,expect}=require("@playwright/test");

async function boot(page){
  await page.goto("");
  await page.evaluate(()=>{
    sessionStorage.setItem("ignite-welcome-seen","1");
    localStorage.setItem("ignite-redesign-v4",JSON.stringify({
      names:{p1:"A",p2:"B"},relationship:"Couple",relationshipSince:null,
      currentJourney:null,step:0,view:"home",mode:"normal"
    }));
  });
  await page.reload();
}

test.describe("UI/UX hardening",()=>{
  test("settings backup controls are wired and reset asks for confirmation",async({page})=>{
    await boot(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await page.getByRole("button",{name:"Settings",exact:true}).click();
    const download=page.waitForEvent("download");
    await page.getByRole("button",{name:"Export Backup",exact:true}).click();
    expect((await download).suggestedFilename()).toMatch(/^ignite-backup-\d{4}-\d{2}-\d{2}\.json$/);
    let dialogSeen=false;
    page.once("dialog",async dialog=>{dialogSeen=true;await dialog.dismiss()});
    await page.getByRole("button",{name:"Reset All Data",exact:true}).click();
    expect(dialogSeen).toBe(true);
  });

  test("backup restore preserves state and progression stores",async({page})=>{
    await boot(page);
    await page.evaluate(()=>{
      localStorage.setItem("ignite-progression-v1",JSON.stringify({xp:130,stats:{journeysCompleted:2,memoriesSaved:1},achievements:["first-memory"]}));
      localStorage.setItem("ignite-memories-v1",JSON.stringify([{id:"m1",moment:"Restored Moment",memoryDate:"2026-09-29"}]));
      localStorage.setItem("ignite-preferences-v1",JSON.stringify({vibes:["Deep"],steps:7}));
      localStorage.setItem("ignite-backup-marker","keep");
    });
    const backup=await page.evaluate(()=>({
      format:"ignite-backup",version:1,exportedAt:new Date().toISOString(),
      data:{
        "ignite-redesign-v4":JSON.stringify({names:{p1:"Restored A",p2:"Restored B"},relationship:"Couple",relationshipSince:null,currentJourney:null,step:0,view:"home",mode:"dark"}),
        "ignite-progression-v1":localStorage.getItem("ignite-progression-v1"),
        "ignite-memories-v1":localStorage.getItem("ignite-memories-v1"),
        "ignite-preferences-v1":localStorage.getItem("ignite-preferences-v1")
      }
    }));
    await page.evaluate(data=>{
      import("./scripts/core/backup.js").then(({restoreAppBackup})=>{
        setTimeout(()=>restoreAppBackup(data),0);
      });
    },backup);
    await page.waitForLoadState("domcontentloaded");
    await expect.poll(()=>page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")).names.p1)).toBe("Restored A");
    await expect.poll(()=>page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-progression-v1")).xp)).toBe(130);
    await expect.poll(()=>page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-memories-v1"))[0].moment)).toBe("Restored Moment");
    await expect.poll(()=>page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-preferences-v1")).vibes[0])).toBe("Deep");
    expect(await page.evaluate(()=>localStorage.getItem("ignite-backup-marker"))).toBe(null);
  });

  test("invalid backup never clears existing local data",async({page})=>{
    await boot(page);
    await page.evaluate(()=>localStorage.setItem("ignite-backup-marker","safe"));
    const result=await page.evaluate(async()=>{
      const {restoreAppBackup}=await import("./scripts/core/backup.js");
      try{restoreAppBackup({format:"ignite-backup",version:1,data:{"ignite-good":"ok","ignite-bad":42}})}catch(e){return {message:e.message,marker:localStorage.getItem("ignite-backup-marker")}};
      return {message:"no-error",marker:localStorage.getItem("ignite-backup-marker")};
    });
    expect(result.message).toBe("Invalid IGNITE backup data.");
    expect(result.marker).toBe("safe");
  });

  test("interrupted Journey generation recovers instead of hanging",async({page})=>{
    await boot(page);
    await page.evaluate(()=>{
      localStorage.setItem("ignite-redesign-v4",JSON.stringify({
        names:{p1:"A",p2:"B"},relationship:"Couple",relationshipSince:null,
        currentJourney:null,step:0,view:"generating",mode:"normal",__journeyTargetSteps:9
      }));
    });
    await page.reload();
    await expect(page.getByText("YOUR SPACE FOR TWO",{exact:true})).toBeVisible();
    await expect(page.getByText("BUILDING YOUR JOURNEY",{exact:true})).toHaveCount(0);
  });

  test("Journey Roleplay is interactive and can unlock Continue",async({page})=>{
    await boot(page);
    await page.evaluate(()=>{
      localStorage.setItem("ignite-redesign-v4",JSON.stringify({
        names:{p1:"A",p2:"B"},relationship:"Couple",relationshipSince:null,
        currentJourney:{
          id:"dark",title:"After Dark Journey",subtitle:"Test",mood:"Intimate",
          steps:[
            {kind:"activity",mechanic:"roleplay",icon:"🎭",title:"Roleplay",text:"Choose a role.",action:"Continue"},
            {kind:"closing",icon:"♥",title:"Close the Journey",text:"Done.",action:"Finish Journey"}
          ]
        },
        step:0,view:"session",mode:"dark"
      }));
    });
    await page.reload();
    await expect(page.getByRole("button",{name:"Open Roleplay →",exact:true})).toBeVisible();
    await page.getByRole("button",{name:"Open Roleplay →",exact:true}).click();
    await expect(page.getByRole("button",{name:"Draw Role",exact:true})).toBeVisible();
    await expect(page.getByRole("button",{name:"Continue →",exact:true})).toBeDisabled();
    await page.getByRole("button",{name:"Done with Roleplay →",exact:true}).click();
    await expect(page.getByRole("button",{name:"Continue →",exact:true})).toBeEnabled();
  });
});
