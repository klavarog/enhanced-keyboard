unit uKeyboardHelper;

interface

uses
	Windows, uLayots, SysUtils;

  procedure KeyDown(nKey:integer);
  procedure KeyDownEx(nKey:integer; nSysKeys:integer);
  procedure KeyUp(nKey:integer);
  procedure KeyPress(nKey:integer);
  procedure KeyPressEx(nKey:integer; nSysKeys:integer);
  procedure ExecKey(vkCode: DWORD; nSys:integer);

  procedure InitKeyStates;

  //
  function CheckShiftReal:integer;
  function CheckCtrlReal:integer;
  function CheckAltReal:integer;
  function GetSysKeysReal:integer;

  function CheckShiftVirt:integer;
  function CheckCtrlVirt:integer;
  function CheckAltVirt:integer;
  function GetSysKeysVirt:integer;

  procedure DebugOut(sMsg:string);

//var
//  m_Input1:TInput;

implementation

uses
	uKeyboard;

procedure DebugOut(sMsg:string);
begin
  OutputDebugString(PChar(sMsg));
end;


procedure KeyDownEx(nKey:integer; nSysKeys:integer);
var
  np1, np2:cardinal;
  bVal:boolean;
  nFlag:cardinal;

  procedure AddKeyDown(nKey:integer);
  begin
  	nFlag := m_KeyStates[nKey].nFlags;

    m_aInputs1[np1].ki.wVk := nKey;
    m_aInputs1[np1].ki.dwFlags := nFlag;
    Inc(np1);
    m_aInputs2[np2].ki.wVk := nKey;
    m_aInputs2[np2].ki.dwFlags := nFlag or KEYEVENTF_KEYUP;
    Inc(np2);
  end;
begin
  //
  np1:=0;
  np2:=0;

  if ((nSysKeys and keyShift)<>0) and ((CheckShiftVirt=0)) then
  begin
    AddKeyDown(VK_LSHIFT);
  end;

  if ((nSysKeys and keyContorl)<>0) and ((CheckCtrlVirt=0)) then
  begin
    AddKeyDown(VK_LCONTROL);
  end;

  if ((nSysKeys and keyAlt)<>0) and ((CheckAltVirt=0)) then
  begin
    AddKeyDown(VK_LMENU);
  end;

  nFlag := m_KeyStates[nKey].nFlags;
  m_aInputs1[np1].ki.wVk := nKey;
  m_aInputs1[np1].ki.dwFlags := nFlag;
  Inc(np1);

  SendInput(np1, m_aInputs1[0], sizeof(TInput));

  if np2>0 then
  begin
    SendInput(np2, m_aInputs2[0], sizeof(TInput));
  end;

end;

procedure KeyDown(nKey:integer);
begin
  //
  m_Input1.ki.wVk := nKey;
  m_Input1.ki.dwFlags := m_KeyStates[nKey].nFlags;

  SendInput(1, m_Input1, sizeof(TInput));//}
end;

procedure KeyUp(nKey:integer);
begin
  //
  m_Input1.ki.wVk := nKey;
  m_Input1.ki.dwFlags := m_KeyStates[nKey].nFlags or KEYEVENTF_KEYUP;

  SendInput(1, m_Input1, sizeof(TInput));
end;

procedure KeyPressEx(nKey:integer; nSysKeys:integer);
begin
  //
  if nSysKeys=0 then
  begin
    KeyPress(nKey);
    exit;
  end;

  //DebugOut('KeyPressEx');
  KeyDownEx(nKey, nSysKeys);
  KeyUp(nKey);
end;

procedure KeyPress(nKey:integer);
begin
  //
  m_aInputs1[0].ki.wVk := nKey;
  m_aInputs1[0].ki.dwFlags := m_KeyStates[nKey].nFlags;

  m_aInputs1[1].ki.wVk := nKey;
  m_aInputs1[1].ki.dwFlags := m_KeyStates[nKey].nFlags or KEYEVENTF_KEYUP;

  SendInput(2, m_aInputs1[0], sizeof(TInput));
