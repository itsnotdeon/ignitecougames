const {test,expect}=require("@playwright/test");

test.describe("Empty content libraries stay safe",()=>{
  test("Roleplay handles an empty active library without crashing",async({page})=>{
    await page.goto("./");
    const result=await page.evaluate(async()=>{
      const m=await import("./scripts/minigames/roleplay.js?v=20260926-03");
      localStorage.setItem("ignite-active-content-v1",JSON.stringify({roleplayNormal:[],roleplayDark:[]}));
      expect(JSON.parse(localStorage.getItem("ignite-active-content-v1")).roleplayNormal).toEqual([]);
      const s=m.createRoleplayState();
      m.nextRoleplay(s);
      return {role:s.role,item:s.item,html:m.renderRoleplay(s)};
    });
    expect(result.role).toBeNull();
    expect(result.item).toBeNull();
    expect(result.html).toContain("No roleplay content is available");
  });

  test("King & Slave handles an empty active command library without crashing",async({page})=>{
    await page.goto("./");
    const result=await page.evaluate(async()=>{
      const m=await import("./scripts/minigames/kingslave.js?v=20260926-03");
      localStorage.setItem("ignite-active-content-v1",JSON.stringify({kingNormal:[],kingDark:[]}));
      expect(JSON.parse(localStorage.getItem("ignite-active-content-v1")).kingNormal).toEqual([]);
      const s=m.createKingState();
      m.kingAction(s,"consent");
      s.rollP1=6;s.rollP2=1;
      m.kingAction(s,"roll");
      m.kingAction(s,"draw");
      return {drawn:s.commandDrawn,command:s.command,html:m.renderKing(s,["A","B"])};
    });
    expect(result.drawn).toBe(false);
    expect(result.command).toBeNull();
    expect(result.html).toContain("No command cards are available");
  });
});
