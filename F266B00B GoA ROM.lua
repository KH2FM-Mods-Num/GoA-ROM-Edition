--ROM Version
--Last Update: LuaFrontend Support
--To Do: Check if stuff crashes after STT Beam or Sanctuary

function _OnInit()
local VersionNum = 'GoA Version 1.52.7'
if (GAME_ID == 0xF266B00B or GAME_ID == 0xFAF99301) and ENGINE_TYPE == "ENGINE" then --PCSX2
	if ENGINE_VERSION < 3.0 then
		print('LuaEngine is Outdated. Things might not work properly.')
	end
	print(VersionNum)
	Platform = 'PS2'
	Now = 0x032BAE0 --Current Location
	Sve = 0x1D5A970 --Saved Location
	BGM = 0x0347D34 --Background Music
	Save = 0x032BB30 --Save File
	Obj0 = 0x1C94100 --00objentry.bin
	Sys3 = 0x1CCB300 --03system.bin
	Btl0 = 0x1CE5D80 --00battle.bin
	Pause = 0x0347E08 --Ability to Pause
	React = 0x1C5FF4E --Reaction Command
	Cntrl = 0x1D48DB8 --Sora Controllable
	Timer = 0x0349DE8
	Combo = 0x1D49080
	Songs = 0x035DAC4 --Atlantica Stuff
	GScre = 0x1F8039C --Gummi Score
	GMdal = 0x1F803C0 --Gummi Medal
	GKill = 0x1F80856 --Gummi Kills
	CamTyp = 0x0348750 --Camera Type
	CutNow = 0x035DE20 --Cutscene Timer
	CutLen = 0x035DE28 --Cutscene Length
	CutSkp = 0x035DE08 --Cutscene Skip
	BtlTyp = 0x1C61958 --Battle Status (Out-of-Battle, Regular, Forced)
	BtlEnd = 0x1D490C0 --Something about end-of-battle camera
	TxtBox = 0x1D48D54 --Last Displayed Textbox
	DemCln = 0x1D48DEC --Demyx Clone Status
	MSNLoad  = 0x04FA440
	Slot1    = 0x1C6C750 --Unit Slot 1
	NextSlot = 0x268
	Point1   = 0x1D48EFC
	NxtPoint = 0x38
	Gauge1   = 0x1D48FA4
	NxtGauge = 0x34
	Menu1    = 0x1C5FF18 --Menu 1 (main command menu)
	NextMenu = 0x4
elseif GAME_ID == 0x431219CC and ENGINE_TYPE == 'BACKEND' then --PC
	if ENGINE_VERSION < 5.0 then
		ConsolePrint('LuaFrontend is Outdated. Things might not work properly.',2)
	end
	ConsolePrint(VersionNum,0)
	Platform = 'PC'
	Now = 0x0714DB8 - 0x56450E
	Sve = 0x2A09C00 - 0x56450E
	BGM = 0x0AB8504 - 0x56450E
	Save = 0x09A7070 - 0x56450E
	Obj0 = 0x2A22B90 - 0x56450E
	Sys3 = 0x2A59DB0 - 0x56450E
	Btl0 = 0x2A74840 - 0x56450E
	Pause = 0x0AB9038 - 0x56450E
	React = 0x2A0E822 - 0x56450E
	Cntrl = 0x2A148A8 - 0x56450E
	Timer = 0x0AB9010 - 0x56450E
	Songs = 0x0B63534 - 0x56450E
	GScre = 0x0728E90 - 0x56450E
	GMdal = 0x0729024 - 0x56450E
	GKill = 0x0AF4906 - 0x56450E
	CamTyp = 0x0716A58 - 0x56450E
	CutNow = 0x0B62758 - 0x56450E
	CutLen = 0x0B62774 - 0x56450E
	CutSkp = 0x0B6275C - 0x56450E
	BtlTyp = 0x2A0EAC4 - 0x56450E
	BtlEnd = 0x2A0D3A0 - 0x56450E
	TxtBox = 0x074BC70 - 0x56450E
	DemCln = 0x2A0CF74 - 0x56450E
	MSNLoad  = 0x0BF08C0 - 0x56450E
	Slot1    = 0x2A20C58 - 0x56450E
	NextSlot = 0x278
	Point1   = 0x2A0D108 - 0x56450E
	NxtPoint = 0x50
	Gauge1   = 0x2A0D1F8 - 0x56450E
	NxtGauge = 0x48
	Menu1    = 0x2A0E7D0 - 0x56450E
	NextMenu = 0x8
end
Slot2  = Slot1 - NextSlot
Slot3  = Slot2 - NextSlot
Slot4  = Slot3 - NextSlot
Slot5  = Slot4 - NextSlot
Slot6  = Slot5 - NextSlot
Slot7  = Slot6 - NextSlot
Slot8  = Slot7 - NextSlot
Slot9  = Slot8 - NextSlot
Slot10 = Slot9 - NextSlot
Slot11 = Slot10 - NextSlot
Slot12 = Slot11 - NextSlot
Point2 = Point1 + NxtPoint
Point3 = Point2 + NxtPoint
Gauge2 = Gauge1 + NxtGauge
Gauge3 = Gauge2 + NxtGauge
Menu2  = Menu1 + NextMenu
Menu3  = Menu2 + NextMenu
pi     = math.pi
end

function Warp(W,R,D,M,B,E) --Warp into the appropriate World, Room, Door, Map, Btl, Evt
WriteByte(Now+0x00,W)
WriteByte(Now+0x01,R)
WriteShort(Now+0x02,D)
WriteShort(Now+0x04,M)
WriteShort(Now+0x06,B)
WriteShort(Now+0x08,E)
--Record Location in Save File
WriteByte(Save+0x000C,W)
WriteByte(Save+0x000D,R)
WriteShort(Save+0x000E,D)
end

function Events(M,B,E) --Check for Map, Btl, and Evt
return ((Map == M or not M) and (Btl == B or not B) and (Evt == E or not E))
end

function Spawn(Type,Subfile,Offset,Value)
local Subpoint = ARD + 0x08 + 0x10*Subfile
local Address
if Platform == 'PS2' and ReadInt(ARD) == 0x01524142 and Subfile <= ReadInt(ARD+4) then
	--Exclusions on Crash Spots in PCSX2-EX
	Address = ReadInt(Subpoint) + Offset
	if Type == 'Short' then
		WriteShort(Address,Value)
	elseif Type == 'Float' then
		WriteFloat(Address,Value)
	elseif Type == 'Int' then
		WriteInt(Address,Value)
	elseif Type == 'String' then
		WriteString(Address,Value)
	end
elseif Platform == 'PC' then
	local x = ARD&0xFFFFFF000000
	if ENGINE_VERSION < 5.0 then --LuaBackend
		if ReadIntA(ARD) == 0x01524142 and Subfile <= ReadIntA(ARD+4) then
			local y = ReadIntA(Subpoint)&0xFFFFFF
			Address = x + y + Offset
			if Type == 'Short' then
				WriteShortA(Address,Value)
			elseif Type == 'Float' then
				WriteFloatA(Address,Value)
			elseif Type == 'Int' then
				WriteIntA(Address,Value)
			elseif Type == 'String' then
				WriteStringA(Address,Value)
			end
		end
	else --LuaFrontend
		if ReadInt(ARD,true) == 0x01524142 and Subfile <= ReadInt(ARD+4,true) then
			local y = ReadInt(Subpoint,true)&0xFFFFFF
			Address = x + y + Offset
			if Type == 'Short' then
				WriteShort(Address,Value,true)
			elseif Type == 'Float' then
				WriteFloat(Address,Value,true)
			elseif Type == 'Int' then
				WriteInt(Address,Value,true)
			elseif Type == 'String' then
				WriteString(Address,Value,true)
			end
		end
	end
end
end

function BitOr(Address,Bit,Abs)
if Abs and Platform == 'PC' then
	if ENGINE_VERSION < 5.0 then
		WriteByteA(Address,ReadByte(Address)|Bit)
	else
		WriteByte(Address,ReadByte(Address)|Bit,true)
	end
else
	WriteByte(Address,ReadByte(Address)|Bit)
end
end

function BitNot(Address,Bit,Abs)
if Abs and Platform == 'PC' then
	if ENGINE_VERSION < 5.0 then
		WriteByteA(Address,ReadByte(Address)&~Bit)
	else
		WriteByte(Address,ReadByte(Address)&~Bit,true)
	end
else
	WriteByte(Address,ReadByte(Address)&~Bit)
end
end

function Faster(Toggle)
if Platform == 'PS2' then
	if Toggle then
		WriteByte(0x0349E1C,0x00) --Faster Speed
		WriteByte(0x0349E20,0x00)
	else
		WriteByte(0x0349E1C,0x01) --Normal Speed
		WriteByte(0x0349E20,0x01)
	end
elseif Platform == 'PC' then
	if Toggle then
		WriteFloat(0x07151D4 - 0x56450E,2) --Faster Speed
	else
		WriteFloat(0x07151D4 - 0x56450E,1) --Normal Speed		
	end
end
end

function RemoveTTBarriers() --Remove All TT & STT Barriers
WriteShort(Save+0x207C,0x0000) --Sunset Station
WriteShort(Save+0x2080,0x0000) --Central Station
WriteShort(Save+0x20E4,0x0000) --Underground Concourse
WriteShort(Save+0x20E8,0x0000) --Woods
WriteShort(Save+0x20EC,0x0000) --Sandlot
WriteShort(Save+0x20F0,0x0000) --Tram Commons
WriteShort(Save+0x20F4,0x0000) --The Mysterious Tower
WriteShort(Save+0x20F8,0x0000) --Tower Wardrobe
WriteShort(Save+0x20FC,0x0000) --Basement Corridor
WriteShort(Save+0x2100,0x0000) --Mansion Library
WriteShort(Save+0x2110,0x0000) --Tunnelway
WriteShort(Save+0x2114,0x0000) --Station Plaza
WriteShort(Save+0x211C,0x0000) --The Old Mansion
WriteShort(Save+0x2120,0x0000) --Mansion Foyer
end

function _OnFrame()
if true then --Define current values for common addresses
	World  = ReadByte(Now+0x00)
	Room   = ReadByte(Now+0x01)
	Place  = ReadShort(Now+0x00)
	Door   = ReadShort(Now+0x02)
	Map    = ReadShort(Now+0x04)
	Btl    = ReadShort(Now+0x06)
	Evt    = ReadShort(Now+0x08)
	PrevPlace = ReadShort(Now+0x30)
	MSN    = MSNLoad + (ReadInt(MSNLoad+4)+1) * 0x10
	if Platform == 'PS2' then
		ARD = ReadInt(0x034ECF4) --Base ARD Address
	elseif Platform == 'PC' then
		ARD = ReadLong(0x2A0CEE8 - 0x56450E) --Base ARD Address
		if GetHertz() < 240 then
			SetHertz(240)
			ConsolePrint('Frequency set to 240Hz to accommodate GoA mod.\n',0)
		end
	end
end
NewGame()
GoA()
TWtNW()
LoD()
BC()
HT()
Ag()
OC()
PL()
TT()
HB()
PR()
DC()
SP()
STT()
AW()
At()
Data()
end

function NewGame()
--Before New Game
if Place == 0xFFFF or Place == 0x0101 or (Place == 0x0102 and Events(0x34,0x34,0x34)) then --In Main Menu, Loop Demo, or Opening
	WriteShort(Btl0+0x2EB4C,500) --Fast MCP (50% Base HP)
	WriteShort(Btl0+0x2EB8C,300) --Double Max Damage %
	WriteShort(Btl0+0x2EB8E,100) --Double Min Damage %
	--Change Form's Icons in PC From Analog Stick
	if Platform == 'PC' then
		WriteByte(Sys3+0x116DB,0x3B) --Valor
		WriteByte(Sys3+0x116F3,0x3B) --Wisdom
		WriteByte(Sys3+0x1170B,0x3B) --Limit
		WriteByte(Sys3+0x11723,0x3B) --Master
		WriteByte(Sys3+0x1173B,0x3B) --Final
		WriteByte(Sys3+0x11753,0x3B) --Anti
	end
end
--Start New Game 1
if Place == 0x0102 and Events(0x34,0x34,0x34) then --Opening Cutscene
	WriteShort(Save+0x03D0,0x01) --Station of Serenity MAP (Dream Weapons)
	WriteShort(Save+0x03D4,0x01) --Station of Serenity EVT
	if Platform == 'PS2' then
		Warp(0x02,0x20,0x32,0x01,0x00,0x01) --Not warping here on PS2 causes crash later
	end
