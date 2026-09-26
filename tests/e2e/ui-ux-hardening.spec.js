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
  test("home vibe behaves as a single-choice control",async({page})=>{
    await boot(page);
    const deep=page.getByRole("button",{name:"Deep",exact:true});
    const romantic=page.getByRole("button",{name:"Romantic",exact:true});
    await deep.click();
    await expect(deep).toHaveAttribute("aria-pressed","true");
    await expect(romantic).toHaveAttribute("aria-pressed","false");
    const primary=page.locator('[data-vibe-home].primary');
    await expect(primary).toHaveCount(1);
  });

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
