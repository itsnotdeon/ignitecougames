const {defineConfig,devices}=require("@playwright/test");

module.exports=defineConfig({
  testDir:"./tests/e2e",
  timeout:30000,
  fullyParallel:true,
  forbidOnly:!!process.env.CI,
  retries:process.env.CI?2:0,
  workers:process.env.CI?2:undefined,
  reporter:process.env.CI?"github":"list",
  use:{
    baseURL:"http://127.0.0.1:4173/redesign/index.html",
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
