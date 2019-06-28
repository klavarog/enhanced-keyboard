unit uLayots;

interface

uses
	Windows;

const
	keyShift = 1;
  keyContorl = 2;
  keyAlt = 4;


const
  cSwitchKeyUp = 0;
  cSwitchToggle = 1;
  cSwitchNextKey = 2;
  cSwitchKeyUpDelay = 3;


type

	TKBDLLHOOKSTRUCT = record
   vkCode: DWORD;
   scanCode: DWORD;
   flags: DWORD;
   time: DWORD;
   dwExtraInfo: DWORD;
 end;
 PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;


	EKeyState = (ksNone = 0, ksDown, ksRepeat);
  EKeyAction = (kaNone = 0, kaSkip, kaLayout);


  TLayout = class;

	RKeyState = record
  	// consts
  	vkCode:integer;
    bSkip:boolean;
    nFlags:cardinal;
    sName:string;

    // variables
    LayNum:cardinal;
    nKeyAction:EKeyAction;
    nLock:integer;
    nRealState:EKeyState;
    nVirtState:EKeyState;
    bToggled:boolean;
    bSkipUp:boolean;
    nSysKeys:integer;
  end;

  PKeyState = ^RKeyState;

	TKeyInfo = class
		constructor Create;
		destructor Destroy; override;
	public
		//
    pNewLayout:TLayout;
    nNewKeyCode:DWORD;
    bExecuted:boolean;
    sMacros:string;
    nSysKeys:integer;
    bToggle:boolean;
    bCloseLayOnKeyUp:boolean;
    nSwitchMode:integer;
	end;

  RKeyDownInfo = record
    vkCode:integer;
    nSysKeys:integer;
  end;
  PKeyDownInfo = ^RKeyDownInfo;

	TLayout = class
		constructor Create;
		destructor Destroy; override;
	public
		//
    keys:array[0..255] of TKeyInfo;
    PressedKeys:array of RKeyDownInfo;
    PressedKeysC:integer;
    PressedKeysAl:integer;

    sName:string;
    LayautID: integer;
    pPrev:TLayout;
    bUsed:boolean;
    nActiveRefs:integer;
    bToggled:boolean;
    bCloseOnKeyUp:boolean;
    nActivatedTime:cardinal;
    nSysKeys:integer;
    nSwitchMode:integer;
  public
  	procedure AddKeyDown(vkCode:cardinal; nSysKeys:integer);
    procedure ClearKeyDown;
	end;

	TLayouts = class
		constructor Create;
		destructor Destroy; override;
	public
		//
    aLayouts:array of TLayout;
    Count:integer;
  public
    function FindLayout(sLayout:string):integer;
  	function FindLayout2(sLayout:string):TLayout;
  	function AddLayout(sName:string):TLayout;
    procedure ClearLayout(l:TLayout);
    procedure ClearLayouts;
    procedure ResetStates;
    function AddKeyReplace(l:TLayout; nKey1, nKey2, nSysKeys:integer):boolean;
    function AddKeyLayout(l:TLayout; nKey1, nSysKeys:integer; sLayout:string; nSwitchMode:integer):boolean;
    function AddKeyMacros(l:TLayout; nKey1:integer; sMacros:string):boolean;

	end;


implementation

///////////////////////////////////////

constructor TKeyInfo.Create;
begin
	//
  pNewLayout:=nil;
  nNewKeyCode:=0;
  nSysKeys:=0;
  bToggle:=false;
  bExecuted:=false;
  bCloseLayOnKeyUp := false;
  nSwitchMode := -1;
end;

destructor TKeyInfo.Destroy;
begin
	//
	inherited Destroy;
end;


//////////////////////////////////////////////////////////////////////////////


procedure TLayout.AddKeyDown(vkCode:cardinal; nSysKeys:integer);
var
	pkdi:PKeyDownInfo;
begin
  //
  //Assert(LayautID>1, 'There is no need to remember keys for default layout');
  if PressedKeysC = 0 then
  begin
    nActivatedTime := GetTickCount;
  end;

  Inc(PressedKeysC);
  if PressedKeysAl <= PressedKeysC then
  begin
    Inc(PressedKeysAl);
    SetLength(PressedKeys, PressedKeysAl);
  end;
  pkdi:=@PressedKeys[PressedKeysC-1];
  pkdi.vkCode:=vkCode;
  pkdi.nSysKeys:=nSysKeys;
end;

procedure TLayout.ClearKeyDown;
begin
  //
  PressedKeysC := 0;
  nActivatedTime := 0;
end;

///////////////////////////////////////

constructor TLayout.Create;
begin
	//
  //FillChar(keys, SizeOf(TKeyInfo) * 256, 0);
  pPrev:=nil;
  bUsed:=false;
  nActiveRefs:=0;
  bToggled:=false;
  nActivatedTime := 0;

  nSysKeys := 0;
  bCloseOnKeyUp := false;
  nSwitchMode := -1;

  PressedKeysC:=0;
  PressedKeysAl:=10;
  SetLength(PressedKeys, PressedKeysAl);
