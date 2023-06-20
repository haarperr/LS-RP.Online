static character_Name_data[MAX_PLAYERS][3][24];
stock character_Select(const playerid) 
{
	Clear_Chat(playerid);
	new query[1280];
	mysql_format(Handle(), query, sizeof(query), "SELECT * FROM `accounts` WHERE `Username` = '%s'", player_get_name(playerid, false));
	if(mysql_tquery(Handle(),query, "character_List","i", playerid))
	{
		new find[1280];
		format(find, sizeof(find), "Dang tim nhan vat cua %s", player_get_name(playerid, false));
		SendClientMessage(playerid, -1, find);
	}
	else SendClientMessage(playerid, -1, "Loi tim tai khoan");
	return 1;
}

forward character_List(const playerid);
public character_List(const playerid)
{
	PlayerSetupping[playerid] = 1;
	SendClientMessage(playerid, -1, "[!] Moi ban chon nhan vat");
	new 
		string[150] = EOS;

	if(cache_num_rows()) 
	{
		for(new i = 0; i < 3; i ++)
		{
			new charname[1280];
			format(charname, sizeof(charname), "CharName%d", i);
			cache_get_value_name(0,charname, character_Name_data[playerid][i]);
			format(string, 150, "%s\n%s", string, character_Name_data[playerid][i]);
		}
		ShowPlayerDialog(playerid, dialog_charSelect, 2, "Chon nhan vat.", string, "Chon", "Huy");
	}
	return 1;
}

forward OnCharacterLoad(const playerid);
public OnCharacterLoad(const playerid)
{
	Character[playerid][char_Login] = true;

	cache_get_value_name_int(0, "id", Character[playerid][char_player_id]);
	cache_get_value_name_float(0, "PosX", Character[playerid][char_last_Pos][0]);
	cache_get_value_name_float(0, "PosY", Character[playerid][char_last_Pos][1]);
	cache_get_value_name_float(0, "PosZ", Character[playerid][char_last_Pos][2]);
	cache_get_value_name_float(0, "PosA", Character[playerid][char_last_Pos][3]);
	cache_get_value_name_float(0, "Health", Character[playerid][char_health]);
	cache_get_value_name_float(0, "Armour", Character[playerid][char_armour]);
	cache_get_value_name_int(0, "Skin", Character[playerid][char_Skin]);
	cache_get_value_name_int(0, "TanSo", Character[playerid][char_tanso]);
	cache_get_value_name_int(0, "Cash", Character[playerid][char_Cash]);
	cache_get_value_name_int(0, "AdminLevel", Character[playerid][char_Admin]);

	// printf("ID Account's %s:%d", player_get_name(playerid), Character[playerid][char_player_id]);

	SetSpawnInfo(playerid, 0, Character[playerid][char_Skin], Character[playerid][char_last_Pos][0], Character[playerid][char_last_Pos][1],Character[playerid][char_last_Pos][2],Character[playerid][char_last_Pos][3],0, 0,0, 0,0, 0);
	SpawnPlayer(playerid);

}

forward OnCharacterCreate(const playerid);
public OnCharacterCreate(const playerid)
{
	Clear_Chat(playerid);
	SendClientMessage(playerid, -1, "|____ Character Create ____|");
	new sdm[1280];
	mysql_format(Handle(), sdm, sizeof(sdm), "Name: %s", player_get_name(playerid));
	SendClientMessage(playerid, -1, sdm);
	
	new query[240];
	format(query, sizeof(query), "SELECT * FROM `players` WHERE `AccID` = '%s'", Character[playerid][char_account_id]);
	mysql_tquery(Handle(), query, "OnCharacterLoad", "i", playerid);

	SetSpawnInfo(playerid, 0, Character[playerid][char_Skin], 1192.78, -1292.68, 13.38, 90, 0,0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	PlayerSetupping[playerid] = 1;
	return 1;
}

#include <YSI\y_hooks>
hook OnPlayerConnect(playerid)
{
	for(new i = 0; i < 3; i ++) 
		format(character_Name_data[playerid][i], MAX_PLAYER_NAME, "");
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	static i;

	if(dialogid == dialog_charSelect) 
	{
		if(response)
		{	
			i = listitem;
			if(!strcmp(character_Name_data[playerid][i], "Tao nhan vat", true)) // List chua co nhan vat 
			{
				SetPVarInt(playerid, "CharSelect_",listitem);
				ShowPlayerDialog(playerid, dialog_charCreate, DIALOG_STYLE_INPUT, "Tao nhan vat.", "Nhap ten nhan vat ban muon tao.", "Tao", "Tro lai");
			}
			else // Da co nhan vat
			{
				SetPlayerName(playerid, character_Name_data[playerid][i]);
				
				new query[240];
				format(query, sizeof(query), "SELECT * FROM `players` WHERE `PlayerName` = '%s'", player_get_name(playerid, false));
				mysql_tquery(Handle(), query, "OnCharacterLoad", "i", playerid);
				SetPVarInt(playerid,"CharSelected_", 1);
			}
		}
		return ~1;
	}
	else if(dialogid == dialog_charCreate)
	{
		if(response)
		{
			new 
				len = strlen(inputtext);
			if(len >= MAX_PLAYER_NAME || inputtext[0] == EOS || len <= 4)
			{
				SendClientMessage(playerid, -1, "Ten khong hop le.");
				ShowPlayerDialog(playerid, dialog_charCreate, DIALOG_STYLE_INPUT, "Tao nhan vat.", "Nhap ten nhan vat ban muon tao.\nListitem: %d", "Tao", "Tro lai");	
			}
			else if(strfind(inputtext, "_", true) == -1 || strfind(inputtext, " ", true) != -1)
			{
				SendClientMessage(playerid, -1, "Ten nhan vat phai co '_' trong ten.");
				ShowPlayerDialog(playerid, dialog_charCreate, DIALOG_STYLE_INPUT, "Tao nhan vat.","Nhap ten nhan vat ban muon tao.","Tao", "Tro lai");	
			}
			else 
			{
				new queyz[1280], Cache:update_cache;
				format(queyz, sizeof(queyz), "UPDATE `accounts` SET `CharName%d` = '%s' WHERE `Username` = '%s'", GetPVarInt(playerid,"CharSelect_"), inputtext, player_get_name(playerid, false));
				update_cache = mysql_query(Handle(),queyz);
				cache_delete(update_cache);
				DeletePVar(playerid,"CharSelect_");
				new 
					Cache:iCache, _query[200];
				new query[240];
				format(query, sizeof(query), "SELECT * FROM `players` WHERE `PlayerName` = '%s'", inputtext);
				iCache = mysql_query
				(
					Handle(),
					query,
					true
				);
				if(cache_num_rows())
				{
					ShowPlayerDialog(playerid, dialog_charCreate, DIALOG_STYLE_INPUT, "Tao nhan vat.", "Nhap lai ten nhan vat ban muon tao. Ten nhan vat nay da duoc tao", "Tao", "Tro lai");							
				}
				else
				{
					SetPlayerName(playerid, inputtext);
					mysql_format(Handle(), _query, 200, "INSERT INTO `players` (`AccID`, `PlayerName`, `Skin`) VALUES ('%d', '%s', %d)", strval(Character[playerid][char_account_id]), inputtext, random(299) + 1);
					mysql_tquery(Handle(), _query, "OnCharacterCreate", "i", playerid);
				}
				cache_delete(iCache);
			}
		}
		else 
			return ~character_Select(playerid);
	}
	return 1;
}