end;


function CheckShiftVirt:integer;
begin
  result:=0;
  if (m_KeyStates[VK_SHIFT].nVirtState > ksNone) or (m_KeyStates[VK_LSHIFT].nVirtState > ksNone) or (m_KeyStates[VK_RSHIFT].nVirtState > ksNone) then
  	result := keyShift;
end;

function CheckCtrlVirt:integer;
begin
  result:=0;
  if (m_KeyStates[VK_CONTROL].nVirtState > ksNone) or (m_KeyStates[VK_LCONTROL].nVirtState > ksNone) or (m_KeyStates[VK_RCONTROL].nVirtState > ksNone) then
    result := keyContorl;
end;

function CheckAltVirt:integer;
begin
  result:=0;
  if (m_KeyStates[VK_MENU].nVirtState > ksNone) or (m_KeyStates[VK_LMENU].nVirtState > ksNone) or (m_KeyStates[VK_RMENU].nVirtState > ksNone) then
    result := keyAlt;
end;

function GetSysKeysVirt:integer;
begin
  result:= CheckShiftVirt or CheckCtrlVirt or CheckAltVirt;
end;

///

function CheckShiftReal:integer;
begin
  result:=0;
  if (m_KeyStates[VK_SHIFT].nRealState > ksNone) or (m_KeyStates[VK_LSHIFT].nRealState > ksNone) or (m_KeyStates[VK_RSHIFT].nRealState > ksNone) then
  	result := keyShift;
end;

function CheckCtrlReal:integer;
begin
  result:=0;
  if (m_KeyStates[VK_CONTROL].nRealState > ksNone) or (m_KeyStates[VK_LCONTROL].nRealState > ksNone) or (m_KeyStates[VK_RCONTROL].nRealState > ksNone) then
    result := keyContorl;
end;

function CheckAltReal:integer;
begin
  result:=0;
  if (m_KeyStates[VK_MENU].nRealState > ksNone) or (m_KeyStates[VK_LMENU].nRealState > ksNone) or (m_KeyStates[VK_RMENU].nRealState > ksNone) then
    result := keyAlt;
end;

function GetSysKeysReal:integer;
begin
  result:= CheckShiftReal or CheckCtrlReal or CheckAltReal;
end;


procedure ExecKey(vkCode: DWORD; nSys:integer);
var
	bVal:boolean;
  np1, np2:cardinal;
  i:integer;
  nFlag: cardinal;

  procedure AddKeyDown(nKey:integer);
  begin
  	nFlag := m_KeyStates[nKey].nFlags;

    m_aInputs1[np1].ki.wVk := nKey;
    m_aInputs1[np1].ki.dwFlags := nFlag;
    Inc(np1);
    m_aInputs2[np2].ki.wVk := nKey;
    m_aInputs2[np2].ki.dwFlags := nFlag or KEYEVENTF_KEYUP;
    Inc(np2);
  end;

  procedure RemoveKeyDown(nKey:integer);
  begin
    if (m_KeyStates[nKey].nVirtState = ksNone) then
    	exit;


    nFlag := m_KeyStates[nKey].nFlags;

    m_aInputs1[np1].ki.wVk := nKey;
    m_aInputs1[np1].ki.dwFlags := nFlag or KEYEVENTF_KEYUP;
    Inc(np1);


    m_aInputs2[np2].ki.wVk := nKey;
    m_aInputs2[np2].ki.dwFlags := nFlag;
    Inc(np2);//}
  end;
begin
  //
	np1:=0;
  np2:=0;
  //OutputDebugString(PChar('# Exec Key: '+inttostr(vkCode)+' '+inttostr(nSys)));

 	bVal:=(nSys and keyShift)<>0;       //  GetKeyState(VK_SHIFT)

  //OutputDebugString(PChar('Shift state '+inttostr(GetKeyState(VK_SHIFT))));
  if (bVal) xor (CheckShiftVirt<>0) then
  begin
  	//OutputDebugString('CheckShift');
  	if bVal then
    begin
    	AddKeyDown(VK_LSHIFT);
    end else
    begin
      RemoveKeyDown(VK_LSHIFT);
      RemoveKeyDown(VK_RSHIFT);
    end;
  end;

  bVal:=(nSys and keyContorl)<>0;
  if (bVal) xor (CheckCtrlVirt<>0) then
  begin
  	if bVal then
    begin
    	AddKeyDown(VK_LCONTROL);
    end else
    begin
