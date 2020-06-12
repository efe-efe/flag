
function OnFlagDropped(data)
{
	GameUI.PingMinimapAtLocation( data.location );
}

(function(){
	GameEvents.Subscribe( "flag_dropped", OnFlagDropped );
})();

