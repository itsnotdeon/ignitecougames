const {test,expect}=require("@playwright/test");

test("Phase 8 context engine derives deterministic time periods",async({page})=>{
 await page.goto("");
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

test("Phase 8 mood selection persists and is reflected in the current context",async({page})=>{
 await page.goto("");
 await expect(page.getByText("Right now")).toBeVisible();
 await page.getByRole("button",{name:"Calm"}).click();
 await expect(page.locator(".context-mood")).toContainText("Calm");
 const stored=await page.evaluate(()=>JSON.parse(localStorage.getItem("ignite-context-v1")));
 expect(stored.mood).toBe("calm");
 await page.reload();
 await expect(page.locator(".context-mood")).toContainText("Calm");
});

test("Phase 8 Dynamic Journey receives mood and time context without breaking Journey flow",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:"Calm"}).click();
 await page.getByRole("button",{name:"Profile"}).click();
 await page.getByRole("button",{name:"Build Dynamic Journey"}).click();
 await expect(page.getByRole("heading",{name:"Normal Journey",exact:true})).toBeVisible();
});
