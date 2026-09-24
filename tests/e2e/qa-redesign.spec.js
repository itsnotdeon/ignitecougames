const {test,expect}=require("@playwright/test");

async function enter(page){
  await page.goto("");
  await page.getByRole("button",{name:/ENTER TOGETHER/}).click();
  await expect(page.getByText("YOUR SPACE FOR TWO")).toBeVisible();
}

test.describe("IGNITE responsive and critical navigation QA",()=>{
  test("mobile shell has no horizontal overflow",async({page})=>{
    await page.setViewportSize({width:375,height:812});
    await enter(page);
    const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-document.documentElement.clientWidth);
    expect(overflow).toBeLessThanOrEqual(0);
  });

  test("Home mode selection persists after reload",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"After Dark",exact:false}).click();
    await expect(page.getByText("AFTER DARK",{exact:true}).first()).toBeVisible();
    await page.reload();
    await expect(page.getByText("AFTER DARK",{exact:true}).first()).toBeVisible();
    await expect(page.getByRole("button",{name:"After Dark",exact:false}).filter({hasText:"After Dark"})).toHaveClass(/active/);
  });

  test("Add Memory returns to Memories",async({page})=>{
    await enter(page);
    await page.getByRole("button",{name:"Memories",exact:true}).click();
    await page.getByRole("button",{name:"Add Memory"}).click();
    await page.getByRole("textbox",{name:"MEMORY"}).fill("QA memory");
    await page.getByRole("button",{name:"Save Memory"}).click();
    await expect(page.getByRole("heading",{name:"Keep the moments."})).toBeVisible();
    await expect(page.getByText("QA memory",{exact:true})).toBeVisible();
  });
});
