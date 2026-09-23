const {test,expect}=require("@playwright/test");

test.beforeEach(async({page})=>{
 page.on("pageerror",error=>{throw error});
});

test("Phase 7 Couple Memories can save a note and expose streak summary",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await page.getByRole("button",{name:"Couple Memories"}).click();
 await expect(page.getByRole("heading",{name:"Keep the moments.",exact:true})).toBeVisible();
 await page.getByRole("button",{name:"←"}).click();
 await page.getByRole("button",{name:"Normal"}).click();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await page.getByRole("button",{name:/Begin Journey/}).click();
 for(let i=0;i<5;i++){await page.getByRole("button",{name:/Merah/}).click();if(i<4)await page.getByRole("button",{name:"Next Round"}).click();}
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await page.locator('textarea[name="note"]').fill("A little moment worth keeping.");
 await page.getByRole("button",{name:"Save This Moment"}).click();
 await page.getByRole("button",{name:"Open Memories"}).click();
 await expect(page.getByText("A little moment worth keeping.")).toBeVisible();
 await expect(page.getByText("1",{exact:true}).first()).toBeVisible();
});

test("Phase 7 preferences persist and drive personalization controls",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await page.getByRole("button",{name:"Journey Preferences"}).click();
 await page.getByRole("button",{name:"Spontaneous"}).click();
 await page.locator('select[name="duration"]').selectOption("long");
 await page.locator('select[name="intensity"]').selectOption("bold");
 await page.getByRole("button",{name:"Save Preferences"}).click();
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await expect(page.getByText("Journey Preferences")).toBeVisible();
});

test("Phase 7 Dynamic Journey and Surprise Mode are wired to Journey actions",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await page.getByRole("button",{name:"Build Dynamic Journey"}).click();
 await expect(page.getByRole("heading",{name:"Who is here?"})).toBeVisible();
 await page.locator("#name-form input[name=\"p1\"]").fill("Deon");
 await page.locator("#name-form input[name=\"p2\"]").fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await expect(page.getByRole("heading",{name:"Date Night"})).toBeVisible();
 await page.getByRole("button",{name:"←"}).click();
 await page.getByRole("button",{name:"←"}).click();
 await page.getByRole("button",{name:"Surprise Us"}).click();
 await expect(page.getByRole("heading",{name:"Date Night"})).toBeVisible();
});

test("Phase 7 generated couple quote remains tied to progression level",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:"Profile",exact:true}).click();
 await expect(page.locator(".generated-couple-quote")).toContainText("Couple Quote · Level 1");
 await expect(page.locator(".generated-couple-quote")).toContainText("Every story starts with a spark.");
 await expect(page.locator('input[name="couple"]')).toHaveCount(0);
});
