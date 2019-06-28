unit uKeyboard;

interface

uses
	Windows, Messages, SysUtils, uLayots, uKeyboardHelper, sndkey32;

const
	LLKHF_ALTDOWN = KF_ALTDOWN shr 8;
	LLKHF_EXTENDED = KF_EXTENDED shr 8;
	LLKHF_INJECTED = $10;
	WH_KEYBOARD_LL = 13;
	cpNone = 0;
	cpSkip = -1;
	cpDeny = -2;
	cpFix = -2;
	c_MaxInputs = 20;
	c_MaxKeys = 255;


function LowLevelKeyboardProc(nCode: integer; wParam: wParam; lParam: lParam)
	: LRESULT; stdcall;

procedure Init;

procedure ResetKeyStates;
procedure RestoreKeys;

var
	hhkLowLevelKybd: HHOOK;
	g_pCurrLayout: TLayout;
	g_pDefLayout: TLayout;
  g_CurrLayNum:cardinal;
  g_nDenyKeyRestore:cardinal;

	m_KeyStates: array [0 .. c_MaxKeys] of RKeyState;
	// m_nIgnore:integer;

	m_aInputs1: array [0 .. c_MaxInputs] of TInput; // we cannot send more then c_MaxInputs inputs by one time
	m_aInputs2: array [0 .. c_MaxInputs] of TInput;
	m_Input1: TInput;

implementation

uses Unit1;


procedure ExecKeyInfo_DownRep(ki: TKeyInfo);
begin
	//
	if ki.nNewKeyCode > 0 then
	begin
		//
		g_pCurrLayout.bUsed := true;

    if ki.nSysKeys=0 then
    begin
      KeyDown(ki.nNewKeyCode);
    end else
    begin
      KeyDownEx(ki.nNewKeyCode, ki.nSysKeys);
    end;
    ki.bExecuted:=true;
	end else
  if ki.sMacros<>'' then
  begin
    g_pCurrLayout.bUsed := true;
    SendKeys(PChar(ki.sMacros), false);
    ki.bExecuted:=true;
  end;
end;

procedure LockSysKeys(nSysKeys:integer);
begin
  //
  if nSysKeys = 0 then
    exit;

  if (nSysKeys and keyShift) <> 0 then
  begin
    if m_KeyStates[VK_LSHIFT].nVirtState = ksNone then
    begin
      // DebugOut('Down VK_LSHIFT');
      KeyDown(VK_LSHIFT);
    end;

    Inc(m_KeyStates[VK_LSHIFT].nLock);
  end;

  if (nSysKeys and keyContorl) <> 0 then
  begin
    if m_KeyStates[VK_LCONTROL].nVirtState = ksNone then
      KeyDown(VK_LCONTROL);

    Inc(m_KeyStates[VK_LCONTROL].nLock);
  end;

  if (nSysKeys and keyAlt) <> 0 then
  begin
    if m_KeyStates[VK_LMenu].nVirtState = ksNone then
      KeyDown(VK_LMenu);

    Inc(m_KeyStates[VK_LMenu].nLock);
  end;
  
end;

procedure ExecKeyInfo_DownFirst(ki: TKeyInfo; pks: PKeyState);
begin
	//
  assert(pks.bSkipUp = false);

  if pks.bToggled = true then
  begin
    pks.bToggled:=false;
    form1.RemoveToggledKey(pks.vkCode);
    exit;
  end;

  ki.bExecuted := false;

  if ki.bToggle then
  begin
	  pks.bToggled:=true;
    pks.bSkipUp:=true;
    form1.AddToggledKey(pks.vkCode);
  end;

  pks.nSysKeys := 0;

	if ki.pNewLayout <> nil then
	begin
		//
		if ki.pNewLayout <> g_pCurrLayout then
		begin
			ki.pNewLayout.pPrev := g_pCurrLayout;
			Form1.SetCurrentLayout(ki.pNewLayout);
			g_pCurrLayout.bUsed := false;
      g_pCurrLayout.bToggled := pks.bToggled;
      g_pCurrLayout.bCloseOnKeyUp := ki.bCloseLayOnKeyUp;
      g_pCurrLayout.nSwitchMode := ki.nSwitchMode;

      if g_pCurrLayout.bCloseOnKeyUp then
      begin
        pks.bSkipUp:=true;
        g_pCurrLayout.nSysKeys := ki.nSysKeys;
        LockSysKeys(ki.nSysKeys);

        assert(g_pCurrLayout.bToggled = false);
      end;
      if g_pCurrLayout.bToggled then
      begin
        assert(g_pCurrLayout.bCloseOnKeyUp = false);
      end;

			g_pCurrLayout.ClearKeyDown;
		end;

		Assert(g_pCurrLayout <> g_pDefLayout);

		if ki.bToggle or ki.bCloseLayOnKeyUp then
		begin
    	g_pCurrLayout.bUsed := true;
		end;//}

		Inc(g_pCurrLayout.nActiveRefs);

    if ki.nSysKeys<>0 then
    begin
      LockSysKeys(ki.nSysKeys);
      pks.nSysKeys := ki.nSysKeys;
      //g_pCurrLayout.nSysKeys := ki.nSysKeys;
    end;
	end;


	if g_pCurrLayout.bToggled then
	begin
    ExecKeyInfo_DownRep(ki);
	end;