end
--Start New Game 2
if Place == 0x2002 and Events(0x01,Null,0x01) then --Station of Serenity Weapons
	BitNot(Save+0x1CD2,0x80) --TT_SCENARIO_1_START (Show Gameplay Elements)
	BitOr(Save+0x1CEA,0x02)  --TT_SORA_OLD_END (Play as KH2 Sora)
	BitOr(Save+0x1CEB,0x08)  --TT_ROXAS_START (Prepare Roxas' Flag)
	WriteByte(Pause,2) --Disable Pause
	if ReadInt(CutLen) == 0x246 then --Dusks attack
		WriteByte(CutSkp,1)
	end
	--Starting Stats
	WriteByte(Save+0x35AE,1) --Have 1 Battlefields of War
	WriteByte(Save+0x35AF,1) --Have 1 Sword of the Ancestors
	WriteByte(Save+0x35B3,1) --Have 1 Beast's Claw
	WriteByte(Save+0x35B4,1) --Have 1 Bone Fist
	WriteByte(Save+0x35B5,1) --Have 1 Proud Fang
	WriteByte(Save+0x35B6,1) --Have 1 Skill and Crossbones
	WriteByte(Save+0x35C0,1) --Have 1 Scimitar
	WriteByte(Save+0x35C1,1) --Have 1 Way to the Dawn
	WriteByte(Save+0x35C2,1) --Have 1 Identity Disk
	WriteByte(Save+0x363F,1) --Have 1 Tournament Poster
	WriteByte(Save+0x3640,1) --Have 1 Poster
	WriteByte(Save+0x3641,1) --Have 1 Letter
	WriteByte(Slot1+0x1B0,100) --Starting Drive %
	WriteByte(Slot1+0x1B1,5)   --Starting Drive Current
	WriteByte(Slot1+0x1B2,5)   --Starting Drive Max
	--Place Scripts
	WriteShort(Save+0x023A,0x01) --Roxas' Room EVT
	WriteShort(Save+0x06AC,0x01) --Garden of Assemblage MAP (Before Computer)
	WriteShort(Save+0x06B0,0x03) --Garden of Assemblage EVT
	WriteShort(Save+0x0C10,0x01) --Bamboo Grove MAP (Burning Village)
	WriteShort(Save+0x0C14,0x01) --Bamboo Grove EVT
	WriteShort(Save+0x0F6E,0x01) --Wildebeest Valley (Past) EVT
	WriteShort(Save+0x10BE,0x01) --The Shore (Night) EVT
	WriteShort(Save+0x1238,0x01) --Gummi Hangar EVT
	WriteShort(Save+0x1B1A,0x01) --Alley to Between EVT
	WriteShort(Save+0x1B5E,0x01) --Proof of Existence MAP (Lock Progress)
	--Tutorial Flags & Form Weapons
	BitOr(Save+0x239E,0x07)  --Pause Menu (1=Items, 2=Party, 4=Customize)
	BitNot(Save+0x239E,0x80) --Show Struggle Bats Outside STT
	BitOr(Save+0x36E8,0x01)  --Enable Item in Command Menu
	WriteShort(Save+0x32F4,0x051) --Valor Form equips FAKE
	WriteShort(Save+0x339C,0x02C) --Master Form equips Detection Saber
	WriteShort(Save+0x33D4,0x02D) --Final Form equips Edge of Ultima
	WriteShort(Save+0x4270,0x1FF) --Pause Menu Tutorial Prompts Seen Flags
	WriteShort(Save+0x4274,0x1FF) --Status Form & Summon Seen Flags
	--Unlock Shop Weapons
	BitOr(Save+0x49F0,0x03) --Shop Tutorial Prompt Flags (1=Big Shops, 2=Small Shops)
	BitOr(Save+0x2396,0x10) --Comet Staff & Falling Star (Olympus Coliseum)
	BitOr(Save+0x2396,0x40) --Victory Bell & Chain Gear (Port Royal)
	BitOr(Save+0x2397,0x80) --Lord's Broom & Dreamcloud (Pride Lands)
	BitOr(Save+0x2398,0x04) --Wisdom Wand & Knight Defender (The World that Never Was)
	--Unlock Data Portals
	BitOr(Save+0x1D35,0x01) --BB_216_END (Xaldin)
	BitOr(Save+0x1D23,0x08) --HB_FM_COM_VEX_END (Vexen)
	BitOr(Save+0x1D23,0x10) --HB_FM_COM_LEX_END (Lexaeus)
	BitOr(Save+0x1D23,0x40) --HB_FM_COM_ZEX_END (Zexion)
	BitOr(Save+0x1CE9,0x04) --TT_013_END (Axel)
	BitOr(Save+0x1D15,0x08) --HB_418_END (Demyx)
	BitOr(Save+0x1D23,0x80) --HB_FM_COM_MAR_END (Marluxia)
	BitOr(Save+0x1D23,0x20) --HB_FM_COM_LAR_END (Larxene)
	BitOr(Save+0x1ED9,0x01) --EH_GAME_COMPLETE (TWtNW Members)
	--Story Flag (Prevent Start-of-Visit Spawn ID Change)
	BitOr(Save+0x1CED,0x10) --TT_START_01
	BitOr(Save+0x1CED,0x20) --TT_START_02
	BitOr(Save+0x1D10,0x01) --HB_START
	BitOr(Save+0x1D11,0x02) --HB_START1_2
	BitOr(Save+0x1D12,0x08) --HB_tr_107_END
	BitOr(Save+0x1D13,0x01) --HB_tr_117_END
	BitOr(Save+0x1D15,0x10) --HB_START2
	BitOr(Save+0x1D15,0x20) --HB_START_wi_dc
	BitOr(Save+0x1D16,0x02) --HB_START_Pooh
	BitOr(Save+0x1D19,0x20) --HB_TR_202_END
	BitOr(Save+0x1D1A,0x02) --HB_TR_tr04_ms202
	BitOr(Save+0x1D1A,0x08) --HB_TR_tr09_ms205
	BitOr(Save+0x1D20,0x10) --HB_POOH_CLEAR
	BitOr(Save+0x1D21,0x10) --HB_RTN_ON
	BitOr(Save+0x1D21,0x80) --HB_TR05_HIDDEN_ON
	BitOr(Save+0x1D22,0x01) --HB_TR05_HIDDEN_OFF
	BitOr(Save+0x1D22,0x02) --HB_TR08_HIDDEN_ON
	BitOr(Save+0x1D22,0x04) --HB_TR08_HIDDEN_OFF
	BitOr(Save+0x1D22,0x80) --HB_RTN_ON_OFF
	BitOr(Save+0x1D30,0x01) --BB_START
	BitOr(Save+0x1D33,0x01) --BB_START2
	BitOr(Save+0x1D50,0x01) --HE_START
	BitOr(Save+0x1D55,0x02) --HE_W_COL_ON
	BitOr(Save+0x1D50,0x80) --HE_START2A
	BitOr(Save+0x1D51,0x02) --HE_START2B
	BitOr(Save+0x1D70,0x01) --AL_START
	BitOr(Save+0x1D72,0x20) --AL_START2
	BitOr(Save+0x1D90,0x01) --MU_START
	BitOr(Save+0x1D92,0x08) --MU_START2
	BitOr(Save+0x1DD0,0x01) --LK_START
	BitOr(Save+0x1DD3,0x01) --LK_START2
	BitOr(Save+0x1DF0,0x01) --LM_START
	BitOr(Save+0x1E10,0x02) --DC_START
	BitOr(Save+0x1E50,0x01) --NM_START
	BitOr(Save+0x1E50,0x02) --NM_START2
	BitOr(Save+0x1E90,0x01) --CA_START
	BitOr(Save+0x1E90,0x04) --CA_START2
	BitOr(Save+0x1EB0,0x01) --TR_START
	BitOr(Save+0x1EB2,0x10) --TR_START2
	BitOr(Save+0x1EB4,0x10) --TR_hb_304_END
	BitOr(Save+0x1EB5,0x01) --TR_hb_501_END
	BitOr(Save+0x1EB5,0x02) --TR_hb_502_END
	BitOr(Save+0x1EB5,0x04) --TR_503_END
	BitOr(Save+0x1EB7,0x04) --TR_HB05_HIDDEN_OFF
	BitOr(Save+0x1ED0,0x01) --EH_START
	BitOr(Save+0x1CD6,0x02) --TT_203_END_L (Show Jiminy and TT in Journal)
	BitOr(Save+0x1ED8,0x04) --EH_FINAL_CHANCE_START
end
end

function GoA()
--Garden of Assemblage Rearrangement
if Place == 0x1A04 then
	--Shop
	WriteString(Obj0+0x13450,'SHOP_POINT\0') --Wallace -> Moogle
	WriteString(Obj0+0x13470,'N_EX960_RTN.mset\0')
	WriteShort(Sys3+0x16F40,0x001) --Stock Potion
	WriteShort(Sys3+0x16F42,0x003) --Stock Ether
	--Open Promise Charm Path
	if ReadByte(Save+0x36B2) > 0 and ReadByte(Save+0x36B3) > 0 and ReadByte(Save+0x36B4) > 0 and ReadByte(Save+0x3694) > 0 then --All Proofs & Promise Charm
		Spawn('Short',0x06,0x05C,0x77A) --Text
	end
	--Demyx's Portal Text
	if ReadByte(Save+0x1D2E) > 0 then --Hollow Bastion Cleared
		Spawn('Short',0x05,0x25C,0x779) --Radiant Garden
	end
else --Revert Shop
	WriteString(Obj0+0x13450,'N_EX700_TT_WEAPON_RTN') --Moogle -> Wallace
	WriteString(Obj0+0x13470,'N_EX700_SHOP_RTN.mset')
	WriteShort(Sys3+0x16F40,0x094) --Stock Hammer Staff
	WriteShort(Sys3+0x16F42,0x08B) --Stock Adamant Shield
end
--Spawn Middle Chest
if ReadShort(Save+0x06AC) == 0x02 then
	WriteShort(Save+0x06AC,0x00) --Garden of Assemblage MAP
end
--World Map -> Garden of Assemblage
if Place == 0x000F then
	local WarpDoor
	if Door == 0x0C then --The World that Never Was
		WarpDoor = 0x15
	elseif Door == 0x03 then --Land of Dragons
		WarpDoor = 0x16
	elseif Door == 0x04 then --Beast's Castle
		WarpDoor = 0x17
	elseif Door == 0x09 then --Halloween Town	
		WarpDoor = 0x18
	elseif Door == 0x0A then --Agrabah
		WarpDoor = 0x19
	elseif Door == 0x05 then --Olympus Coliseum
		WarpDoor = 0x1A
	elseif Door == 0x0B then --Pride Lands
		WarpDoor = 0x1B
	elseif Door == 0x01 then --Twilight Town
		if ReadByte(Save+0x1CFF) == 8 then --Twilight Town
			WarpDoor = 0x1C
		elseif ReadByte(Save+0x1CFF) == 13 then --Simulated Twilight Town
			WarpDoor = 0x21
		end
		WriteByte(Save+0x1CFF,0)
	elseif Door == 0x02 then --Hollow Bastion
		WarpDoor = 0x1D
	elseif Door == 0x08 then --Port Royal
		WarpDoor = 0x1E
	elseif Door == 0x06 then --Disney Castle
		WarpDoor = 0x1F
	elseif Door == 0x07 then --Atlantica
		WarpDoor = 0x01
	end
	if WarpDoor then
		Warp(0x04,0x1A,WarpDoor,0x00,0x00,0x02)
	end
end
--Battle Level
if true then
	local Bitmask, Visit
	if World == 0x02 then --Twilight Town & Simulated Twilight Town
		Visit = ReadByte(Save+0x3FF5)
		if Visit == 1 or Visit == 2 or Visit == 3 then
			Bitmask = 0x040001
		elseif Visit == 4 or Visit == 5 then
			Bitmask = 0x140001
		elseif Visit == 6 then
			Bitmask = 0x140401
		elseif Visit == 7 or Visit == 8 then
			Bitmask = 0x141C01
		elseif Visit == 9 then
			Bitmask = 0x143D01
		elseif Visit == 10 then
			Bitmask = 0x157D79
		elseif Visit == 13 then --Road to Data
			Bitmask = 0x060000
		end
	elseif World == 0x04 then --Hollow Bastion
		Visit = ReadByte(Save+0x3FFD)
		if Visit == 1 or Visit == 2 or Visit == 3 then
			Bitmask = 0x141C01
		elseif Visit == 4 then
			Bitmask = 0x147D09
		elseif Visit == 5 then
			Bitmask = 0x15FD79
		end
	elseif World == 0x05 then --Beast's Castle
		Visit = ReadByte(Save+0x4001)
		if Visit == 1 then
			Bitmask = 0x141C01
		elseif Visit == 2 then
			Bitmask = 0x147D19
		end
	elseif World == 0x06 then --Olympus Coliseum
		Visit = ReadByte(Save+0x4005)
		if Visit == 1 then
			Bitmask = 0x141C01
		elseif Visit == 2 then
			Bitmask = 0x147D19
		end
	elseif World == 0x07 then --Agrabah
		Visit = ReadByte(Save+0x4009)
		if Visit == 1 then
			Bitmask = 0x141D01
		elseif Visit == 2 then
			Bitmask = 0x147D19
		end
	elseif World == 0x08 then --The Land of Dragons
		Visit = ReadByte(Save+0x400D)
		if Visit == 1 then
			Bitmask = 0x141C01
		elseif Visit == 2 then
			Bitmask = 0x147D19
		end
	elseif World == 0x0A then --Pride Lands
		Visit = ReadByte(Save+0x4015)
		if Visit == 1 then
			Bitmask = 0x141D01
		elseif Visit == 2 then
			Bitmask = 0x15FDF9
		end
	elseif World == 0x0C or World == 0x0D then --Disney Castle & Timeless River
		Bitmask = 0x141D01
	elseif World == 0x0E then --Halloween Town
		Visit = ReadByte(Save+0x4025)
		if Visit == 1 then
			Bitmask = 0x141D01
		elseif Visit == 2 then
			Bitmask = 0x147D19
		end
	elseif World == 0x10 then --Port Royal
		Visit = ReadByte(Save+0x402D)
		if Visit == 1 then
			Bitmask = 0x141C01
		elseif Visit == 2 then
			Bitmask = 0x147D19
		end
	elseif World == 0x11 then --Space Paranoids
		Visit = ReadByte(Save+0x4031)
		if Visit == 1 then
			Bitmask = 0x147D01
		elseif Visit == 2 then
			Bitmask = 0x15FD79
		end
	elseif World == 0x12 then --The World that Never Was
		Bitmask = 0x157D79
	end
	if not Bitmask then --Safeguard if all above are false
		Bitmask = 0x040000
	end
	WriteInt(Save+0x3724,Bitmask)
end
--Fix Genie Crash
if true then --No Valor, Wisdom, Master, or Final
	local CurSubmenu
	if Platform == 'PS2' then
		CurSubmenu = ReadInt(Menu2)
		CurSubmenu = ReadByte(CurSubmenu)
	elseif Platform == 'PC' then
		CurSubmenu = ReadLong(Menu2)
		if ENGINE_VERSION < 5.0 then
			CurSubmenu = ReadByteA(CurSubmenu)
		else
			CurSubmenu = ReadByte(CurSubmenu,true)
		end
	end
	if CurSubmenu == 7 and ReadByte(Save+0x36C0)&0x56 == 0x00 then --In Summon menu without Forms
		BitOr(Save+0x36C0,0x02) --Add Valor Form
		BitOr(Save+0x06B2,0x01)
	elseif ReadShort(React) == 0x059 and ReadByte(Save+0x36C0)&0x56 == 0x00 then --Genie in Auto Summon RC without Forms
		BitOr(Save+0x36C0,0x02) --Add Valor Form
		BitOr(Save+0x06B2,0x01)
	elseif CurSubmenu ~= 7 and ReadShort(React) ~= 0x059 and ReadByte(Save+0x06B2)&0x01==0x01 then --None of the above
		BitNot(Save+0x36C0,0x02) --Remove Valor Form
		BitNot(Save+0x06B2,0x01)
	end
end
--Progressive Growth Abilities & Fixed Trinity Limit Slot
for Slot = 0,68 do
	local Current = Save+0x2544 + 2*Slot
	local Ability = ReadShort(Current)
	if Ability >= 0x05E and Ability <= 0x061 then --High Jump
		local Slot70 = Save+0x25CE
		WriteShort(Current,0)
		if ReadShort(Slot70)|0x8000 < 0x805E then
			WriteShort(Slot70,0x005E)
		elseif ReadShort(Slot70)|0x8000 >= 0x8061 then
		else
			WriteShort(Slot70,ReadShort(Slot70)+0x0001)
		end
	elseif Ability >= 0x062 and Ability <= 0x065 then --Quick Run
		local Slot71 = Save+0x25D0
		WriteShort(Current,0)
		if ReadShort(Slot71)|0x8000 < 0x8062 then
			WriteShort(Slot71,0x0062)
		elseif ReadShort(Slot71)|0x8000 >= 0x8065 then
		else
			WriteShort(Slot71,ReadShort(Slot71)+0x0001)
		end
	elseif Ability >= 0x234 and Ability <= 0x237 then --Dodge Roll
		local Slot72 = Save+0x25D2
		WriteShort(Current,0)
		if ReadShort(Slot72)|0x8000 < 0x8234 then
			WriteShort(Slot72,0x0234)
		elseif ReadShort(Slot72)|0x8000 >= 0x8237 then
		else
			WriteShort(Slot72,ReadShort(Slot72)+0x0001)
		end
	elseif Ability >= 0x066 and Ability <= 0x069 then --Aerial Dodge
		local Slot73 = Save+0x25D4
		WriteShort(Current,0)
		if ReadShort(Slot73)|0x8000 < 0x8066 then
			WriteShort(Slot73,0x0066)
		elseif ReadShort(Slot73)|0x8000 >= 0x8069 then
		else
			WriteShort(Slot73,ReadShort(Slot73)+0x0001)
		end
	elseif Ability >= 0x06A and Ability <= 0x06D then --Glide
		local Slot74 = Save+0x25D6
		WriteShort(Current,0)
		if ReadShort(Slot74)|0x8000 < 0x806A then
			WriteShort(Slot74,0x006A)
		elseif ReadShort(Slot74)|0x8000 >= 0x806D then
		else
			WriteShort(Slot74,ReadShort(Slot74)+0x0001)
		end
	elseif Ability == 0x0C6 then --Trinity Limit
		WriteShort(Current,0)
		WriteShort(Save+0x25D8,0x00C6)
	end
end
--Munny Pouch (Olette)
if ReadByte(Save+0x363C) > ReadByte(Save+0x35C4) then
	WriteShort(Save+0x2440,ReadShort(Save+0x2440)+5000)
	WriteByte(Save+0x35C4,ReadByte(Save+0x35C4)+1)
end
--Munny Pouch (Mickey)
if ReadByte(Save+0x3695) > ReadByte(Save+0x35C5) then
	WriteShort(Save+0x2440,ReadShort(Save+0x2440)+5000)
	WriteByte(Save+0x35C5,ReadByte(Save+0x35C5)+1)
end
--DUMMY 23 = Maximum HP Increased!
if ReadByte(Save+0x3671) > 0 then
	local Bonus
	if ReadByte(Save+0x2498) < 0x03 then --Non-Critical
		Bonus = 5
	else --Critical
		Bonus = 2
	end
	WriteInt(Slot1+0x000,ReadInt(Slot1+0x000)+Bonus)
	WriteInt(Slot1+0x004,ReadInt(Slot1+0x004)+Bonus)
	WriteByte(Save+0x3671,ReadByte(Save+0x3671)-1)
end
--DUMMY 24 = Maximum MP Increased!
if ReadByte(Save+0x3672) > 0 then
	local Bonus
	if ReadByte(Save+0x2498) < 0x03 then --Non-Critical
		Bonus = 10
	else --Critical
		Bonus = 5
	end
	WriteInt(Slot1+0x180,ReadInt(Slot1+0x180)+Bonus)
	WriteInt(Slot1+0x184,ReadInt(Slot1+0x184)+Bonus)
	WriteByte(Save+0x3672,ReadByte(Save+0x3672)-1)
end
--DUMMY 25 = Drive Gauge Powered Up!
if ReadByte(Save+0x3673) > 0 then
	WriteByte(Slot1+0x1B1,ReadByte(Slot1+0x1B1)+1)
	WriteByte(Slot1+0x1B2,ReadByte(Slot1+0x1B2)+1)
	WriteByte(Save+0x3673,ReadByte(Save+0x3673)-1)
end
--DUMMY 26 = Gained Armor Slot!
if ReadByte(Save+0x3674) > 0 and ReadByte(Save+0x2500) < 8 then
	WriteByte(Save+0x2500,ReadByte(Save+0x2500)+1)
	WriteByte(Save+0x3674,ReadByte(Save+0x3674)-1)
end
--DUMMY 27 = Gained Accessory Slot!
if ReadByte(Save+0x3675) > 0 and ReadByte(Save+0x2501) < 8 then
	WriteByte(Save+0x2501,ReadByte(Save+0x2501)+1)
	WriteByte(Save+0x3675,ReadByte(Save+0x3675)-1)
end
--DUMMY 16 = Gained Item Slot!
if ReadByte(Save+0x3660) > 0 and ReadByte(Save+0x2502) < 8 then
	WriteByte(Save+0x2502,ReadByte(Save+0x2502)+1)
	WriteByte(Save+0x3660,ReadByte(Save+0x3660)-1)
end
--Donald's Staff Active Abilities
if true then
	local Staff = ReadShort(Save+0x2604)
	local Ability
	if Staff == 0x04B then --Mage's Staff
		Ability = 0x13F36
	elseif Staff == 0x094 then --Hammer Staff
		Ability = 0x13F46
	elseif Staff == 0x095 then --Victory Bell
		Ability = 0x13F56
	elseif Staff == 0x097 then --Comet Staff
		Ability = 0x13F76
	elseif Staff == 0x098 then --Lord's Broom
		Ability = 0x13F86
	elseif Staff == 0x099 then --Wisdom Wand
		Ability = 0x13F96
	elseif Staff == 0x096 then --Meteor Staff
		Ability = 0x13F66
	elseif Staff == 0x09A then --Rising Dragon
		Ability = 0x13FA6
	elseif Staff == 0x09C then --Shaman's Relic
		Ability = 0x13FC6
	elseif Staff == 0x258 then --Shaman's Relic+
		Ability = 0x14406
	elseif Staff == 0x09B then --Nobody Lance
		Ability = 0x13FB6
	elseif Staff == 0x221 then --Centurion
		Ability = 0x14316
	elseif Staff == 0x222 then --Centurion+
		Ability = 0x14326
	elseif Staff == 0x1E2 then --Save the Queen
		Ability = 0x14186
	elseif Staff == 0x1F7 then --Save the Queen+
		Ability = 0x142D6
	elseif Staff == 0x223 then --Plain Mushroom
		Ability = 0x14336
	elseif Staff == 0x224 then --Plain Mushroom+
		Ability = 0x14346
	elseif Staff == 0x225 then --Precious Mushroom
		Ability = 0x14356
	elseif Staff == 0x226 then --Precious Mushroom+
		Ability = 0x14366
	elseif Staff == 0x227 then --Premium Mushroom
		Ability = 0x14376
	elseif Staff == 0x0A1 then --Detection Staff
		Ability = 0x13FD6
	end
	if Ability then
		Ability = ReadShort(Sys3+Ability)
		if Ability == 0x0A5 then --Donald Fire
			WriteShort(Save+0x26F6,0x80A5)
			WriteByte(Sys3+0x11F0B,0)
		elseif Ability == 0x0A6 then --Donald Blizzard
			WriteShort(Save+0x26F6,0x80A6)
			WriteByte(Sys3+0x11F23,0)
		elseif Ability == 0x0A7 then --Donald Thunder
			WriteShort(Save+0x26F6,0x80A7)
			WriteByte(Sys3+0x11F3B,0)
		elseif Ability == 0x0A8 then --Donald Cure
			WriteShort(Save+0x26F6,0x80A8)
			WriteByte(Sys3+0x11F53,0)
		else
			WriteShort(Save+0x26F6,0) --Remove Ability Slot 80
			WriteByte(Sys3+0x11F0B,2) --Restore Original AP Costs
			WriteByte(Sys3+0x11F23,2)
			WriteByte(Sys3+0x11F3B,2)
			WriteByte(Sys3+0x11F53,3)
		end
	end
end
--Goofy's Shield Active Abilities
if true then
	local Shield = ReadShort(Save+0x2718)
	local Ability --Safeguard if none of the above (i.e. Main Menu)
	if Shield == 0x031 then --Knight's Shield
		Ability = 0x13FE6
	elseif Shield == 0x08B then --Adamant Shield
		Ability = 0x13FF6
	elseif Shield == 0x08C then --Chain Gear
		Ability = 0x14006
	elseif Shield == 0x08E then --Falling Star
		Ability = 0x14026
	elseif Shield == 0x08F then --Dreamcloud
		Ability = 0x14036
	elseif Shield == 0x090 then --Knight Defender
		Ability = 0x14046
	elseif Shield == 0x08D then --Ogre Shield
		Ability = 0x14016
	elseif Shield == 0x091 then --Genji Shield
		Ability = 0x14056
	elseif Shield == 0x092 then --Akashic Record
		Ability = 0x14066
	elseif Shield == 0x259 then --Akashic Record+
		Ability = 0x14416
	elseif Shield == 0x093 then --Nobody Guard
		Ability = 0x14076
	elseif Shield == 0x228 then --Frozen Pride
		Ability = 0x14386
	elseif Shield == 0x229 then --Frozen Pride+
		Ability = 0x14396
	elseif Shield == 0x1E3 then --Save the King
		Ability = 0x14196
	elseif Shield == 0x1F8 then --Save the King+
		Ability = 0x142E6
	elseif Shield == 0x22A then --Joyous Mushroom
		Ability = 0x143A6
	elseif Shield == 0x22B then --Joyous Mushroom+
		Ability = 0x143B6
	elseif Shield == 0x22C then --Majestic Mushroom
		Ability = 0x143C6
	elseif Shield == 0x22D then --Majestic Mushroom+
		Ability = 0x143D6
	elseif Shield == 0x22E then --Ultimate Mushroom
		Ability = 0x143E6
	elseif Shield == 0x032 then --Detection Shield
		Ability = 0x14086
	elseif Shield == 0x033 then --Test the King
		Ability = 0x14096
	end
	if Ability then --Safeguard if none of the above (i.e. Main Menu)
		Ability = ReadShort(Sys3+Ability)
		if Ability == 0x1A7 then --Goofy Tornado
			WriteShort(Save+0x280A,0x81A7)
			WriteByte(Sys3+0x11F6B,0)
		elseif Ability == 0x1AD then --Goofy Bash
			WriteShort(Save+0x280A,0x81AD)
			WriteByte(Sys3+0x11F83,0)
		elseif Ability == 0x1A9 then --Goofy Turbo
			WriteShort(Save+0x280A,0x81A9)
			WriteByte(Sys3+0x11F9B,0)
		else
			WriteShort(Save+0x280A,0) --Remove Ability Slot 80
			WriteByte(Sys3+0x11F6B,2) --Restore Original AP Costs
			WriteByte(Sys3+0x11F83,2)
			WriteByte(Sys3+0x11F9B,2)
		end
	end
end
--Enable Secret Movie after All Worlds are Cleared
if Place == 0x0001 then
	local PostStorySaves = {0x1EDE,0x1D9E,0x1D3E,0x1E5E,0x1D7E,0x1D6E,0x1DDE,0x1CFD,0x1D2E,0x1E9E,0x1E1E,0x1EBE,0x1CFE} --Ordered by Portal Number
	local Completed = true
	for index in pairs(PostStorySaves) do
		if ReadByte(Save+PostStorySaves[index]) == 0 then --World Not Cleared
			Completed = false
			break
		end
	end
	if Completed then
		BitOr(Save+0x1D1E,0x80) --HB_SCENARIO_5_END (100AW and Atlantica should be automatic)
	else
		BitNot(Save+0x1D1E,0x80) --In case someone did HB 5
	end
end
--[[Enable Anti Form Forcing
if ReadByte(Save+0x3524) == 6 then --In Anti Form
	BitOr(Save+0x36C0,0x20) --Unlocks Anti Form
end--]]
--[[Anti Form Costs Max Drive Instead of a Static 9.
WriteByte(Sys3+0x00500,ReadByte(Slot1+0x1B2))--]]
end

function TWtNW()
--Data Xemnas -> The World that Never Was
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1EDE)
	local Progress = ReadByte(Save+0x1EDF)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --[1st Visit, Before Entering Castle that Never Was]
			WarpRoom = 0x01
			WriteInt(Save+0x357C,0x12020100)
		elseif Progress == 1 then --Before Xigbar
			WarpRoom = 0x04
			WriteInt(Save+0x357C,0x12020100)
		elseif Progress == 2 then --[After Xigbar, After Reunion with Riku & Kairi]
			WarpRoom = 0x09
			WriteInt(Save+0x357C,0x12020100)
		elseif Progress == 3 then --[Before Luxord, After Saix]
			WarpRoom = 0x0D
			WriteInt(Save+0x357C,0x12020100)
		elseif Progress == 4 then --[After Riku Joins the Party, Before Xemnas I]
			WarpRoom = 0x0D
		end
	elseif PostSave == 1 then --Alley to Between
		WarpRoom = 0x01
	elseif PostSave == 2 then --The Brink of Despair
		WarpRoom = 0x04
	elseif PostSave == 3 then --Twilight's View
		WarpRoom = 0x09
	elseif PostSave == 4 then --Proof of Existence
		WarpRoom = 0x0D
	elseif PostSave == 5 then --The Altar of Naught
		WarpRoom = 0x12
	end
	Spawn('Short',0x0A,0x07C,WarpRoom)