end;

destructor TLayout.Destroy;
var
	i:integer;
begin
	//
  for i := 0 to 255 do
  begin
    //
    if keys[i]<>nil then
    	keys[i].Free;
  end;

	inherited Destroy;
end;

///////////////////////////////////////

function TLayouts.FindLayout(sLayout:string):integer;
var
	i:integer;
begin
  //
  for i := 0 to Count-1 do
  begin
    if aLayouts[i].sName=sLayout then
    begin
      result:=i;
      exit;
    end;
  end;

  result:=-1;

end;

procedure TLayouts.ResetStates;
var
	i:integer;
  lt:TLayout;
begin
  //
  for i := 0 to Count-1 do
  begin
    lt := aLayouts[i];
    lt.bUsed:=false;
    lt.nActiveRefs := 0;
    lt.ClearKeyDown;
  end;
end;

function TLayouts.FindLayout2(sLayout:string):TLayout;
var
  li:integer;
begin
  //
  result:=nil;
  li := FindLayout(sLayout);
  if li=-1 then
  	exit;

  result:=aLayouts[li];

end;


function TLayouts.AddKeyReplace(l:TLayout; nKey1, nKey2, nSysKeys:integer):boolean;
var
	ki: TKeyInfo;
begin
  //
  result:=false;
  assert(l.keys[nKey1] = nil);
  if l.keys[nKey1]<>nil then
  	exit;

  ki := TKeyInfo.Create;
  ki.nNewKeyCode := nKey2;
  //ki.bRepeat := true;
  ki.nSysKeys := nSysKeys;

  l.keys[nKey1] := ki;
  result:=true;
end;

function TLayouts.AddKeyLayout(l:TLayout; nKey1, nSysKeys:integer; sLayout:string; nSwitchMode:integer):boolean;
var
	ki: TKeyInfo;
  Lay2:TLayout;
  li:integer;
begin
  //
  result:=false;
  li := FindLayout(sLayout);
  if li=-1 then
  	exit;
  Lay2:= aLayouts[li];

  if (nSwitchMode <> 2) then
  begin
    assert(Lay2.keys[nKey1] = nil);
    if Lay2.keys[nKey1]<>nil then
      exit;
  end;

  result:=true;

  ki := TKeyInfo.Create;
  ki.pNewLayout := Lay2;
  ki.nSysKeys := nSysKeys;
  ki.bToggle := (nSwitchMode = cSwitchToggle);
  ki.bCloseLayOnKeyUp := (nSwitchMode = cSwitchNextKey);
  ki.nSwitchMode := nSwitchMode;
  assert(l.keys[nKey1] = nil);
  l.keys[nKey1] := ki;

  if ki.bCloseLayOnKeyUp then
    exit;

  ki := TKeyInfo.Create;
  ki.pNewLayout := Lay2;
  ki.nSysKeys := nSysKeys;
  ki.bToggle := (nSwitchMode = cSwitchToggle);
  ki.nSwitchMode := nSwitchMode;

  Lay2.keys[nKey1] := ki;

end;


function TLayouts.AddKeyMacros(l:TLayout; nKey1:integer; sMacros:string):boolean;
var
	ki: TKeyInfo;
begin
  //
  result:=false;
  assert(l.keys[nKey1] = nil);
  if l.keys[nKey1]<>nil then
  	exit;

  ki := TKeyInfo.Create;
  //ki.nNewKeyCode := nKey2;
  ki.sMacros := sMacros;

  l.keys[nKey1] := ki;
  result:=true;
end;

procedure TLayouts.ClearLayout(l:TLayout);
var
	i:integer;
  ki, ki2:TKeyInfo;
begin
	//
  for i := 0 to 255 do
  begin
    //
    ki:=l.keys[i];
    if ki = nil then
    	continue;

    if ki.pNewLayout = l then
    	continue;

    if ki.pNewLayout <> nil then
    begin
      //
      ki2:=ki.pNewLayout.keys[i];
      assert(ki2<>nil);
      if ki2<>nil then
      begin
        //
        ki2.Free;
        ki.pNewLayout.keys[i]:=nil;
      end;
    end;

    ki.Free;
    l.keys[i]:=nil;

  end;
end;

function TLayouts.AddLayout(sName:string):TLayout;
begin
  //
  result:=nil;
  Inc(Count);
  SetLength(aLayouts, Count);
  aLayouts[Count-1] := TLayout.Create;
  result:=aLayouts[Count-1];
  result.sName:=sName;
  result.LayautID := Count;
end;

constructor TLayouts.Create;
var
	ki: TKeyInfo;
begin
	//
  Count:=0;
end;


procedure TLayouts.ClearLayouts;
var
	i:integer;
begin
  //
  for i := 0 to Count-1 do
  	aLayouts[i].Free;

  Count:=0;
  SetLength(aLayouts, Count);
end;

destructor TLayouts.Destroy;
begin
	//
  ClearLayouts;
	inherited Destroy;
end;

end.

