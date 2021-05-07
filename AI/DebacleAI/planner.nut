class Planner {
    town_list = null;
    date_town_acceptance_update  = 0;

    constructor() {
		this.town_list     = null;
		date_town_acceptance_update  = 0;
	}

    function BuildTownList();
    function FindTownsToBuild();
    function GetMaxAcceptance();
    function DistanceMeasure(town1, town2);
}

function Planner::BuildTownList()
{
    local manager = TownManager();
    this.town_list = AITownList();
    for (local i = town_list.Begin(); town_list.HasNext(); i = town_list.Next()) {
        local loc = manager.FindStationLocation(i);
        if (loc != false) {
            town_list.SetValue(i, manager.GetStationAcceptance(loc));
        } else {
            town_list.SetValue(i, 0);
        }
    }
    town_list.Sort(AIList.SORT_BY_VALUE, AIList.SORT_DESCENDING);
}

function Planner::GetMaxAcceptance()
{
    local maxsum = 0;
    for (local i = 0; i < town_list.Count(); i++) {
        for (local j = i+1; j < town_list.Count(); j++) {
            local sum = town_list.GetValue(i) + town_list.GetValue(j);
            if (sum > maxsum) {
                maxsum = sum;
            }
        }
    }
    return maxsum;
}

function Planner::DistanceMeasure(town1, town2)
{
    local distance = AIMap.DistanceManhattan(AITown.GetLocation(town1), AITown.GetLocation(town2)).tofloat();
    local dstar = 50.0;
    local dmin = 30.0;
    local dmax = 100.0;
    if (distance < dmin) {
        return 0.0;
    }
    if (distance < dstar) {
        local result = (distance - dmin) / (dstar - dmin);
        return result;
    }
    if (distance == dstar) {
        return 1.0;
    }
    if (distance <= dmax) {
        local result = 1 - ((distance - dstar) / (dmax - dstar));
        return result;
    }
    if (distance > dmax) {
        return 0.0;
    }
}

function Planner::FindTownsToBuild()
{
    town_list.Clear();
    BuildTownList();

    local town_it = AITown();
    local w = 0.5;
    local townArray = array(town_list.Count());
    local towneArray = array((town_list.Count() * town_list.Count()) / 2);
    local i = 0;

    for (town_it = town_list.Begin(); town_list.HasNext(); town_it = town_list.Next()) {
        townArray[i] = [town_it, town_list.GetValue(town_it).tofloat()];
        i++;
    }

    local n = 0;
    for (local i = 0; i < townArray.len(); i++) {
        for (local j = i + 1; j < townArray.len(); j++) {
            local d = DistanceMeasure(townArray[i][0], townArray[j][0]);
            local maxacc = GetMaxAcceptance().tofloat();
            local e = (w * ((townArray[i][1] + townArray[j][1]) / maxacc)) + ((1.0 - w) * d);
            towneArray[n] = [townArray[i][0], townArray[j][0], e];
            n++;
        }
    }

    for (local l = 0; l < n; l++) {
        AILog.Info(l+1 + " " + towneArray[l][2].tostring());
    }
    local tmp;
    for (local i = n-1; i > 0; i--) {
        for (local j = 0; j < i; j++) {
            if (towneArray[j][2] < towneArray[j+1][2]) {
                tmp = towneArray[j];
                towneArray[j] = towneArray[j+1];
                towneArray[j+1] = tmp;
            }
        }
    }

    local town = towneArray[0][0];
    local town2 = towneArray[0][1];

    if (town != null && town2 != null) {
        return [town, town2];
    } else {
        return null;
    }
}