end
--World Progress
if Place == 0x0412 and Events(Null,Null,0x02) then --The Path to the Castle
	WriteByte(Save+0x1EDF,1)
elseif Place == 0x1012 and Events(Null,Null,0x01) then --Riku!
	WriteByte(Save+0x1EDF,2)
elseif Place == 0x1012 and Events(Null,Null,0x02) then --Ansem's Wager
	WriteByte(Save+0x1EDF,3)
elseif Place == 0x1012 and Events(Null,Null,0x05) then --Back to His Old Self
	WriteByte(Save+0x1EDF,4)
elseif Place == 0x1212 and Events(Null,Null,0x03) then --The Door to Kingdom Hearts
	BitOr(Save+0x1EDA,0x04)  --EH_FM_XEM_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1EDE,5) --Post-Story Save
	WriteShort(Save+0x1B24,0x03) --Memory's Skyscraper BTL
	WriteShort(Save+0x1B7C,0x0D) --The Altar of Naught MAP (Data Door)
	BitOr(Save+0x1ED6,0x80) --EH_JIMMNY_FULL_OPEN
elseif Place == 0x0001 and Events(0x3A,0x3A,0x3A) then --The Door to Light
	WriteInt(Save+0x000C,0x321A04) --Post-Game Save at Garden of Assemblage
	BitNot(Save+0x1CEE,0x0C) --TT_TT21 (Computer Room Flag Fix)
end
--The World that Never Was Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1EDE) > 0 then
	if PrevPlace == 0x0112 then --Alley to Between
		WriteByte(Save+0x1EDE,1)
	elseif PrevPlace == 0x0412 then --The Brink of Despair
		WriteByte(Save+0x1EDE,2)
	elseif PrevPlace == 0x0912 then --Twilight's View
		WriteByte(Save+0x1EDE,3)
	elseif PrevPlace == 0x0D12 then --Proof of Existence
		WriteByte(Save+0x1EDE,4)
	elseif PrevPlace == 0x1212 then --The Altar of Naught
		WriteByte(Save+0x1EDE,5)
	end
end
--Final Door Requirements and Data Xemnas Warp
if Place == 0x1212 and Events(0x04,0x00,0x04) then
	if ReadByte(Save+0x36B2) > 0 and ReadByte(Save+0x36B3) > 0 and ReadByte(Save+0x36B4) > 0 then --All Proofs Obtained
		Spawn('Short',0x05,0x060,0x13D) --Spawn Door RC
	else
		Spawn('Short',0x05,0x060,0x000) --Despawn Door RC
	end
end
--[[Skip Dragon Xemnas
if Place == 0x1D12 then
	Spawn('Short',0x03,0x038,0x5C)
end--]]
--Laser Dome Skip
if Place == 0x1412 and ReadShort(Slot3) == 1 then --Boss in Xemnas II's arena have 1 HP
	WriteShort(Slot3,0) --Change to 0 HP
end
--Post Final Xemnas Cutscenes
if Place == 0x1412 and ReadByte(Pause) == 2 then
	WriteByte(Pause,0) --Enable Pause
elseif Place == 0x0001 and ReadByte(Pause) == 2 then
	WriteByte(Pause,0) --Enable Pause
end
end

function LoD()
--Data Xigbar -> The Land of Dragons
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1D9E)
	local Progress = ReadByte(Save+0x1D9F)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --[1st Visit, Before Mountain Climb]
			WarpRoom = 0x00
		elseif Progress == 1 then --Before Village Cave Heartless
			WarpRoom = 0x04
		elseif Progress == 2 then --Before Summit Rapid Heartless
			WarpRoom = 0x0C
		elseif Progress == 3 then --[After Summit Heartless, Before Shan Yu]
			WarpRoom = 0x00
		elseif Progress == 4 then --Post 1st Visit
			WarpRoom = 0x0C
		elseif Progress == 5 then --[2nd Visit, Before Riku]
			WarpRoom = 0x0C
		elseif Progress == 6 then --[Before Imperial Square Heartless II, Before Antechamber Nobodies]
			WarpRoom = 0x00
		elseif Progress == 7 then --Before Storm Rider
			WarpRoom = 0x0B
		end
	elseif PostSave == 1 then --Bamboo Grove
		WarpRoom = 0x00
	elseif PostSave == 2 then --Village (Intact)
		WarpRoom = 0x04
	elseif PostSave == 3 then --Throne Room
		WarpRoom = 0x0B
	end
	Spawn('Short',0x0A,0x09C,WarpRoom)
end
--World Progress
if Place == 0x0308 and Events(0x47,0x47,0x47) then --Mountain Climb
	WriteByte(Save+0x1D9F,1)
elseif Place == 0x0C08 and Events(Null,Null,0x01) then --Attack on the Camp
	WriteByte(Save+0x1D9F,2)
elseif Place == 0x0708 and Events(Null,Null,0x02) then --Avalanche
	WriteByte(Save+0x1D9F,3)
	if ReadInt(CutLen) == 0x064 then --Remove Mulan's Auto Limit
		for Slot = 0,79 do
			local AbilitySlot = Save + 0x2AA8 + Slot*2
			if ReadShort(AbilitySlot) == 0x81A1 then
				WriteShort(AbilitySlot,0x01A1)
				break
			end
		end
	end
elseif Place == 0x0908 and Events(0x69,0x69,0x69) then --The Hero Who Saved the Day
	WriteByte(Save+0x1D9F,4)
elseif ReadByte(Save+0x1D9F) == 4 and ReadByte(Save+0x35AF) > 0 then --2nd Visit Unlocked
	WriteByte(Save+0x1D9F,5)
	WriteShort(Save+0x0C14,0x12) --Bamboo Grove EVT
	WriteShort(Save+0x0C18,0x0A) --Encampment BTL
	WriteShort(Save+0x0C1E,0x0A) --Checkpoint BTL
	WriteShort(Save+0x0C24,0x0A) --Mountain Trail BTL
	WriteShort(Save+0x0C30,0x0A) --Village Cave BTL
	WriteShort(Save+0x0C42,0x0A) --Imperial Square BTL
	WriteShort(Save+0x0C48,0x0A) --Palace Gate BTL
	WriteShort(Save+0x0C5C,0x0A) --Village (Destroyed) EVT
elseif Place == 0x0608 and Events(Null,Null,0x0C) then --The City is in Danger!
	WriteByte(Save+0x1D9F,6)
elseif Place == 0x0B08 and Events(Null,Null,0x0A) then --To the Emperor
	WriteByte(Save+0x1D9F,7)
elseif Place == 0x0B08 and Events(Null,Null,0x0B) then --The Highest Reward
	BitOr(Save+0x1ED9,0x80)  --EH_FM_XIG_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1D9E,2) --Post-Story Save
	WriteShort(Save+0x0C3A,0x0D) --Summit MAP (Data Door)
end
--The Land of Dragons Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1D9E) > 0 then
	if PrevPlace == 0x0008 then --Bamboo Grove
		WriteByte(Save+0x1D9E,1)
	elseif PrevPlace == 0x0408 then --Village (Intact)
		WriteByte(Save+0x1D9E,2)
	elseif PrevPlace == 0x0B08 then --Throne Room
		WriteByte(Save+0x1D9E,3)
	end
end
end

function BC()
--Data Xaldin -> Beast's Castle
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1D3E)
	local Progress = ReadByte(Save+0x1D3F)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x00
			Spawn('Short',0x0A,0x0B6,0x00)
		elseif Progress == 1 then --[After Parlor Heartless, Before Meeting Belle]
			WarpRoom = 0x01
		elseif Progress == 2 then --After Meeting Belle
			WarpRoom = 0x02
		elseif Progress == 3 then --[Before the Wardrobe, After Thresholder]
			WarpRoom = 0x01
		elseif Progress == 4 then --[Before Talking to Cogsworth, Before Beast]
			WarpRoom = 0x0A
		elseif Progress == 5 then --[After Beast, After Talking to the Wardrobe]
			WarpRoom = 0x02
		elseif Progress == 6 then --Before Shadow Stalker
			WarpRoom = 0x01
		elseif Progress == 7 then --Post 1st Visit
			WarpRoom = 0x01
		elseif Progress == 8 then --2nd Visit
			WarpRoom = 0x02
		elseif Progress == 9 then --[Before Ballroom Nobodies, After Ballroom Nobodies]
			WarpRoom = 0x01
		elseif Progress == 10 then --Before Talking to Beast
			WarpRoom = 0x03
		elseif Progress == 11 then --[Before Entrance Hall Nobodies, Before Xaldin]
			WarpRoom = 0x01
		end
	elseif ReadByte(Save+0x1D3E) == 1 then --Parlor
		WarpRoom = 0x01
	elseif ReadByte(Save+0x1D3E) == 2 then --Belle's Room
		WarpRoom = 0x02
	elseif ReadByte(Save+0x1D3E) == 3 then --Dungeon
		WarpRoom = 0x0A
	elseif ReadByte(Save+0x1D3E) == 4 then --Beast's Room
		WarpRoom = 0x03
	end
	Spawn('Short',0x0A,0x0BC,WarpRoom)
end
--World Progress
if Place == 0x0105 and Events(Null,Null,0x01) then --Parlor Heartless
	WriteByte(Save+0x1D3F,1)
elseif Place == 0x0205 and Events(Null,Null,0x02) then --A Familiar Voice
	WriteByte(Save+0x1D3F,2)
elseif Place == 0x0805 and Events(Null,Null,0x02) then --The Wardrobe
	WriteByte(Save+0x1D3F,3)
elseif Place == 0x0A05 and Events(Null,Null,0x01) then --The Castle's Residents
	WriteByte(Save+0x1D3F,4)
elseif Place == 0x0305 and Events(Null,Null,0x01) then --Organization XIII's Ploy
	WriteByte(Save+0x1D3F,5)
elseif Place == 0x0005 and Events(Null,Null,0x03) then --Damsel in Distress
	WriteByte(Save+0x1D3F,6)
elseif Place == 0x0E05 and Events(Null,Null,0x01) then --Things are Just Beginning
	WriteByte(Save+0x1D3F,7)
elseif ReadByte(Save+0x1D3F) == 7 and ReadByte(Save+0x35B3) > 0 then --2nd Visit
	WriteByte(Save+0x1D3F,8)
	WriteShort(Save+0x0792,0x00) --Entrance Hall BTL
	WriteShort(Save+0x07A0,0x0A) --Belle's Room EVT
	WriteShort(Save+0x07CE,0x00) --Dungeon BTL
elseif Place == 0x0205 and Events(Null,Null,0x0A) then --Dressing Up
	WriteByte(Save+0x1D3F,9)
elseif Place == 0x0405 and Events(Null,Null,0x0A) then --Uninvited Guests
	WriteByte(Save+0x1D3F,10)
elseif Place == 0x0305 and Events(Null,Null,0x0B) then --Don't Give Up
	WriteByte(Save+0x1D3F,11)
elseif Place == 0x0D05 and Events(Null,Null,0x0A) then --The Whirlwind Lancer: Xaldin
	BitNot(Save+0x1D35,0x01) --BB_216_END (Change Spawn ID in Next Cutscene Properly)
elseif Place == 0x0605 and Events(Null,Null,0x0B) then --Stay With Me
	BitOr(Save+0x1D34,0x80)  --BB_FM_XAL_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1D3E,1) --Post-Story Save
	WriteShort(Save+0x07A8,0x0D) --Ballroom (Light) MAP (Data Door)
end
--Beast's Castle Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1D3E) > 0 then
	if PrevPlace == 0x0105 then --Parlor
		WriteByte(Save+0x1D3E,1)
	elseif PrevPlace == 0x0205 then --Belle's Room
		WriteByte(Save+0x1D3E,2)
	elseif PrevPlace == 0x0A05 then --Dungeon
		WriteByte(Save+0x1D3E,3)
	elseif PrevPlace == 0x0305 then --Beast's Room
		WriteByte(Save+0x1D3E,4)
	end
end
--Mrs. Potts Teleport in Lantern Minigame
if Place == 0x0C05 and Events(Null,0x16,0x02) then
	if Platform == 'PS2' then --PC Address is Currently Unknown
		local PottsLocAddress = 0x1ABB7D0
		if ReadFloat(Gauge1) == 0 then --Cogsworth Out of Stamina
			if not PottsCoordinate then
				PottsCoordinate = ReadArray(PottsLocAddress,12)
			end
			WriteInt(PottsLocAddress+0,0xC5241753)
			WriteInt(PottsLocAddress+4,0x00000000)
			WriteInt(PottsLocAddress+8,0x44CF7FBE)
		elseif ReadFloat(Gauge1) == 35 and PottsCoordinate then --Stamina Refilled
			WriteArray(PottsLocAddress,PottsCoordinate)
			PottsCoordinate = Null
		end
	end
else --Exited Minigame
	PottsCoordinate = Null
end
--Marluxia's Absent Silhouette Removal
if ReadShort(Save+0x07A4) == 0x01 then
	WriteShort(Save+0x07A4,0x00) --Beast's Room BTL
	WriteShort(Now+6,0x00)
end
end

function HT() 
--Data Vexen -> Halloween Town
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1E5E)
	local Progress = ReadByte(Save+0x1E5F)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x04
			Spawn('Short',0x0A,0x0D6,0x00)
		elseif Progress == 1 then --[Before Halloween Town Square Heartless, Before Entering Christmas Town]
			WarpRoom = 0x01
		elseif Progress == 2 then --[Before Candy Cane Lane Heartless, After Candy Cane Lane Heartless]
			WarpRoom = 0x05
		elseif Progress == 3 then --After Entering Santa's House
			WarpRoom = 0x08
		elseif Progress == 4 then --[After Leaving Santa's House, Before Prison Keeper]
			WarpRoom = 0x05
		elseif Progress == 5 then --After Prison Keeper
			WarpRoom = 0x01
		elseif Progress == 6 then --Before Oogie Boogie
			WarpRoom = 0x08
		elseif Progress == 7 then --Post 1st Visit
			WarpRoom = 0x05
		elseif Progress == 8 then --2nd Visit
			WarpRoom = 0x01
		elseif Progress == 9 then --Before Lock, Shock, Barrel
			WarpRoom = 0x08
		elseif Progress == 10 then --Before Halloween Town Square Presents
			WarpRoom = 0x05
		elseif Progress == 11 then --[Before Gift Wrapping, Before the Experiment]
			WarpRoom = 0x08
		end
	elseif PostSave == 1 then --Dr. Finklestein's Lab
		WarpRoom = 0x01
	elseif PostSave == 2 then --Yuletide Hill
		WarpRoom = 0x05
	elseif PostSave == 3 then --Santa's House
		WarpRoom = 0x08
	end
	Spawn('Short',0x0A,0x0DC,WarpRoom)
end
--World Progress
if Place == 0x010E and Events(Null,Null,0x01) then --The Doctor's Research
	WriteByte(Save+0x1E5F,1)
elseif Place == 0x050E and Events(Null,Null,0x01) then --Christmas Town
	WriteByte(Save+0x1E5F,2)
elseif Place == 0x080E and Events(Null,Null,0x01) then --Santa's Home
	WriteByte(Save+0x1E5F,3)
elseif Place == 0x060E and Events(Null,Null,0x03) then --Follow the Footprints
	WriteByte(Save+0x1E5F,4)
elseif Place == 0x040E and Events(0x3A,0x3A,0x3A) then --Maleficent and Oogie
	WriteByte(Save+0x1E5F,5)
elseif Place == 0x050E and Events(Null,Null,0x03) then --Where There's Smoke...
	WriteByte(Save+0x1E5F,6)
elseif Place == 0x060E and Events(Null,Null,0x05) then --Everyone Has a Job to Do
	WriteByte(Save+0x1E5F,7)
elseif ReadByte(Save+0x1E5F) == 7 and ReadByte(Save+0x35B4) > 0 then --2nd Visit
	WriteByte(Save+0x1E5F,8)
	WriteShort(Save+0x151A,0x0A) --Dr. Finklestein's Lab EVT
	WriteShort(Save+0x1534,0x04) --Candy Cane Lane MAP (Destroyed Sleigh)
	WriteShort(Save+0x1540,0x02) --Santa's House MAP (Visibility)
	WriteShort(Save+0x1546,0x00) --Toy Factory: Shipping and Receiving MAP (Despawn Skateboard)
elseif Place == 0x080E and Events(Null,Null,0x14) then --The Stolen Presents
	WriteByte(Save+0x1E5F,9)
elseif Place == 0x0A0E and Events(Null,Null,0x0A) then --The Three Culprits
	WriteByte(Save+0x1E5F,10)
elseif Place == 0x000E and Events(Null,Null,0x0A) then --Retrieving the Presents
	WriteByte(Save+0x1E5F,11)
elseif Place == 0x000E and Events(Null,Null,0x0B) then --Merry Christmas!
	BitOr(Save+0x1D26,0x01)  --HB_FM_VEX_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1E5E,2) --Post-Story Save
	WriteShort(Save+0x1530,0x01) --Yuletide Hill BTL
