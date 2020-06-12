"use strict";
let grand_parent = $.GetContextPanel().GetParent();
for(var i = 0; i < 100; i++) {
	if(grand_parent.id != "Hud") {
		grand_parent = grand_parent.GetParent();
	} else {
		break;
	}
}

function UpdateBuffs(){
	const debuffs_list_panel = grand_parent.FindChildTraverse("debuffs")
	if (!debuffs_list_panel)
		return;

	const entity_index = Players.GetSelectedEntities(Players.GetLocalPlayer())[0];
	if(entity_index != Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())){
		RemoveAllDeleteBuffEvents(debuffs_list_panel, entity_index)
		return;
	}
	
	let counter = 0

	for(let i = 0; i < Entities.GetNumBuffs(entity_index); i++){
		const debuff_index = Entities.GetBuff(entity_index, i);

		if(debuff_index == -1)
			continue;

		if (Buffs.IsHidden(entity_index, debuff_index))
			continue;
			
		if (!Buffs.IsDebuff(entity_index, debuff_index))
			continue;

		const buff_name = Buffs.GetName(entity_index, debuff_index)

		if(buff_name == "modifier_item_flag"){
			AddDeleteBuffEvent(debuffs_list_panel, counter, buff_name, entity_index)
		}
		counter++;
	}
}

function AddDeleteBuffEvent(panel, index, buff_name, entity_index){
	panel.GetChild(index).GetChild(0).SetPanelEvent("onactivate", function(){
		GameEvents.SendCustomGameEventToServer("remove_modifier", {
			buff_name: buff_name,
			entity_index: entity_index,
		});
	});
}

function RemoveAllDeleteBuffEvents(panel){
	for(let i = 0; i < panel.GetChildCount(); i++){
		RemoveDeleteBuffEvent(panel, i)
	}	
}

function RemoveDeleteBuffEvent(panel, index){
	panel.GetChild(index).GetChild(0).SetPanelEvent("onactivate", function(){});
}

function AutoUpdateBuffs(){
	UpdateBuffs();
	$.Schedule( 0.1, AutoUpdateBuffs );
}

(function()
{
	AutoUpdateBuffs();
})();