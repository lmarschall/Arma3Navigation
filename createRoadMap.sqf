[] spawn
{
	while{true} do
	{
		_nearRoads = player nearRoads 20;
		_roadDistances = [];
		
		{
			_road = _x;
			_roadDistance = player distance _road;
			_roadDistances pushBack [_roadDistance, _road];
		
		} foreach _nearRoads;
		
		_roadDistances sort true;				
		_nearestRoad = (_roadDistances select 0) select 1;	
		_connectedRoads = roadsConnectedTo _nearestRoad;
		
		// Create Local Markers to navigate to destination
		_roadMarker = "VR_3DSelector_01_exit_F" createVehicleLocal getPosATL(_nearestRoad);
		
		hintSilent format["Nearest Road: %1\nRoad Conntect To: %2", _nearestRoad, _connectedRoads];
		sleep(0.1);
		deleteVehicle _roadMarker;
	}
}

[] spawn
{
	while{true} do
	{
		_nearRoads = [];
		_range = 0;
		
		while{count _nearRoads == 0} do
		{
			_range = _range +1;
			_nearRoads = player nearRoads _range;
		};
		
		_nearestRoad = _nearRoads select 0;
		_connectedRoads = roadsConnectedTo _nearestRoad;
		
		// Create Local Markers to navigate to destination
		_roadMarker = "VR_3DSelector_01_exit_F" createVehicleLocal getPosATL(_nearestRoad);
		
		hintSilent format["Nearest Road: %1\nRoad Conntect To: %2", _nearestRoad, _connectedRoads];
		sleep(0.1);
		deleteVehicle _roadMarker;
	}
}


