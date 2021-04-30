import("pathfinder.road", "RoadPathFinder", 3);
require("busline.nut");
require("builder.nut");
require("townmanager.nut");
require("planner.nut");

class DebacleAI extends AIController
{
  company = null;
  lines = null;

  constructor() {
		company   = AICompany();
    lines = [];
	}
  function Start();
  function SetCompanyName();
  function ManageLoan();
}

function DebacleAI::Start()
{
  this.Sleep(1);
  SetCompanyName();

  AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

  local planner = Planner();
  planner.InitTownList();

  local towns;
  local lineCreated = null;
  local i = 0;
  local j;
  while (true) {
    if (i%25 == 0){
      this.company.SetLoanAmount(AICompany.GetMaxLoanAmount());
      if (lines.len() && this.company.GetBankBalance(AICompany.COMPANY_SELF) > 30000) {
        for (j = 0; j < lines.len(); j++) {
          lines[j].ManageBuses();
        }
      }
      if (this.company.GetBankBalance(AICompany.COMPANY_SELF) > 50000) {
        towns = planner.FindTownsToBuild();
        local line = Line();
        if (towns != null) {
          lineCreated = line.CreateNewLine(towns);
          if (!lineCreated) {
            AILog.Info("Line creation failed");
          } else {
            AILog.Info("Line created");
            lines.append(line);
          }
        }
      }
    }
    this.ManageLoan();
  }
}

function DebacleAI::ManageLoan()
{
  local balance = this.company.GetBankBalance(AICompany.COMPANY_SELF);
	local loan = this.company.GetLoanAmount();
	local pay_back_balance =  loan + this.company.GetLoanInterval();
	local loan_interval = this.company.GetLoanInterval();
	local pay_back = 0;

	while(( balance - pay_back >= pay_back_balance) && (loan - pay_back > 0))	{
		pay_back += loan_interval;
	}
	if (pay_back) {
		if(!this.company.SetLoanAmount(loan - pay_back))	{
			AILog.Info(this.name + " Failed to pay back");
		}
	}
}

function DebacleAI::SetCompanyName()
{
    if (!AICompany.SetName("DebacleAI")) {
        local i = 2;
        while (!AICompany.SetName("DebacleAI #" + i)) {
            i = i + 1;
    }
  }
}