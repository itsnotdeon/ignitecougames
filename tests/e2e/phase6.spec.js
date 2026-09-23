const {test,expect}=require("@playwright/test");

test("Phase 6 mobile layout has no horizontal overflow",async({page})=>{
  await page.setViewportSize({width:375,height:812});
  await page.goto("");
  await expect(page.locator('link[href="./styles/phase6.css"]')).toHaveCount(1);
  const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth);
  expect(overflow).toBe(false);
  await expect(page.getByText("Let’s spend")).toBeVisible();
  await expect(page.getByRole("button",{name:/Normal/})).toBeVisible();
});

test("Phase 6 preserves an active Journey after reload",async({page})=>{
  await page.goto("");
  await page.getByRole("button",{name:/Normal/}).click();
  await page.locator('input[name="p1"]').fill("Deon");
  await page.locator('input[name="p2"]').fill("Partner");
  await page.getByRole("button",{name:"Save Couple"}).click();
  await page.getByRole("button",{name:/Begin Journey/}).click();
  await page.getByRole("button",{name:"Skip"}).click();
  await expect(page.getByText("Talk Card")).toBeVisible();
  await page.reload();
  await expect(page.getByText("Talk Card")).toBeVisible();
  await expect(page.getByText("Moment 2 of 6")).toBeVisible();
});

test("Phase 6 keeps form submission working on mobile",async({page})=>{
  await page.setViewportSize({width:390,height:844});
  await page.goto("");
  await page.getByRole("button",{name:/Normal/}).click();
  await page.locator('input[name="p1"]').fill("Deon");
  await page.locator('input[name="p2"]').fill("Partner");
  await page.getByRole("button",{name:"Save Couple"}).click();
  await expect(page.getByRole("heading",{name:"Normal Journey",exact:true})).toBeVisible();
});

test("Phase 6 reduced-motion preference removes long transitions",async({page})=>{
  await page.emulateMedia({reducedMotion:"reduce"});
  await page.goto("");
  const duration=await page.locator("button").first().evaluate(el=>getComputedStyle(el).transitionDuration);
  expect(parseFloat(duration)).toBeLessThanOrEqual(0.001);
});