elseif Place == 0x2004 and Events(0x79,0x79,0x79) then --Vexen Defeated
	WriteShort(Save+0x1530,0x02) --Yuletide Hill BTL
end
--Halloween Town Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1E5E) > 0 then
	if PrevPlace == 0x010E then --Dr. Finklestein's Lab
		WriteByte(Save+0x1E5E,1)
	elseif PrevPlace == 0x050E then --Yuletide Hill
		WriteByte(Save+0x1E5E,2)
	elseif PrevPlace == 0x080E then --Santa's House
		WriteByte(Save+0x1E5E,3)
	end
end
--[[Fast Oogie
if Place == 0x090E and Events(0x37,0x37,0x37) then
	WriteInt(Slot2+8,0)
	WriteInt(Slot3+8,0)
	WriteInt(Slot4+8,0)
end]]
--[[Fast Gift Wrapping
if Place == 0x0A0E and Events(0x3F,0x3F,0x3F) then
	WriteString(Obj0+0x0ED70,'F_NM170_XL')
	WriteString(Obj0+0x0ED90,'F_NM170_XL.mset')
	WriteString(Obj0+0x0EDD0,'F_NM170_XL')
	WriteString(Obj0+0x0EDF0,'F_NM170_XL.mset')
	WriteString(Obj0+0x0EE30,'F_NM170_XL')
	WriteString(Obj0+0x0EE50,'F_NM170_XL.mset')
end--]]
end

function Ag()
--Data Lexaeus -> Agrabah
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1D7E)
	local Progress = ReadByte(Save+0x1D7F)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x00
			Spawn('Short',0x0A,0x0F6,0x00)
		elseif Progress == 1 then --Before Meeting Jasmine & Aladdin
			WarpRoom = 0x02
		elseif Progress == 2 then --[Before Entering Cave of Wonders, Before Abu Escort]
			WarpRoom = 0x06
		elseif Progress == 3 then --Before Chasm of Challenges
			WarpRoom = 0x09
		elseif Progress == 4 then --[After Chasm of Challenges, Before Treasure Room Heartless]
			WarpRoom = 0x0D
		elseif Progress == 5 then --Before Volcanic Lord & Blizzard Lord
			WarpRoom = 0x02
		elseif Progress == 6 then --Post 1st Visit
			WarpRoom = 0x02
		elseif Progress == 7 then --2nd Visit
			WarpRoom = 0x04
		elseif Progress == 8 then --Start of 2nd Visit
			WarpRoom = 0x0F
		elseif Progress == 9 then --[Before Entering Sandswept Ruins, Sandswept Ruins Crystals]
			WarpRoom = 0x06
		elseif Progress == 10 then --Before Carpet Escape
			WarpRoom = 0x0B
		elseif Progress == 11 then --Before Genie Jafar
			WarpRoom = 0x0F
		end
	elseif PostSave == 1 then --The Peddler's Shop (Rich)
		WarpRoom = 0x0F
	elseif PostSave == 2 then --Palace Walls
		WarpRoom = 0x06
	elseif PostSave == 3 then --The Cave of Wonders: Stone Guardians
		WarpRoom = 0x09
	elseif PostSave == 4 then --The Cave of Wonders: Chasm of Challenges
		WarpRoom = 0x0D
	elseif PostSave == 5 then --Ruined Chamber
		WarpRoom = 0x0B
	end
	Spawn('Short',0x0A,0x0FC,WarpRoom)
end
--World Progress
if Place == 0x0007 and Events(Null,Null,0x01) then --Turning Over a New Feather
	WriteByte(Save+0x1D7F,1)
elseif Place == 0x0007 and Events(Null,Null,0x03) then --Aladdin and Abu
	WriteByte(Save+0x1D7F,2)
elseif Place == 0x0907 and Events(Null,Null,0x03) then --A Path is Revealed
	WriteByte(Save+0x1D7F,3)
elseif Place == 0x0D07 and Events(Null,Null,0x02) then --Beyond the Doors
	WriteByte(Save+0x1D7F,4)
elseif Place == 0x0A07 and Events(0x3A,0x3A,0x3A) then --Back to Agrabah!
	WriteShort(Save+0x0AD0,0x02) --Treasure Room EVT
elseif Place == 0x0207 and Events(Null,Null,0x03) then --Behind the Curtain
	WriteByte(Save+0x1D7F,5)
	WriteShort(Save+0x0AD0,0x00) --Treasure Room EVT
elseif Place == 0x0307 and Events(Null,Null,0x03) then --Come Back Soon
	WriteByte(Save+0x1D7F,6)
elseif ReadByte(Save+0x1D7F) == 6 and ReadByte(Save+0x35C0) > 0 then --2nd Visit
	WriteByte(Save+0x1D7F,7)
	WriteShort(Save+0x0A9C,0x00) --The Peddler's Shop (Poor) MAP (Remove Treasure)
	WriteShort(Save+0x0AA0,0x00) --The Peddler's Shop (Poor) EVT
	WriteShort(Save+0x0AAC,0x0A) --Vault EVT
elseif Place == 0x0407 and Events(Null,Null,0x0A) then --Jafar's Return
	WriteByte(Save+0x1D7F,8)
elseif Place == 0x0607 and Events(Null,Null,0x0A) then --Genie Works His Magic
	WriteByte(Save+0x1D7F,9)
elseif Place == 0x0B07 and Events(Null,Null,0x0A) then --Iago's Confession
	WriteByte(Save+0x1D7F,10)
elseif Place == 0x0607 and Events(Null,Null,0x0B) then --A Successful Escape
	WriteByte(Save+0x1D7F,11)
elseif Place == 0x0007 and Events(Null,Null,0x0A) then --Cosmic Razzle-Dazzle
	BitOr(Save+0x1D26,0x02)  --HB_FM_LEX_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1D7E,2) --Post-Story Save
	WriteShort(Save+0x0AEC,0x01) --The Peddler's Shop (Rich) BTL
elseif Place == 0x2104 and Events(0x7B,0x7B,0x7B) then --Lexaeus Defeated
	WriteShort(Save+0x0AEC,0x02) --The Peddler's Shop (Rich) BTL
end
--Agrabah Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1D7E) > 0 then
	if PrevPlace == 0x0F07 then --The Peddler's Shop (Rich)
		WriteByte(Save+0x1D7E,1)
	elseif PrevPlace == 0x0607 then --Palace Walls
		WriteByte(Save+0x1D7E,2)
	elseif PrevPlace == 0x0907 then --The Cave of Wonders: Stone Guardians
		WriteByte(Save+0x1D7E,3)
	elseif PrevPlace == 0x0D07 then --The Cave of Wonders: Chasm of Challenges
		WriteByte(Save+0x1D7E,4)
	elseif PrevPlace == 0x0B07 then --Ruined Chamber
		WriteByte(Save+0x1D7E,5)
	end
end
--Lexaeus' Absent Sillhouette Removal
if ReadShort(Save+0x0AEC) == 0x01 and ReadByte(Save+0x1D7E) == 0 then --Agrabah Not Cleared
	WriteShort(Save+0x0AEC,0x00) --The Peddler's Shop (Rich) BTL
end
end

function OC()
--Data Zexion -> Olympus Coliseum
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1D6E)
	local Progress = ReadByte(Save+0x1D6F)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x00
			Spawn('Short',0x0A,0x116,0x00)
		elseif Progress == 1 then --[Before Helping Megara Up, Chasing after Demyx]
			WarpRoom = 0x03
		elseif Progress == 2 then --[Before Entering Valley of the Dead, Before Cerberus]
			WarpRoom = 0x0A
		elseif Progress == 3 then --[After Cerberus, Before Seeing Hercules]
			WarpRoom = 0x03
		elseif Progress == 4 then --[Before Seeing Phil, After Phil's Training]
			WarpRoom = 0x04
		elseif Progress == 5 then --[Before Hercules Fights Hydra, Before Demyx's Clones]
			WarpRoom = 0x03
		elseif Progress == 6 then --[After Demyx's Water Clones, Before Pete]
			WarpRoom = 0x0C
		elseif Progress == 7 then --Before Hydra
			WarpRoom = 0x03
		elseif Progress == 8 then --Post 1st Visit
			WarpRoom = 0x03
		elseif Progress == 9 then --[2nd Visit, Before Talking to Auron]
			WarpRoom = 0x03
		elseif Progress == 10 then --[After Talking to Auron, Before Hades' Chamber Nobodies]
			WarpRoom = 0x0A
		elseif Progress == 11 then --Before Hades
			WarpRoom = 0x03
		end
	elseif PostSave == 1 then --Underworld Entrance
		WarpRoom = 0x03
	elseif PostSave == 2 then --Cave of the Dead: Inner Chamber
		WarpRoom = 0x0A
	elseif PostSave == 3 then --The Lock
		WarpRoom = 0x0C
	elseif PostSave == 4 then --Coliseum Gates
		WarpRoom = 0x02
	end
	Spawn('Short',0x0A,0x11C,WarpRoom)
end
--World Progress
if Place == 0x0306 and Events(Null,Null,0x02) then --Megara
	WriteByte(Save+0x1D6F,1)
elseif Place == 0x0A06 and Events(Null,Null,0x01) then --A Fleeing member of the Organization
	WriteByte(Save+0x1D6F,2)
elseif Place == 0x0406 and Events(Null,Null,0x01) then --The Exhausted Hero
	WriteByte(Save+0x1D6F,3)
elseif Place == 0x0106 and Events(Null,Null,0x02) then --The Reunion
	WriteByte(Save+0x1D6F,4)
elseif Place == 0x0306 and Events(Null,Null,0x05) then --Arriving in the Underworld
	WriteByte(Save+0x1D6F,5)
elseif Place == 0x1106 and Events(Null,Null,0x01) then --Sora and Friends vs. Demyx
	WriteByte(Save+0x1D6F,6)
elseif Place == 0x0806 and Events(Null,Null,0x01) then --Presistent Ol' Pete
	WriteByte(Save+0x1D6F,7)
	WriteShort(Save+0x0944,0x03) --Well of Captivity EVT (Skip Megara Escort)
elseif Place == 0x1206 and Events(0xAB,0xAB,0xAB) then --The Aftermath
	WriteByte(Save+0x1D6F,8)
	WriteShort(Save+0x0926,0x0A) --Underworld Entrance EVT
elseif ReadByte(Save+0x1D6F) == 8 and ReadByte(Save+0x35AE) > 0 then --2nd Visit
	WriteByte(Save+0x1D6F,9)
	WriteShort(Save+0x0920,0x12) --Coliseum Gates (Destroyed) EVT
	if ReadShort(Save+0x0926) == 0x0A then
		WriteShort(Save+0x0926,0x0B) --Underworld Entrance EVT
	else
		WriteShort(Save+0x0926,0x0C) --Underworld Entrance EVT
	end
elseif Place == 0x0306 and Events(Null,Null,0x14) then --(After) Sneaking into Hades' Chambers
	WriteByte(Save+0x1D6F,10)
elseif Place == 0x0606 and Events(Null,Null,0x0A) then --Voices from the Past
	WriteByte(Save+0x1D6F,11)
elseif Place == 0x0E06 and Events(Null,Null,0x0A) then --The Constellation of Heroes
	BitOr(Save+0x1D26,0x04)  --HB_FM_ZEX_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1D6E,1) --Post-Story Save
	WriteShort(Save+0x094E,0x01) --Cave of the Dead: Inner Chamber BTL
elseif Place == 0x2204 and Events(0x7D,0x7D,0x7D) then --Zexion Defeated
	WriteShort(Save+0x094E,0x02) --Cave of the Dead: Inner Chamber BTL
end
--Olympus Coliseum Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1D6E) > 0 then
	if PrevPlace == 0x0306 then --Underworld Entrance
		WriteByte(Save+0x1D6E,1)
	elseif PrevPlace == 0x0A06 then --Cave of the Dead: Inner Chamber
		WriteByte(Save+0x1D6E,2)
	elseif PrevPlace == 0x0C06 then --The Lock
		WriteByte(Save+0x1D6E,3)
	elseif PrevPlace == 0x0206 then --Coliseum Gates
		WriteByte(Save+0x1D6E,4)
	end
end
--Enable Drive with Olympus Stone
if ReadByte(Save+0x3644) > 0 then
	if Place == 0x0306 then --Underworld Entrance
		Spawn('Short',0x0F,0x01C,0) --BTL 0x16
	elseif Place == 0x0506 then --Valley of the Dead
		Spawn('Short',0x06,0x060,0) --BTL 0x01
		Spawn('Short',0x06,0x08C,0) --BTL 0x02
		Spawn('Short',0x06,0x10C,0) --BTL 0x6F (Hades Escape)
	elseif Place == 0x0606 then --Hades' Chamber
		Spawn('Short',0x05,0x014,0) --BTL 0x16
		Spawn('Short',0x05,0x064,0) --BTL 0x70 (Invincible Hades)
	elseif Place == 0x0706 then --Cave of the Dead: Entrance
		Spawn('Short',0x07,0x0B0,0) --BTL 0x01
		Spawn('Short',0x07,0x10C,0) --BTL 0x02
		Spawn('Short',0x07,0x1A0,0) --BTL 0x72 (Cerberus)
	elseif Place == 0x0A06 then --Cave of the Dead: Inner Chamber
		Spawn('Short',0x0A,0x010,0) --BTL 0x16
	elseif Place == 0x0B06 then --Underworld Caverns: Entrance
		Spawn('Short',0x09,0x044,0) --BTL 0x01
	elseif Place == 0x0F06 then --Cave of the Dead: Passage
		Spawn('Short',0x0B,0x0AC,0) --BTL 0x01
		Spawn('Short',0x0B,0x0F4,0) --BTL 0x02
	elseif Place == 0x1006 then --Underworld Caverns: The Lost Road
		Spawn('Short',0x09,0x040,0) --BTL 0x01
	elseif Place == 0x1106 then --Underworld Caverns: Atrium
		Spawn('Short',0x08,0x034,0) --BTL 0x16
		Spawn('Short',0x08,0x078,0) --BTL 0x7B (Demyx's Water Clones)
	end
end
--Softlock Prevention Without Cups Unlocked
if Place == 0x0306 and ReadShort(Save+0x239C)&0x07BA == 0 then
	Spawn('Short',0x2E,0x05C,0x0E4) --Before 2nd Visit Text
	Spawn('Short',0x2E,0x060,0x01F) --Before 2nd Visit RC
	Spawn('Short',0x30,0x05C,0x32B) --During 2nd Visit Text
	Spawn('Short',0x30,0x060,0x01F) --During 2nd Visit RC
end
--Unlock All Paradox Cup after Goddess of Fate Cup
if Place == 0x0D06 and Events(0xB7,0xB7,0xB7) then
	WriteShort(Save+0x239C,ReadShort(Save+0x239C)|0x07BA)
end
--Unlock All Cups with Hades Cups Trophy
if ReadByte(Save+0x3696) > 0 then
	WriteShort(Save+0x239C,ReadShort(Save+0x239C)|0x07BA)
	if ReadByte(Save+0x1D6E) > 0 then --Make Hades Appear in His Chamber after 2nd Visit
		WriteShort(Save+0x0936,0x15) --Hades' Chamber BTL
		WriteShort(Save+0x0938,0x14) --Hades' Chamber EVT
	end
end
--Zexion's Absent Silhouette Removal
if ReadShort(Save+0x094E) == 0x01 and ReadByte(Save+0x1D6E) == 0 then --Olympus Coliseum Not Cleared
	WriteShort(Save+0x094E,0x00) --Cave of the Dead: Inner Chamber BTL
end
end

function PL()
--Data Saix -> Pride Lands
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1DDE)
	local Progress = ReadByte(Save+0x1DDF)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x10
		elseif Progress == 1 then --[Before Elephant Graveyard Heartless, After Elephant Graveyard Heartless]
			WarpRoom = 0x06
		elseif Progress == 2 then --After Entering Pride Rock
			WarpRoom = 0x01
		elseif Progress == 3 then --[After Leaving Pride Rock, After Learning Dash]
			WarpRoom = 0x06
		elseif Progress == 4 then --[After Entering Oasis, Before Talking to Simba]
			WarpRoom = 0x09
		elseif Progress == 5 then --After Talking to Simba
			WarpRoom = 0x06
		elseif Progress == 6 then --[Before Hyenas I, Before Scar]
			WarpRoom = 0x01
		elseif Progress == 7 then --Post 1st Visit
			WarpRoom = 0x01
		elseif Progress == 8 then --2nd Visit
			WarpRoom = 0x04
		elseif Progress == 9 then --[Before Meeting Up with Simba & Nala, Before Groundshaker]
			WarpRoom = 0x01
		end
	elseif PostSave == 1 then --Gorge
		WarpRoom = 0x06
	elseif PostSave == 2 then --Oasis
		WarpRoom = 0x09
	elseif PostSave == 3 then --Stone Hollow
		WarpRoom = 0x01
	end
	Spawn('Short',0x0A,0x13C,WarpRoom)
end
--World Progress
if Place == 0x060A and Events(Null,Null,0x01) then --The Wild Kingdom
	WriteByte(Save+0x1DDF,1)
elseif Place == 0x000A and Events(Null,Null,0x01) then --Rafiki's Verdict
	WriteByte(Save+0x1DDF,2)
elseif Place == 0x040A and Events(Null,Null,0x01) then --His Majesty, Scar
	WriteByte(Save+0x1DDF,3)
elseif Place == 0x090A and Events(Null,Null,0x02) then --There's Simba!
	WriteByte(Save+0x1DDF,4)
elseif Place == 0x0C0A and Events(Null,Null,0x01) then --Simba's Strength
	WriteByte(Save+0x1DDF,5)
elseif Place == 0x000A and Events(Null,Null,0x04) then --The Truth Comes Out
	WriteByte(Save+0x1DDF,6)
elseif Place == 0x000A and Events(Null,Null,0x05) then --A New King
	WriteByte(Save+0x1DDF,7)
elseif ReadByte(Save+0x1DDF) == 7 and ReadByte(Save+0x35B5) > 0 then --2nd Visit
	WriteByte(Save+0x1DDF,8)
	WriteShort(Save+0x0F2C,0x0A) --Savannah EVT
elseif Place == 0x000A and Events(Null,Null,0x0A) then --Scar's Ghost
	WriteByte(Save+0x1DDF,9)
elseif Place == 0x000A and Events(Null,Null,0x0E) then --The Circle of Life
	BitOr(Save+0x1EDA,0x01) --EH_FM_SAI_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1DDE,3) --Post-Story Save
	WriteShort(Save+0x0F5E,0x0D) --Peak MAP (Data Door)
end
--Pride Lands Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1DDE) > 0 then
	if PrevPlace == 0x060A then --Gorge
		WriteByte(Save+0x1DDE,1)
	elseif PrevPlace == 0x090A then --Oasis
		WriteByte(Save+0x1DDE,2)
	elseif PrevPlace == 0x010A then --Stone Hollow
		WriteByte(Save+0x1DDE,3)
	end
