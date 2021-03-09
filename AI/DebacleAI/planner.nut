class Planner {
    town_list = null;
    town_list2 = null;
    town_acceptance_list = null;
    date_town_acceptance_update  = 0;

    constructor() {
		this.town_list     = null;
		this.town_list2    = null;
		this.town_acceptance_list = null;
		date_town_acceptance_update  = 0;
	}

    function InitTownList();
    function FindTownsToBuild();
    function UpdateTownAcceptanceList();
}

function Planner::InitTownList()
{
    this.town_list2 = AITownList(); 
	this.town_list  = AIList();
	this.town_list.AddList(this.town_list2);
	town_list.Valuate(AITown.GetPopulation);
	this.town_acceptance_list = AIList();
	UpdateTownAcceptanceList();
}

function Planner::UpdateTownAcceptanceList()
{
	if (AIDate.GetCurrentDate() - date_town_acceptance_update > 60)	{
		town_acceptance_list.Clear();
		foreach ( twn, v in town_list){
            local manager = TownManager();
			local acceptance = manager.GetAcceptance(twn);
			town_acceptance_list.AddItem(twn, acceptance);
		 	AIController.Sleep(1);
		}
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
    local distance_limit = 50

    UpdateTownAcceptanceList();
    if (town_acceptance_list.Count()) {
        for (town_it = town_acceptance_list.Begin(); town_acceptance_list.HasNext(); town_it = town_acceptance_list.Next()){					
			local tl2 = AITileList();
			tl2.AddRectangle(AITown.GetLocation(town_it) + AIMap.GetTileIndex(-8, -8), AITown.GetLocation(town_it) + AIMap.GetTileIndex(8, 8));
			tl2.Valuate(AIRoad.IsRoadStationTile);
			tl2.KeepValue(1);

			if (!tl2.Count()){
				town = town_it;
				found = true;
				town_acceptance_list.RemoveItem(town_it);
				break;
			}
		}
        if (found) {
            found = false;
            for (town_it = town_acceptance_list.Begin(); town_acceptance_list.HasNext(); town_it = town_acceptance_list.Next()) {
                if (AIMap.DistanceManhattan(AITown.GetLocation(town), AITown.GetLocation(town_it)) > 40 && AIMap.DistanceManhattan(AITown.GetLocation(town), AITown.GetLocation(town_it)) < distance_limit) {
                    town2 = town_it;
                    found = true;
                    town_acceptance_list.RemoveItem(town_it);
                    break;
                }
                distance_limit += 10;
            }
        }
    }
    if (found) {
        return [town, town2];
    } else {
        return null;
    }
}