class Planner {
    town_list = null;
    date_town_acceptance_update  = 0;

    constructor() {
		this.town_list     = null;
		date_town_acceptance_update  = 0;
	}

    function BuildTownList();
    function FindTownsToBuild();
}

function Planner::BuildTownList()
{
    local manager = TownManager();
    this.town_list = AITownList();
    for (local i = town_list.Begin(); town_list.HasNext(); i = town_list.Next()) {
        local loc = manager.FindStationLocation(i);
        if (loc != false) {
            town_list.SetValue(i, manager.GetStationAcceptance(loc));
        }
    }
    town_list.Sort(AIList.SORT_BY_VALUE, AIList.SORT_DESCENDING);
}

function Planner::FindTownsToBuild()
{
    town_list.Clear();
    BuildTownList();

    local town = null;
    local town2 = null;
    local helperList = AIList();
    local town_it = AITown();

    if (!town_list.IsEmpty()) {
        AILog.Info("Getting best town " + AITown.GetName(town_list.Begin()) + town_list.GetValue(town_list.Begin()));
        town = town_list.Begin();
        town_list.RemoveItem(town);
    }
    if (town) {
        AILog.Info("Looking for second town");
        helperList.Clear();
        for (town_it = town_list.Begin(); town_list.HasNext(); town_it = town_list.Next()) {
            local value = town_list.GetValue(town_it) / AIMap.DistanceManhattan(AITown.GetLocation(town), AITown.GetLocation(town_it));
            // AILog.Info(value.tostring());
            helperList.AddItem(town_it, value);
        }
        helperList.Sort(AIList.SORT_BY_VALUE, AIList.SORT_DESCENDING);
        town2 = helperList.Begin();
        AILog.Info("Second Town: " + AITown.GetName(town2) + " " + helperList.GetValue(town2));
    }
    if (town && town2) {
        return [town, town2];
    } else {
        return null;
    }
}