//      RemoveKeyDown(VK_CONTROL);
      RemoveKeyDown(VK_LCONTROL);
      RemoveKeyDown(VK_RCONTROL);
    end;
  end;

  bVal:=(nSys and keyAlt)<>0;
  if (bVal) xor (CheckAltVirt<>0) then
  begin
  	if bVal then
    begin
    	AddKeyDown(VK_LMENU);
    end else
    begin
//      RemoveKeyDown(VK_MENU);
      RemoveKeyDown(VK_LMENU);
      RemoveKeyDown(VK_RMENU);
    end;
  end;              //}


  nFlag := m_KeyStates[vkCode].nFlags;

  m_aInputs1[np1].ki.wVk := vkCode;
  m_aInputs1[np1].ki.dwFlags := nFlag;
  Inc(np1);
  m_aInputs1[np1].ki.wVk := vkCode;
  m_aInputs1[np1].ki.dwFlags := nFlag or KEYEVENTF_KEYUP;
  Inc(np1);


//  OutputDebugString(PChar('Shift: '+inttostr(GetKeyState(VK_SHIFT) and $8000)));

  SendInput(np1, m_aInputs1[0], sizeof(TInput));

  {for i := 0 to np1 - 1 do
  begin
  	OutputDebugString(PChar('Key : ' +inttostr(m_aInputs1[i].ki.wVk)+' '+inttostr(m_aInputs1[i].ki.dwFlags)));
  end;//}

//  OutputDebugString(PChar('Shift: '+inttostr(GetKeyState(VK_SHIFT) and $8000)));



  if np2>0 then
  begin
  	{OutputDebugString('--');
  	for i := 0 to np2 - 1 do
    begin
      OutputDebugString(PChar('Key : '+inttostr(m_aInputs2[i].ki.wVk)+' '+inttostr(m_aInputs2[i].ki.dwFlags)));
    end;//}

    SendInput(np2, m_aInputs2[0], sizeof(TInput));
  end;      //}

end;


procedure InitKeyNames;
var
	i:integer;
begin
  //
  for i := 48 to  90 do
  begin
    m_KeyStates[i].sName:=Chr(i);
  end;

  m_KeyStates[VK_LBUTTON].sName := 'Lb';
  m_KeyStates[VK_RBUTTON].sName := 'Rb';
  m_KeyStates[VK_CANCEL].sName := 'Cancel';
  m_KeyStates[VK_MBUTTON].sName := 'Mb';
  m_KeyStates[VK_BACK].sName := 'Backspace';
  m_KeyStates[VK_RETURN].sName := 'Enter';
  m_KeyStates[VK_SHIFT].sName := 'Shift';
  m_KeyStates[VK_CONTROL].sName := 'Ctrl';
  m_KeyStates[VK_MENU].sName := 'Alt';
  m_KeyStates[VK_PAUSE].sName := 'Pause';
  m_KeyStates[VK_CAPITAL].sName := 'CapsLock';
  m_KeyStates[VK_ESCAPE].sName := 'Esc';
  m_KeyStates[VK_SPACE].sName := 'Space';
  m_KeyStates[VK_PRIOR].sName := 'PageUp';
  m_KeyStates[VK_NEXT].sName := 'PageDown';
  m_KeyStates[VK_END].sName := 'End';
  m_KeyStates[VK_HOME].sName := 'Home';
  m_KeyStates[VK_LEFT].sName := 'Left';
  m_KeyStates[VK_UP].sName := 'Up';
  m_KeyStates[VK_RIGHT].sName := 'Right';
  m_KeyStates[VK_DOWN].sName := 'Down';
  m_KeyStates[VK_SELECT].sName := 'Select';
  m_KeyStates[VK_PRINT].sName := 'Print';
  m_KeyStates[VK_EXECUTE].sName := 'Execute';
  m_KeyStates[VK_SNAPSHOT].sName := 'PrtScr';
  m_KeyStates[VK_INSERT].sName := 'Ins';
  m_KeyStates[VK_DELETE].sName := 'Del';
  m_KeyStates[VK_HELP].sName := 'Help';
  //
  m_KeyStates[VK_LWIN].sName := 'LWin';
  m_KeyStates[VK_RWIN].sName := 'RWin';
  m_KeyStates[VK_APPS].sName := 'Apps';

  m_KeyStates[VK_NUMPAD0].sName := 'np0';
  m_KeyStates[VK_NUMPAD1].sName := 'np1';
  m_KeyStates[VK_NUMPAD2].sName := 'np2';
  m_KeyStates[VK_NUMPAD3].sName := 'np3';
  m_KeyStates[VK_NUMPAD4].sName := 'np4';
  m_KeyStates[VK_NUMPAD5].sName := 'np5';
  m_KeyStates[VK_NUMPAD6].sName := 'np6';
  m_KeyStates[VK_NUMPAD7].sName := 'np7';
  m_KeyStates[VK_NUMPAD8].sName := 'np8';
  m_KeyStates[VK_NUMPAD9].sName := 'np9';
  //
  m_KeyStates[VK_MULTIPLY].sName := 'Multiply';
  m_KeyStates[VK_ADD].sName := 'Add';
  m_KeyStates[VK_SEPARATOR].sName := 'Separator';
  m_KeyStates[VK_SUBTRACT].sName := 'Subtract';
  m_KeyStates[VK_DECIMAL].sName := 'Decimal';
  m_KeyStates[VK_DIVIDE].sName := 'Divide';

  m_KeyStates[VK_F1].sName := 'F1';
  m_KeyStates[VK_F2].sName := 'F2';
  m_KeyStates[VK_F3].sName := 'F3';
  m_KeyStates[VK_F4].sName := 'F4';
  m_KeyStates[VK_F5].sName := 'F5';
  m_KeyStates[VK_F6].sName := 'F6';
  m_KeyStates[VK_F7].sName := 'F7';
  m_KeyStates[VK_F8].sName := 'F8';
  m_KeyStates[VK_F9].sName := 'F9';
  m_KeyStates[VK_F10].sName := 'F10';
  m_KeyStates[VK_F11].sName := 'F11';
  m_KeyStates[VK_F12].sName := 'F12';
  m_KeyStates[VK_F13].sName := 'F13';
  m_KeyStates[VK_F14].sName := 'F14';
  m_KeyStates[VK_F15].sName := 'F15';
  m_KeyStates[VK_F16].sName := 'F16';
  m_KeyStates[VK_F17].sName := 'F17';
  m_KeyStates[VK_F18].sName := 'F18';
  m_KeyStates[VK_F19].sName := 'F19';
  m_KeyStates[VK_F20].sName := 'F20';
  m_KeyStates[VK_F21].sName := 'F21';
  m_KeyStates[VK_F22].sName := 'F22';
  m_KeyStates[VK_F23].sName := 'F23';
  m_KeyStates[VK_F24].sName := 'F24';
  //
  m_KeyStates[192].sName := '`';
  m_KeyStates[189].sName := '-';
  m_KeyStates[187].sName := '=';
  m_KeyStates[219].sName := '[';
  m_KeyStates[221].sName := ']';
  m_KeyStates[220].sName := '\';
  m_KeyStates[186].sName := ';';
  m_KeyStates[222].sName := '''';
  m_KeyStates[188].sName := ',';
  m_KeyStates[190].sName := '.';
  m_KeyStates[191].sName := '/';
  //m_KeyStates[].sName := '';
  //
  m_KeyStates[VK_NUMLOCK].sName := 'NumLock';
  m_KeyStates[VK_SCROLL].sName := 'ScrollLock';
  m_KeyStates[VK_LSHIFT].sName := 'LShift';
  m_KeyStates[VK_RSHIFT].sName := 'RShift';
  m_KeyStates[VK_LCONTROL].sName := 'LCtrl';
  m_KeyStates[VK_RCONTROL].sName := 'RCtrl';
  m_KeyStates[VK_LMENU].sName := 'LAlt';
  m_KeyStates[VK_RMENU].sName := 'RAlt';
  m_KeyStates[VK_PLAY].sName := 'Play';
  m_KeyStates[VK_ZOOM].sName := 'Zoom';

  //////////
  m_KeyStates[95].sName := 'Sleep';
  m_KeyStates[166].sName := 'Back';
  m_KeyStates[167].sName := 'Forward';
  m_KeyStates[168].sName := 'Refresh';
  m_KeyStates[169].sName := 'Stop';
  m_KeyStates[170].sName := 'Serach';
  //
  m_KeyStates[171].sName := 'Fav';
  m_KeyStates[172].sName := 'HomePage';
  m_KeyStates[173].sName := 'Mute';
  m_KeyStates[174].sName := 'VolUp';
  m_KeyStates[175].sName := 'VolDown';
  m_KeyStates[176].sName := 'NextTrack';
  m_KeyStates[177].sName := 'PrevTrack';
  m_KeyStates[178].sName := 'MediaStop';
  m_KeyStates[179].sName := 'MediaPause';
  m_KeyStates[180].sName := 'Mail';
  m_KeyStates[181].sName := 'MediaSelect';
  m_KeyStates[182].sName := 'App1';
  m_KeyStates[183].sName := 'App2';  //}


end;

procedure InitKeyStates;
var
	i: integer;
begin
  //
  g_CurrLayNum:=1;
  //FillChar(m_KeyStates, SizeOf(RKeyState)*c_MaxKeys, 0);

  for i := 0 to c_MaxKeys do
	begin
		//
		m_KeyStates[i].vkCode := i;
	end;

	m_KeyStates[VK_SHIFT].bSkip := true;
	m_KeyStates[VK_CONTROL].bSkip := true;
	m_KeyStates[VK_MENU].bSkip := true; // Alt

	m_KeyStates[VK_LSHIFT].bSkip := true;
	m_KeyStates[VK_LCONTROL].bSkip := true;
	m_KeyStates[VK_LMENU].bSkip := true;

	m_KeyStates[VK_RSHIFT].bSkip := true;
	m_KeyStates[VK_RSHIFT].nFlags := KEYEVENTF_EXTENDEDKEY;
	m_KeyStates[VK_RCONTROL].bSkip := true;
	m_KeyStates[VK_RCONTROL].nFlags := KEYEVENTF_EXTENDEDKEY;
	m_KeyStates[VK_RMENU].bSkip := true;
	m_KeyStates[VK_RMENU].nFlags := KEYEVENTF_EXTENDEDKEY;

	m_KeyStates[VK_LEFT].nFlags := KEYEVENTF_EXTENDEDKEY;
	m_KeyStates[VK_RIGHT].nFlags := KEYEVENTF_EXTENDEDKEY;
	m_KeyStates[VK_UP].nFlags := KEYEVENTF_EXTENDEDKEY;
	m_KeyStates[VK_DOWN].nFlags := KEYEVENTF_EXTENDEDKEY;
	m_KeyStates[VK_HOME].nFlags := KEYEVENTF_EXTENDEDKEY;
	m_KeyStates[VK_END].nFlags := KEYEVENTF_EXTENDEDKEY;

  m_KeyStates[VK_PRIOR].nFlags := KEYEVENTF_EXTENDEDKEY; // Page Up
  m_KeyStates[VK_NEXT].nFlags := KEYEVENTF_EXTENDEDKEY; // Page Down

  m_KeyStates[VK_Insert].nFlags := KEYEVENTF_EXTENDEDKEY;
  m_KeyStates[VK_Delete].nFlags := KEYEVENTF_EXTENDEDKEY;

  InitKeyNames;
end;

end.