end
--[[Early Dash
WriteShort(Btl0+0x31A6C,0x820E) --Lion Sora Starts with Dash
if Place == 0x030A then --Remove Extra Dash
	Spawn('Short',0x0D,0x134,0x1E)
	Spawn('Short',0x0D,0x138,0x00)
	if Events(0x3E,0x3E,0x3E) then --Remove 'Sora Learned the "Dash" Ability.' Prompt
		WriteByte(CutSkp,1)
	end
end--]]
--[[Fast Hyenas II
if Place == 0x050A and Events(0x39,0x39,0x39) then
	Spawn('Short',0x0D,0x120,0x000) --Shenzi -> Nothing
	Spawn('Short',0x0D,0x160,0x000) --Ed -> Nothing
	if ReadInt(Point1) == 135 then
		WriteInt(Point1,236) --Shenzi & Ed Dead
	end
end--]]
--Music Change - Scar
if Place == 0x0E0A --[[and Platform == 'PS2'--]] then
	Spawn('Short',0x05,0x00C,0x96) --Squirming Evil (Removed in PC Version)
	Spawn('Short',0x05,0x00E,0x96)
end
end

function TT()
--Data Axel -> Twilight Town
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1CFD)
	local Progress = ReadByte(Save+0x1D0D)
	local WarpRoom, WarpEvt
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpEvt = 0x75
		elseif Progress == 1 then --Before Station Plaza Nobodies
			WarpRoom = 0x02
		elseif Progress == 2 then --After Station Plaza Nobodies
			WarpRoom = 0x09
		elseif Progress == 3 then --[After The Tower Heartless, After Moon Chamber Heartless]
			WarpRoom = 0x1A
		elseif Progress == 4 then --Before Talking to Yen Sid
			WarpRoom = 0x1B
		elseif Progress == 5 then --After Talking to Yen Sid
			WarpRoom = 0x1B
		elseif Progress == 6 then --Post 1st Visit
			WarpRoom = 0x02
		elseif Progress == 7 then --2nd Visit
			WarpEvt = 0x40
		elseif Progress == 8 then --Before Sandlot Nobodies II
			WarpRoom = 0x02
		elseif Progress == 9 then --After Sandlot Nobodies II
			WarpRoom = 0x02
		elseif Progress == 10 then --Post 2nd Visit
			WarpRoom = 0x02
		elseif Progress == 11 then --3rd Visit
			WarpEvt = 0x77
		elseif Progress == 12 then --[Before The Old Mansion Nobodies, After The Old Mansion Nobodies]
			WarpRoom = 0x09
		elseif Progress == 13 then --After Entering the Mansion Foyer
			WarpRoom = 0x12
		elseif Progress == 14 then --[After Entering the Computer Room, Before Betwixt and Between Nobodies]
			WarpRoom = 0x15
		end
	elseif PostSave == 1 then --The Usual Spot
		WarpRoom = 0x02
	elseif PostSave == 2 then --Central Station
		WarpRoom = 0x09
	elseif PostSave == 3 then --Sunset Station
		WarpRoom = 0x0B
	elseif PostSave == 4 then --Mansion: The White Room
		WarpRoom = 0x12
	elseif PostSave == 5 then --Mansion: Computer Room
		WarpRoom = 0x15
	elseif PostSave == 6 then --Tower: Entryway
		WarpRoom = 0x1A
	elseif PostSave == 7 then --Tower: Sorcerer's Loft
		WarpRoom = 0x1B
	end
	if WarpRoom then
		Spawn('Short',0x0A,0x15C,WarpRoom)
	else
		Spawn('Short',0x0A,0x158,0x02)
		Spawn('Short',0x0A,0x160,WarpEvt)
		if WarpEvt == 0x40 then
			Spawn('Short',0x0A,0x15A,0x12)
		end
	end
end
--World Progress
if Place == 0x0202 and Events(Null,Null,0x01) then --A Message from Pence and Olette
	WriteByte(Save+0x1D0D,1)
	WriteShort(Save+0x0336,0x16) --Station Heights BTL
elseif Place == 0x0902 and Events(Null,Null,0x03) then --Matching Pouches
	WriteByte(Save+0x1D0D,2)
elseif Place == 0x1902 and Events(Null,Null,0x01) then --My Name Is Pete
	WriteByte(Save+0x1D0D,3)
elseif Place == 0x1B02 and Events(Null,Null,0x01) then --Master Yen Sid
	WriteByte(Save+0x1D0D,4)
elseif Place == 0x1B02 and Events(Null,Null,0x03) then --The Journey Begins
	WriteByte(Save+0x1D0D,5)
elseif Place == 0x1C02 and Events(0x97,0x97,0x97) then --The Evil Fairy's Revival
	WriteByte(Save+0x1D0D,6)
	WriteByte(Save+0x1CFF,0)
	WriteShort(Save+0x01C4,0x04) --Station Heights MAP (Jobs Unavailable)
	WriteShort(Save+0x03A8,0x01) --The Tower: Entryway BTL
	WriteShort(Save+0x03C0,0x01) --Tower: Star Chamber BTL
	WriteShort(Save+0x03C6,0x01) --Tower: Moon Chamber BTL
	WriteShort(Save+0x03CC,0x01) --Tower: Wayward Stairs (Lower Level) BTL
	WriteShort(Save+0x03F6,0x01) --Tower: Wayward Stairs (Middle Level) BTL
	WriteShort(Save+0x03FC,0x01) --Tower: Wayward Stairs (Upper Level) BTL
elseif ReadByte(Save+0x1D0D) == 6 and ReadByte(Save+0x363F) > 0 then --2nd Visit
	WriteByte(Save+0x1D0D,7)
elseif Place == 0x0702 and Events(0x6B,0x6B,0x6B) then --A Frantic Vivi
	WriteByte(Save+0x1D0D,8)
	WriteShort(Save+0x032C,0x01) --Sandlot EVT
	WriteShort(Save+0x0334,0x00) --Station Heights MAP (Jobs Available)
	WriteShort(Save+0x0338,0x10) --Station Heights EVT
	WriteShort(Save+0x033A,0x00) --Tram Commons MAP (Jobs Available)
	WriteShort(Save+0x033C,0x16) --Tram Commons BTL
	WriteShort(Save+0x034A,0x10) --Central Station EVT
	WriteShort(Save+0x0362,0x00) --The Woods EVT
elseif Place == 0x0402 and Events(Null,Null,0x01) then --Leave It to Us!
	WriteByte(Save+0x1D0D,9)
elseif Place == 0x0012 and Events(0x75,0x75,0x75) then --Saix's Report
	WriteByte(Save+0x1D0D,10)
	WriteByte(Save+0x1CFF,0)
elseif ReadByte(Save+0x1D0D) == 10 and ReadByte(Save+0x3640) > 0 then --3rd Visit
	WriteByte(Save+0x1D0D,11)
elseif Place == 0x0902 and Events(0x77,0x77,0x77) then --The Photograph
	WriteByte(Save+0x1D0D,12)
	WriteShort(Save+0x0322,0x06) --Back Alley MAP (Despawn Skateboard)
	WriteShort(Save+0x0324,0x07) --Back Alley BTL
	WriteShort(Save+0x0334,0x06) --Station Heights MAP (Despawn Skateboard)
	WriteShort(Save+0x0336,0x07) --Station Heights BTL
	WriteShort(Save+0x0338,0x00) --Station Heights EVT
	WriteShort(Save+0x033A,0x06) --Tram Common MAP (Despawn Skateboard)
	WriteShort(Save+0x033C,0x07) --Tram Common BTL
	WriteShort(Save+0x033E,0x00) --Tram Common EVT
	WriteShort(Save+0x0340,0x06) --Station Plaza MAP (Despawn Skateboard)
	WriteShort(Save+0x0342,0x07) --Station Plaza BTL
	WriteShort(Save+0x0346,0x06) --Central Station MAP (Despawn Trains)
	WriteShort(Save+0x034A,0x00) --Central Station EVT
	WriteShort(Save+0x034C,0x06) --Sunset Terrace MAP (Visibility)
	WriteShort(Save+0x034E,0x16) --Sunset Terrace BTL
	WriteShort(Save+0x0352,0x06) --Sunset Station MAP (Despawn Train)
	WriteShort(Save+0x0358,0x06) --Sunset Hill MAP (Visibility)
	WriteShort(Save+0x0360,0x07) --The Woods BTL
	WriteShort(Save+0x0362,0x00) --The Woods EVT
	WriteShort(Save+0x0364,0x04) --The Old Mansion MAP (Despawn Skateboard)
	WriteShort(Save+0x0366,0x00) --The Old Mansion BTL
	WriteShort(Save+0x0368,0x05) --The Old Mansion EVT
elseif Place == 0x0E02 and Events(Null,Null,0x08) then --Reuniting with the King
	WriteByte(Save+0x1D0D,13)
elseif Place == 0x1502 and Events(Null,Null,0x02) then --The Password Is...
	WriteByte(Save+0x1D0D,14)
elseif Place == 0x2802 and Events(0xA1,0xA1,0xA1) then --His Last Words
	BitNot(Save+0x1CE9,0x04) --TT_013_END (Change Spawn ID in Next Cutscene Properly)
elseif Place == 0x0012 and Events(0x77,0x77,0x77) then --Those Who Remain
	BitOr(Save+0x1CEB,0x10) --TT_FM_AXE_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1CFD,1) --Post-Story Save
	WriteByte(Save+0x1CFF,0)
	WriteShort(Save+0x0212,0x00) --Basement Hall MAP (TT Real)
	WriteShort(Save+0x0214,0x07) --Basement Hall BTL
	WriteShort(Save+0x021E,0x03) --Computer Room MAP (TT Real)
	WriteShort(Save+0x0222,0x0F) --Computer Room EVT
	WriteShort(Save+0x0400,0x0D) --Betwixt & Between MAP (Data Door)
	BitNot(Save+0x1CEE,0x0C) --TT_TT21 (Computer Room Flag Fix)
end
--Twilight Town Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1CFD) > 0 and Door == 0x1C then
	if PrevPlace == 0x0202 then --The Usual Spot
		WriteByte(Save+0x1CFD,1)
	elseif PrevPlace == 0x0902 then --Central Station
		WriteByte(Save+0x1CFD,2)
	elseif PrevPlace == 0x0B02 then --Sunset Station
		WriteByte(Save+0x1CFD,3)
	elseif PrevPlace == 0x1202 then --Mansion: The White Room
		WriteByte(Save+0x1CFD,4)
	elseif PrevPlace == 0x1502 then --Mansion: Computer Room
		WriteByte(Save+0x1CFD,5)
	elseif PrevPlace == 0x1A02 then --Tower: Entryway
		WriteByte(Save+0x1CFD,6)
	elseif PrevPlace == 0x1B02 then --Tower: Sorcerer's Loft
		WriteByte(Save+0x1CFD,7)
	end
end
--Spawn IDs
if ReadShort(TxtBox) == 0x768 and PrevPlace == 0x1A04 and ReadByte(Save+0x1CFF) == 0 and (World == 0x02 or Place == 0x0112) then --Load Spawn ID upon Entering TT
	WriteInt(Save+0x353C,0x12020100) --Full Party
	WriteByte(Save+0x1CFF,8) --TT Flag
	for i = 0,143 do
		WriteByte(Save+0x0310+i,ReadByte(Save+0x01A0+i))
	end
	WriteShort(Save+0x03E8,ReadShort(Save+0x0310)) --The Empty Realm -> Tunnelway
	WriteShort(Save+0x03EA,ReadShort(Save+0x0312))
	WriteShort(Save+0x03EC,ReadShort(Save+0x0314))
	local PostSave = ReadByte(Save+0x1CFD)
	local Progress = ReadByte(Save+0x1D0D)
	local Visit --Battle Level & Barriers
	RemoveTTBarriers()
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			Visit = 7
		elseif Progress == 1 then --Before Station Plaza Nobodies
			Visit = 7
			WriteShort(Save+0x20E4,0xCB74) --Underground Concourse Barrier
			WriteShort(Save+0x2120,0xC54A) --Mansion Foyer Barrier
		elseif Progress == 2 then --After Station Plaza Nobodies
			Visit = 7
			WriteShort(Save+0x207C,0xCA3F) --Sunset Station Barrier
			WriteShort(Save+0x20E4,0xCB74) --Underground Concourse Barrier
			WriteShort(Save+0x20F4,0xCC6A) --The Tower Barrier
			WriteShort(Save+0x2120,0xC54A) --Mansion Foyer Barrier
		elseif Progress == 3 then --[After The Tower Heartless, After Moon Chamber Heartless]
			Visit = 8
			WriteShort(Save+0x20F4,0xC54E) --The Tower Barrier
		elseif Progress == 4 then --Before Talking to Yen Sid
			Visit = 8
			WriteShort(Save+0x20F4,0xC54E) --The Tower Barrier
			WriteShort(Save+0x20F8,0x9F4E) --Tower: Wardrobe Barrier
		elseif Progress == 5 then --After Talking to Yen Sid
			Visit = 8
			WriteShort(Save+0x20F4,0xC54E) --The Tower Barrier
		elseif Progress == 6 then --Post 1st Visit
			Visit = 8
			WriteShort(Save+0x207C,0xCA3F) --Sunset Station Barrier
			WriteShort(Save+0x20E4,0xCB74) --Underground Concourse Barrier
			WriteShort(Save+0x2120,0xC54A) --Mansion Foyer Barrier
		elseif Progress == 7 then --2nd Visit
			Visit = 9
		elseif Progress == 8 then --Before Sandlot Nobodies II
			Visit = 9
			WriteShort(Save+0x2080,0xC663) --Central Station Barrier
			WriteShort(Save+0x20E4,0xC66D) --Underground Concourse Barrier
			WriteShort(Save+0x2120,0xC665) --Mansion Foyer Barrier
		elseif Progress == 9 then --After Sandlot Nobodies II
			Visit = 9
			WriteShort(Save+0x20E4,0xC66F) --Underground Concourse Barrier
			WriteShort(Save+0x2120,0xC667) --Mansion Foyer Barrier
		elseif Progress == 10 then --Post 2nd Visit
			Visit = 9
			WriteShort(Save+0x20E4,0xCB74) --Underground Concourse Barrier
			WriteShort(Save+0x2120,0xC54A) --Mansion Foyer Barrier
		elseif Progress == 11 then --3rd Visit
			Visit = 10
		elseif Progress == 12 or Progress == 13 or Progress == 14 then --[Before The Old Mansion Nobodies, Before Betwixt and Between Nobodies]
			Visit = 10
			WriteShort(Save+0x20EC,0xCB76) --Sandlot Barrier
		end
	else
		Visit = 10
	end
	WriteByte(Save+0x3FF5,Visit)
	--Load the Proper Spawn ID
	local SpawnOffset = 0x310 + Room*6
	if Evt < 0x20 then --Not a Special Event
		WriteShort(Now+0x4,ReadShort(Save+SpawnOffset+0x0))
		WriteShort(Now+0x6,ReadShort(Save+SpawnOffset+0x2))
		WriteShort(Now+0x8,ReadShort(Save+SpawnOffset+0x4))
	end
elseif ReadByte(Save+0x1CFF) == 8 then --Save Events within TT
	WriteShort(Save+0x0310,ReadShort(Save+0x03E8)) --Tunnelway -> The Empty Realm
	WriteShort(Save+0x0312,ReadShort(Save+0x03EA))
	WriteShort(Save+0x0314,ReadShort(Save+0x03EC))
	for i = 0,143 do
		WriteByte(Save+0x01A0+i,ReadByte(Save+0x0310+i))
	end
end
--Save Points -> World Points (1st Visit)
if ReadByte(Save+0x1CFF) == 8 and false then
	if Place == 0x0202 then --The Usual Spot
		Spawn('Short',0x06,0x034,0x239)
	elseif Place == 0x0902 then --Central Station
		Spawn('Short',0x11,0x034,0x239)
	elseif Place == 0x1A02 then --Tower: Entryway
		Spawn('Short',0x07,0x034,0x239)
	elseif Place == 0x1B02 then --Tower: Sorcerer's Loft
		Spawn('Short',0x09,0x034,0x239)
	end
end
--Station Plaza Nobodies with Trinity Limit End Softlock Fix
if Place == 0x0802 and Events(0x6C,0x6C,0x6C) and ReadInt(Point1) == 98 then --Hit Counter Almost Reached
	WriteInt(CutLen,0x001) --End Trinity Limit Early
end
--Lexaeus Absent Silhouette Removal
if ReadShort(Save+0x032A) == 0x02 then
	WriteShort(Save+0x032A,0x00) --Sandlot BTL
end
end

function HB()
--Data Demyx -> Hollow Bastion
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1D2E)
	local Progress = ReadByte(Save+0x1D2F)
	local WarpRoom, Visit
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x00
			Visit = 1
		elseif Progress == 1 then --Before Bailey Nobodies
			WarpRoom = 0x0D
			Visit = 1
		elseif Progress == 2 then --Post 1st Visit
			WarpRoom = 0x0D
			Visit = 1
		elseif Progress == 3 then --4th Visit
			WarpRoom = 0x0A
			Visit = 4
		elseif Progress == 4 then --[Before Meeting YRP, After Meeting YRP]
			WarpRoom = 0x0D
			Visit = 4
		elseif Progress == 5 then --[After Entering Postern, Before Entering Ansem's Study]
			WarpRoom = 0x06
			Visit = 4
		elseif Progress == 6 then --[After Talking to Leon, Before Corridors Fight]
			WarpRoom = 0x05
			Visit = 4
		elseif Progress == 7 then --[Before Restoration Site Nobodies, Before Demyx]
			WarpRoom = 0x06
			Visit = 4
		elseif Progress == 8 then --After Demyx
			WarpRoom = 0x06
			Visit = 4
		elseif Progress == 9 then --Before 1000 Heartless
			WarpRoom = 0x03
			Visit = 4
		elseif Progress == 10 then --Post 4th Visit
			WarpRoom = 0x0D
			Visit = 4
		elseif Progress == 11 then --5th Visit
			WarpRoom = 0x0A
			Visit = 5
		elseif Progress == 12 then --After Borough Heartless III
			WarpRoom = 0x06
			Visit = 5
		end
	elseif PostSave == 1 then --Merlin's House
		WarpRoom = 0x0D
		Visit = 5
	elseif PostSave == 2 then --Postern
		WarpRoom = 0x06
		Visit = 5
	elseif PostSave == 3 then --Ansem's Study
		WarpRoom = 0x05
		Visit = 5
	elseif PostSave == 4 then --Crystal Fissure
		WarpRoom = 0x03
		Visit = 5
	end
	Spawn('Short',0x0A,0x17C,WarpRoom)
	WriteByte(Save+0x3FFD,Visit)
end
--World Progress
if Place == 0x0004 and Events(Null,Null,0x01) then --Pete Enters the Castle
	WriteShort(Save+0x0614,0x02) --Villain's Vale EVT
elseif Place == 0x0D04 and Events(Null,Null,0x01) then --The Hollow Bastion Restoration Committee
	WriteByte(Save+0x1D2F,1)
elseif Place == 0x0012 and Events(0x74,0x74,0x74) then --The Keyblade's Hero
	WriteByte(Save+0x1D2F,2)
elseif ReadByte(Save+0x1D2F) == 2 and ReadByte(Save+0x35C1) > 0 then --4th Visit
	WriteByte(Save+0x1D2F,3)
	WriteShort(Save+0x064C,0x02) --Marketplace MAP (Barrier Beyond Cloud)
	WriteShort(Save+0x0650,0x02) --Marketplace EVT
elseif Place == 0x0D04 and Events(Null,Null,0x02) then --Cid's Report
	WriteByte(Save+0x1D2F,4)
elseif Place == 0x0604 and Events(Null,Null,0x02) then --The Underground Corridor
	WriteByte(Save+0x1D2F,5)
elseif Place == 0x0504 and Events(Null,Null,0x03) then --Transportation Device
	WriteByte(Save+0x1D2F,6)
	WriteShort(Save+0x0632,0x04) --Ansem's Study EVT
elseif ReadShort(Save+0x0632) == 0x07 then --Back Inside the Program
	WriteShort(Save+0x0632,0x08) --Ansem's Study EVT
elseif Place == 0x0604 and Events(Null,Null,0x02) then --Sephiroth
	WriteByte(Save+0x1D2F,7)
elseif Place == 0x0404 and Events(Null,Null,0x01) then --The Melodious Nocturne: Demyx
	WriteByte(Save+0x1D2F,8)
	WriteShort(Save+0x0628,0x01) --Castle Gate MAP
	WriteShort(Save+0x062C,0x02) --Castle Gate EVT
elseif Place == 0x0304 and Events(Null,Null,0x01) then --Goofy's Awake!
	WriteByte(Save+0x1D2F,9)
	WriteShort(Save+0x0628,0x00) --Castle Gate MAP
	WriteShort(Save+0x062C,0x00) --Castle Gate EVT
elseif Place == 0x0104 and Events(Null,Null,0x01) then --Xemnas's Agenda
	BitNot(Save+0x1D15,0x08) --HB_418_END (Change Spawn ID in Next Cutscene Properly)
elseif Place == 0x0104 and Events(0x5C,0x5C,0x5C) then --A Box of Memories
	WriteByte(Save+0x1D2F,10)
elseif ReadByte(Save+0x1D2F) == 10 and true then --5th Visit
	WriteByte(Save+0x1D2F,11)
	WriteShort(Save+0x0650,0x0A) --Marketplace EVT
elseif Place == 0x0904 and Events(Null,Null,0x0B) then --The Rogue Security System
	WriteByte(Save+0x1D2F,12)
elseif Place == 0x0504 and Events(Null,Null,0x0D) then --Wait for Us, Tron
	WriteShort(Save+0x0662,0x0C) --Merlin's House EVT
elseif Place == 0x0604 and Events(0x5E,0x5E,0x5E) then --Radiant Garden
	BitOr(Save+0x1D26,0x20) --HB_FM_DEM_RE_CLEAR (Change Portal Color)
	WriteShort(Save+0x1D2E,2) --Post-Story Save
	WriteShort(Save+0x067C,0x0D) --Restoration Site (Destroyed) MAP (Data Door)
elseif Place == 0x1904 and Events(Null,0x05,0x04) then --Transport to Remembrance Cleared
	WriteShort(Save+0x06A8,0x04) --Transport to Remembrance BTL
	WriteShort(Save+0x06AA,0x00) --Transport to Remembrance EVT
	BitOr(Save+0x1D27,0x04) --HB_FM_13TSUURO_OUT
end
--Hollow Bastion Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1D2E) > 0 then
	if PrevPlace == 0x0D04 then --Merlin's House
		WriteByte(Save+0x1D2E,1)
	elseif PrevPlace == 0x0604 then --Postern
		WriteByte(Save+0x1D2E,2)
	elseif PrevPlace == 0x0504 then --Ansem's Study
		WriteByte(Save+0x1D2E,3)
	elseif PrevPlace == 0x0304 then --Crystal Fissure
		WriteByte(Save+0x1D2E,4)
	end
