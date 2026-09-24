const {test}=require("@playwright/test");
test("IGNITE module isolation",async({page})=>{
  await page.goto("./");
  const modules=[
    "./scripts/journey/mechanics.js?v=diag",
    "./scripts/minigames/index.js?v=diag",
    "./scripts/progression.js?v=diag",
    "./scripts/journey/content.js?v=diag",
    "./scripts/features/ui.js?v=diag",
    "./scripts/features/memories.js?v=diag",
    "./scripts/features/adaptive.js?v=diag",
    "./scripts/ui/accessibility.js?v=diag"
  ];
  for(const path of modules){
    const result=await page.evaluate(async(path)=>{
      try{await import(path);return {ok:true,path}}
      catch(error){return {ok:false,path,message:String(error?.message||error),stack:String(error?.stack||"")}}
    },path);
    console.log("[MODULE-DIAG]",JSON.stringify(result));
  }
});