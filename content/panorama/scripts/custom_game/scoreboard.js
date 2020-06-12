const panel = $("#Scoreboard__Container");

function UpdateScoreboard(){
    const score = CustomNetTables.GetTableValue( "game_state", "score" )

    const radiant_score = score[DOTATeam_t.DOTA_TEAM_GOODGUYS.toString()];
    const dire_score = score[DOTATeam_t.DOTA_TEAM_BADGUYS.toString()];

    const radiant_panel = panel.FindChildrenWithClassTraverse("Scoreboard__Team")[0]
    const dire_panel = panel.FindChildrenWithClassTraverse("Scoreboard__Team")[1]

    const radiant_flags_panel = radiant_panel.FindChildrenWithClassTraverse("Scoreboard__Flag-Container")
    const dire_flags_panel = dire_panel.FindChildrenWithClassTraverse("Scoreboard__Flag-Container")

    radiant_flags_panel.forEach(function(flag_panel, i){
        if(i < radiant_score){
            flag_panel.SetHasClass("Scoreboard__Flag-Container--Picked-Radiant", true)
        }
    })

    dire_flags_panel.forEach(function(flag_panel, i){
        if(i < dire_score){
            flag_panel.SetHasClass("Scoreboard__Flag-Container--Picked-Dire", true)
        }
    })
}

function AutoUpdateScoreboard()
{
	UpdateScoreboard();
	$.Schedule( 0.1, AutoUpdateScoreboard );
}

(function()
{
    AutoUpdateScoreboard();
})();