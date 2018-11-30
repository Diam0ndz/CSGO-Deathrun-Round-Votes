#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Diam0ndzx"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma newdecls required

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "Deathrun Gravityround Vote",
	author = PLUGIN_AUTHOR,
	description = "Part of round vote system for SNG's Deathrun Server. This is Gravity round.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/Diam0ndz/"
};

bool succeedNextRound = false;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	RegAdminCmd("sm_gravityvote", CallGravityVote, ADMFLAG_BAN, "Gravity rounds yay"); //Allow admins with banning perms(servers+ on SNG) to force call gravity round vote
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	//PrintToChatAll("RoundStart was called");
	for (int i = 1; i <= MaxClients; i++)
	{
		if(i == 1)
		{
			int fivePercentChance = GetRandomInt(0, 19);
			if(fivePercentChance == 14) // A 5% chance to occur (And if it does happen call VoteGravity())
			{
				PrintToServer("%i", fivePercentChance);
				VoteGravity();
			}
		}
	}
	if(succeedNextRound)
	{
		ServerCommand("sm_gravity @all 0.5");
		PrintToChatAll(" \x0fHalf gravity round enabled! All players now have half gravity until the end of the round.");
		succeedNextRound = false;
	}else
	{
		succeedNextRound = false;
	}
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ServerCommand("sm_gravity @all 1");
}

public Action CallGravityVote(int client, int args)
{
	VoteGravity();
}

public int Handle_VoteMenu(Menu menu, MenuAction action, int param1, int param2)
{
	if(action == MenuAction_End)
	{
		delete menu; //Delete menu after vote end
	}
	else if(action == MenuAction_VoteEnd)
	{
		if(param1 == 0)
		{
			succeedNextRound = true;
			PrintToChatAll(" \x0fRound vote passed! Half gravity round will be enabled next round!");
		}
	}
}

void VoteGravity()
{
	if(IsVoteInProgress())
	{
		return;
	}
	
	Menu menu = new Menu(Handle_VoteMenu);
	menu.SetTitle("Half Gravity Round?");
	menu.AddItem("yes", "Yes");
	menu.AddItem("no", "No");
	menu.ExitButton = false;
	menu.DisplayVoteToAll(15);
}