end
--Remove 100 Acre Wood Book
if ReadShort(Save+0x065E) == 0x00 or ReadShort(Save+0x065E) == 0x04 then
	WriteShort(Save+0x065E,0x01) --Merlin's House MAP
end
--Heartless Manufactory Early Access with Membership Card
if Place == 0x0504 and ReadByte(Save+0x3643) > 0 then
	WriteShort(Save+0x20D4,0x0000) --Heartless Manufactory Barrier Removal
	Spawn('Int',0x01,0x5B0,0xC1C8F) --MAP 0x0D
	Spawn('String',0x01,0x5FC,'m_11')
	Spawn('Int',0x01,0x950,0xC1C8F) --MAP 0x0F
	Spawn('String',0x01,0x9A4,'m_11')
	Spawn('Int',0x01,0x10E0,0xC1C8F) --MAP 0x08
	Spawn('String',0x01,0x112C,'m_11')
end
--After-Demyx Checkpoint
if ReadByte(Save+0x1D2F) == 8 then
	if Place == 0x1A04 then
		WriteInt(Save+0x3544,0x12020100) --Add Goofy
	elseif Place ~= 0x0404 and Place ~= 0x2004 and Place ~= 0x2104 and Place ~= 0x2204 and Place ~= 0x2604 then --Not in HB Org Arenas
		WriteInt(Save+0x3544,0x12120100) --Remove Goofy
	end
end
--Skip Hollow Bastion 5th Visit
if ReadShort(Save+0x0650) == 0x0A then
	BitOr(Save+0x1D26,0x20) --HB_FM_DEM_RE_CLEAR (Change Portal Color)
	WriteShort(Save+0x1D2E,2) --Post-Story Save
	WriteShort(Save+0x0618,0x00) --The Dark Depths BTL
	WriteShort(Save+0x061A,0x16) --The Dark Depths EVT
	WriteShort(Save+0x061E,0x02) --The Great Maw BTL
	WriteShort(Save+0x0620,0x03) --The Great Maw EVT
	WriteShort(Save+0x062E,0x0E) --Ansem's Study MAP (Heartless Manufactory Door Opened)
	WriteShort(Save+0x0632,0x00) --Ansem's Study EVT
	WriteShort(Save+0x0648,0x0B) --Borough BTL
	WriteShort(Save+0x0650,0x06) --Marketplace EVT
	WriteShort(Save+0x0654,0x0B) --Corridors BTL
	WriteShort(Save+0x065C,0x16) --Heartless Manufactory EVT
	WriteShort(Save+0x0662,0x10) --Merlin's House EVT
	WriteShort(Save+0x0672,0x0B) --Ravine Trail BTL
	WriteShort(Save+0x067C,0x0D) --Restoration Site (Destroyed) MAP (Data Door)
	WriteShort(Save+0x067E,0x0B) --Restoration Site (Destroyed) BTL
	WriteShort(Save+0x0684,0x0B) --Bailey (Destroyed) BTL
	WriteShort(Save+0x20D4,0x0000) --Heartless Manufactory Barrier Removal
	BitOr(Save+0x1D19,0x10) --HB_508_END
	BitOr(Save+0x1D1C,0x10) --HB_509_END
	BitOr(Save+0x1D1C,0x20) --HB_hb09_ms501
	BitOr(Save+0x1D1C,0x40) --HB_511_END
	BitOr(Save+0x1D22,0x20) --HB_hb_event_512
	BitOr(Save+0x1D1D,0x01) --HB_513_END
	BitOr(Save+0x1D1D,0x02) --HB_514_END
	BitOr(Save+0x1D22,0x40) --HB_hb_event_515
	BitOr(Save+0x1D1D,0x08) --HB_516_END
	BitOr(Save+0x1D1D,0x20) --HB_518_END
	BitOr(Save+0x1D1D,0x40) --HB_519_END
	BitOr(Save+0x1D19,0x40) --HB_501_END
	BitOr(Save+0x1D21,0x04) --HB_hb_event_502
	BitOr(Save+0x1D1A,0x04) --HB_503_END
	BitOr(Save+0x1D1A,0x10) --HB_504_END
	BitOr(Save+0x1D1A,0x20) --HB_505_END
	BitOr(Save+0x1D1A,0x40) --HB_506_END
	BitOr(Save+0x1D21,0x08) --HB_hb_event_507 (Hollow Bastion -> Radiant Garden)
end
--Mushroom XIII Unlocked
if Place == 0x0204 and Events(Null,0x02,0x03) and ReadByte(Save+0x36B4) > 0 then
	WriteShort(Save+0x3E94,3) --Mushroom I
	WriteShort(Save+0x3E98,70)
	WriteShort(Save+0x3E9C,3) --Mushroom II
	WriteShort(Save+0x3EA0,80)
	WriteShort(Save+0x3EA4,3) --Mushroom III
	WriteShort(Save+0x3EA8,450)
	WriteShort(Save+0x3EAC,3) --Mushroom IV
	WriteShort(Save+0x3EB0,85)
	WriteShort(Save+0x3EB4,4) --Mushroom V
	WriteShort(Save+0x3EB8,600)
	WriteShort(Save+0x3EBC,4) --Mushroom VI
	WriteShort(Save+0x3EC0,2700)
	WriteShort(Save+0x3EC4,4) --Mushroom VII
	WriteShort(Save+0x3EC8,600)
	WriteShort(Save+0x3ECC,3) --Mushroom VIII
	WriteShort(Save+0x3ED0,85)
	WriteShort(Save+0x3ED4,3) --Mushroom IX
	WriteShort(Save+0x3ED8,75)
	WriteShort(Save+0x3EDC,4) --Mushroom X
	WriteShort(Save+0x3EE0,3300)
	WriteShort(Save+0x3EE4,4) --Mushroom XI
	WriteShort(Save+0x3EE8,1140)
	WriteShort(Save+0x3EEC,3) --Mushroom XII
	WriteShort(Save+0x3EF0,40)
end
end

function PR()
--Data Luxord -> Port Royal
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1E9E)
	local Progress = ReadByte(Save+0x1E9F)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --[1st Visit, Before Talking to Will]
			WarpRoom = 0x00
		elseif Progress == 1 then --After Talking to Will
			WarpRoom = 0x04
		elseif Progress == 2 then --Before Cave Mouth Pirates
			WarpRoom = 0x08
		elseif Progress == 3 then --[Before The Interceptor Pirates, Before The Interceptor Barrels]
			WarpRoom = 0x04
		elseif Progress == 4 then --Before Barbossa
			WarpRoom = 0x08
		elseif Progress == 5 then --Post 1st Visit
			WarpRoom = 0x00
		elseif Progress == 6 then --2nd Visit
			WarpRoom = 0x0A
		elseif Progress == 7 then --Before Harbor Pirates II
			WarpRoom = 0x00
		elseif Progress == 8 then --[After Harbor Pirates II, Before Grim Reaper I]
			WarpRoom = 0x06
		elseif Progress == 9 then --After Grim Reaper I
			WarpRoom = 0x0B
		elseif Progress == 10 then --[Medallion Collection, Before Grim Reaper II]
			WarpRoom = 0x06
		end
	elseif PostSave == 1 then --Rampart
		WarpRoom = 0x00
	elseif PostSave == 2 then --The Black Pearl: Captain's Stateroom
		WarpRoom = 0x06
	elseif PostSave == 3 then --Isla De Muerta: Rock Face
		WarpRoom = 0x10
	elseif PostSave == 4 then --Ship Graveyard: The Interceptor's Hold
		WarpRoom = 0x0B
	end
	Spawn('Short',0x0A,0x19C,WarpRoom)
end
--World Progress
if Place == 0x1710 and Events(0x4F,0x4F,0x4F) then --The Cursed Medallion
	WriteByte(Save+0x1E9F,1)
elseif Place == 0x1110 and Events(0x3D,0x3D,0x3D) then --The Blood Will Be Repaid
	WriteByte(Save+0x1E9F,2)
elseif Place == 0x1110 and Events(Null,Null,0x01) then --On the Island
	WriteByte(Save+0x1E9F,3)
elseif Place == 0x0310 and Events(0x38,0x38,0x38) then --To Isla de Muerta
	WriteByte(Save+0x1E9F,4)
elseif Place == 0x0810 and Events(Null,Null,0x04) then --Parting Ways
	WriteByte(Save+0x1E9F,5)
elseif ReadByte(Save+0x1E9F) == 5 and ReadByte(Save+0x35B6) > 0 then --2nd Visit
	WriteByte(Save+0x1E9F,6)
	WriteShort(Save+0x1818,0x00) --Harbor BTL
	WriteShort(Save+0x1850,0x0A) --Treasure Heap EVT
	WriteShort(Save+0x1852,0x01) --The Interceptor's Hold MAP (Visibility)
elseif Place == 0x0A10 and Events(Null,Null,0x0A) then --A Looming Shadow
	WriteByte(Save+0x1E9F,7)
elseif Place == 0x0110 and Events(Null,Null,0x0A) then --The Jack Sparrow Way
	WriteByte(Save+0x1E9F,8)
elseif Place == 0x0B10 and Events(Null,Null,0x0A) then --The Ship Graveyard
	WriteByte(Save+0x1E9F,9)
elseif Place == 0x0E10 and Events(Null,Null,0x0A) then --Retrieve the Medallion!
	WriteByte(Save+0x1E9F,10)
elseif Place == 0x0510 and Events(Null,Null,0x0E) then --Into the Ocean
	BitOr(Save+0x1EDA,0x02)  --EH_FM_LUX_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1E9E,2) --Post-Story Save
	WriteShort(Save+0x184C,0x0D) --Treasure Heap MAP (Data Door)
end
--Port Royal Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1E9E) > 0 then
	if PrevPlace == 0x0010 then --Rampart
		WriteByte(Save+0x1E9E,1)
	elseif PrevPlace == 0x0610 then --The Black Pearl: Captain's Stateroom
		WriteByte(Save+0x1E9E,2)
	elseif PrevPlace == 0x1010 then --Isla De Muerta: Rock Face
		WriteByte(Save+0x1E9E,3)
	elseif PrevPlace == 0x0B10 then --Ship Graveyard: The Interceptor's Hold
		WriteByte(Save+0x1E9E,4)
	end
end
--The Interceptor Pirates End Screen
if Place == 0x0710 and ReadInt(CutLen) == 0x000F and ReadByte(BtlEnd) == 0x04 then
	WriteByte(BtlEnd,0x03) --Delay Fade-Out after Winning Fight
end
--Larxene's Absent Silhouette Removal
if ReadShort(Save+0x1842) == 0x01 then
	WriteShort(Save+0x1842,0x00) --Isla De Muerta: Rock Face (1st Visit) BTL
elseif ReadShort(Save+0x1872) == 0x01 then
	WriteShort(Save+0x1872,0x00) --Isla De Muerta: Rock Face (2nd Visit) BTL
end
end

function DC()
--Data Marluxia -> Disney Castle
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1E1E)
	local Progress = ReadByte(Save+0x1E1F)
	local WarpRoom, WarpEvt
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpEvt = 0x35
		elseif Progress == 1 then --Before Entering Courtyard
			WarpRoom = 0x06
		elseif Progress == 2 then --[After Entering Courtyard, Before Minnie Escort]
			WarpRoom = 0x01
		elseif Progress == 3 then --[Before Entering Timeless River, After Entering Timeless River]
			WarpRoom = 0x04
		end
	elseif PostSave == 1 then --Gummi Hangar
		WarpRoom = 0x06
	elseif PostSave == 2 then --Library
		WarpRoom = 0x01
	elseif PostSave == 3 then --Hall of the Cornerstone (Light)
		WarpRoom = 0x05
	end
	if WarpRoom then
		Spawn('Short',0x0A,0x1BC,WarpRoom)
	else
		Spawn('Short',0x0A,0x1B8,0x02)
		Spawn('Short',0x0A,0x1C0,WarpEvt)
	end
end
--World Progress
if Place == 0x060C and Events(Null,Null,0x01) then --There's Something Strange Going On
	WriteByte(Save+0x1E1F,1)
elseif Place == 0x030C and Events(Null,Null,0x01) then --Welcome to Disney Castle
	WriteByte(Save+0x1E1F,2)
elseif Place == 0x000C and Events(Null,Null,0x01) then --Heartless? Here?
	WriteArray(Save+0x0664,ReadArray(Save+0x065E,6)) --Save Merlin's House Spawn ID
elseif Place == 0x040C and Events(Null,Null,0x02) then --The Strange Door
	WriteByte(Save+0x1E1F,3)
	WriteArray(Save+0x065E,ReadArray(Save+0x0664,6)) --Load Merlin's House Spawn ID
elseif Place == 0x000D and Events(Null,Null,0x07) then --Back to Their Own World
elseif Place == 0x050C and Events(Null,Null,0x01) then --The Castle is Secure
	BitOr(Save+0x1D26,0x80) --HB_FM_MAR_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1E1E,3) --Post-Story Save
	WriteShort(Save+0x1230,0x01) --Hall of the Cornerstone (Light) BTL
elseif Place == 0x2604 and Events(0x7F,0x7F,0x7F) then --Marluxia Defeated
	WriteShort(Save+0x1230,0x02) --Hall of the Cornerstone (Light) BTL
elseif ReadByte(Save+0x36B2) > 0 and ReadByte(Save+0x1E1E) > 0 and ReadShort(Save+0x1232) == 0x00 then --Proof of Connection, DC Cleared, Terra Locked
	WriteShort(Save+0x121A,0x11) --Library EVT
	WriteShort(Save+0x1232,0x02) --Hall of the Cornerstone (Light) EVT
	WriteShort(Save+0x1238,0x12) --Gummi Hangar EVT
	BitOr(Save+0x1CB1,0x02) --ES_FM_URA_MOVIE (BBS Movie 1) (Show Prompt in TWtNW)
	BitOr(Save+0x1E13,0x80) --DC_FM_NAZO_ON
end
--Disney Castle Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1E1E) > 0 then
	if PrevPlace == 0x060C then --Gummi Hangar
		WriteByte(Save+0x1E1E,1)
	elseif PrevPlace == 0x010C then --Library
		WriteByte(Save+0x1E1E,2)
	elseif PrevPlace == 0x050C then --Hall of the Cornerstone (Light)
		WriteByte(Save+0x1E1E,3)
	end
end
--Marluxia HUD Pop-Up
if Place == 0x2604 and ReadInt(CutNow) == 0x7A then
	if Events(0x91,0x91,0x91) then --AS
		if Platform == 'PS2' and ReadShort(0x1C58FE0) ~= 0x923 then
			WriteByte(Cntrl,0x00)
		elseif Platform == 'PC' and ReadShort(0x29ED484 - 0x56450E) ~= 0x923 then
			WriteByte(Cntrl,0x00)
		end
	elseif Events(0x96,0x96,0x96) then --Data
		if Platform == 'PS2' and ReadShort(0x1C59114) ~= 0x923 then
			WriteByte(Cntrl,0x00)
		elseif Platform == 'PC' and ReadShort(0x29ED5C4 - 0x56450E) ~= 0x923 then
			WriteByte(Cntrl,0x00)
		end
	end
end
end

function SP()
--Data Larxene -> Space Paranoids
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1EBE)
	local Progress = ReadByte(Save+0x1EBF)
	local WarpRoom, WarpDoor
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x01
			WarpDoor = 0x00
		elseif Progress == 1 then --Before Dataspace Monitors
			WarpRoom = 0x00
			WarpDoor = 0x37
		elseif Progress == 2 then --After Dataspace Monitors
			WarpRoom = 0x00
		elseif Progress == 3 then --Before Hostile Program
			WarpRoom = 0x05
			WarpDoor = 0x37
		elseif Progress == 4 then --Post 1st Visit
			WarpRoom = 0x00
		elseif Progress == 5 then --2nd Visit
			WarpRoom = 0x01
		elseif Progress == 6 then --Before Game Grid Heartless
			WarpRoom = 0x00
			WarpDoor = 0x37
		elseif Progress == 7 then --Before Hallway Heartless
			WarpRoom = 0x00
		elseif Progress == 8 then --Before Solar Sailer Heartless
			WarpRoom = 0x05
			WarpDoor = 0x37
		elseif Progress == 9 then --Before Sark & MCP
			WarpRoom = 0x08
			WarpDoor = 0x37
		end
	elseif PostSave == 1 then --Pit Cell
		WarpRoom = 0x00
	elseif PostSave == 2 then --I/O Tower: Communications Room
		WarpRoom = 0x05
	elseif PostSave == 3 then --Central Computer Mesa
		WarpRoom = 0x08
	end
	Spawn('Short',0x0A,0x1DC,WarpRoom)
	if WarpDoor then
		Spawn('Short',0x0A,0x1DE,WarpDoor)
	end
