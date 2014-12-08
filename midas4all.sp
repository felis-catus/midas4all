#include <sourcemod>
#pragma semicolon 1
#define PL_VERSION "0.1"

new Handle:cvar_enabled;
new Handle:cvar_admins;
new Handle:cvar_flag;
new Handle:cvar_midas4all;

new bool:clientHasMidas[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "midas4all",
	author = "Felis, Spirrwell",
	description = "fun with ragdolls",
	version = PL_VERSION,
	url = "loli.dance"
}

public OnPluginStart()
{
	cvar_enabled = CreateConVar("sm_midas4all_enabled", "1", "Enable midas4all.");
	cvar_admins = CreateConVar("sm_midas4all_admins", "1", "Admins get midas touch.");
	cvar_flag = CreateConVar("sm_midas4all_flag", "b", "Admin flag required for midas.");
	cvar_midas4all = CreateConVar("sm_midas4all_everyone", "0", "midas4ALL");
	
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_death", OnPlayerDeath);
}

public OnMapStart()
{
	Reset();
}

public OnClientConnected(client)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	GiveMidas(client);
}

public OnClientDisconnect(client)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	clientHasMidas[client] = false;
}

public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	new userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(userid);
	
	GiveMidas(client);
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvar_enabled))
		return;
	
	new attackerId = GetEventInt(event, "attacker");
	new attacker = GetClientOfUserId(attackerId);
	
	new victimId = GetEventInt(event, "userid");
	new victim = GetClientOfUserId(victimId);
	
	if (clientHasMidas[attacker])
	{
		new ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
		SetEntProp(ragdoll, Prop_Send, "m_iDismemberment", 6);
	}
}

public bool:CheckFlag(client)
{
	if (GetUserFlagBits(client) == 0)
		return false;
	
	decl String:strflag[8];
	GetConVarString(cvar_flag, strflag, 8);
	
	new flag = ReadFlagString(strflag);
	if (GetUserFlagBits(client) >= flag)
		return true;
	else
	return false;
}

public GiveMidas(client)
{
	if (GetConVarBool(cvar_admins))
	{
		if (CheckFlag(client))
		{
			clientHasMidas[client] = true;
		}
	}
	else if (GetConVarBool(cvar_midas4all))
	{
		clientHasMidas[client] = true;
	}
}

public Reset()
{
	for (new i = 1; i < MaxClients; i++)
	{
		clientHasMidas[i] = false;
	}
}