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
  function GetMoney(amount);
  function PayBackMoney();
}

function DebacleAI::Start()
{
  this.Sleep(1);
  SetCompanyName();

  AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

  local planner = Planner();
  planner.BuildTownList();

  local towns;
  local retries = 0;
  local counter = 0;
  local lineCreated = null;
  local i = 0;
  local j;
  while (true) {
    if (i%50 == 0) {
      local hasMoney = GetMoney(30000);
      if (hasMoney && counter < 5) {
        if (lines.len()) {
          for (j = 0; j < lines.len(); j++) {
            lines[j].ManageBuses();
          }
        }
      } else {
        counter++;
        AILog.Info("Failed to get enough money");
      }
      PayBackMoney();
    }
    if (i%200 == 0) {
      local hasMoney = GetMoney(50000);
      if (hasMoney && retries < 10) {
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
        } else {
          AILog.Info("Failed to create line");
          retries++;
        }
      }
      PayBackMoney();
    }
    if (i%100000 == 0) {
      retries = 0;
      counter = 0;
      AILog.Info("Resetting retries");
      i = 0;
    }
    i++;
    PayBackMoney();
  }
}

function DebacleAI::GetMoney(amount)
{
  local balance = this.company.GetBankBalance(AICompany.COMPANY_SELF);
  local loan = this.company.GetLoanAmount();

  if (balance > amount) {
    return true;
  }
  if ((loan + amount) <= this.company.GetMaxLoanAmount()) {
    this.company.SetLoanAmount(loan + amount);
    return true;
  } else {
    return false;
  }
}

function DebacleAI::PayBackMoney()
{
  local balance = this.company.GetBankBalance(AICompany.COMPANY_SELF);
	local loan = this.company.GetLoanAmount();
	local pay_back_balance = 5 * this.company.GetLoanInterval();
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