end
--World Progress
if Place == 0x0011 and Events(Null,Null,0x01) then --Tron
	WriteByte(Save+0x1EBF,1)
elseif ReadShort(Save+0x1994) == 0x15 then --Tron's Request (Skip HB Visit)
	WriteShort(Save+0x1994,0x06) --Pit Cell EVT
elseif Place == 0x0211 and Events(Null,Null,0x01) then --The Game Grid (Skip Light Cycle)
	WriteShort(Save+0x19A0,0x02) --Game Grid EVT
	WriteShort(Save+0x1994,0x07) --Pit Cell EVT
elseif Place == 0x0311 and Events(0x4E,0x4E,0x4E) then --Buying Time
	WriteByte(Save+0x1EBF,2)
	if ReadInt(CutLen) == 0x064 then --Unequip Tron's Auto Limit
		for Slot = 0,79 do
			local AbilitySlot = Save + 0x3120 + Slot*2
			if ReadShort(AbilitySlot) == 0x81A1 then
				WriteShort(AbilitySlot,0x01A1)
				break
			end
		end
	end
elseif Place == 0x0511 and Events(Null,Null,0x01) then --Before Communications Room Cutscene
	Spawn('Short',0x05,0x034,0x000) --Monitor -> Nothing
elseif Place == 0x0511 and Events(0x02,0x00,0x16) then --After Communications Room Cutscene
	WriteByte(Save+0x1EBF,3)
	Spawn('Short',0x05,0x034,0x1C4) --Nothing -> Monitor
elseif Place == 0x0511 and Events(Null,Null,0x04) then --To Hollow Bastion
	WriteByte(Save+0x1EBF,4)
elseif ReadByte(Save+0x1EBF) == 4 and ReadByte(Save+0x35C2) > 0 then --2nd Visit
	WriteByte(Save+0x1EBF,5)
	WriteShort(Save+0x1990,0x03) --Pit Cell MAP (Despawn Party Members)
	WriteShort(Save+0x199A,0x0A) --Canyon EVT
	WriteShort(Save+0x199E,0x00) --Game Grid BTL
	WriteShort(Save+0x19A0,0x0A) --Game Grid EVT
elseif Place == 0x0011 and Events(Null,Null,0x0A) then --To the Game Grid
	WriteByte(Save+0x1EBF,6)
elseif Place == 0x0211 and Events(Null,Null,0x0A) then --Tron's in Danger!
	WriteByte(Save+0x1EBF,7)
	WriteShort(Save+0x19AC,0x0A) --Hallway EVT
elseif Place == 0x0411 and Events(Null,Null,0x0A) then --Facing Danger
	WriteByte(Save+0x1EBF,8)
	WriteShort(Save+0x19B2,0x0A) --Communications Room EVT
elseif Place == 0x0811 and Events(Null,Null,0x0A) then --The System's Core
	WriteByte(Save+0x1EBF,9)
elseif Place == 0x0911 and Events(0x3B,0x3B,0x3B) then --Destroying the MCP
	BitOr(Save+0x1D27,0x01) --HB_FM_LAR_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1EBE,2) --Post-Story Save
	WriteShort(Save+0x19C2,0x01) --Central Computer Mesa BTL
elseif Place == 0x2104 and Events(0x81,0x81,0x81) then --Larxene Defeated
	WriteShort(Save+0x19C2,0x02) --Central Computer Mesa BTL
end
--Space Paranoids Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1EBE) > 0 then
	if PrevPlace == 0x0011 then --Pit Cell
		WriteByte(Save+0x1EBE,1)
	elseif PrevPlace == 0x0511 then --I/O Tower: Communications Room
		WriteByte(Save+0x1EBE,2)
	elseif PrevPlace == 0x0811 then --Central Computer Mesa
		WriteByte(Save+0x1EBE,3)
	end
end
--Skip Solar Sailer Heartless Post-Story
if Place == 0x0A11 and ReadByte(Save+0x1EBE) > 0 then
	Spawn('Short',0x01,0x070,0x01)
	Spawn('Short',0x01,0x074,0x08)
	Spawn('Short',0x01,0x076,0x01)
end
end

