const {test,expect}=require("@playwright/test");

test("topic expansion adds 45 unique entries to every category",async({page})=>{
  await page.goto("");
  const result=await page.evaluate(async()=>{
    const m=await import("/redesign/scripts/data/topics.js?v=20260925-19");
    const norm=v=>String(v).normalize("NFKC").trim().replace(/\\s+/g," ").toLocaleLowerCase("id-ID");
    const unique=list=>new Set(list.map(norm)).size===list.length;
    const explicitBase=m.explicitPools.flatMap(x=>x.topics||[]);
    const truthBase=m.truthOrDarePools.find(x=>x.name==="Truth")?.topics||[];
    const dareBase=m.truthOrDarePools.find(x=>x.name==="Dare")?.topics||[];
    const checks=[
      ["normal",m.allNormalTopics,m.topicPools.length+m.legacyJourneyPools.starterNormalCards.length],
      ["explicit",m.allExplicitTopics,explicitBase.length+m.legacyJourneyPools.starterExplicitCards.length],
      ["truth",m.allTruthTopics,truthBase.length+m.legacyJourneyPools.starterTruth.length],
      ["dare",m.allDareTopics,dareBase.length+m.legacyJourneyPools.starterDare.length],
      ["intimateTruth",m.allIntimateTruthTopics,m.legacyJourneyPools.starterIntimateTruth.length+Math.min(20,truthBase.length)],
      ["intimateDare",m.allIntimateDareTopics,m.legacyJourneyPools.starterIntimateDare.length+Math.min(20,dareBase.length)],
      ["kingNormal",m.allKingNormalCommands,m.ksCommands.length+m.legacyJourneyPools.ksLegacyNormal.length],
      ["kingDark",m.allKingDarkCommands,m.ksCommandsExplicit.length+m.legacyJourneyPools.ksLegacyDark.length]
    ];
    return {
      checks:checks.map(([name,pool,base])=>({name,length:pool.length,base,added:pool.length-base,unique:unique(pool)})),
      roleplayNormal:{base:m.roleplayBuiltInRoles.length+m.legacyJourneyPools.roleplayLegacyNormal.length,length:m.allRoleplayNormalRoles.length,added:m.allRoleplayNormalRoles.length-(m.roleplayBuiltInRoles.length+m.legacyJourneyPools.roleplayLegacyNormal.length),unique:new Set(m.allRoleplayNormalRoles.map(x=>x.id)).size===m.allRoleplayNormalRoles.length},
      roleplayDark:{base:m.legacyJourneyPools.roleplayLegacyDark.length,length:m.allRoleplayDarkRoles.length,added:m.allRoleplayDarkRoles.length-m.legacyJourneyPools.roleplayLegacyDark.length,unique:new Set(m.allRoleplayDarkRoles.map(x=>x.id)).size===m.allRoleplayDarkRoles.length}
    };
  });
  for(const item of result.checks){
    expect(item.added,item.name).toBe(45);
    expect(item.unique,item.name).toBe(true);
  }
  expect(result.roleplayNormal.added).toBe(45);
  expect(result.roleplayNormal.unique).toBe(true);
  expect(result.roleplayDark.added).toBe(45);
  expect(result.roleplayDark.unique).toBe(true);
});
