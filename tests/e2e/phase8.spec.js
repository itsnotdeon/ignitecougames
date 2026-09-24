const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await expect(page.getByText("LET’S BEGIN TOGETHER")).toBeVisible();
  await page.locator('input[name="p1"]').fill("Ariel");
  await page.locator('input[name="p2"]').fill("Fe");
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

test("context engine derives deterministic time periods",async({page})=>{
 await enter(page);
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

test("global mode changes Home state",async({page})=>{
 await enter(page);
 await expect(page.getByText("IGNITE MODE",{exact:true})).toBeVisible();
 await expect(page.getByRole("button",{name:"Calm",exact:true})).not.toBeVisible();
 await page.getByRole("button",{name:"After Dark",exact:true}).click();
 const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-redesign-v4")));
 expect(stored.mode).toBe("dark");
 await expect(page.getByRole("button",{name:"After Dark",exact:true})).toHaveAttribute("aria-pressed","true");
});

test("global mode reaches After Dark Journey consent",async({page})=>{
 await enter(page);
 await page.getByRole("button",{name:"After Dark",exact:true}).click();
 await page.getByRole("button",{name:"Play",exact:true}).click();
 await page.getByRole("button",{name:"Start Journey →"}).click();
 await expect(page.getByRole("heading",{name:"After Dark",exact:true})).toBeVisible();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).not.toBeVisible();
 await page.locator("#consent").check();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).toBeVisible();
});


test("Memories can create a manual memory",async({page})=>{
 await enter(page);
 await page.getByRole("button",{name:"Memories",exact:true}).click();
 await page.getByRole("button",{name:"Add Memory",exact:true}).click();
 await expect(page.getByRole("heading",{name:"Keep this one.",exact:true})).toBeVisible();
 await page.locator('input[name="moment"]').fill("Our little September moment");
 await page.locator('textarea[name="note"]').fill("Saved from the Memories hub.");
 await page.getByRole("button",{name:"Save Memory",exact:true}).click();
 await page.getByRole("button",{name:"Memories",exact:true}).click();
 await expect(page.getByText("Our little September moment",{exact:true})).toBeVisible();
});
