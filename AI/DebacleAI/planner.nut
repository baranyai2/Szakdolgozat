class Planner {
    town_list = null;
    // town_acceptance_list = null;
    date_town_acceptance_update  = 0;

    constructor() {
		this.town_list     = null;
		// this.town_acceptance_list = null;
		date_town_acceptance_update  = 0;
	}

    function InitTownList();
    function FindTownsToBuild();
    function UpdateTownAcceptanceList();
}

function Planner::InitTownList()
{
    this.town_list = AITownList();
	town_list.Valuate(AITown.GetPopulation);
    town_list.Sort(AIAbstractList.SORT_BY_VALUE, false);
    //AILog.Info(AITown.GetName(town_list.Begin()));
	//this.town_acceptance_list = AIList();
	UpdateTownAcceptanceList();
}

function Planner::UpdateTownAcceptanceList()
{
	if (AIDate.GetCurrentDate() - date_town_acceptance_update > 60)	{
		//town_acceptance_list.Clear();
        AILog.Info("Updating town list");
        town_list.Clear();
        this.town_list = AITownList();
        town_list.Valuate(AITown.GetPopulation);
        town_list.Sort(AIAbstractList.SORT_BY_VALUE, false);
        // for (local i = town_list.Begin(); town_list.HasNext(); i = town_list.Next()) {
        //     AILog.Info(AITown.GetName(i));
        // }
		// foreach ( twn, v in town_list) {
        //     local manager = TownManager();
		// 	local acceptance = manager.GetAcceptance(twn);
		// 	town_acceptance_list.AddItem(twn, acceptance);
		// }
        // for (local i = town_acceptance_list.Begin(); town_acceptance_list.HasNext(); i = town_acceptance_list.Next()) {
        //     AILog.Info(AITown.GetName(i));
        // }
		date_town_acceptance_update = AIDate.GetCurrentDate();
	}
}

function Planner::FindTownsToBuild()
{
    local town = null;
    local town2 = null;
    local towns = [0,0];
    local town_it = AITown();
    local found = false;
    local distance_limit = 40

    UpdateTownAcceptanceList();
    if (town_list.Count()) {
        AILog.Info("Looking for town");
        for (town_it = town_list.Begin(); town_list.HasNext(); town_it = town_list.Next()){
            town = town_it;
            found = true;
            town_list.RemoveItem(town_it);
	        break;
            // local tl = AITileList();
			// tl.AddRectangle(AITown.GetLocation(town_it) + AIMap.GetTileIndex(-8, -8), AITown.GetLocation(town_it) + AIMap.GetTileIndex(8, 8));
			// tl.Valuate(AIRoad.IsRoadStationTile);
			// tl.KeepValue(1);

			// if (tl.IsEmpty()){
			// 	town = town_it;
			// 	found = true;
			// 	town_list.RemoveItem(town_it);
			// 	break;
            // }
		}
        if (found) {
            AILog.Info("Firt Town Found: " + AITown.GetName(town));
            AILog.Info("Looking for Second Town");
            found = false;
            for (local i = 0; i < town_list.Count() && !found; i++) {
                for (town_it = town_list.Begin(); town_list.HasNext(); town_it = town_list.Next()) {
                    if (AIMap.DistanceManhattan(AITown.GetLocation(town), AITown.GetLocation(town_it)) > 30 && AIMap.DistanceManhattan(AITown.GetLocation(town), AITown.GetLocation(town_it)) < distance_limit) {
                        town2 = town_it;
                        found = true;
                        town_list.RemoveItem(town_it);
                        break;
                    }
                }
                distance_limit += 10;
            }
            if (!found) {
                AILog.Info("Second town not found");
                return null;
            }
        } else {
            AILog.Info("Town not found");
            return null;
        }
    }
    if (found) {
        return [town, town2];
    } else {
        return null;
    }
}