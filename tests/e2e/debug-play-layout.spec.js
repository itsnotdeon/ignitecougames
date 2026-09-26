const {test}=require("@playwright/test");

test("debug Play Hub computed layout",async({page})=>{
  await page.goto("");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await page.locator('input[name="p1"]').fill("Ariel");
  await page.locator('input[name="p2"]').fill("Fe");
  await page.getByRole("button",{name:/Start Our Journey/}).click();
  await page.getByRole("button",{name:"Play",exact:true}).click();
  const data=await page.evaluate(()=>{
    const selectors=["#app",".app-shell",".play-v1",".play-v1-hero",".play-spotlight",".play-spotlight .eyebrow"];
    return Object.fromEntries(selectors.map(sel=>{
      const el=document.querySelector(sel);
      if(!el)return [sel,null];
      const s=getComputedStyle(el),r=el.getBoundingClientRect();
      return [sel,{display:s.display,width:s.width,maxWidth:s.maxWidth,minWidth:s.minWidth,height:s.height,gridTemplateColumns:s.gridTemplateColumns,flexDirection:s.flexDirection,position:s.position,transform:s.transform,opacity:s.opacity,visibility:s.visibility,overflow:s.overflow,x:r.x,y:r.y,w:r.width,h:r.height,parent:el.parentElement?.className||""}];
    }));
  });
  console.log("PLAY_LAYOUT_DEBUG",JSON.stringify(data,null,2));
});
