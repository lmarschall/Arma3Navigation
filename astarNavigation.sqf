[] spawn
{
	_start = diag_tickTime;

	// Create Road Map 
	_roadMap = [];
	_nextRoads = [];		
	_finishedRoads = [];

	_startRoads = player nearRoads 10;
	_firstRoad = _startRoads select 0;
	_nextRoads pushBack _firstRoad;
		
	_iterationCounter = 0;

	while {count _nextRoads > 0 && _iterationCounter < 1000} do
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

	// // Create Local Markers to Indicate all Roads
	// {
		// // _streetMarker = "VR_3DSelector_01_exit_F" createVehicleLocal getPosATL(_x);
		// _mapMarker = createMarkerLocal [format["%1_marker",_x],visiblePosition _x];
		// _mapMarker setMarkerColorLocal "ColorRed";
		// _mapMarker setMarkerTypeLocal "Mil_dot";
		// _mapMarker setMarkerTextLocal format["%1", _x];
		// diag_log format["Marker: %1", _mapMarker];
	// } foreach _finishedRoads;

	diag_log format ["RoadMap: %1", _roadMap];

	// _stop = diag_tickTime;
	// diag_log format ["Time: %1, Iterations: %2", _stop - _start, _iterationCounter];
	
	// Run the A Star Algorithm
	
	// Get the Start
	_nearestRoads = player nearRoads 10;
	_startRoad = _nearestRoads select 0;
	
	diag_log format["%1", _startRoad];
	
	// Get the Destination
	_destinationMarker = allMapMarkers select ((count allMapMarkers) -1);
	_destinationRoad = (getMarkerPos(_destinationMarker) nearRoads 10) select 0;

	// Init
	_distanceArray = [];
	_workQueue = [];

	_distanceArray pushBack [_startRoad, 0, null];
	
	diag_log format["%1", _distanceArray];

	_visitedRoads = [];
	_visitedRoads pushBack _startRoad;
	_workQueue pushBack [0, _startRoad];

	_iterationCounter = 0;
	_targetReached = false;


	// _start = diag_tickTime;

	while { count _workQueue > 0 && _iterationCounter < 10000 && _targetReached IsEqualTo false} do
	{
		_workItem = _workQueue deleteAt 0;
		_actualRoad = _workItem select 1;
		if(_actualRoad == _destinationRoad) then {_targetReached = true};
		
		_connRoads = _roadMap select {(_x select 0) isEqualTo _actualRoad && !((_x select 1) in _visitedRoads)};
		
		{
			_road = _x select 0;
			_connRoad = _x select 1;
			_connDistance = _x select 2;
			
			_visitedRoads pushBack _connRoad;
			
			// Find Parent in Distance Array
			// diag_log format["%1", _distanceArray];
			_parent = _distanceArray select {(_x select 0 IsEqualTo _road)} select 0;
			// diag_log format["%1", _parent];
			_parentDistance = _parent select 1;
			// diag_log format["%1", _parentDistance];
			_heuretic = _connRoad distance _destinationRoad;
			// diag_log format["%1", _heuretic];
			
			_roadDistance = _connDistance + _parentDistance + _heuretic;
			// diag_log format["%1", _roadDistance];
			
			_distanceArray pushBack [_connRoad, _roadDistance, _road];
			_workQueue pushBack [_roadDistance, _connRoad];
			
		} foreach _connRoads;
		
		_iterationCounter = _iterationCounter +1;
		if(count _workQueue  > 0) then {_workQueue sort true;};
	
		// _stop = diag_tickTime;
		// diag_log format ["Time: %1, Iteration: %2", _stop - _start, _iterationCounter];
	};

	// Now Finding the Shortest Path to Destination
	_destinationPath = [];
	_destinationLength = 0;

	_startNode = _distanceArray select 0;

	// Find DestinationRoad in Array
	_selectedNode = _distanceArray select {_x select 0 == _destinationRoad} select 0;

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
		_selectedNode = _distanceArray select {_x select 0 == _nodeParent} select 0;
	};

	_destinationPath pushBack (_startNode select 0);

	// Create Local Markers to navigate to destination
	{
		_roadMarker = "VR_3DSelector_01_exit_F" createVehicleLocal getPosATL(_x);
	} foreach _destinationPath;
	
	_stop = diag_tickTime;
	diag_log format ["Time: %1, Count DestinationPath: %2", _stop - _start, count _destinationPath];

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
}