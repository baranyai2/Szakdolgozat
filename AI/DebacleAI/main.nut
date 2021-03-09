import("pathfinder.road", "RoadPathFinder", 3);
require("line.nut");
require("builder.nut");
require("manager.nut");
require("planner.nut");

class DebacleAI extends AIController 
{
  function Start();
  function SetCompanyName();
}

function DebacleAI::Start()
{
  this.Sleep(1);
  SetCompanyName();

  AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);

  local planner = Planner();
  planner.InitTownList();

  local towns;
  towns = planner.FindTownsToBuild();

  AILog.Info("2");

  local line = Line();
  line.CreateNewLine(towns);

  while (true) {
    AILog.Info("This is a ping");
    this.Sleep(100);
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