end;

procedure RestoreKeys;
var
	i: integer;
	pkdi: PKeyDownInfo;
  nTime:Cardinal;
begin
	//
	Assert(g_pCurrLayout.bUsed = false);
  if (g_nDenyKeyRestore > 0) and (g_pCurrLayout.nActivatedTime > 0) and (g_pCurrLayout.nSwitchMode<>cSwitchKeyUpDelay) then
  begin
    //
    nTime := GetTickCount;
    nTime := nTime - g_pCurrLayout.nActivatedTime;
    if nTime > g_nDenyKeyRestore then
    	exit;
  end;

	// DebugOut('RestoreKeys');
	for i := 0 to g_pCurrLayout.PressedKeysC - 1 do
	begin
		pkdi := @g_pCurrLayout.PressedKeys[i];
		ExecKey(pkdi.vkCode, pkdi.nSysKeys);
		// DebugOut('RestoreKey '+inttostr(pkdi.vkCode)+' '+inttostr(pkdi.nSysKeys));
	end;

end;

procedure RestoreSysKeys(nSysKeys:integer);
begin
  //
  //DebugOut('RestoreSysKeys '+inttostr(nSysKeys));

  if nSysKeys = 0 then
    exit;

  if (nSysKeys and keyShift) <> 0 then
  begin
    // if m_KeyStates[VK_LSHIFT].nRealState = ksNone then
    //DebugOut('Release shift '+inttostr(m_KeyStates[VK_LSHIFT].nLock)+' realstate: '+inttostr(integer(m_KeyStates[VK_LSHIFT].nRealState)));
    Assert(m_KeyStates[VK_LSHIFT].nVirtState > ksNone);
    Assert(m_KeyStates[VK_LSHIFT].nLock > 0);

    Dec(m_KeyStates[VK_LSHIFT].nLock);
    if (m_KeyStates[VK_LSHIFT].nRealState = ksNone) and (m_KeyStates[VK_LSHIFT].nLock=0) then // and (m_KeyStates[VK_LSHIFT].nVirtState > ksNone) then
      KeyUp(VK_LSHIFT);
  end;
  if (nSysKeys and keyContorl) <> 0 then
  begin
    //DebugOut('Release ctrl '+inttostr(m_KeyStates[VK_LCONTROL].nLock)+' realstate: '+inttostr(integer(m_KeyStates[VK_LCONTROL].nRealState)));
    Assert(m_KeyStates[VK_LCONTROL].nVirtState > ksNone);
    Assert(m_KeyStates[VK_LCONTROL].nLock > 0);

    Dec(m_KeyStates[VK_LCONTROL].nLock);
    if (m_KeyStates[VK_LCONTROL].nRealState = ksNone) and (m_KeyStates[VK_LCONTROL].nLock=0) then
      KeyUp(VK_LCONTROL);
  end;
  if (nSysKeys and keyAlt) <> 0 then
  begin
    //DebugOut('Release ctrl '+inttostr(m_KeyStates[VK_LCONTROL].nLock)+' realstate: '+inttostr(integer(m_KeyStates[VK_LCONTROL].nRealState)));
    Assert(m_KeyStates[VK_LMENU].nVirtState > ksNone);
    Assert(m_KeyStates[VK_LMENU].nLock > 0);

    Dec(m_KeyStates[VK_LMENU].nLock);
    if (m_KeyStates[VK_LMENU].nRealState = ksNone) and (m_KeyStates[VK_LMENU].nLock=0) then
      KeyUp(VK_LMENU);
  end;
end;



procedure RestorePrevLayout;
begin
  //RestoreSysKeys(pks.nSysKeys);
  //pks.nSysKeys := 0;
  RestoreSysKeys(g_pCurrLayout.nSysKeys);
  // OutputDebugString(PChar('Release lay ' + inttostr(integer(m_pCurrLayout.bUsed))));
  Dec(g_pCurrLayout.nActiveRefs);

  if (g_pCurrLayout.nActiveRefs = 0) then//and (g_pCurrLayout.bToggled=false) then
  begin

    if g_pCurrLayout.nSwitchMode = cSwitchKeyUpDelay then
    begin
      //
      Form1.DelayedRestoreLayout;
      exit;
    end;

    Form1.SetCurrentLayout(g_pCurrLayout.pPrev);

  end;