function STT()
--Data Roxas -> Simulated Twilight Town
if Place == 0x1A04 then
	local PostSave = ReadByte(Save+0x1CFE)
	local Progress = ReadByte(Save+0x1D0E)
	local WarpRoom
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			WarpRoom = 0x01
		elseif Progress == 1 then --Before Munny Collection
			WarpRoom = 0x02
		elseif Progress == 2 then --Munny Collection
			WarpRoom = 0x02
		elseif Progress == 3 then --Before Sandlot Dusk
			WarpRoom = 0x02
		elseif Progress == 4 then --Before Twilight Thorn
			WarpRoom = 0x20
		elseif Progress == 5 then --[Start of Day 4, Before Setzer]
			WarpRoom = 0x05
		elseif Progress == 6 then --Start of Day 5
			WarpRoom = 0x02
		elseif Progress == 7 then --Before Vivi's Wonder
			WarpRoom = 0x0B
		elseif Progress == 8 then --[After Vivi's Wonder, After Seven Wonders]
			WarpRoom = 0x0B
		elseif Progress == 9 then --Before Namine's Wonder
			WarpRoom = 0x02
		elseif Progress == 10 then --[Before Back Street Nobodies, Before Entering the Mansion]
			WarpRoom = 0x02
		elseif Progress == 11 then --[Before Entering the Library, Before Entering Computer Room]
			WarpRoom = 0x12
		elseif Progress == 12 then --Before Axel II
			WarpRoom = 0x15
		elseif Progress == 13 then --After Axel II
			WarpRoom = 0x15
		end
	elseif PostSave == 1 then --The Usual Spot
		WarpRoom = 0x02
	elseif PostSave == 2 then --Central Station
		WarpRoom = 0x09
	elseif PostSave == 3 then --Sunset Station
		WarpRoom = 0x0B
	elseif PostSave == 4 then --Mansion: The White Room
		WarpRoom = 0x12
	elseif PostSave == 5 then --Mansion: Computer Room
		WarpRoom = 0x15
	end
	Spawn('Short',0x0A,0x1FC,WarpRoom)
	if WarpRoom == 0x15 and ReadByte(Save+0x1CFB) == 1 then --Computer Room Beam
		Spawn('Short',0x0A,0x1FE,0x3B)
	end
end
--World Progress
if Place == 0x0102 and Events(0x39,0x39,0x39) then --Just Another Morning
	WriteByte(Save+0x1D0E,1)
elseif Place == 0x0602 and Events(Null,Null,0x01) then --It's a Promise
	WriteByte(Save+0x1D0E,2)
elseif Place == 0x0602 and ReadShort(Save+0x0338) == 0x0C and (Events(0x59,0x59,0x59) or Events(0x5A,0x5A,0x5A) or Events(0x5B,0x5B,0x5B)) then --End Day 2 Early 1
	WriteShort(Save+0x0338,0x0D) --Station Heights EVT
elseif Place == 0x0702 and ReadShort(Save+0x033E) == 0x0C and (Events(0x64,0x64,0x64) or Events(0x65,0x65,0x65) or Events(0x66,0x66,0x66)) then --End Day 2 Early 2
	WriteShort(Save+0x033E,0x0D) --Tram Common EVT
elseif ReadShort(Save+0x0320) == 0x16 then --Keep Munny after Day 2
	WriteShort(Save+0x0320,0x00) --The Usual Spot EVT
elseif Place == 0x0102 and Events(0x3A,0x3A,0x3A) then --Awakened by an Illusion
	WriteByte(Save+0x1D0E,3)
elseif Place == 0x2002 and Events(0x9C,0x9C,0x9C) then --Station of Awakening
	WriteByte(Save+0x1D0E,4)
	WriteShort(Save+0x03D4,0x03) --Station of Serenity EVT
elseif Place == 0x0102 and Events(0x3B,0x3B,0x3B) then --A Troubled Awakening
	WriteByte(Save+0x1D0E,5)
elseif Place == 0x0102 and Events(0x3C,0x3C,0x3C) then --A Hazy Morning
	WriteByte(Save+0x1D0E,6)
elseif Place == 0x0902 and Events(Null,Null,0x0C) then --Seeking Out the Wonders
	WriteByte(Save+0x1D0E,7)
elseif Place == 0x2402 and Events(0x9F,0x9F,0x9F) then --Moans from the Tunnel
	WriteByte(Save+0x1D0E,8)
elseif Place == 0x0802 and Events(0x73,0x73,0x73) then --The Seventh Wonder
	WriteByte(Save+0x1D0E,9)
elseif Place == 0x0102 and Events(0x3D,0x3D,0x3D) then --Shadow of Another
	WriteByte(Save+0x1D0E,10)
elseif Place == 0x1202 and Events(Null,Null,0x01) then --Sketches
	WriteByte(Save+0x1D0E,11)
elseif Place == 0x1502 and Events(Null,Null,0x01) then --The Computer System
	WriteByte(Save+0x1D0E,12)
elseif Place == 0x1302 and Events(0x88,0x88,0x88) then --In the Next Life
	WriteByte(Save+0x1D0E,13)
	WriteShort(Save+0x0346,0x02) --Central Station MAP (Spawn Sunset Station Train)
	WriteShort(Save+0x034A,0x13) --Central Station EVT
	WriteShort(Save+0x0366,0x01) --The Old Mansion BTL
	WriteShort(Save+0x036C,0x01) --Mansion Foyer BTL
	WriteShort(Save+0x0372,0x01) --Dining Room BTL
	WriteShort(Save+0x2114,0x0000) --Station Plaza Barrier Removal
	WriteShort(Save+0x211C,0x0000) --The Old Mansion Barrier Removal
elseif Place == 0x1702 and Events(Null,Null,0x01) then --My Summer Vacation Is Over
	BitOr(Save+0x1ED9,0x40) --EH_FM_ROX_RE_CLEAR (Change Portal Color)
	WriteByte(Save+0x1CFE,1) --Post-Story Save
	WriteByte(Save+0x1CFF,0)
	WriteShort(Save+0x02BA,0x0D) --Pod Room MAP (Data Door)
	WriteShort(Save+0x02BE,0x00) --Pod Room EVT
end
--Simulated Twilight Town Post-Story Save
if Place == 0x1A04 and ReadByte(Save+0x1CFE) > 0 and Door == 0x21 then
	if PrevPlace == 0x0202 then --The Usual Spot
		WriteByte(Save+0x1CFE,1)
	elseif PrevPlace == 0x0902 then --Central Station
		WriteByte(Save+0x1CFE,2)
	elseif PrevPlace == 0x0B02 then --Sunset Station
		WriteByte(Save+0x1CFE,3)
	elseif PrevPlace == 0x1202 then --Mansion: The White Room
		WriteByte(Save+0x1CFE,4)
	elseif PrevPlace == 0x1502 then --Mansion: Computer Room
		WriteByte(Save+0x1CFE,5)
	end
end
--Spawn IDs
if ReadShort(TxtBox) == 0x76D and PrevPlace == 0x1A04 and ReadByte(Save+0x1CFF) == 0 and World == 0x02 then --Load Spawn ID upon Entering STT
	WriteInt(Save+0x353C,0x12121200) --Roxas Only
	WriteByte(Save+0x1CFF,13) --STT Flag
	for i = 0,143 do
		WriteByte(Save+0x0310+i,ReadByte(Save+0x0230+i))
	end
	WriteShort(Save+0x03E8,ReadShort(Save+0x0310)) --The Empty Realm -> Tunnelway
	WriteShort(Save+0x03EA,ReadShort(Save+0x0312))
	WriteShort(Save+0x03EC,ReadShort(Save+0x0314))
	local PostSave = ReadByte(Save+0x1CFE)
	local Progress = ReadByte(Save+0x1D0E)
	local Visit --Battle Level & Barriers
	RemoveTTBarriers()
	if PostSave == 0 then
		if Progress == 0 then --1st Visit
			Visit = 1
			WriteShort(Save+0x0366,0x00) --The Old Mansion BTL
			BitNot(Save+0x1CD6,0x02) --TT_203_END_L (Make Day 2 Work Properly)
		elseif Progress == 1 then --Before Munny Collection
			Visit = 2
			WriteShort(Save+0x20EC,0xC449) --Sandlot Barrier
		elseif Progress == 2 then --Munny Collection
			Visit = 2
			WriteShort(Save+0x2080,0xC44B) --Central Station Barrier
			WriteShort(Save+0x20E8,0x9F4A) --The Woods Barrier
			WriteShort(Save+0x20EC,0x9F49) --Sandlot Barrier
		elseif Progress == 3 then --Before Sandlot Dusk
			Visit = 3
			WriteShort(Save+0x20EC,0xC44C) --Sandlot Barrier
		elseif Progress == 4 then --Before Twilight Thorn
			Visit = 3
		elseif Progress == 5 then --[Start of Day 4, Before Setzer]
			Visit = 4
			WriteShort(Save+0x20E8,0xC542) --The Woods Barrier
			WriteShort(Save+0x2114,0xC540) --Station Plaza Barrier
		elseif Progress == 6 then --Start of Day 5
			Visit = 5
		elseif Progress == 7 then --Before Vivi's Wonder
			Visit = 5
			WriteByte(Save+0x2110,0xB791) --Tunnelway Barrier
		elseif Progress == 8 then --[After Vivi's Wonder, After Seven Wonders]
			Visit = 5
		elseif Progress == 9 then --Before Namine's Wonder
			Visit = 5
			WriteShort(Save+0x2080,0xC544) --Central Station Barrier
		elseif Progress == 10 then --[Before Back Street Nobodies, Before Entering the Mansion]
			Visit = 6
			WriteShort(Save+0x2114,0xC546) --Station Plaza Barrier
		elseif Progress == 11 then --[Before Entering the Library, Before Entering Computer Room]
			Visit = 6
			WriteShort(Save+0x211C,0xC548) --The Old Mansion Barrier
		elseif Progress == 12 then --Before Axel II
			Visit = 6
			WriteShort(Save+0x211C,0xC548) --The Old Mansion Barrier
		elseif Progress == 13 then --After Axel II
			Visit = 6
		end
	else
		Visit = 6
	end
	WriteByte(Save+0x3FF5,Visit)
	WriteShort(Save+0x20E4,0x9F42) --Underground Concourse Barrier
	WriteByte(Save+0x1CFB,0) --Beam Flag Reset
	--Load the Proper Spawn ID
	local SpawnOffset = 0x310 + Room*6
	if Evt < 0x20 then --Not a Special Event
		WriteShort(Now+0x4,ReadShort(Save+SpawnOffset+0x0))
		WriteShort(Now+0x6,ReadShort(Save+SpawnOffset+0x2))
		WriteShort(Now+0x8,ReadShort(Save+SpawnOffset+0x4))
	end
elseif ReadByte(Save+0x1CFF) == 13 then --Save Spawn ID within STT
	WriteShort(Save+0x0310,ReadShort(Save+0x03E8)) --Tunnelway -> The Empty Realm
	WriteShort(Save+0x0312,ReadShort(Save+0x03EA))
	WriteShort(Save+0x0314,ReadShort(Save+0x03EC))
	for i = 0,143 do
		WriteByte(Save+0x0230+i,ReadByte(Save+0x0310+i))
	end
end
--Save Points -> World Points
if ReadByte(Save+0x1CFF) == 13 then
	if Place == 0x0202 then --The Usual Spot
		if Events(0x02,0x02,0x02) then --Forced Save Menu
			Spawn('Short',0x06,0x034,0x23A)
		else
			Spawn('Short',0x06,0x034,0x239)
		end
	elseif Place == 0x2002 then --Station of Serenity
		Spawn('Short',0x04,0x034,0x239)
	elseif Place == 0x0502 then --Sandlot (Day 4)
		Spawn('Short',0x06,0x034,0x239)
	elseif Place == 0x0B02 then --Sunset Station
		Spawn('Short',0x09,0x034,0x239)
	elseif Place == 0x0902 then --Central Station
		Spawn('Short',0x11,0x034,0x239)
	elseif Place == 0x1202 then --The White Room
		Spawn('Short',0x06,0x034,0x239)
	elseif Place == 0x1502 then --Computer Room
		Spawn('Short',0x09,0x034,0x239)
	end
end
--Simulated Twilight Town Adjustments
if ReadByte(Save+0x1CFF) == 13 then --STT Removals
	BitNot(Save+0x1CEA,0x01) --TT_ROXAS_END (Play as Roxas)
	BitNot(Save+0x239E,0x08) --Hide Journal
	if ReadShort(Save+0x25D2)&0x8000 == 0x8000 then --Dodge Roll
		BitNot(Save+0x25D3,0x80)
		BitOr(Save+0x1CF1,0x01)
	end
	if ReadShort(Save+0x25D8)&0x8000 == 0x8000 then --Trinity Limit
		BitNot(Save+0x25D9,0x80)
		BitOr(Save+0x1CF1,0x02)
	end
	while ReadByte(Save+0x3594) > 0 do --Fire
		WriteByte(Save+0x1CF2,ReadByte(Save+0x1CF2)+1)
		WriteByte(Save+0x3594,ReadByte(Save+0x3594)-1)
	end
	while ReadByte(Save+0x3595) > 0 do --Blizzard
		WriteByte(Save+0x1CF3,ReadByte(Save+0x1CF3)+1)
		WriteByte(Save+0x3595,ReadByte(Save+0x3595)-1)
	end
	while ReadByte(Save+0x3596) > 0 do --Thunder
		WriteByte(Save+0x1CF4,ReadByte(Save+0x1CF4)+1)
		WriteByte(Save+0x3596,ReadByte(Save+0x3596)-1)
	end
	while ReadByte(Save+0x3597) > 0 do --Cure
		WriteByte(Save+0x1CF5,ReadByte(Save+0x1CF5)+1)
		WriteByte(Save+0x3597,ReadByte(Save+0x3597)-1)
	end
	while ReadByte(Save+0x35CF) > 0 do --Magnet
		WriteByte(Save+0x1CF6,ReadByte(Save+0x1CF6)+1)
		WriteByte(Save+0x35CF,ReadByte(Save+0x35CF)-1)
	end
	while ReadByte(Save+0x35D0) > 0 do --Reflect
		WriteByte(Save+0x1CF7,ReadByte(Save+0x1CF7)+1)
		WriteByte(Save+0x35D0,ReadByte(Save+0x35D0)-1)
	end
	local Equip = ReadShort(Save+0x24F0) --Currently equipped Keyblade
	local Store = ReadShort(Save+0x1CF9) --Last equipped Keyblade
	local Struggle
	if ReadByte(Save+0x1CF8) == 1 then
		Struggle = 0x180 --Struggle Sword
	elseif ReadByte(Save+0x1CF8) == 2 then
		Struggle = 0x1F5 --Struggle Wand
	elseif ReadByte(Save+0x1CF8) == 3 then
		Struggle = 0x1F6 --Struggle Hammer
	elseif not(Place == 0x0402 and Events(0x4C,0x4C,0x4C)) then --No Struggle Weapon Chosen
		WriteByte(Save+0x1CF8,math.random(3))
	end
	if Place == 0x0402 and Events(0x4C,0x4C,0x4C) then --Sandlot Weapons
		if Equip ~= 0x180 and Equip ~= 0x1F5 and Equip ~= 0x1F6 then
			WriteByte(Save+0x1CF8,0) --Reset Struggle Weapon Flag
		elseif ReadByte(Save+0x1CF8) == 0 then
			if Equip == 0x180 then --Struggle Sword
				WriteByte(Save+0x3651,ReadByte(Save+0x3651)+1)
				WriteByte(Save+0x1CF8,1)
			elseif Equip == 0x1F5 then --Struggle Wand
				WriteByte(Save+0x3690,ReadByte(Save+0x3690)+1)
				WriteByte(Save+0x1CF8,2)
			elseif Equip == 0x1F6 then --Struggle Hammer
				WriteByte(Save+0x3691,ReadByte(Save+0x3691)+1)
				WriteByte(Save+0x1CF8,3)
			end
		end
	elseif Place == 0x0402 and (Events(0x4D,0x4D,0x4D) or Events(0x4E,0x4E,0x4E) or Events(0x4F,0x4F,0x4F)) then --Tutorial Fights
		WriteShort(Save+0x24F0,Struggle)
	elseif Place == 0x0502 and (Events(0x54,0x54,0x54) or Events(0x55,0x55,0x55) or Events(0x58,0x58,0x58)) then --Struggle Fights
		WriteShort(Save+0x24F0,Struggle)
	elseif Place == 0x0502 and ReadShort(Now+0x32) ~= Door and (Door == 0x33 or Door == 0x35) then --Losing to Seifer or Vivi
		WriteShort(Save+0x24F0,Store)
	elseif Place == 0x0E02 and Events(0x7F,0x7F,0x7F) then --The Old Mansion Dusk
		WriteShort(Save+0x24F0,Struggle)
	elseif Place == 0x1402 then --Axel II (Oblivion is Equipped & Unequipped Automatically)
	elseif Equip ~= Store then
		if ReadByte(Cntrl) == 0 then
			WriteShort(Save+0x1CF9,Equip) --Change Stored Keyblade
		elseif Store > 0 then
			WriteShort(Save+0x24F0,Store) --Change Equipped Keyblade
		end
	end
	if ReadShort(Sys3+0xC0CE) == 0x35 then --STT BGM
		for i = 0x00,0x29 do
			local DefaultBGM = Sys3 + 0xC0CC + 0x40*i
			if ReadShort(DefaultBGM+2) == 0x35 then
				WriteShort(DefaultBGM+0x0,0x76) --Lazy Afternoons
				WriteShort(DefaultBGM+0x2,0x77) --Sinister Sundowns
				WriteShort(DefaultBGM+0x4,0x76)
				WriteShort(DefaultBGM+0x6,0x77)
				WriteShort(DefaultBGM+0x8,0x76)
				WriteShort(DefaultBGM+0xA,0x77)
			end
		end
	elseif ReadByte(Save+0x3FF5) == 6 and ReadByte(Save+0x1CFE) == 0 and ReadShort(Sys3+0xC0CC) == 0x76 then --Day 6 & STT Not Cleared
		for i = 0x00,0x29 do
			local DefaultBGM = Sys3 + 0xC0CC + 0x40*i
			if ReadShort(DefaultBGM+2) == 0x77 then
				WriteShort(DefaultBGM+0x0,0) --Remove Field Music
				WriteShort(DefaultBGM+0x4,0)
				WriteShort(DefaultBGM+0x8,0)
			end
		end
	end
else --Restore Outside STT
	BitOr(Save+0x1CEA,0x01) --TT_ROXAS_END (Play as Sora)
	BitOr(Save+0x239E,0x08) --Show Journal
	if ReadByte(Save+0x1CF1)&0x01 == 0x01 then --Dodge Roll
		BitOr(Save+0x25D3,0x80)
		BitNot(Save+0x1CF1,0x01)
	end
	if ReadByte(Save+0x1CF1)&0x02 == 0x02 then --Trinity Limit
		BitOr(Save+0x25D9,0x80)
		BitNot(Save+0x1CF1,0x02)
	end
	while ReadByte(Save+0x1CF2) > 0 do --Fire
		WriteByte(Save+0x1CF2,ReadByte(Save+0x1CF2)-1)
		WriteByte(Save+0x3594,ReadByte(Save+0x3594)+1)
	end
	while ReadByte(Save+0x1CF3) > 0 do --Blizzard
		WriteByte(Save+0x1CF3,ReadByte(Save+0x1CF3)-1)
		WriteByte(Save+0x3595,ReadByte(Save+0x3595)+1)
	end
	while ReadByte(Save+0x1CF4) > 0 do --Thunder
		WriteByte(Save+0x1CF4,ReadByte(Save+0x1CF4)-1)
		WriteByte(Save+0x3596,ReadByte(Save+0x3596)+1)
	end
	while ReadByte(Save+0x1CF5) > 0 do --Cure
		WriteByte(Save+0x1CF5,ReadByte(Save+0x1CF5)-1)
		WriteByte(Save+0x3597,ReadByte(Save+0x3597)+1)
	end
	while ReadByte(Save+0x1CF6) > 0 do --Magnet
		WriteByte(Save+0x1CF6,ReadByte(Save+0x1CF6)-1)
		WriteByte(Save+0x35CF,ReadByte(Save+0x35CF)+1)
	end
	while ReadByte(Save+0x1CF7) > 0 do --Reflect
		WriteByte(Save+0x1CF7,ReadByte(Save+0x1CF7)-1)
		WriteByte(Save+0x35D0,ReadByte(Save+0x35D0)+1)
	end
	WriteShort(Save+0x1CF9,0) --Remove stored Keyblade
	if ReadShort(Sys3+0xC0CE) == 0x77 then --TT BGM
		for i = 0x00,0x29 do
			local DefaultBGM = Sys3 + 0xC0CC + 0x40*i
			if ReadShort(DefaultBGM+2) == 0x77 then
				WriteShort(DefaultBGM+0x0,0x34) --The Afternoon Streets
				WriteShort(DefaultBGM+0x2,0x35) --Working Together
				WriteShort(DefaultBGM+0x4,0x34)
				WriteShort(DefaultBGM+0x6,0x35)
				WriteShort(DefaultBGM+0x8,0x34)
				WriteShort(DefaultBGM+0xA,0x35)
			end
		end
	end
end
--Faster Twilight Thorn Reaction Commands
if Place == 0x2202 and Events(0x9D,0x9D,0x9D) then
	WriteShort(Save+0x03DE,0x00) --Station of Awakening BTL (Used as an STT Flag)
	if ReadInt(CutLen) == 0x40 then --RC Start
		BitOr(Save+0x1CFB,0x02)
	elseif ReadInt(CutLen) == 0x16C and ReadInt(CutNow) == 0x16C then --Break Raid Succeed
		BitNot(Save+0x1CFB,0x02)
	elseif ReadInt(CutLen) == 0x260 and ReadInt(CutNow) == 0x260 then --Break Raid Failed
		BitNot(Save+0x1CFB,0x02)
	elseif ReadInt(CutLen) == 0x04D then --Break Raid Kill
		BitNot(Save+0x1CFB,0x02)
	end
	if ReadByte(Save+0x1CFB)&0x02 == 0x02 then
		Faster(true)
	elseif Platform == 'PS2' then
		Faster(false)
	elseif Platform == 'PC' and ReadFloat(0x07151D4) > 1 then --Exclude death cutscene
		Faster(false)
	end
end
--[[Shorter Day 5
if Place == 0x0B02 and Events(0x01,0x00,0x0C) then
	WriteByte(Save+0x1D0E,8)
	WriteShort(Save+0x034C,0x02) --Sunset Terrace MAP (After Wonders)
	WriteShort(Save+0x0350,0x0D) --Sunset Terrace EVT
	WriteShort(Save+0x0356,0x13) --Sunset Station EVT
	WriteShort(Save+0x0358,0x03) --Sunset Hill MAP (After Wonder)
	WriteShort(Save+0x035C,0x01) --Sunset Hill EVT
	WriteShort(Save+0x03E8,0x03) --Tunnelway MAP (Spawn Skateboard)
	WriteShort(Save+0x03EC,0x00) --Tunnelway EVT
	WriteShort(Save+0x2110,0x0000) --Tunnelway Barrier Removal
	BitOr(Save+0x2394,0x1E) --Minigame Finished Flags
	BitOr(Save+0x1CDD,0x40) --TT_MISTERY_A_END (The Animated Bag)
	BitOr(Save+0x1CDD,0x80) --TT_MISTERY_B_END (The Friend from Beyond the Wall)
	BitOr(Save+0x1CDE,0x01) --TT_MISTERY_C_END (The Moans from the Tunnel)
	BitOr(Save+0x1CEF,0x80) --TT_MISTERY_C_OUT
	BitOr(Save+0x1CDE,0x02) --TT_MISTERY_D_END (The Doppelganger)
	BitOr(Save+0x1CDE,0x04) --TT_506_END_L
end--]]
--Beam -> Garden of Assemblage
if ReadShort(Save+0x0392) == 0x00 then --Beam Event Trigger Spawn
	WriteShort(Save+0x0392,0x10) --Computer Room EVT
elseif Place == 0x1502 and ReadByte(Save+0x1CFF) == 13 then
	Spawn('Int',0x01,0x220,0x00099) --Show Beam
	Spawn('String',0x01,0x254,'m_81') --Spawn Beam RC
	Spawn('Short',0x10,0x55A,0x04) --Warp Pointer to Garden of Assemblage
	Spawn('Short',0x10,0x55C,0x1A)
	Spawn('Short',0x10,0x55E,0x21)
	Spawn('Short',0x10,0x552,0xC58) --b 11 0001011 000
	--Same as BitOr(Save+0x1CFB,0x01). Also stops the game from editing the spawn IDs.
elseif Place == 0x1A04 and Door == 0x21 and ReadByte(Save+0x1CFB) == 1 then --Exited STT By Beam
	WriteByte(Save+0x1CFF,0)
	if ReadByte(Save+0x1CFE) > 0 then --Post-Story Save
		WriteByte(Save+0x1CFE,5)
	end
end
end

function AW()
--0th Visit Adjustments
if Place == 0x0009 and Events(0x00,Null,Null) then --0th Visit
	BitNot(Save+0x1D16,0x02) --HB_START_Pooh
	WriteArray(Save+0x066A,ReadArray(Save+0x0646,6)) --Save Borough Spawn ID
	WriteArray(Save+0x0664,ReadArray(Save+0x065E,6)) --Save Merlin's House Spawn ID
elseif Place == 0x0D04 and Events(0x65,0x65,0x65) and PrevPlace == 0x0209 then --Lost Memories
	WriteByte(Save+0x1DBF,1)
	WriteArray(Save+0x0646,ReadArray(Save+0x066A,6)) --Load Borough Spawn ID
	WriteArray(Save+0x065E,ReadArray(Save+0x0664,6)) --Load Merlin's House Spawn ID
end
--Prevent Leaving in 0th Visit
if Place == 0x0009 and ReadByte(Save+0x1DBF) == 0 then
	Spawn('Short',0x01,0x414,0x0D) --MAP 0x01
	Spawn('Short',0x01,0x416,0x01)
	Spawn('Short',0x01,0x57C,0x0D) --MAP 0x02
	Spawn('Short',0x01,0x57E,0x01)
end
--Skip 0th Visit
if ReadShort(Save+0x0D90) == 0x00 then
	WriteByte(Save+0x1DBF,1)
	WriteShort(Save+0x0D90,0x02) --The Hundred Acre Wood MAP (Pooh's House Only)
	WriteShort(Save+0x0DA0,0x16) --Pooh's House EVT
	BitOr(Save+0x1D16,0x04) --HB_901_END
	BitOr(Save+0x1D16,0x08) --HB_902_END
	BitOr(Save+0x1D16,0x20) --HB_903_END
	BitOr(Save+0x1DB0,0x01) --PO_START
	BitOr(Save+0x1DB0,0x02) --PO_001_END (Show 100AW in Journal)
	BitOr(Save+0x1DB0,0x04) --PO_003_END
	BitOr(Save+0x1DB0,0x08) --PO_004_END
	BitOr(Save+0x1D16,0x10) --HB_po_004_END
	BitOr(Save+0x1D16,0x40) --HB_904_END
	BitOr(Save+0x1D17,0x08) --HB_905_END (Enable Torn Page Detection)
	BitOr(Save+0x1D18,0x08) --HB_hb09_ms901
	BitOr(Save+0x1DB0,0x10) --PO_HB_BATTLE_END
	BitOr(Save+0x1DB0,0x20) --PO_005_END
	BitOr(Save+0x1DB0,0x40) --PO_007_END
	BitOr(Save+0x1DB0,0x80) --PO_008_END
	BitOr(Save+0x1D17,0x02) --HB_po_008_END
	BitOr(Save+0x1D17,0x08) --HB_907_END
end
--Faster A Blustery Rescue
if Place == 0x0609 then --In Minigame
	if ReadByte(Cntrl) == 0 then --Minigame Started
		Faster(true)
	end
elseif Place == 0x0409 then --Minigame Ended
	Faster(false)
end
--Faster Hunny Slider
if Place == 0x0709 then --In Minigame
	if ReadByte(Cntrl) == 0 then --Minigame Started
		Faster(true)
	end
elseif Place == 0x0309 then --Minigame Ended
	Faster(false)
end
end

function At()
--Garden of Assemblage Exit -> Atlantica
if Place == 0x1A04 and ReadByte(Save+0x1DFF) == 0 then --1st Visit
	Spawn('Short',0x0A,0x23C,0x07)
end
--Atlantica Visited
if Place == 0x020B and Events(Null,Null,0x01) then --The Kingdom Under the Sea
	WriteByte(Save+0x1DFF,1)
end
end

function Data()
--Station of Calling Spawns
if true then
	local Path
	if Place == 0x2002 then --Station of Serenity
		Path = 0
	elseif Place == 0x1212 then --The Altar of Naught
		Path = 1
	elseif Place == 0x0708 then --Summit
		Path = 2
	elseif Place == 0x0405 then --Ballroom
		Path = 3
	elseif Place == 0x0D0A then --Peak
		Path = 7
	elseif Place == 0x2802 and ReadByte(Save+0x1CFF) == 8 then --Betwixt & Between
		Path = 8
		WriteByte(Save+0x3FF5,10) --Battle Level TT3
	elseif Place == 0x1204 then --Restoration Site (Destroyed)
		Path = 9
	elseif Place == 0x0A10 then --Isla de Muerta: Treasure Heap
		Path = 10
	elseif Place == 0x1702 and ReadByte(Save+0x1CFF) == 13 then --Mansion: Pod Room
		Path = 13
		WriteByte(Save+0x3FF5,6) --Battle Level Day 6
	elseif Place == 0x1A04 then --Garden of Assemblage
		Path = 15
	end
	if Path == 0 then
		WriteShort(Save+0x03D6,0x00) --Station of Calling MAP
		WriteShort(Save+0x03D8,0x01) --Station of Calling BTL
		WriteByte(Save+0x3FF5,3) --Battle Level Day 3
	elseif Path then
		WriteShort(Save+0x03D6,Path) --Station of Calling MAP
		WriteShort(Save+0x03D8,0x00) --Station of Calling BTL
	end
end
--Prevent Disappearing Summon Softlock
if Place == 0x2102 and PrevPlace ~= 0x2102 and PrevPlace ~= 0x2002 then
	WriteByte(Save+0x3FF5,13) --Battle Level Data
end
--Revert STT/TT Flags
if Place == 0x1312 and Events(0x67,0x67,0x67) then --Data Xemnas I
	BitNot(Save+0x1CEE,0x0C) --TT_TT21 (Computer Room Flag Fix)
elseif Place == 0x1402 and Events(0xD3,0xD3,0xD3) then --Data Axel
	WriteByte(Save+0x1CFF,0) --Reset TT & STT Flag
	WriteShort(Save+0x0212,0x00) --Basement Hall MAP (TT Real)
	WriteShort(Save+0x0214,0x07) --Basement Hall BTL
	WriteShort(Save+0x021E,0x03) --Computer Room MAP (TT Real)
	WriteShort(Save+0x0222,0x0F) --Computer Room EVT
	BitNot(Save+0x1CEE,0x0C) --TT_TT21 (Computer Room Flag Fix)
elseif Place == 0x1512 and Events(0x71,0x71,0x71) then --Data Roxas
	WriteByte(Save+0x1CFF,0) --Reset TT & STT Flag
end
--Music Change - Final Fights
if ReadShort(Save+0x03D6) == 15 --[[and Platform == 'PS2'--]] then
	if Place == 0x1B12 then --Part I
		Spawn('Short',0x06,0x0A4,0x09C) --Guardando nel buio
		Spawn('Short',0x06,0x0A6,0x09C)
	elseif Place == 0x1C12 then --Part II
		Spawn('Short',0x07,0x008,0x09C)
		Spawn('Short',0x07,0x00A,0x09C)
	elseif Place == 0x1A12 then --Cylinders
		Spawn('Short',0x07,0x008,0x09C)
		Spawn('Short',0x07,0x00A,0x09C)
	elseif Place == 0x1912 then --Core
		Spawn('Short',0x07,0x008,0x09C)
		Spawn('Short',0x07,0x00A,0x09C)
	elseif Place == 0x1812 then --Armor Xemnas I
		Spawn('Short',0x06,0x008,0x09C)
		Spawn('Short',0x06,0x00A,0x09C)
		Spawn('Short',0x06,0x034,0x09C)
		Spawn('Short',0x06,0x036,0x09C)
	elseif Place == 0x1D12 then --Pre-Dragon Xemnas
		Spawn('Short',0x03,0x010,0x09C)
		Spawn('Short',0x03,0x012,0x09C)
	end
end
end

--[[Unused Bytes Repurposed:
[Save+0x01A0,Save+0x022F] TT Spawn IDs
[Save+0x0230,Save+0x02BF] STT Spawn IDs
[Save+0x0664,Save+0x0669] Merlin's House Spawn IDs
[Save+0x066A,Save+0x066F] Borough Spawn IDs
Save+0x06B2 Genie Crash Fix
[Save+0x07F0,Save+0x07FB] Mrs Potts' Minigame Location
[Save+0x1B13,Save+0x1B15] Promise Charm Warp
Save+0x1CF1 STT Dodge Roll, STT Trinity Limit
Save+0x1CF2 STT Fire
Save+0x1CF3 STT Blizzard
Save+0x1CF4 STT Thunder
Save+0x1CF5 STT Cure
Save+0x1CF6 STT Magnet
Save+0x1CF7 STT Reflect
Save+0x1CF8 STT Struggle Weapon
[Save+0x1CF9,Save+0x1CFA] STT Keyblade
Save+0x1CFB STT Computer Beam & Twilight Thorn Flag
Save+0x1CFC Road to Data
Save+0x1CFD TT Post-Story Save
Save+0x1CFE STT Post-Story Save
Save+0x1CFF STT/TT Flag
Save+0x1D0D TT Progress
Save+0x1D0E STT Progress
Save+0x1D2E HB Post-Story Save
Save+0x1D2F HB Progress
Save+0x1D3E BC Post-Story Save
Save+0x1D3F BC Progress
Save+0x1D6E OC Post-Story Save
Save+0x1D6F OC Progress
Save+0x1D7E Ag Post-Story Save
Save+0x1D7F Ag Progress
Save+0x1D9E LOD Post-Story Save
Save+0x1D9F LOD Progress
Save+0x1DBF AW 0th Visit Flag
Save+0x1DDE PL Post-Story Save
Save+0x1DDF PL Progress
Save+0x1DFF At 0th Visit Flag
Save+0x1E1E DC Post-Story Save
Save+0x1E1F DC Progress
Save+0x1E5E HT Post-Story Save
Save+0x1E5F HT Progress
Save+0x1E9E PR Post-Story Save
Save+0x1EBE SP Post-Story Save
Save+0x1EBF SP Progress
Save+0x1EDE TWtNW Post-Story Save
Save+0x1EDF TWtNW Progress
Save+0x35C4 Ollete's Munny Pouch
Save+0x35C5 Mickey's Munny Pouch
--]]
