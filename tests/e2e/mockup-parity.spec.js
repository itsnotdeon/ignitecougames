const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await page.locator('input[name="p1"]').fill("Ariel");
  await page.locator('input[name="p2"]').fill("Fe");
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

test.describe("IGNITE mockup parity and dual themes",()=>{
  test("Normal keeps a sweet elegant dark theme",async({page})=>{
    await enter(page);
    const normal=await page.evaluate(()=>({
      mode:document.body.dataset.igniteMode,
      background:getComputedStyle(document.body).backgroundImage,
      accent:getComputedStyle(document.documentElement).getPropertyValue("--ignite-accent").trim()
    }));
    expect(normal.mode).toBe("normal");
    expect(normal.background).toContain("linear-gradient");
    expect(normal.accent).toBe("#e985a5");
  });

  test("After Dark switches to a distinct deep elegant theme",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"After Dark"}).click();
    await expect(page.locator("body")).toHaveAttribute("data-ignite-mode","dark");
    const dark=await page.evaluate(()=>({
      background:getComputedStyle(document.body).backgroundImage,
      accent:getComputedStyle(document.body).getPropertyValue("--rose").trim()
    }));
    expect(dark.background).toContain("linear-gradient");
    expect(dark.accent).toBe("#b94d70");
  });

  test("Home follows the mockup information hierarchy",async({page})=>{
    await enter(page);
    for(const name of ["Our Journey","Today’s Moment","Our Vibe Right Now","Quick Connection","Recent Memories","Upcoming & Motivation","Couple Level"]){
      await expect(page.getByText(name,{exact:true})).toBeVisible();
    }
    await expect(page.getByRole("button",{name:/Start Journey/})).toBeVisible();
    await expect(page.locator(".ignite-home-timeline")).toBeVisible();
    await expect(page.locator(".ignite-vibe-grid")).toBeVisible();
    await expect(page.locator(".ignite-activity-list")).toBeVisible();
  });

  test("Home does not expose mockup placeholder relationship data",async({page})=>{
    await enter(page);
    const app=page.locator("#app");
    await expect(app).not.toContainText("14 Feb");
    await expect(app).not.toContainText("238 Days");
    await expect(app).not.toContainText("84% Match");
    await expect(app).toContainText("Set your date");
  });

  test("Profile supports real optional person details",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await page.getByText("Edit Profiles",{exact:true}).click();
    await expect(page.locator('input[name="p1Pronouns"]')).toBeVisible();
    await expect(page.locator('input[name="p1BirthDate"]')).toBeVisible();
    await expect(page.locator('textarea[name="p1Bio"]')).toBeVisible();
    await page.locator('input[name="p1Pronouns"]').fill("They / Them");
    await page.locator('input[name="p1BirthDate"]').fill("2001-01-12");
    await page.locator('textarea[name="p1Bio"]').fill("A real profile detail.");
    await page.locator("#profile-edit-form").getByRole("button",{name:"Save"}).click();
    await page.getByText("Ariel",{exact:true}).click();
    await expect(page.getByText("They / Them",{exact:true})).toBeVisible();
    await expect(page.getByText("A real profile detail.",{exact:true})).toBeVisible();
  });

  test("Journey completion is idempotent per run",async({page})=>{
    await enter(page);
    const result=await page.evaluate(async()=>{
      const progression=await import("./scripts/progression.js?v=20260928-02");
      progression.resetProgress();
      progression.completeJourney("normal",{eventId:"e2e-run-1",title:"Test Journey"});
      progression.completeJourney("normal",{eventId:"e2e-run-1",title:"Test Journey"});
      const p=progression.getProgress();
      return {completed:p.stats.journeysCompleted,xp:p.xp,history:p.journeyHistory.length};
    });
    expect(result).toEqual({completed:1,xp:60,history:1});
  });

  test("Preferred Content controls the Journey entry mode",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await page.getByText("Relationship Settings",{exact:true}).click();
    await page.getByRole("button",{name:"After Dark 18+"}).click();
    await page.locator("#relationship-profile-form").getByRole("button",{name:"Save"}).click();
    await page.getByRole("button",{name:"Play",exact:true}).click();
    await page.getByRole("button",{name:"Journey Preferences"}).click();
    await page.getByRole("button",{name:/Start Journey/}).click();
    await expect(page.getByText("BUILDING YOUR JOURNEY")).toBeVisible();
    await expect.poll(async()=>page.evaluate(()=>{
      const saved=JSON.parse(localStorage.getItem("ignite-redesign-v4")||"{}");
      return saved.currentJourney?.id||null;
    })).toBe("dark");
  });

  test("Memories hub matches the mockup information hierarchy",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Memories",exact:true}).click();
    await expect(page.getByRole("heading",{name:"MEMORIES",exact:true})).toBeVisible();
    await expect(page.getByText("OUR SPECIAL MOMENTS",{exact:true})).toBeVisible();
    await expect(page.getByText("Memory Categories",{exact:true})).toBeVisible();
    await expect(page.getByRole("button",{name:/Add Memory/})).toBeVisible();
  });

  test("Saving a memory unlocks Keep the Moment progression",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Memories",exact:true}).click();
    await page.getByRole("button",{name:/Add Memory/}).click();
    await page.locator("#memory-form input[name=moment]").fill("Progression memory");
    await page.locator("#memory-form").getByRole("button",{name:/Save Memory|Save/}).click();
    await expect.poll(async()=>page.evaluate(()=>{
      const p=JSON.parse(localStorage.getItem("ignite-progression-v1")||"{}");
      return p.stats?.memoriesSaved||0;
    })).toBe(1);
    await expect.poll(async()=>page.evaluate(()=>{
      const p=JSON.parse(localStorage.getItem("ignite-progression-v1")||"{}");
      return Array.isArray(p.achievements)&&p.achievements.includes("first-memory");
    })).toBe(true);
  });

  test("Play exposes all mockup game entry points",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Play",exact:true}).click();
    for(const name of ["Truth or Dare","Roleplay","King & Slave","Chess","Snake & Ladder"]){
      await expect(page.getByRole("button",{name:new RegExp(name)})).toBeVisible();
    }
  });

  test("Profile exposes the mockup's three profile destinations",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Profile",exact:true}).click();
    await expect(page.getByText("PROFILES",{exact:true})).toBeVisible();
    await expect(page.getByText("Edit Profiles",{exact:true})).toBeVisible();
    await expect(page.getByText("Relationship Settings",{exact:true})).toBeVisible();
    await expect(page.getByText("Achievements",{exact:true})).toBeVisible();
  });
});
