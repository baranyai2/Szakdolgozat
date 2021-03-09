import("pathfinder.road", "RoadPathFinder", 3);


class Line {
    towns = null;
    stations = null;
    depot = null;
    buses = null;

    constructor() {
        towns = [];
        stations = [];
        depot = null;
        buses = [];
    }

    function CreateNewLine(town_pair);
    function AddDepot(tile);
    function AddBuses();
}

function Line::CreateNewLine(town_pair)
{
    local manager = TownManager();
    for (local i = 0; i < town_pair.len(); i++) {
        towns.append(town_pair[i]);
    }

    if (town_pair) {
        local stops = [];
        local builtstation = [];
        stops.append(manager.FindStationLocation(town_pair[0]));
        stops.append(manager.FindStationLocation(town_pair[1]));
        if (stops[0] && stops[1]) {
            builtstation.append(manager.BuildStation(stops[0]));
            builtstation.append(manager.BuildStation(stops[1]));
        }
        if (builtstation[0] && builtstation[1]) {
            stations.append(builtstation[0]);
            stations.append(builtstation[1]);
        }
    } else {
        AILog.Info("Failed to build bus stops");
    }

    local connect = false;
    local builder = Builder();
    connect = builder.RoadBuilder(AITown.GetLocation(town_pair[0]), AITown.GetLocation(town_pair[1]));

    if (!connect) {
        AILog.Info("Failed to connect towns");
    } else {
        AILog.Info("Town connection successful");
    }

    if(connect && stations[0] && stations[1]) {
        local built = false;
        built = this.AddDepot(stations[0]);
        if (!built){
            AILog.Info("Failed to build depot")
        } else {
            this.depot = built;
        }
    }

    this.AddBuses();
}

function Line::AddDepot(tile)
{
    local builder = Builder();
    local found = false;
    local success = false;
    local tl = AITileList();
    local it = null;
    AILog.Info(tile);
    tl.AddRectangle(tile + AIMap.GetTileIndex(-10, -10), tile + AIMap.GetTileIndex(10, 10));
    if(tl.Count()) {
        if (tl.Count()) {
            tl.Valuate(AIRoad.GetNeighbourRoadCount);
            tl.KeepAboveValue(0);
        }
        if (tl.Count()) {
            tl.Valuate(AIRoad.IsRoadTile);	
            tl.KeepValue(0);
	   }
       if (tl.Count()) {
           tl.Valuate(AITile.GetSlope);
           tl.KeepValue(0);
       }
       if (tl.Count()) {
            tl.Valuate(AITile.GetDistanceManhattanToTile, AITown.GetLocation(towns[1]));
            tl.Sort(AITileList.SORT_BY_VALUE, true);

            for (it = tl.Begin(); tl.HasNext() && !success; it = tl.Next()) 
            {
                local adjacentTiles = builder.GetAdjacentTiles(it);
                for(local tile2 = adjacentTiles.Begin(); adjacentTiles.HasNext(); tile2 = adjacentTiles.Next()) {
                    if(AIRoad.IsRoadTile(tile2) && !AITile.GetSlope(tile2) && !AIRoad.IsRoadStationTile(tile2)) {
                        found = AITile.IsBuildable(it);
                        AILog.Info("Depot Location found");
                        if (!found) {
                            found = AITile.DemolishTile(it);
                        }
                        if (found) {
                            success = AIRoad.BuildRoadDepot(it, tile2);
                            if (success) {
                                found = builder.RoadBuilder(it, tile2);
                            }
                        }
                    }
                    if(found) break;
                }
                if(found) break;
            }
        }
    }
    if (found) return it;
    else return null;
}

function Line::AddBuses()
{
    local model = null;
    local engine_list = AIEngineList(AIVehicle.VT_ROAD);
    local new_bus;

    engine_list.Valuate(AIEngine.GetRoadType);
    engine_list.KeepValue(AIRoad.ROADTYPE_ROAD);

    engine_list.Valuate(AIEngine.GetCargoType);
    engine_list.KeepValue(0);

    engine_list.Valuate(AIEngine.GetCapacity);
    engine_list.KeepTop(1);

    model = engine_list.Begin();

    new_bus = AIVehicle.BuildVehicle(this.depot, model);
    if(AIVehicle.IsValidVehicle(new_bus)){
        this.buses.append(new_bus);

        AILog.Info(this.buses[0]);
        local bus = this.buses[0];

        AIOrder.AppendOrder(bus, this.depot, AIOrder.AIOF_SERVICE_IF_NEEDED);
        AIOrder.AppendOrder(bus, this.stations[0], AIOrder.AIOF_NONE);
        AIOrder.AppendOrder(bus, this.stations[1], AIOrder.AIOF_NONE);

        AIVehicle.StartStopVehicle(bus);
    } else {
        AILog.Info("Bus building failed");
        AILog.Info(AIError.GetLastErrorString());
    }
    
}