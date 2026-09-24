const {defineConfig,devices}=require("@playwright/test");

module.exports=defineConfig({
  testDir:"./tests/e2e",
  timeout:20000,
  expect:{timeout:30000},
  globalTimeout:15*60*1000,
  fullyParallel:true,
  workers:process.env.CI?2:undefined,
  retries:process.env.CI?1:0,
  maxFailures:process.env.CI?8:undefined,
  forbidOnly:!!process.env.CI,
  reporter:process.env.CI?"github":"list",
  use:{
    baseURL:"http://127.0.0.1:4173/redesign/index.html",
    actionTimeout:30000,
    navigationTimeout:10000,
    trace:"retain-on-failure",
    screenshot:"only-on-failure",
  },
  projects:[
    {name:"chromium",use:{...devices["Desktop Chrome"]}},
    {name:"mobile-chrome",use:{...devices["Pixel 5"]}},
  ],
  webServer:{
    command:"python3 -m http.server 4173 --directory .",
    url:"http://127.0.0.1:4173/redesign/index.html",
    reuseExistingServer:true,
    timeout:10000
  }
});
