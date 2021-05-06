import("pathfinder.road", "RoadPathFinder", 3);


class Line {
    towns = null;
    stations = null;
    depot = null;
    buses = null;
    needed_buses = null;
    groupID = null
    vehicles = null;
    busesToRemove = null;

    constructor() {
        towns = [];
        stations = [];
        depot = null;
        buses = [];
        needed_buses = 0;
        groupID = null;
        vehicles = null;
        busesToRemove = AIVehicleList();
        busesToRemove.Clear();
    }

    function CreateNewLine(town_pair);
    function AddDepot(tile);
    function AddBuses(depot, amount);
    function EstimateBusesNeeded(station1, station2);
    function MangeBuses();
    function GetNewestBus();
    function SetupBus(bus);
}

function Line::CreateNewLine(town_pair)
{
    local manager = TownManager();
    if (town_pair.len() != 0) {
        for (local i = 0; i < town_pair.len(); i++) {
            towns.append(town_pair[i]);
        }
    }

    if (towns.len() != 0) {
        AILog.Info("Creating line between: " + AITown.GetName(towns[0]) + " and " + AITown.GetName(towns[1]));
        local stops = [];
        local builtstation = [];
        AILog.Info("Looking for station location in: " + AITown.GetName(towns[0]));
        stops.append(manager.FindStationLocation(town_pair[0]));
        AILog.Info("Looking for station location in: " + AITown.GetName(towns[1]));
        stops.append(manager.FindStationLocation(town_pair[1]));
        if (stops[0] && stops[1]) {
            builtstation.append(manager.BuildStation(stops[0], town_pair[0]));
            if (builtstation.top() != false) {
                stations.append(stops[0]);
                builtstation.append(manager.BuildStation(stops[1], town_pair[1]));
                if (builtstation.top() == false) {
                    AILog.Info("Failed to build second station");
                    stations.pop();
                    AIRoad.RemoveRoadStation(stops[0]);
                    return false;
                }
                stations.append(stops[1]);
            } else {
                AILog.Info("Failed to build first station");
                return false;
            }

        } else {
            AILog.Info("Station location finding failed");
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
        built = AddDepot(stations[0]);
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
    this.groupID = AIGroup.CreateGroup(AIVehicle.VT_ROAD);
    if (AIGroup.IsValidGroup(this.groupID)) {
        local newName = AIStation.GetName(AIStation.GetStationID(this.stations[0])) + "-" + AIStation.GetName(AIStation.GetStationID(this.stations[1]));
        newName = newName.slice(0, min(newName.len(), 30));
        local named = AIGroup.SetName(this.groupID, newName);
        if (named) {
            this.needed_buses = EstimateBusesNeeded(this.stations[0], this.stations[1]);
            this.needed_buses = AddBuses(this.depot, this.needed_buses);
            for (local i = 0; i < buses.len(); i++) {
               SetupBus(this.buses[i]);
            }
        }
    } else {
        AILog.Info("Group creation failed");
        return false;
    }

    return true;
}

function Line::AddDepot(tile)
{
    local builder = Builder();
    local searchedArea = AITileList();
    local built = false;
    local depos = AIDepotList(AITile.TRANSPORT_ROAD);

    searchedArea.AddRectangle(tile + AIMap.GetTileIndex(-15, -15), tile + AIMap.GetTileIndex(15, 15));

    searchedArea.Valuate(AIRoad.IsRoadDepotTile);
    searchedArea.KeepValue(1);

    if(!searchedArea.IsEmpty()) {
        for (local i = searchedArea.Begin(); searchedArea.HasNext(); i = searchedArea.Next()) {
            if (depos.HasItem(i)) {
                AILog.Info("Existing depot found");
                return i;
            }
        }
    }
    local newDepot = AITileList();
    newDepot.AddRectangle(tile + AIMap.GetTileIndex(-8, -8), tile + AIMap.GetTileIndex(8, 8));
    if (!newDepot.IsEmpty()) {
        newDepot.Valuate(AIRoad.GetNeighbourRoadCount);
        newDepot.KeepAboveValue(0);
        if (!newDepot.IsEmpty()) {
            newDepot.Valuate(AITile.GetSlope);
            newDepot.KeepValue(0);
            if (!newDepot.IsEmpty()) {
                newDepot.Valuate(AIRoad.IsRoadTile);
                newDepot.KeepValue(0);
                if (!newDepot.IsEmpty()) {
                    newDepot.Valuate(AITile.GetDistanceManhattanToTile, AITown.GetLocation(towns[1]));
                    newDepot.Sort(AITileList.SORT_BY_VALUE, AITileList.SORT_ASCENDING);
                    for (local i = newDepot.Begin(); newDepot.HasNext(); i = newDepot.Next()) {
                        local adjacentTiles = builder.GetAdjacentTiles(i);
                        for (local j = adjacentTiles.Begin(); adjacentTiles.HasNext(); j = adjacentTiles.Next()) {
                            if (AIRoad.IsRoadTile(j) && !AITile.GetSlope(j) && !AIRoad.IsRoadStationTile(j)) {
                                if (!AITile.IsBuildable(i)) {
                                    AITile.DemolishTile(i);
                                }
                                if (AITile.IsBuildable(i)) {
                                    built = AIRoad.BuildRoadDepot(i, j);
                                    AIRoad.BuildRoad(j, i);
                                    if (built) {
                                        builder.RoadBuilder(i, tile)
                                        return i;
                                    }
                                }
                            }
                        }
                    }
                } else {
                    AILog.Info("Could not Find tile that is not road");
                }
            } else {
                AILog.Info("Could not find tile that is not slope");
            }
        } else {
            AILog.Info("Could not find tile next to road");
        }
    } else {
        AILog.Info("Could not fill Tile List");
    }
    if (!built) {
        AILog.Info("Depot building failed");
        return null;
    }
}

function Line::GetNewestBus()
{
    local engineList= AIEngineList(AIVehicle.VT_ROAD);
    local model = null

    engineList.Valuate(AIEngine.GetRoadType);
    engineList.KeepValue(AIRoad.ROADTYPE_ROAD);

    engineList.Valuate(AIEngine.GetCargoType);
    engineList.KeepValue(0);

    if (!engineList.IsEmpty()) {
        engineList.Valuate(AIEngine.GetCapacity);
        engineList.Sort(AIList.SORT_BY_VALUE, AIList.SORT_DESCENDING);
        model = engineList.Begin();
    } else {
        AILog.Info("No compatible bus model found");
        return null;
    }
    return model;
}

function Line::AddBuses(depot, amount)
{
    local model = null;
    local newBus;

    model = GetNewestBus();

    if (model == null) {
        AILog.Info("No engines available");
        return amount;
    }

    local busesBuilt = 0;
    for (local i = 0; i < amount; i++) {
        newBus = AIVehicle.BuildVehicle(depot, model);

        local er = AIError.GetLastError();

        if (AIVehicle.IsValidVehicle(newBus)) {
            this.buses.append(newBus);
            busesBuilt++;
        } else {
            if (er != AIError.ERR_NOT_ENOUGH_CASH) {
                amount = amount - 1;
            }
            AILog.Info("Bus building failed");
        }
    }
    amount = amount - busesBuilt;
    if (amount != 0) {
        AILog.Info("Failed to build: " + amount + " buses.");
    }
    return amount;
}

function Line::EstimateBusesNeeded(station1, station2)
{
    if(!station1 || !station2) {
        return 0;
    }
    local manager = TownManager();
    local acceptance = manager.GetStationAcceptance(station1) + manager.GetStationAcceptance(station2);
    local distance = AIMap.DistanceManhattan(station1, station2);
    // AILog.Info("Estimate: distance: " + distance + " acceptance: " + acceptance);
    local estimatedBuses = 2 + (acceptance/35) * (distance/35);
    if (estimatedBuses > 25) {
        estimatedBuses = 10;
    }
    // AILog.Info("Needed buses: " + estimatedBuses);
    return estimatedBuses;
}

function Line::SetupBus(bus) {
    AIGroup.MoveVehicle(this.groupID, bus);

    AIOrder.AppendOrder(bus, this.depot, AIOrder.AIOF_SERVICE_IF_NEEDED);
    AIOrder.AppendOrder(bus, this.stations[0], AIOrder.AIOF_NONE);
    AIOrder.AppendOrder(bus, this.stations[1], AIOrder.AIOF_NONE);

    AIVehicle.StartStopVehicle(bus);
}

function Line::ManageBuses() {
    if (!this.busesToRemove.IsEmpty()) {
        for (local i = busesToRemove.Begin(); busesToRemove.HasNext(); i = busesToRemove.Next()) {
            if (AIVehicle.IsStoppedInDepot(i)) {
                local sold = AIVehicle.SellVehicle(i);
                if (sold) {
                    busesToRemove.RemoveItem(i);
                    AILog.Info("Sold bus in depot");
                }
            }
        }
    }
    if (this.needed_buses != 0) {
        AILog.Info("Building additional buses");
        this.needed_buses = AddBuses(this.depot, this.needed_buses);
        for (local i = 0; i < this.buses.len(); i++) {
            if (AIVehicle.IsStoppedInDepot(this.buses[i])) {
                SetupBus(this.buses[i]);
            }
        }
    } else {
        local newEstimate = EstimateBusesNeeded(this.stations[0], this.stations[1]);
        if (this.buses.len() < newEstimate) {
            AILog.Info("Adding additional buses to line");
            this.needed_buses = AddBuses(this.depot, (newEstimate - this.buses.len()));
            for (local i = 0; i < this.buses.len(); i++) {
                if (AIVehicle.IsStoppedInDepot(this.buses[i])) {
                    SetupBus(this.buses[i]);
                }
            }
        } else if (this.buses.len() > newEstimate) {
            AILog.Info("Removing Vehicles from line");
            for (local i = 0; i < (this.buses.len() - newEstimate); i++) {
                local removedBus = this.buses.pop();
                AIVehicle.SendVehicleToDepot(removedBus);
                this.busesToRemove.AddItem(removedBus, 0);
            }
        }
        for (local i = 0; i < this.buses.len(); i++) {
            if (AIVehicle.GetAgeLeft(this.buses[i]) <= 366) {
                AILog.Info("Renewing Vehicles");
                local newmodel = GetNewestBus();
                local oldmodel = AIVehicle.GetEngineType(this.buses[i]);
                if (oldmodel == newmodel) {
                    local cloned = AIVehicle.CloneVehicle(this.depot, this.buses[i], true);
                    if (AIVehicle.IsValidVehicle(cloned)) {
                        local oldBus = this.buses[i];
                        AIVehicle.SendVehicleToDepot(oldBus);
                        this.busesToRemove.AddItem(oldBus, 0);
                        this.buses[i] = cloned;
                        AIVehicle.StartStopVehicle(cloned);
                    } else {
                        AILog.Info("Failed to clone vehicle");
                    }
                } else {
                    local oldBus = this.buses[i];
                    AIVehicle.SendVehicleToDepot(oldBus);
                    this.busesToRemove.AddItem(oldBus, 0);
                    local newBus = AIVehicle.BuildVehicle(this.depot, newmodel);
                    if (AIVehicle.IsValidVehicle(newBus)) {
                        this.buses[i] = newBus;
                        SetupBus(newBus);
                    } else {
                        AILog.Info("Failed to build new vehicle");
                    }
                }
            }
        }
    }
    return;
}