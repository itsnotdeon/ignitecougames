const {test,expect}=require("@playwright/test");

async function enterIgniteWelcome(page){
  await expect(page.getByRole("button",{name:"Enter IGNITE"})).toBeVisible();
  await page.getByRole("button",{name:"Enter IGNITE"}).click();
  await expect(page.getByText("Let’s spend")).toBeVisible();
}

test("Phase 6 mobile layout has no horizontal overflow",async({page})=>{
  await page.setViewportSize({width:375,height:812});
  await page.goto("");
  await enterIgniteWelcome(page);
  await expect(page.locator('link[href^="./styles/phase6.css"]')).toHaveCount(1);
  const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>window.innerWidth);
  expect(overflow).toBe(false);
  await expect(page.getByText("Let’s spend")).toBeVisible();
  await expect(page.getByRole("button",{name:/Normal/})).toBeVisible();
});

test("Release candidate has no application page errors on Home",async({page})=>{
  const pageErrors=[];
  page.on("pageerror",error=>pageErrors.push(error.message));
  await page.goto("");
  await enterIgniteWelcome(page);
  await expect(page.getByText("Let’s spend")).toBeVisible();
  expect(pageErrors).toEqual([]);
});



test("Global mode controls Home and Play spotlight",async({page})=>{
  await page.goto("");
  await enterIgniteWelcome(page);
  await expect(page.getByRole("button",{name:"Normal",exact:true})).toHaveAttribute("aria-pressed","true");
  await page.getByRole("button",{name:"After Dark",exact:true}).click();
  await expect(page.getByRole("button",{name:"After Dark",exact:true})).toHaveAttribute("aria-pressed","true");
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await expect(page.getByText("AFTER DARK JOURNEY",{exact:true})).toBeVisible();
  await expect(page.getByRole("button",{name:"Start Journey →"})).toBeVisible();
  await expect(page.getByText("Quick Play · After Dark",{exact:true})).toBeVisible();
  await page.getByRole("button",{name:"Roleplay"}).click();
  await expect(page.getByText("AFTER DARK QUICK PLAY",{exact:true})).not.toBeVisible();
  await expect(page.getByRole("heading",{name:"Roleplay",exact:true})).toBeVisible();
  await page.getByRole("button",{name:"Draw Role"}).click();
  await expect(page.getByText("SCENE",{exact:true})).toBeVisible();
});

test("Selected mode persists after returning to Home",async({page})=>{
  await page.goto("");
  await enterIgniteWelcome(page);
  await page.getByRole("button",{name:"After Dark",exact:true}).click();
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await page.getByRole("button",{name:"Home",exact:true}).click();
  await expect(page.getByRole("button",{name:"After Dark",exact:true})).toHaveAttribute("aria-pressed","true");
});

test("Phase 6 preserves an active Journey after reload",async({page})=>{
  await page.goto("");
  await enterIgniteWelcome(page);
  await page.getByRole("button",{name:"Normal",exact:true}).click();
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await page.getByRole("button",{name:"Start Journey →"}).click();
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
  await enterIgniteWelcome(page);
  await page.getByRole("button",{name:"Normal",exact:true}).click();
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await page.getByRole("button",{name:"Start Journey →"}).click();
  await page.locator('input[name="p1"]').fill("Deon");
  await page.locator('input[name="p2"]').fill("Partner");
  await page.getByRole("button",{name:"Save Couple"}).click();
  await expect(page.getByRole("heading",{name:"Normal Journey",exact:true})).toBeVisible();
});

test("Phase 6 reduced-motion preference removes long transitions",async({page})=>{
  await page.emulateMedia({reducedMotion:"reduce"});
  await page.goto("");
  await enterIgniteWelcome(page);
  const duration=await page.locator("button").first().evaluate(el=>getComputedStyle(el).transitionDuration);
  expect(parseFloat(duration)).toBeLessThanOrEqual(0.001);
});

