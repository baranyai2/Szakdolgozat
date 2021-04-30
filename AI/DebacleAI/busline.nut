import("pathfinder.road", "RoadPathFinder", 3);


class Line {
    towns = null;
    stations = null;
    depot = null;
    buses = null;
    needed_buses = null;

    constructor() {
        towns = [];
        stations = [];
        depot = null;
        buses = [];
        needed_buses = 0;
    }

    function CreateNewLine(town_pair);
    function AddDepot(tile);
    function AddBuses();
    function EstimateBusesNeeded(station1, station2);
    function MangeBuses();
}

function Line::CreateNewLine(town_pair)
{
    local manager = TownManager();
    for (local i = 0; i < town_pair.len(); i++) {
        towns.append(town_pair[i]);
    }

    if (town_pair) {
        AILog.Info("Creating line between: " + AITown.GetName(towns[0]) + " and " + AITown.GetName(towns[1]));
        local stops = [];
        local builtstation = [];
        AILog.Info("Looking for station location in: " + AITown.GetName(towns[0]));
        stops.append(manager.FindStationLocation(town_pair[0]));
        AILog.Info("Looking for station location in: " + AITown.GetName(towns[1]));
        stops.append(manager.FindStationLocation(town_pair[1]));
        if (stops[0] && stops[1]) {
            builtstation.append(manager.BuildStation(stops[0], town_pair[0]));
            builtstation.append(manager.BuildStation(stops[1], town_pair[1]));
        } else {
            AILog.Info("Station location finding failed");
            return false;
        }
        if (builtstation.len()) {
            stations.append(stops[0]);
            stations.append(stops[1]);
        } else {
            AILog.Info("Stations not built");
            return false;
        }
    } else {
        AILog.Info("Town pair not valid");
        return false;
    }

    local connect = false;
    local builder = Builder();
    connect = builder.RoadBuilder(AITown.GetLocation(town_pair[0]), AITown.GetLocation(town_pair[1]));

    if (!connect) {
        AILog.Info("Failed to connect towns");
        return false;
    } else {
        AILog.Info("Town connection successful");
    }

    if(connect && stations.len()) {
        local built = false;
        built = this.AddDepot(stations[0]);
        if (!built){
            AILog.Info("Failed to build depot")
            return false;
        } else {
            this.depot = built;
        }
    } else {
        AILog.Info("Create line failed");
        return false;
    }

    this.AddBuses();
    return true;
}

function Line::AddDepot(tile)
{
    local builder = Builder();
    local found = false;
    local success = false;
    local tl = AITileList();
    local it = null;
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
                                found = builder.RoadBuilder(it, AITown.GetLocation(towns[1]));
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

    if (needed_buses == 0) {
        needed_buses = this.EstimateBusesNeeded(this.stations[0], this.stations[1])
    }

    local buses_built = 0;
    for (local i = 0; i < needed_buses; i++)
    {
        new_bus = AIVehicle.BuildVehicle(this.depot, model);

        local er = AIError.GetLastError();

        if(AIVehicle.IsValidVehicle(new_bus)){
            this.buses.append(new_bus);

            local bus = this.buses[i];

            AIOrder.AppendOrder(bus, this.depot, AIOrder.AIOF_SERVICE_IF_NEEDED);
            AIOrder.AppendOrder(bus, this.stations[0], AIOrder.AIOF_NONE);
            AIOrder.AppendOrder(bus, this.stations[1], AIOrder.AIOF_NONE);

            AIVehicle.StartStopVehicle(bus);
            buses_built++;
        } else {
            if (er != AIError.ERR_NOT_ENOUGH_CASH) {
				needed_buses = needed_buses - 1;
			}
            AILog.Info("Bus building failed");
            AILog.Info(AIError.GetLastErrorString());
        }
    }
    needed_buses = needed_buses - buses_built;
    AILog.Info("Buses failed to build: " + needed_buses);
}

function Line::EstimateBusesNeeded(station1, station2)
{
    if(!station1 || !station2) {
        return 0;
    }
    local acceptance = AITile.GetCargoAcceptance(station1, 0, 1, 1, AIStation.GetCoverageRadius(AIStation.STATION_BUS_STOP)) +
        AITile.GetCargoAcceptance(station2, 0, 1, 1, AIStation.GetCoverageRadius(AIStation.STATION_BUS_STOP));
    local distance = AIMap.DistanceManhattan(station1, station2);
    AILog.Info("Estimate: distance: " + distance + " acceptance: " + acceptance);
    local needed_buses = 2 + (acceptance/35) * (distance/35);
    if (needed_buses > 10 ) {
        needed_buses = 10;
    }
    AILog.Info("Needed buses: " + needed_buses);
    return needed_buses;
}

function Line::ManageBuses() {
    if (needed_buses != 0) {
        AILog.Info("Building additional buses");
        AddBuses();
    }
    return;
}