end;

procedure ExecKeyInfo_Up(ki: TKeyInfo; pks: PKeyState);
var
	bLayoutSwitch:boolean;
begin
	//

  bLayoutSwitch := ki.pNewLayout = g_pCurrLayout;

	if bLayoutSwitch then
	begin
		//
    RestoreSysKeys(pks.nSysKeys);
    pks.nSysKeys := 0;
    RestorePrevLayout;
    exit;
	end else
  if ki.nNewKeyCode > 0 then
	begin
		//
		g_pCurrLayout.bUsed := true;

    begin
      if m_KeyStates[ki.nNewKeyCode].nVirtState > ksNone then
      begin
        KeyUp(ki.nNewKeyCode);
      end
      else
      begin
        KeyPressEx(ki.nNewKeyCode, ki.nSysKeys);
      end;
    end;
	end else
  if ki.sMacros<>'' then
  begin
    //
    g_pCurrLayout.bUsed := true;
    if ki.bExecuted=false then
    begin
	    SendKeys(PChar(ki.sMacros), false);
    end;
  end;
end;

function DenyByLayout(pks: PKeyState): boolean;
begin
	//
	result := (g_pCurrLayout.bToggled = false) and (pks.bSkip = false);
end;

function OnKeyDown(pks: PKeyState): boolean;
var
	ki: TKeyInfo;
begin
	result := true;
	Assert(pks.nKeyAction <> kaSkip);
	// DebugOut('OnKeyDown '+inttostr(pks.vkCode));

	ki := g_pCurrLayout.keys[pks.vkCode];
	if ki = nil then
	begin

		if DenyByLayout(pks) then
		begin
			// DebugOut('AddKeyDown1 '+inttostr(pks.vkCode)+' '+inttostr(GetSysKeysReal));
			g_pCurrLayout.AddKeyDown(pks.vkCode, GetSysKeysReal);
			exit;
		end;

		pks.nKeyAction := kaSkip;
		// DebugOut('OnKeyDown Void');
		result := false;
		exit;
	end;

	ExecKeyInfo_DownFirst(ki, pks);
	// DebugOut('AddKeyDown0 '+inttostr(pks.vkCode)+' '+inttostr(GetSysKeysReal));
	if g_pCurrLayout.bUsed = false then
		g_pCurrLayout.AddKeyDown(pks.vkCode, GetSysKeysReal);

end;

function OnKeyRepeat(pks: PKeyState): boolean;
var
	ki: TKeyInfo;
begin
	result := true;
	Assert(pks.nKeyAction <> kaSkip);
	// DebugOut('Key Repeat');

  if pks.LayNum <> g_CurrLayNum then // Layout was changed
	begin
		//
    if pks.nSysKeys <>0 then
    begin
      RestoreSysKeys(pks.nSysKeys);
      pks.nSysKeys := 0;
    end;

		pks.nKeyAction := kaSkip; // Skip this key in future
    pks.LayNum := 0;
		result := false;
		exit;
	end;

  ki := g_pCurrLayout.keys[pks.vkCode];

	if (ki = nil) then
	begin
		// DebugOut('Key Repeat - ki');
		Assert(DenyByLayout(pks), 'This case should be filtered in OnKeyDown');
		g_pCurrLayout.AddKeyDown(pks.vkCode, GetSysKeysReal);
		exit;
	end;


	// DebugOut('Key Repeat - ExecKeyInfo_DownRep');

	ExecKeyInfo_DownRep(ki);
end;

function OnKeyUp(pks: PKeyState): boolean;
var
	ki: TKeyInfo;
begin
	result := true;

  if pks.bSkipUp = true then
    result := true;

	Assert(pks.nKeyAction <> kaSkip);

  if pks.bSkipUp = true then
  begin
    pks.bSkipUp := false;
    exit;
  end;

  if pks.LayNum = 0 then
	begin
		result := false;
		exit;
	end;

  if (pks.LayNum <> g_CurrLayNum) then
	begin
		exit;
	end;

  ki := g_pCurrLayout.keys[pks.vkCode];

  if ki <> nil then
  	ExecKeyInfo_Up(ki, pks);

  if g_pCurrLayout.bCloseOnKeyUp then
  begin
    assert(g_pCurrLayout.nSwitchMode = cSwitchNextKey);
    RestorePrevLayout;
  end;

end;

