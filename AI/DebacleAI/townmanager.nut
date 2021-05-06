import("pathfinder.road", "RoadPathFinder", 3);

class TownManager
{
  function FindStationLocation(town_id);
  function GetAcceptance(town_id);
  function BuildStation(tile, town_id);
  function GetStationAcceptance(tile);
}

function TownManager::FindStationLocation(town_id)
{
  local demolished = false;
  local tl = AITileList();
  local town_loc = AITown.GetLocation(town_id);
  local tile_it = null;
  local i = null;
  local found = false;
  local station_loc = null;
  local builder = Builder();
  local tl2 = AITileList();

  tl.AddRectangle(town_loc + AIMap.GetTileIndex(-8, -8), town_loc + AIMap.GetTileIndex(8, 8));
  local tl3 = AITileList();
  tl3.AddList(tl);
	tl3.Valuate(AIRoad.IsRoadStationTile);
	tl3.KeepValue(1);

  for (local rstl = tl3.Begin(); tl3.HasNext(); rstl = tl3.Next()) {
    tl.RemoveRectangle(rstl + AIMap.GetTileIndex(-4, -4), rstl + AIMap.GetTileIndex(4, 4));
  }

  tl.Valuate(AIMap.IsValidTile);
  tl.KeepValue(1);
  tl.Valuate(AITile.IsWaterTile);
  tl.KeepValue(0);

  tl2.Clear();
  if (tl.Count()) {
    tl.Valuate(AIRoad.GetNeighbourRoadCount);
    tl.KeepAboveValue(0);
    if (tl.Count()) {
      tl.Valuate(AITile.GetSlope);
      tl.KeepValue(0);
      if (tl.Count()) {
        for (tile_it = tl.Begin(); tl.HasNext(); tile_it = tl.Next()) {
          if (!AIRoad.IsRoadTile(tile_it)) {
            tl.SetValue(tile_it, GetStationAcceptance(tile_it));
          } else {
            tl2.Clear();
            tl2.AddList(builder.GetAdjacentTiles(tile_it));
            local adjacent = [];
            for (i = tl2.Begin(); tl2.HasNext(); i = tl2.Next()) {
              adjacent.append(AIRoad.IsRoadTile(i));
            }
            if (adjacent[0] && adjacent[3] && !adjacent[2] && !adjacent[1] || adjacent[1] && adjacent[2] && !adjacent[0] && !adjacent[3]) {
              tl.SetValue(tile_it, GetStationAcceptance(tile_it));
            } else {
              tl.RemoveItem(tile_it);
              continue;
            }
          }
        }
        tl.Sort(AIList.SORT_BY_VALUE, AIList.SORT_DESCENDING);
        if (tl.GetValue(tl.Begin()) > 15) {
          station_loc = tl.Begin();
        } else {
          AILog.Info("No station location worth exploring " + tl.GetValue(tl.Begin()));
          return false;
        }
        return station_loc;
      } else {
        AILog.Info("Available tiles are slopes");
        return false;
      }
    } else {
      AILog.Info("No tiles next to road present");
      return false;
    }
  } else {
    AILog.Info("Too many stations in town");
    return false;
  }
}

