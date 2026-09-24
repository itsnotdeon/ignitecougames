const {test,expect}=require("@playwright/test");

async function enterIgniteWelcome(page){
  await expect(page.getByRole("button",{name:"Enter IGNITE"})).toBeVisible();
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("Let’s spend")).toBeVisible();
}

test("Phase 8 context engine derives deterministic time periods",async({page})=>{
 await page.goto("");
 await enterIgniteWelcome(page);
 const result=await page.evaluate(async()=>{
  const m=await import("./scripts/features/context.js");
  return [
   m.getTimeContext(new Date("2026-09-23T08:00:00")),
   m.getTimeContext(new Date("2026-09-23T13:00:00")),
   m.getTimeContext(new Date("2026-09-23T20:00:00")),
   m.getTimeContext(new Date("2026-09-23T23:30:00"))
  ].map(x=>x.period);
 });
 expect(result).toEqual(["morning","midday","evening","night"]);
});

test("Phase 8 global mode replaces visible mood selection",async({page})=>{
 await page.goto("");
 await enterIgniteWelcome(page);
 await expect(page.getByRole("region",{name:"IGNITE mode"})).toBeVisible();
 await expect(page.getByRole("button",{name:"Calm",exact:true})).not.toBeVisible();
 await page.getByRole("button",{name:"After Dark",exact:true}).click();
 const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-context-v1")));
 expect(stored.mode).toBe("dark");
 await page.reload();
 await expect(page.getByRole("button",{name:"After Dark",exact:true})).toHaveAttribute("aria-pressed","true");
});

test("Phase 8 global mode reaches Journey without legacy mood controls",async({page})=>{
 await page.goto("");
 await enterIgniteWelcome(page);
 await page.getByRole("button",{name:"Normal",exact:true}).click();
 await page.getByRole("button",{name:"Minigames",exact:true}).click();
 await expect(page.getByRole("button",{name:"Start Journey →"})).toBeVisible();
 await page.getByRole("button",{name:"Start Journey →"}).click();
 await expect(page.getByRole("heading",{name:"Who is here?",exact:true})).toBeVisible();
 await page.locator('#name-form input[name="p1"]').fill("Deon");
 await page.locator('#name-form input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await expect(page.getByRole("heading",{name:"Normal Journey",exact:true})).toBeVisible();
});
