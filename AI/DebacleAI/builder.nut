import("pathfinder.road", "RoadPathFinder", 3);

class Builder
{
  function RoadBuilder(start, goal);
  function GetAdjacentTiles(tile);
}

function Builder::RoadBuilder(start, goal)
{
  if (start == null || goal == null){
    AILog.Info("There are no tiles");
    return false;
  }

  AIRoad.SetCurrentRoadType(AIRoad.ROADTYPE_ROAD);
  local pathfinder = RoadPathFinder();
  pathfinder.InitializePath([start], [goal]);

  local path = false;
  while (path == false) {
    path = pathfinder.FindPath(100);
    AIController.Sleep(1);
  }

  if (path == null) {
    AILog.Error("pathfinder.FindPath return null");
  }
  while (path != null) {
    local par = path.GetParent();
    if (par != null) {
      local last_node = path.GetTile();
      if (AIMap.DistanceManhattan(path.GetTile(), par.GetTile()) == 1 ) {
        AIRoad.BuildRoad(path.GetTile(), par.GetTile());
      } else {
        if (!AIBridge.IsBridgeTile(path.GetTile()) && !AITunnel.IsTunnelTile(path.GetTile())) {
          if (AIRoad.IsRoadTile(path.GetTile())) AITile.DemolishTile(path.GetTile());
          if (AITunnel.GetOtherTunnelEnd(path.GetTile()) == par.GetTile()) {
            if (!AITunnel.BuildTunnel(AIVehicle.VT_ROAD, path.GetTile())) {
            }
          } else {
            local bridge_list = AIBridgeList_Length(AIMap.DistanceManhattan(path.GetTile(), par.GetTile()) + 1);
            bridge_list.Valuate(AIBridge.GetMaxSpeed);
            bridge_list.Sort(AIAbstractList.SORT_BY_VALUE, false);
            if (!AIBridge.BuildBridge(AIVehicle.VT_ROAD, bridge_list.Begin(), path.GetTile(), par.GetTile())) {
            }
          }
        }
      }
    }
    path = par;
  }
  return true;
}

function Builder::GetAdjacentTiles(tile)
{
	local adjTiles = AITileList();

	adjTiles.AddTile(tile - AIMap.GetTileIndex(1,0));
	adjTiles.AddTile(tile - AIMap.GetTileIndex(0,1));
	adjTiles.AddTile(tile - AIMap.GetTileIndex(-1,0));
	adjTiles.AddTile(tile - AIMap.GetTileIndex(0,-1));

	return adjTiles;
}