function GetEKeyState(nCurState: EKeyState; wParam: wParam): EKeyState;
begin
	result := ksNone;
	if (wParam = WM_KEYDOWN) or (wParam = WM_SYSKEYDOWN) then
	begin
    //DebugOut('Down');
		if nCurState = ksNone then
			result := ksDown
		else
			result := ksRepeat;
	end
	else if (wParam = WM_KEYUP) or (wParam = WM_SYSKEYUP) then
	begin
    //DebugOut('Up');
		result := ksNone;
	end;
end;

function LowLevelKeyboardProc(nCode: integer; wParam: wParam; lParam: lParam)
	: LRESULT; stdcall;
label l_Skip;
var
	p: PKBDLLHOOKSTRUCT;
	// vkCode: DWORD;
	pks: PKeyState;
	bHandled: boolean;
	bMyMsg: boolean;
  bInjected:boolean;
begin
	pks := nil;

	if nCode <> HC_ACTION then
		goto l_Skip;

	p := PKBDLLHOOKSTRUCT(lParam);

	if p^.vkCode > c_MaxKeys then
		goto l_Skip;

	result := 1;
	pks := @(m_KeyStates[p^.vkCode]);

  bInjected:= (p^.flags and LLKHF_INJECTED) <> 0;
	bMyMsg := (p^.scanCode = 0) and (bInjected);

  {DebugOut(' ');
  DebugOut('vkCode '+inttostr(p^.vkCode));
  DebugOut('scanCode '+inttostr(p^.scanCode) + ' flags: ' + inttostr(p^.flags) + ' injected: '+inttostr(p^.flags and LLKHF_INJECTED));//}

	if bInjected then
	begin
		//DebugOut('MyMsg');
    if bMyMsg then
      p^.scanCode := MapVirtualKey(pks.vkCode, 0); // MAPVK_VK_TO_VSC = 0
	end
	else
	begin
		pks.nRealState := GetEKeyState(pks.nRealState, wParam);
	end;

	// DebugOut('Key msg '+inttostr(pks.vkCode) +' '+inttostr(p^.scanCode));

	if (pks.nLock > 0) then
	begin
		// DebugOut('Key msg Lock');
		exit;
	end;

	// DebugOut('Key msg '+inttostr(pks.vkCode)+' ' + inttostr(p^.scanCode));
	if bMyMsg then // our message
	begin
		// DebugOut('Key msg Skip');
		goto l_Skip;
	end;

	{ if pks.nRealState = ksNone then
		//DebugOut('Key msg State: None')
		else if pks.nRealState = ksDown then
		DebugOut('Key msg State: ksDown')
		else
		DebugOut('Key msg State: ksRep'); }

	bHandled := false;

	if (wParam = WM_KEYDOWN) or (wParam = WM_SYSKEYDOWN) then
	begin
    //DebugOut('WM_KEYDOWN');
		if pks.nKeyAction = kaSkip then
			goto l_Skip;

		if pks.nRealState = ksDown then
		begin
			bHandled := OnKeyDown(pks);
      pks.LayNum := g_CurrLayNum;
		end
		else
		begin
			bHandled := OnKeyRepeat(pks);
		end;

	end
	else if (wParam = WM_KEYUP) or (wParam = WM_SYSKEYUP) then
	begin
		//
    //DebugOut('WM_KEYUP');
		if pks.nKeyAction = kaSkip then
			bHandled := false
		else
			bHandled := OnKeyUp(pks);

    pks.LayNum := 0;
		pks.nKeyAction := kaNone;

    if pks.nSysKeys<>0 then
    begin
      RestoreSysKeys(pks.nSysKeys);
      pks.nSysKeys:=0;
    end;
	end;

	if bHandled then
	begin
		// DebugOut('Key msg Handled');
		exit;
	end;

l_Skip :
	if pks <> nil then
	begin
		pks.nVirtState := GetEKeyState(pks.nVirtState, wParam);
	end;

	result := CallNextHookEx(0, nCode, wParam, lParam);
end;

procedure Init;
var
	i: integer;
begin
	//
	m_Input1.Itype := INPUT_KEYBOARD;

	for i := 0 to c_MaxInputs do
	begin
		m_aInputs1[i].Itype := INPUT_KEYBOARD;
		m_aInputs2[i].Itype := INPUT_KEYBOARD;
	end;

	InitKeyStates;
end;


procedure ResetKeyStates;
var
	i: integer;
  pks:PKeyState;
begin
  //
  for i := 0 to c_MaxKeys do
	begin
    pks := @m_KeyStates[i];

    pks.LayNum := 0;
    pks.nKeyAction := kaNone;
    pks.nLock := 0;
    pks.nRealState := ksNone;
    pks.nVirtState := ksNone;
    pks.bToggled := false;
    pks.bSkipUp := false;

    pks.nSysKeys := 0;
	end;
end;

end.
