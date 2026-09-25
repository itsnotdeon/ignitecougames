const {test,expect}=require("@playwright/test");

test("content source exposes the imported JSON libraries",async({page})=>{
  await page.goto("");
  const result=await page.evaluate(async()=>{
    const m=await import("/redesign/scripts/data/topics.js?v=20260926-01");
    const norm=v=>String(v).normalize("NFKC").trim().replace(/\s+/g," ").toLocaleLowerCase("id-ID");
    const unique=list=>new Set(list.map(norm)).size===list.length;
    const explicitBase=m.explicitPools.flatMap(x=>x.topics||[]);
    const truthBase=m.truthOrDarePools.find(x=>x.name==="Truth")?.topics||[];
    const dareBase=m.truthOrDarePools.find(x=>x.name==="Dare")?.topics||[];
    const afterDarkBase=m.truthOrDarePools.find(x=>x.name==="After Dark")?.topics||[];
    return {
      normal:{source:m.topicPools[0]?.topics?.length||0,active:m.allNormalTopics.length,unique:unique(m.allNormalTopics)},
      explicit:{source:explicitBase.length,active:m.allExplicitTopics.length,unique:unique(m.allExplicitTopics)},
      truth:{source:truthBase.length,active:m.allTruthTopics.length,unique:unique(m.allTruthTopics)},
      dare:{source:dareBase.length,active:m.allDareTopics.length,unique:unique(m.allDareTopics)},
      afterDarkTruth:{source:afterDarkBase.length,active:m.allIntimateTruthTopics.length,unique:unique(m.allIntimateTruthTopics)},
      afterDarkDare:{source:afterDarkBase.length,active:m.allIntimateDareTopics.length,unique:unique(m.allIntimateDareTopics)},
      kingNormal:{source:m.ksCommands.length,active:m.allKingNormalCommands.length,unique:unique(m.allKingNormalCommands)},
      kingDark:{source:m.ksCommandsExplicit.length,active:m.allKingDarkCommands.length,unique:unique(m.allKingDarkCommands)},
      roleplayNormal:{source:m.roleplayBuiltInRoles.length,active:m.allRoleplayNormalRoles.length,unique:new Set(m.allRoleplayNormalRoles.map(x=>x.id)).size===m.allRoleplayNormalRoles.length},
      roleplayDark:{source:m.roleplayBuiltInRolesExplicit.length,active:m.allRoleplayDarkRoles.length,unique:new Set(m.allRoleplayDarkRoles.map(x=>x.id)).size===m.allRoleplayDarkRoles.length}
    };
  });

  expect(result.normal.active).toBe(result.normal.source);
  expect(result.normal.unique).toBe(true);
  expect(result.explicit.active).toBe(result.explicit.source);
  expect(result.explicit.unique).toBe(true);
  expect(result.truth.active).toBe(result.truth.source);
  expect(result.truth.unique).toBe(true);
  expect(result.dare.active).toBe(result.dare.source);
  expect(result.dare.unique).toBe(true);

  // The imported JSON currently has no After Dark Truth/Dare prompts.
  expect(result.afterDarkTruth.source).toBe(0);
  expect(result.afterDarkTruth.active).toBe(0);
  expect(result.afterDarkDare.source).toBe(0);
  expect(result.afterDarkDare.active).toBe(0);

  expect(result.kingNormal.active).toBe(result.kingNormal.source);
  expect(result.kingNormal.unique).toBe(true);
  expect(result.kingDark.active).toBe(result.kingDark.source);
  expect(result.kingDark.unique).toBe(true);

  // Custom Roleplay scenes are normalized into role objects, so the active
  // role count is allowed to exceed the built-in role count.
  expect(result.roleplayNormal.active).toBeGreaterThan(0);
  expect(result.roleplayNormal.unique).toBe(true);
  expect(result.roleplayDark.active).toBeGreaterThan(0);
  expect(result.roleplayDark.unique).toBe(true);
});