test("Visual system keeps controls, cards, navigation, and spacing consistent",async({page})=>{
  await page.setViewportSize({width:390,height:844});
  await page.goto("");
  await enterIgniteWelcome(page);
  await expect(page.getByRole("navigation",{name:"Main navigation"})).toBeVisible();
  const metrics=await page.evaluate(()=>{
    const buttons=[...document.querySelectorAll(".btn")].filter(el=>el.offsetParent!==null);
    const cards=[...document.querySelectorAll(".experience-card")].filter(el=>el.offsetParent!==null);
    const nav=document.querySelector(".bottom-nav");
    const rect=el=>el?.getBoundingClientRect();
    return {
      buttonHeights:buttons.map(el=>Math.round(rect(el).height)),
      cardRadii:cards.map(el=>getComputedStyle(el).borderTopLeftRadius),
      navHeight:nav?Math.round(rect(nav).height):0,
      bottomGap:nav?Math.round(window.innerHeight-rect(nav).bottom):0,
      overflow:document.documentElement.scrollWidth>window.innerWidth
    };
  });
  expect(metrics.overflow).toBe(false);
  expect(metrics.buttonHeights.every(h=>h>=44)).toBe(true);
  expect(metrics.cardRadii.every(r=>r==="22px"||r==="20px")).toBe(true);
  expect(metrics.navHeight).toBeGreaterThanOrEqual(60);
  expect(metrics.bottomGap).toBeGreaterThanOrEqual(8);
});

test("Main bottom navigation exposes all destinations and opens Journey story",async({page})=>{
  await page.goto("");
  await enterIgniteWelcome(page);
  await expect(page.getByRole("navigation",{name:"Main navigation"})).toBeVisible();
  await expect(page.getByRole("button",{name:"Home",exact:true})).toBeVisible();
  await expect(page.getByRole("button",{name:"Play",exact:true})).toBeVisible();
  await expect(page.getByRole("button",{name:"Journey"})).toBeVisible();
  await expect(page.getByRole("button",{name:"Profile"})).toBeVisible();
  await page.getByRole("button",{name:"Journey"}).click();
  await expect(page.getByRole("heading",{name:"One moment at a time.",exact:true})).toBeVisible();
  await expect(page.getByText("Your Story",{exact:true}).last()).toBeVisible();
});

test("Profile and Minigames use the same compact control system",async({page})=>{
  await page.goto("");
  await enterIgniteWelcome(page);
  await page.getByRole("button",{name:"Profile"}).click();
  await expect(page.getByRole("heading",{name:"Make it yours.",exact:true})).toBeVisible();
  const profileButtons=await page.locator(".content-actions .btn").evaluateAll(els=>els.map(el=>Math.round(el.getBoundingClientRect().height)));
  expect(profileButtons.every(h=>h>=40)).toBe(true);
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await expect(page.getByRole("heading",{name:"Choose a game.",exact:true})).toBeVisible();
  const miniCards=await page.locator(".mini-card").count();
  expect(miniCards).toBe(4);
});

test("Couple quote is generated from XP level instead of manual input",async({page})=>{
  await page.goto("");
  await enterIgniteWelcome(page);
  await page.getByRole("button",{name:"Profile"}).click();
  await expect(page.getByText(/Couple Quote · Level 1/)).toBeVisible();
  await expect(page.locator(".generated-couple-quote")).toContainText("Every story starts with a spark.");
  await expect(page.locator('input[name="couple"]')).toHaveCount(0);
  await page.locator('input[name="p1"]').fill("Deon");
  await page.locator('input[name="p2"]').fill("Partner");
  await page.getByRole("button",{name:"Save Changes"}).click();
  await page.getByRole("button",{name:"Profile",exact:true}).click();
  await expect(page.locator(".generated-couple-quote")).toContainText("Every story starts with a spark.");
});

test("Phase 6 replay starts Journey mechanics from a clean state",async({page})=>{
  await page.goto("");
  await enterIgniteWelcome(page);
  await page.getByRole("button",{name:"Normal",exact:true}).click();
  await page.getByRole("button",{name:"Play",exact:true}).click();
  await page.getByRole("button",{name:"Start Journey →"}).click();
  await page.locator('input[name="p1"]').fill("Deon");
  await page.locator('input[name="p2"]').fill("Partner");
  await page.getByRole("button",{name:"Save Couple"}).click();
  await page.getByRole("button",{name:/Begin Journey/}).click();

  for(let i=0;i<5;i++){
    await page.getByRole("button",{name:/Merah/}).click();
    if(i<4) await page.getByRole("button",{name:"Next Round"}).click();
  }
  await page.getByRole("button",{name:"Continue →"}).click();
  for(let i=0;i<4;i++) await page.getByRole("button",{name:"Skip"}).click();
  await page.getByRole("button",{name:/Finish Journey/}).click();

  await page.getByRole("button",{name:"Play Again"}).click();
  await page.getByRole("button",{name:/Begin Journey/}).click();
  await expect(page.getByText("Warm Up")).toBeVisible();
  await expect(page.getByText("Pilih warna kartu")).toBeVisible();
  await expect(page.locator(".mechanic-result")).toHaveCount(0);
});