[] spawn
{
	// Create Road Map
	
	_start = diag_tickTime;
	
	_roads = [];
	_finishedCrossways = [];
	_visitedCrossways = [];
	_islandRoads = [];
	
	_crosswayMap = [];
	_firstCrossway = objNull;
	
	// Get the Start Point
	_nearPlayerRoads = player nearRoads 20;
	_startRoad = _nearPlayerRoads select 0;
	// _destinationMarker = allMapMarkers select ((count allMapMarkers) -1);
	// _destinationRoad = (getMarkerPos(_destinationMarker) nearRoads 20) select 0;
	
	_finishedRoads = [];
	_roadQueue = [];
	_roadQueue pushBack _startRoad;
	
	_itCounter = 0;
	
	// Find First Crossway
	while { IsNull _firstCrossway} do
	{
		_handleRoad = _roadQueue deleteAt 0;
		_connectedRoads = roadsConnectedTo _handleRoad;
		
		if(count _connectedRoads > 2) then {_firstCrossway = _handleRoad;};
		
		{
			_connectedRoad = _x;
			
			if((_finishedRoads find _connectedRoad) == -1 ) then
			{
				_roadQueue pushBack _connectedRoad;
			};
		
		} foreach _connectedRoads;
		
		_finishedRoads pushBack _handleRoad;	
		_itCounter = _itCounter+1;
	};
	
	_finishedRoads = [];
	_crosswayQueue = [];
	_crosswayQueue pushBack _firstCrossway;
	_visitedCrossways pushBack _firstCrossway;
	
	// Loop through all connected Crossways
	while {count _crosswayQueue > 0} do
	{	
		_handleCrossway = _crosswayQueue deleteAt 0;
		_connectedCrosswayRoads = roadsConnectedTo _handleCrossway;
		
		// diag_log format ["Crossway Queue: %1", _crosswayQueue];
		// diag_log format ["Finished Crossways: %1", _finishedCrossways];
		// diag_log format ["Handle Crossway: %1", _handleCrossway];
		// diag_log format ["Connection Crossway Roads: %1", _connectedCrosswayRoads];
		
		{
			_handleNextCrossway = _x;
			
			// diag_log str "Init Road Values";
			
			_roads = [];
			_finishedRoads = [];
			_crossways = [];
			_roadQueue = [];
			_roadLength = 0;
			
			// diag_log format["Roads: %1", _roads];
			// diag_log format["Finished Roads: %1", _finishedRoads];
			// diag_log format["Crossways: %1", _crossways];
			// diag_log format["Road Queue: %1", _roadQueue];
			// diag_log format["Road Length: %1", _roadLength];
			// diag_log format ["Handle Crossway: %1", _handleCrossway];
			// diag_log format ["Handle Next Crossway: %1", _handleNextCrossway];
			
			_pos = _connectedCrosswayRoads find _handleNextCrossway;
			_finishedRoads append _connectedCrosswayRoads;
			_finishedRoads deleteAt _pos;
			
			// diag_log format ["Finished Roads: %1", _finishedRoads];
			// 
			// diag_log format ["Handle Next Crossway Road: %1", _handleNextCrosswayRoad];
			
			_roadQueue pushBack _handleCrossway;
		
			// Find next Crossways of Street
			while {count _roadQueue > 0} do
			{
				_handleRoad = _roadQueue deleteAt 0;
				_connectedRoads = roadsConnectedTo _handleRoad;
				
				// diag_log format ["Handle Road: %1", _handleRoad];
				// diag_log format ["Connected Roads: %1", _connectedRoads];
				// diag_log format ["Finished Roads: %1", _finishedRoads];
				
				if(count _connectedRoads > 2) then { _crossways pushBack _handleRoad;};
				
				if(count _crossways < 2) then {
					{
						_connectedRoad = _x;
						
						if((_finishedRoads find _connectedRoad) == -1) then
						{
							_roadQueue pushBack _connectedRoad;
							_distance = _connectedRoad distance _handleRoad;
							_roads pushBack [_handleRoad, _connectedRoad, _distance];
							_roadLength = _roadLength + _distance;
						};
					
					} foreach _connectedRoads;
				};
				
				// _mapMarker = createMarkerLocal [format["%1_marker", _handleRoad],visiblePosition _handleRoad];
				// _mapMarker setMarkerTextLocal format["%1", _handleRoad];
				// _mapMarker setMarkerTypeLocal "Mil_dot";
			
				// if(_handleRoad in _crossways) then {_mapMarker setMarkerColorLocal "ColorRed"} else {_mapMarker setMarkerColorLocal "ColorGreen"};
				
				// diag_log format ["Crossways: %1", _crossways];
				// diag_log format ["Length: %1", _roadLength];
				// diag_log format ["Roads: %1", _roads];
				// diag_log str "End of Road Queue";
				// diag_log format ["Finished Roads: %1", _finishedRoads];
				// diag_log format ["Finished Crossways: %1", _finishedCrossways];
				// diag_log format ["Road Queue: %1", _roadQueue];
				// diag_log format ["CrosswayQueue: %1", _crosswayQueue];
				_finishedRoads pushBack _handleRoad;
				_itCounter = _itCounter+1;
			};
			
			// diag_log format ["Crossways: %1", _crossways];
			// diag_log format ["Length: %1", _roadLength];
			// diag_log format ["Roads: %1", _roads];
			
			if(count _crossways > 1) then {_crosswayMap pushBack [_crossways select 0, _crossways select 1, _roadLength];};
			_islandRoads pushBack _roads;
			
			if((_visitedCrossways find (_crossways select 1)) == -1) then
			{
				_crosswayQueue pushBack (_crossways select 1);
				_visitedCrossways pushBack (_crossways select 1);
			};
			
		} foreach _connectedCrosswayRoads;
		
		// diag_log str "End of Crossway Queue";
		// diag_log format ["Finished Roads: %1", _finishedRoads];
		// diag_log format ["Finished Crossways: %1", _finishedCrossways];
		// diag_log format ["Road Queue: %1", _roadQueue];
		// diag_log format ["CrosswayQueue: %1", _crosswayQueue];
	};
	
	// copyToClipboard str _islandRoads;
	
	_stop = diag_tickTime;
	diag_log format ["Create RoadMap Time: %1", _stop - _start];
	_start = diag_tickTime;
	
	// Find Destination Road
	_destinationMarker = allMapMarkers select ((count allMapMarkers) -1);
	_nearestDestinationRoad = (getMarkerPos(_destinationMarker) nearRoads 20) select 0;
	
	_destinationCrossway = ObjNull;
	_finishedRoads = [];
	_roadQueue = [];
	_roadQueue pushBack _nearestDestinationRoad;
	
	// Find Destination Crossway
	while { IsNull _destinationCrossway} do
	{
		_handleRoad = _roadQueue deleteAt 0;
		_connectedRoads = roadsConnectedTo _handleRoad;
		
		if(count _connectedRoads > 2) then {_destinationCrossway = _handleRoad;};
		
		{
			_connectedRoad = _x;
			
			if((_finishedRoads find _connectedRoad) == -1 ) then
			{
				_roadQueue pushBack _connectedRoad;
			};
		
		} foreach _connectedRoads;
		
		_finishedRoads pushBack _handleRoad;	
		_itCounter = _itCounter+1;
	};
	
	// Run the A Star Algorithm

	// Init
	_distanceArray = [];
	_workQueue = [];

	_distanceArray pushBack [_firstCrossway, 0, objNull];

	_finishedCrossways = [];
	_finishedCrossways pushBack _firstCrossway;
	_workQueue pushBack [0, _firstCrossway];

	_iterationCounter = 0;
	_targetReached = false;

	while { count _workQueue > 0 && _iterationCounter < 10000 && _targetReached IsEqualTo false} do
	{
		_workItem = _workQueue deleteAt 0;
		_actualCrossway = _workItem select 1;
		if(_actualCrossway == _destinationCrossway) then {_targetReached = true};
		
		// _connCrossways = _crosswayMap select {(_x select 0) isEqualTo _actualCrossway && !((_x select 1) in _visitedCrossways)};
		_connCrossways = _crosswayMap select {(_x select 0) isEqualTo _actualCrossway};
		
		{
			_crossway = _x select 0;
			_connCrossway = _x select 1;
			_connectionWeight = _x select 2;
			
			// Find Parent in Distance Array
			// diag_log format["%1", _distanceArray];
			_parent = _distanceArray select {(_x select 0 IsEqualTo _crossway)} select 0;
			diag_log format["Parent: %1", _parent];
			// diag_log format["%1", _parent];
			_parentDistance = _parent select 1;
			// diag_log format["%1", _parentDistance];
			//_heuretic = _connCrossway distance _destinationCrossway;
			_heuretic = 0;
			// diag_log format["%1", _heuretic];
			
			_crosswayDistance = _connectionWeight + _parentDistance + _heuretic;
			// diag_log format["%1", _roadDistance];
			
			_posWorkQueue = _workQueue findIf {(_x select 1) == _connCrossway};
			
			diag_log format["Pos Work Queue : %1", _posWorkQueue];
			diag_log format["Finished Crossways: %1", _finishedCrossways];
			
			if((_posWorkQueue == -1) && (!(_connCrossway in _finishedCrossways))) then
			{	
				_workQueue pushBack [_crosswayDistance, _connCrossway];
				diag_log format["Work Queue: %1", _workQueue];
			};
			
			_posDistArray = _distanceArray findIf {(_x select 0) == _connCrossway};
			
			if( _posDistArray != -1) then
			{
				_oldDistance = (_distanceArray select _posDistArray) select 1;
				
				if(_oldDistance > _crosswayDistance) then
				{
					_distanceArray set [_posDistArray, [_connCrossway, _crosswayDistance, _crossway]];
				};
			}
			else
			{
				_distanceArray pushBack [_connCrossway, _crosswayDistance, _crossway];
			};
			
			_iterationCounter = _iterationCounter +1;
			
			diag_log format["Distance Array: %1", _distanceArray];
		} foreach _connCrossways;
		
		diag_log format["Connected Crossways: %1", _connCrossways];
		diag_log format["Work Queue: %1", _workQueue];
		
		_finishedCrossways pushBack _actualCrossway;
		
		
		if(count _workQueue  > 0) then {_workQueue sort true;};
	
		// _stop = diag_tickTime;
		// diag_log format ["Time: %1, Iteration: %2", _stop - _start, _iterationCounter];
	};
	
	diag_log format["Iteration Counter: %1", _iterationCounter];

	// Now Finding the Shortest Path to Destination
	_destinationPath = [];
	_destinationLength = 0;
	
	copyToClipboard str _distanceArray;

	_startNode = _distanceArray select 0;

	// Find DestinationRoad in Array
	_selectedNode = _distanceArray select {_x select 0 == _destinationCrossway} select 0;

	// Get the Distance to Destination
	_destinationLength = _selectedNode select 1;

	diag_log format ["StartNode: %1, SelectNode: %2, DestinationLength: %3", _startNode, _selectedNode, _destinationLength];

	// Get the Path to Destination
	while{!(_selectedNode isEqualTo _startNode)} do
	{
		_nodeRoad = _selectedNode select 0;			// Select the Road in the Node
		_destinationPath pushBack _nodeRoad;		// Save the Road in the Path
		_nodeParent = _selectedNode select 2;		// Node Parent to find
		
		_mapMarker = createMarkerLocal [format["%1_marker", _nodeRoad],visiblePosition _nodeRoad];
		_mapMarker setMarkerTextLocal format["%1", _nodeRoad];
		_mapMarker setMarkerTypeLocal "Mil_dot";
		
		// Find Node Parent in Distance Array
		_selectedNode = _distanceArray select {_x select 0 == _nodeParent} select 0;
		diag_log format ["Result: %1", _distanceArray select {_x select 0 == _nodeParent}];
	};

	_destinationPath pushBack (_startNode select 0);
	reverse _destinationPath;
	
	_allRoads = [];
	
	_counter = 0;
	
	// Get All Roads 
	while {_counter < (count _destinationPath -1)} do
	{
		_startRoad = _destinationPath select _counter;
		_endRoad = _destinationPath select (_counter + 1);
		_entryPosition = _islandRoads findIf {((_x select 0) select 0) == _startRoad && (_x select (count _x -1)) select 1 == _endRoad};
		_entryRoads = _islandRoads select _entryPosition;
		
		// diag_log format["Start Road: %1", _startRoad];
		// diag_log format["End Road: %1", _endRoad];
		// diag_log format["Entry Position: %1", _entryPosition];
		// diag_log format["Entry Roads: %1", _entryRoads];
		
		{
			_allRoads pushBack (_x select 0);
		} foreach _entryRoads;
		
		_counter = _counter + 1;
	};
	
	_lastRoadMarker = ObjNull;

	// // Create Local Markers to navigate to destination
	// {
		// _road = _x;
	
		// _roadMarker = "Sign_Arrow_Direction_F" createVehicleLocal getPosATL(_x);
		// _mapMarker = createMarkerLocal [format["%1_marker", _x],visiblePosition _x];
		// _mapMarker setMarkerTextLocal format["%1", _x];
		// _mapMarker setMarkerTypeLocal "Mil_dot";
		
		// if(!(IsNull _lastRoadMarker)) then
		// {
			// _posLastRoadMarker = getPos _lastRoadMarker;
			// _posRoadMarker = getPos _roadMarker;
			// _direction = _posLastRoadMarker getDir _posRoadMarker;
			// _lastRoadMarker setDir _direction;
		// };
		
		// _lastRoadMarker = _roadMarker;
		
	// } foreach _allRoads;
	
	_stop = diag_tickTime;
	diag_log format ["Time: %1, Count DestinationPath: %2", _stop - _start, count _destinationPath];
	diag_log format ["Destination Path: %1", _destinationPath];

	// Delete Local Markers when passing them
	[] spawn {
		while{true} do
		{
			_nearestObjects = nearestObjects [player, [], 10];
			{
				if(typeOf _x == "Sign_Arrow_Direction_F") then
				{
					deleteVehicle _x;
				}		
			} foreach _nearestObjects;
			sleep 0.1;
		}
	}
}