function TownManager::GetStationAcceptance(tile) {
  if (!AIMap.IsValidTile(tile)) {
    AILog.Info("Tile is not valid");
    return 0;
  }
  local NewStationTiles = AITileList();
  local SearchedArea = AITileList();
  local OldStationTiles = AITileList();
  local tile_it = null;
  local NewStationOverlap = AITileList();
  local acceptance = 0;
  local statrad = AIStation.GetCoverageRadius(AIStation.STATION_BUS_STOP);

  NewStationTiles.AddRectangle(tile + AIMap.GetTileIndex(-statrad, -statrad), tile + AIMap.GetTileIndex(statrad, statrad));
  SearchedArea.AddRectangle(tile + AIMap.GetTileIndex(-(2 * statrad), -(2 * statrad)), tile + AIMap.GetTileIndex((2 * statrad), (2 * statrad)));

  if (!NewStationTiles.IsEmpty()) {
    for (local i = NewStationTiles.Begin(); NewStationTiles.HasNext(); i = NewStationTiles.Next()) {
      NewStationTiles.SetValue(i, 1);
    }
  }
  if (!SearchedArea.IsEmpty() && !NewStationTiles.IsEmpty()) {
    for (tile_it = SearchedArea.Begin(); SearchedArea.HasNext(); tile_it = SearchedArea.Next()) {
      OldStationTiles.Clear();
      if (AIRoad.IsRoadStationTile(tile_it)) {
        if (AIStation.IsValidStation(AIStation.GetStationID(tile_it))) {
          OldStationTiles.AddRectangle(tile_it + AIMap.GetTileIndex(-statrad, -statrad), tile + AIMap.GetTileIndex(statrad, statrad));
          for (local i = NewStationTiles.Begin(); NewStationTiles.HasNext(); i = NewStationTiles.Next()) {
            if (OldStationTiles.HasItem(i)) {
              NewStationTiles.SetValue(i, (NewStationTiles.GetValue(i) + 1));
            }
          }
          for (local i = NewStationTiles.Begin(); NewStationTiles.HasNext(); i = NewStationTiles.Next()) {
            acceptance += (AITile.GetCargoAcceptance(i, 0, 1, 1, 0) / NewStationTiles.GetValue(i));
          }
          return acceptance;
        } else {
          acceptance = AITile.GetCargoAcceptance(tile, 0, 1, 1, statrad);
          return acceptance;
        }
      } else {
        acceptance = AITile.GetCargoAcceptance(tile, 0, 1, 1, statrad);
        return acceptance;
      }
    }
  } else {
    AILog.Info("List is empty");
    return acceptance;
  }
}

function TownManager::BuildStation(tile, town_id)
{
  local builder = Builder();
  local built = false;
  local demolished = false;
  local adjacentTiles = builder.GetAdjacentTiles(tile);
  local adjacent = []
  local i = null;

  for (i = adjacentTiles.Begin(); adjacentTiles.HasNext(); i = adjacentTiles.Next()) {
    if (AIRoad.IsRoadTile(i)) {
      adjacent.append(i);
    } else {
      adjacent.append(false);
    }
  }

  if (!AIRoad.IsRoadTile(tile)) {
    if (!AITile.IsBuildable(tile)) {
      AILog.Info("Demolishing tile: " + tile);
      demolished = AITile.DemolishTile(tile);
    } else {
      demolished = true;
    }
    if (demolished) {
      for(local tile2 = adjacentTiles.Begin(); adjacentTiles.HasNext() && !built; tile2 = adjacentTiles.Next()) {
        if(AIRoad.IsRoadTile(tile2) ) {
          builder.RoadBuilder(tile2, tile);
          built = AIRoad.BuildRoadStation(tile, tile2, AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
          builder.RoadBuilder(tile2, AITown.GetLocation(town_id));
        }
      }
      if (built) {
        AILog.Info("Station built in: " + AITown.GetName(town_id));
        return true;
      } else {
        AILog.Info("Station building failed");
        return false;
      }
    }
  } else {
    if (adjacent[0] != false && adjacent[3] != false && adjacent[1] == false && adjacent[2] == false) {
      built = AIRoad.BuildDriveThroughRoadStation(tile, adjacent[0], AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
      builder.RoadBuilder(adjacent[3], AITown.GetLocation(town_id));
    } else if (adjacent[1] != false && adjacent[2] != false && adjacent[0] == false && adjacent[3] == false) {
      built = AIRoad.BuildDriveThroughRoadStation(tile, adjacent[1], AIRoad.ROADVEHTYPE_BUS, AIStation.STATION_NEW);
      builder.RoadBuilder(adjacent[2], AITown.GetLocation(town_id));
    } else {
      AILog.Info("This shouldnt happen");
    }
    if (built) {
      AILog.Info("DriveThroughStation built in: " + AITown.GetName(town_id));
      return true;
    } else {
      AILog.Info("DriveThroughStation building failed " + tile);
      return false;
    }
  }
}