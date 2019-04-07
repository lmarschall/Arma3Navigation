// Create Road Map 
_roadMap = [];
_nextRoads = [];		
_finishedRoads = [];

_startRoads = player nearRoads 10;
_firstRoad = _startRoads select 0;
_nextRoads pushBack _firstRoad;
	
_iterationCounter = 0;

while {_iterationCounter < 1000} do
{	
	_nextRoad = _nextRoads deleteAt 0;	
	_connectedRoads = roadsConnectedTo _nextRoad;
	
	{
		_distance = _x distance _nextRoad;
		_roadMap pushBack [_nextRoad, _x, _distance];
		
		if((_finishedRoads find _x) == -1) then
		{
			_nextRoads pushBack _x;
		};
		
	} foreach _connectedRoads;
	
	_finishedRoads pushBack _nextRoad;	
	_iterationCounter = _iterationCounter +1;
};

diag_log format ["RoadMap: %1", _roadMap];

// Run the Dijkstra Algorithm
_startRoads = player nearRoads 10;
_startRoad = _startRoads select 0;

// Init Distances
_distanceArray = [];
_workQueue = [];

_distanceArray pushBack [_startRoad, 0, null];

_visitedRoads = [];
_visitedRoads pushBack _startRoad;
_workQueue pushBack [0, _startRoad];

_itC = 0;
_timeArray = [];

_start = diag_tickTime;

while { count _workQueue > 0} do
{
	_workItem = _workQueue deleteAt 0;
	_actualRoad = _workItem select 1;
	
	_itC = _itC +1;
	
	_connRoads = _roadMap select {(_x select 0) isEqualTo _actualRoad && !((_x select 1) in _visitedRoads)};
	
	{
		_road = _x select 0;
		_connRoad = _x select 1;
		_connDistance = _x select 2;
		
		_visitedRoads pushBack _connRoad;
		_roadDistance = _connDistance;
		
		// Find Parent in Distance Array
		_parents = _distanceArray select {(_x select 0 IsEqualTo _road)};
		
		{
			_parentRoad = _x select 0;
			_parentDistance = _x select 1;
			_parentParent = _x select 2;
			
			_roadDistance = _roadDistance + _parentDistance;
			
			
		} foreach _parents;
		
		_distanceArray pushBack [_connRoad, _roadDistance, _road];
		_workQueue pushBack [_roadDistance, _connRoad];
		
	} foreach _connRoads;
	
	// diag_log format ["Result: %1", _result];
	
	
	
	
	// // Get the connected Roads out the RoadMap
	// {
		// _road = _x select 0;
		// _connRoad = _x select 1;
		// _connDistance = _x select 2;
		
		// if ((_road == _actualRoad) && !(_connRoad in _visitedRoads)) then	// Find Connected Roads, not yet visited
		// {
			// _visitedRoads pushBack _connRoad;					// Save connected road as visited
			
			// // Calculate Distance between the Roads
			// _roadDistance = _connDistance;
			
			// // Search for Parent in Distance Array and get his Distance
			// {
				// _parentRoad = _x select 0;
				// _parentDistance = _x select 1;
				// _parentParent = _x select 2;
				
				// if(_parentRoad == _road) then 
				// {
					// _roadDistance = _roadDistance + _parentDistance;		// Add distance of parent to new distance
				// };
				
			// } foreach _distanceArray;
			
			// // Save new Road in Distance Array
			// _distanceArray pushBack [_connRoad, _roadDistance, _road];	// Add connected road to Distance Array
			// _workQueue pushBack [_roadDistance, _connRoad];				// Add connected road to queue
		// };
		
	// } forEach _roadMap;
	
	if(count _workQueue  > 0) then {_workQueue sort true;};
};

_stop = diag_tickTime;
diag_log format ["Time: %1, Iteration: %2", _stop - _start, _itC];

// diag_log str _itC;
// diag_log format ["Number of Iterations: %1, TimeArray: %2", _itC, _timeArray];

// Now Finding the Shortest Path to Destination
_destinationPath = [];
_destinationLength = 0;

_startNode = _distanceArray select 0;

// Get the Destination Node from Marker
_destinationMarker = allMapMarkers select ((count allMapMarkers) -1);

_nearestDestinationRoad = (getMarkerPos(_destinationMarker) nearRoads 10) select 0;

_selectedNode = [];

// Find DestinationRoad in Array
{
	_nodeRoadx = _x select 0;
	
	if(_nodeRoadx == _nearestDestinationRoad) then
	{
		_selectedNode = _x;
	}
} foreach _distanceArray;

// Get the Distance to Destination
_destinationLength = _selectedNode select 1;

diag_log format ["StartNode: %1, SelectNode: %2, DestinationLength: %3", _startNode, _selectedNode, _destinationLength];

// Get the Path to Destination
while{!(_selectedNode isEqualTo _startNode)} do
{
	_nodeRoad = _selectedNode select 0;			// Select the Road in the Node
	_destinationPath pushBack _nodeRoad;		// Save the Road in the Path
	_nodeParent = _selectedNode select 2;		// Node Parent to find	
	
	// Find Node Parent in Distance Array
	{
		_nodeRoadx = _x select 0;
		
		if(_nodeRoadx == _nodeParent) then
		{
			_selectedNode = _x;
		}
	} foreach _distanceArray;
};

_destinationPath pushBack (_startNode select 0);

// Create Local Markers to navigate to the path
{
	_streetMarker = "VR_3DSelector_01_exit_F" createVehicleLocal getPosATL(_x);
	// _mapMarker = createMarkerLocal ["markername",[getPos(_x select 0) select 0,getPos(_x select 0) select 1]];
	// _mapMarker setMarkerShapeLocal "ICON";m
	// _mapMarker setMarkerTypeLocal "DOT";
} foreach _destinationPath;

// Delete Local Markers when passing them
[] spawn {
	while{true} do
	{
		_nearestObjects = nearestObjects [player, [], 10];
		{
			if(typeOf _x == "VR_3DSelector_01_exit_F") then
			{
				deleteVehicle _x;
			}		
		} foreach _nearestObjects;
		sleep 0.1;
	}
}