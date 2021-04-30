import("pathfinder.road", "RoadPathFinder", 3);


class TownManager
{
  function FindStationLocation(town_id);
  function GetAcceptance(town_id);
  function BuildStation(tile, town_id);
}

function TownManager::FindStationLocation(town_id)
{
  local tl = AITileList();
  local town_loc = AITown.GetLocation(town_id);
  local tile_it = null;
  local found = false;
  local station_loc = null;

  tl.AddRectangle(town_loc + AIMap.GetTileIndex(-8, -8), town_loc + AIMap.GetTileIndex(8, 8));
  local tl2 = AITileList();

	tl2.AddList(tl);
	tl2.Valuate(AIRoad.IsRoadStationTile);
	tl2.KeepValue(1);

  for (local rstl = tl2.Begin(); tl2.HasNext() ; rstl = tl2.Next()){
    tl.RemoveRectangle(rstl + AIMap.GetTileIndex(-6, -6), rstl + AIMap.GetTileIndex(6, 6));
  }
  if (tl.Count()) {
    tl.Valuate(AIRoad.GetNeighbourRoadCount);
    tl.KeepAboveValue(0);
    if (tl.Count()) {
      tl.Valuate(AIRoad.IsRoadTile);
      tl.KeepValue(0);
      if(tl.Count()) {
        tl.Valuate(AITile.GetSlope);
        tl.KeepValue(0);
        if(tl.Count()) {
          tl.Valuate(AITile.GetCargoAcceptance, 0, 1, 1, AIStation.GetCoverageRadius(AIStation.STATION_BUS_STOP));
          for (tile_it = tl.Begin(); tl.HasNext(); tile_it = tl.Next()){
            AILog.Info(tl.GetValue(tile_it));
						if (tl.GetValue(tile_it) >= 15){
  						found = AITile.IsBuildable(tile_it);
							if (false) {
								found = true;
							}
							if (!found)	{
								found = AITile.DemolishTile(tile_it);
							}
							if (found) {
								station_loc = tile_it;
								break;
							}
						}
	   			}
				}
				else {
					AILog.Info("Found busstop location, no unsloped tiles present");
				}
	   	}
			else {
				AILog.Info("Found busstop location, no tiles that are not road present");
			}
	   }
		else {
			AILog.Info("Found busstop location, no tiles next to road present");
		}
	}
  if (found) {
	  return station_loc;
  } else {
		return false;
	}
}

// function TownManager::GetAcceptance(town_id)
// {
//   local location = AITown.GetLocation(town_id);
//   local acceptance = AITile.GetCargoAcceptance(location, 0, 1, 1, AIStation.GetCoverageRadius(AIStation.STATION_BUS_STOP));
//   return acceptance;
// }

function TownManager::BuildStation(tile, town_id)
{
  local success = false;
  local builder = Builder();
  local adjacentTiles = builder.GetAdjacentTiles(tile);

  for(local tile2 = adjacentTiles.Begin(); adjacentTiles.HasNext() && !success; tile2 = adjacentTiles.Next()) {
    if(AIRoad.IsRoadTile(tile2) ) {
      builder.RoadBuilder(tile2, tile);
      success = AIRoad.BuildDriveThroughRoadStation(tile, tile2, AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
      builder.RoadBuilder(tile2, AITown.GetLocation(town_id));
    }
  }

  if (!success) {
    AILog.Info("Build busstop failed "+ AIError.GetLastErrorString());
    return false;
  }
  return true;
}