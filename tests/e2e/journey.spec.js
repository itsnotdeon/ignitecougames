const {test,expect}=require("@playwright/test");

async function startNormal(page){
 await page.goto("");
 await expect(page.getByText("Let’s spend")).toBeVisible();
 await page.getByRole("button",{name:/Normal/}).click();
 await expect(page.getByText("Who is here?")).toBeVisible();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await expect(page.getByText("Normal Journey")).toBeVisible();
 await page.getByRole("button",{name:/Begin Journey/}).click();
 await expect(page.getByText("Warm Up")).toBeVisible();
}

test.beforeEach(async({page})=>{
 page.on("pageerror",error=>{throw error});
});

test("home renders and Normal Journey can complete",async({page})=>{
 await startNormal(page);
 await expect(page.getByText("Pilih warna kartu")).toBeVisible();
 await page.getByRole("button",{name:/Merah/}).click();
 await expect(page.getByText(/Kartu:/)).toBeVisible();
 await page.getByRole("button",{name:"Next Round"}).click();
 await page.getByRole("button",{name:/Hitam/}).click();
 await page.getByRole("button",{name:"Next Round"}).click();
 await page.getByRole("button",{name:"Continue →"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:"Skip"}).click();
 await page.getByRole("button",{name:/Finish Journey/}).click();
 await expect(page.getByText("Journey Complete")).toBeVisible();
});

test("Normal Journey exposes card and Truth or Dare mechanics",async({page})=>{
 await startNormal(page);
 await page.getByRole("button",{name:"Continue →"}).click();
 await expect(page.getByText("Talk Card")).toBeVisible();
 await page.getByText("Tap to reveal").click();
 await expect(page.locator(".reveal-card")).toContainText(/./);
 await page.getByRole("button",{name:"Continue →"}).click();
 await expect(page.getByText("Change the Energy")).toBeVisible();
 await page.getByRole("button",{name:"Batu"}).click();
 await page.getByRole("button",{name:"Kertas"}).click();
 await expect(page.getByRole("button",{name:"Next Round"})).toBeVisible();
 await page.getByRole("button",{name:"Next Round"}).click();
 await page.getByRole("button",{name:"Continue →"}).click();
 await expect(page.getByText("Truth or Dare")).toBeVisible();
 await page.getByRole("button",{name:"Dare"}).click();
 await page.getByText("Tap to reveal").click();
 await expect(page.locator(".reveal-card")).toContainText(/./);
});

test("After Dark requires consent before entering",async({page})=>{
 await page.goto("");
 await page.getByRole("button",{name:/After Dark/}).click();
 await page.locator('input[name="p1"]').fill("Deon");
 await page.locator('input[name="p2"]').fill("Partner");
 await page.getByRole("button",{name:"Save Couple"}).click();
 await expect(page.getByRole("heading",{name:"After Dark",exact:true})).toBeVisible();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).not.toBeVisible();
 await page.locator("#consent").check();
 await page.getByRole("button",{name:/Enter After Dark/}).click();
 await expect(page.getByText("Set the Mood")).toBeVisible();
});
