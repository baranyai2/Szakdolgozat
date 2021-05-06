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

    local found = false;
    local town = null;
    local town2 = null;
    local town_it = AITown();

    if (!town_list.IsEmpty()) {
        town = town_list.Begin();
        AILog.Info("Getting best town " + AITown.GetName(town) + town_list.GetValue(town));
        if (AITown.IsValidTown(town)) {
            town_list.RemoveItem(town);
            found = true;
        } else {
            AILog.Info("Town not valid");
        }
    }
    if (found) {
        AILog.Info("Looking for second town");
        local townArray = array(town_list.Count());
        local i = 0;
        for (town_it = town_list.Begin(); town_list.HasNext(); town_it = town_list.Next()) {
            local value = (town_list.GetValue(town_it)).tofloat() / (AIMap.DistanceManhattan(AITown.GetLocation(town), AITown.GetLocation(town_it)).tofloat());
            townArray[i] = [town_it, value];
            i++;
        }
        local n = townArray.len()
        local tmp;
        for (local i = n-1; i > 0; i--) {
            for ( local j = 0; j < i; j++) {
                if (townArray[j][1] < townArray[j+1][1]) {
                    tmp = townArray[j];
                    townArray[j] = townArray[j+1];
                    townArray[j+1] = tmp;
                }
            }
        }
        for (local i = 0; i < n; i++) {
            AILog.Info(AITown.GetName(townArray[i][0]) + " " + townArray[i][1]);
        }
        if (townArray[0][1] < 0.5) {
            AILog.Info("No town worth connectiong to");
            return null;
        } else {
            town2 = townArray[0][0];
        }
        // AILog.Info("Second Town: " + AITown.GetName(town2) + " " + townArray[0][1]);
    }
    if (town != null && town2 != null) {
        return [town, town2];
    } else {
        return null;
    }
}