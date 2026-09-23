const {test,expect}=require("@playwright/test");

async function enterIgniteWelcome(page){
  await expect(page.getByRole("button",{name:"Enter IGNITE"})).toBeVisible();
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("Let’s spend")).toBeVisible();
}

test("King & Slave mobile flow keeps the action as the primary result",async({page})=>{
 await page.addInitScript(()=>{let n=0;const seq=[0.05,0.75,0.25,0.9,0.4,0.6];Math.random=()=>seq[n++%seq.length]});
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:"Minigames"}).click();
 await page.getByRole("button",{name:"King & Slave"}).click();
 await expect(page.getByText("KING & SLAVE",{exact:true})).toBeVisible();
 await page.locator("#ks-consent").check();
 await page.getByRole("button",{name:"Mulai Sesi"}).click();
 await expect(page.getByText("ROUND 1")).toBeVisible();
 await page.getByRole("button",{name:"Reveal King"}).click();
 await expect(page.locator(".ks-role-person.king").getByText("KING / QUEEN",{exact:true})).toBeVisible();
 await page.getByRole("button",{name:"Draw Command Card"}).click();
 await expect(page.locator(".ks-command-card-main")).toBeVisible();
 await expect(page.locator(".ks-command-part strong")).toBeVisible();
 await expect(page.getByRole("button",{name:"Jalankan"})).toBeVisible();
 await expect(page.getByRole("button",{name:"Skip"})).toBeVisible();
 const sizes=await page.locator(".ks-command-part strong").evaluateAll(es=>es.map(e=>Number.parseFloat(getComputedStyle(e).fontSize)));
 expect(Math.max(...sizes)).toBeGreaterThanOrEqual(30);
});

test("King & Slave supports five one-use powers and Draw Again",async({page})=>{
 await page.addInitScript(()=>{let n=0;const seq=[0.1,0.8,0.3,0.9,0.2,0.7,0.4,0.6];Math.random=()=>seq[n++%seq.length]});
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:"Minigames"}).click();
 await page.getByRole("button",{name:"King & Slave"}).click();
 await page.locator("#ks-consent").check();
 await page.getByRole("button",{name:"Mulai Sesi"}).click();
 await page.getByRole("button",{name:"Reveal King"}).click();
 await page.getByRole("button",{name:/Power Cards/}).click();
 await expect(page.getByText("Titah Ganda")).toBeVisible();
 await expect(page.getByText("Hak Pilih")).toBeVisible();
 await expect(page.getByText("Perpanjangan Takhta")).toBeVisible();
 await expect(page.getByText("Tukar Takdir")).toBeVisible();
 await expect(page.getByText("Waktu Milikku")).toBeVisible();
 await page.getByRole("button",{name:"Use"}).first().click();
 await page.getByRole("button",{name:"Draw Command Card"}).click();
 await expect(page.getByRole("button",{name:"Draw Again"})).toBeVisible();
 await page.getByRole("button",{name:"Draw Again"}).click();
 await expect(page.locator(".ks-command-part")).toHaveCount(2);
});

test("King & Slave slave response is limited to Run or Skip",async({page})=>{
 await page.addInitScript(()=>{let n=0;const seq=[0.1,0.8,0.3,0.9];Math.random=()=>seq[n++%seq.length]});
 await page.goto("");
  await enterIgniteWelcome(page);
 await page.getByRole("button",{name:"Minigames"}).click();
 await page.getByRole("button",{name:"King & Slave"}).click();
 await page.locator("#ks-consent").check();
 await page.getByRole("button",{name:"Mulai Sesi"}).click();
 await page.getByRole("button",{name:"Reveal King"}).click();
 await page.getByRole("button",{name:"Draw Command Card"}).click();
 await expect(page.getByRole("button",{name:"Jalankan"})).toBeVisible();
 await expect(page.getByRole("button",{name:"Skip"})).toBeVisible();
 await expect(page.getByRole("button",{name:"Pelan"})).toHaveCount(0);
});
