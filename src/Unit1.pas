unit Unit1;

interface

uses
	Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
	Dialogs, StdCtrls, uKeyboard, uLayots, uAIDB, ComCtrls, ExtCtrls, ShellApi;

const
	LLKHF_ALTDOWN = KF_ALTDOWN shr 8;
  WM_NOTIFYICON  = WM_USER+333;

type
	TForm1 = class(TForm)
		btnStart: TButton;
		btnStop: TButton;
		Label3: TLabel;
		btnSettings: TButton;
		lblToggledKeys: TLabel;
		Panel1: TPanel;
		lvKeys: TListView;
		btnRename: TButton;
		btnEdit: TButton;
		btnDeleteLayout: TButton;
		btnDelete: TButton;
		btnAdd: TButton;
		btnNewLayout: TButton;
		cobLayout: TComboBox;
		Label2: TLabel;
    cbHideToTray: TCheckBox;
    btnAdvanced: TButton;
    TimerRestoreLay: TTimer;
    Bevel1: TBevel;
    lbl1: TLabel;
    cobHKL: TComboBox;
    btnHKLNew: TButton;
    btnHKLDelete: TButton;
    TimerHKL: TTimer;
    Label1: TLabel;
		procedure btnStartClick(Sender: TObject);
		procedure btnStopClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure btnNewLayoutClick(Sender: TObject);
		procedure btnAddClick(Sender: TObject);
		procedure cobLayoutChange(Sender: TObject);
		procedure btnEditClick(Sender: TObject);
		procedure btnDeleteClick(Sender: TObject);
		procedure btnDeleteLayoutClick(Sender: TObject);
		procedure btnRenameClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure cbHideToTrayClick(Sender: TObject);
    procedure btnAdvancedClick(Sender: TObject);
    procedure TimerRestoreLayTimer(Sender: TObject);
    procedure btnHKLNewClick(Sender: TObject);
    procedure cobHKLChange(Sender: TObject);
    procedure btnHKLDeleteClick(Sender: TObject);
    procedure TimerHKLTimer(Sender: TObject);
	private
		{ Private declarations }
    tnid: TNotifyIconData;
    HMainIcon: HICON;
    //

		procedure GetMinMaxInfo(var Msg: TWMGETMINMAXINFO);	message WM_GETMINMAXINFO;
    procedure CMClickIcon(var msg: TMessage); message WM_NOTIFYICON;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;

		procedure DisplayLayouts;
    procedure DisplayHKL;
		procedure DisplayLayout(id: integer); // (db:TAIDBSection);
		procedure InitLayouts;
		procedure LoadLayouts;
		procedure ReloadLayouts;
		procedure ResetKeys;
		procedure LoadLayout(db: TAIDBSection);
		procedure UpdateTogLabel;
    procedure HideSettings;
    procedure InitTray(bVal:boolean);
    procedure AddHKL(id:string);
    function HasHKL(id:string):boolean;
    procedure LoadHKL(id:string);
	public
		{ Public declarations }
		Layouts: TLayouts;
		m_saToggled: TStringList;
		m_pActiveLayout: TAIDBSection;
    m_bSettings:boolean;
    m_LastHKL:cardinal;
    m_LockHKLUpdate:integer;

		procedure ShowNewKeyDlg(bEdit: boolean);
		procedure SetCurrentLayout(Lay: TLayout);
    procedure DelayedRestoreLayout;
		function GetModifiersText(nSysKey: integer; nSwitchMode: integer): string;
		procedure AddToggledKey(id: integer);
		procedure RemoveToggledKey(id: integer);
    procedure CheckTraySetting;

    procedure SaveFormSettings;
		procedure LoadFormSettings;

    procedure LoadAdvSettings;
	end;

var
	Form1: TForm1;
	aidb: TAIDBSection;
	m_pLayouts: TAIDBSection;
  m_pHKL: TAIDBSection;

implementation

{$R *.dfm}

uses
	uNewKeyDlg, uAdvSettingsDlg, uHKL;

//


function GetLayoutShortNameI(id:cardinal): String;
var
  LayoutName: array [0 .. KL_NAMELENGTH + 1] of Char;
  LangName: array [0 .. 1024] of Char;
begin
  Result := '??';
  if id > 0 then
  begin
    if GetLocaleInfo(LoWord(id),
      LOCALE_SABBREVLANGNAME,
      @LangName, SizeOf(LangName) - 1) <> 0 then
        Result := StrPas(LangName);
  end;

  //Result := UpperCase(Copy(Result, 1, 2));
  Result := UpperCase(Result);
end;


procedure TForm1.WMSysCommand;
begin
  if (Msg.CmdType = SC_MINIMIZE) then
  begin
    if cbHideToTray.Checked then
    begin
      Hide;
      exit;
    end;
  end else
  if (Msg.CmdType = SC_MAXIMIZE) then
  begin
    m_bSettings:=true;
    BorderStyle := bsSizeable;
  end;

  inherited;
end;

procedure TForm1.InitTray(bVal:boolean);
begin
  //
  if bVal=false then
  begin
    //
    Shell_NotifyIcon(NIM_DELETE, @tnid);
    exit;
  end;

  Shell_NotifyIcon(NIM_DELETE, @tnid);

  Shell_NotifyIcon(NIM_ADD, @tnid);
end;


procedure TForm1.CMClickIcon(var msg: TMessage);
begin
  case msg.lparam of
    //WM_LBUTTONDBLCLK :
    WM_LBUTTONDOWN :
    begin
    	Show;
      {BringToFront;
      SetForegroundWindow(self.Handle);
      FormStyle:= fsStayOnTop;
      //left:=10;
      //top:=10;
      ShowWindow(Application.Handle, SW_SHOW) ;
      ShowWindow(Application.Handle, SW_RESTORE) ;}

    end;
  end;
end;

procedure TForm1.GetMinMaxInfo(var Msg: TWMGETMINMAXINFO);
begin
	with Msg.MinMaxInfo^ do
	begin
  	if m_bSettings then
    begin
      ptMinTrackSize.X := 500; // min. Width
      ptMinTrackSize.Y := 300; // min. Height
    end else
    begin
      //
      //ClientHeight := 300;
      //ClientWidth := 500;

    end;
	end;
end;

procedure TForm1.UpdateTogLabel;
var
	i: integer;
	s: string;
begin
	//
	s := '';
	if m_saToggled.Count = 0 then
	begin
		lblToggledKeys.Caption := 'None';
		exit;
	end;

	for i := 0 to m_saToggled.Count - 1 do
	begin
		//
		if i <> 0 then
			s := s + ', ';
		s := s + m_saToggled[i] + ' (' + m_KeyStates[strtoint(m_saToggled[i])]
			.sName + ')';
	end;
	lblToggledKeys.Caption := s;
end;

procedure TForm1.SetCurrentLayout(Lay: TLayout);
begin

  if (g_pCurrLayout<>nil) and (g_pCurrLayout<>g_pDefLayout) and (g_pCurrLayout.bUsed = false) then
  begin
    g_pCurrLayout.nActiveRefs:=0;
    RestoreKeys;
  end;

  TimerRestoreLay.Enabled:=false;
	g_pCurrLayout := Lay;
  g_pCurrLayout.nSysKeys := 0;
  g_pCurrLayout.bCloseOnKeyUp:=false;
	// lblLayout.Caption :=g_pCurrLayout.sName;
	//Caption := 'Enhanced Keyboard: ' + g_pCurrLayout.sName;
  Caption := 'EnKey: ' + g_pCurrLayout.sName;
	inc(g_CurrLayNum);
	if g_CurrLayNum = 0 then
		g_CurrLayNum := 1;
end;


procedure TForm1.AddToggledKey(id: integer);
begin
	//
	m_saToggled.AddObject(inttostr(id), Pointer(id));
	UpdateTogLabel;
end;

procedure TForm1.RemoveToggledKey(id: integer);
var
	i: integer;
begin
	//
	i := m_saToggled.IndexOfObject(Pointer(id));
	Assert(i >= 0);
	if i < 0 then
		exit;
	m_saToggled.Delete(i);

	UpdateTogLabel;
end;

procedure TForm1.LoadLayout(db: TAIDBSection);
label l_Cont;
var
	lt: TLayout;
	i: integer;
	s: string;
	kdb: TAIDBSection;
	nKey1, nKey2, nSys: integer;
	bVal: boolean;
  nMode:integer;
begin
	//
	lt := Layouts.FindLayout2(db.name);

	i := 0;
	while i < db.Count do
	begin
		kdb := db.SubItems[i];

		nKey1 := strtoint(kdb.Name);
		nKey2 := kdb.GetIntValue('NewKeyCode', -1);
		nSys := kdb.GetIntValue('SysKeys', 0);

		bVal := true;
		if nKey2 > -1 then
		begin
			bVal := Layouts.AddKeyReplace(lt, nKey1, nKey2, nSys);
			goto l_Cont;
		end;

		s := kdb.GetValue('Layout', '');
		if s <> '' then
		begin
			//bToggle := kdb.GetBoolValue('Toggle', false);
      nMode := kdb.GetIntValue('SwitchMode', 0);
			bVal := Layouts.AddKeyLayout(lt, nKey1, nSys, s, nMode);
			goto l_Cont;
		end;

		s := kdb.GetValue('Text', '');
		if s <> '' then
		begin
			//
			bVal := Layouts.AddKeyMacros(lt, nKey1, s);
			goto l_Cont;
		end;

	l_Cont :
		if bVal = false then
		begin
			db.DeleteSubItemN(i);
		end
		else
		begin
			inc(i);
		end;
	end; // while

end;

procedure TForm1.ResetKeys;
begin
	//
	ResetKeyStates;
	SetCurrentLayout(Layouts.aLayouts[0]);
  Layouts.ResetStates;
	m_saToggled.Clear;
	UpdateTogLabel;
end;

procedure TForm1.ReloadLayouts;
begin
	//
	ResetKeys;
	Layouts.ClearLayouts;
	LoadLayouts;
end;

procedure TForm1.LoadLayouts;
var
	i: integer;
begin
	//
	for i := 0 to m_pLayouts.Count - 1 do
	begin
		Layouts.AddLayout(m_pLayouts.SubItems[i].name);
	end;

	for i := 0 to m_pLayouts.Count - 1 do
	begin
		LoadLayout(m_pLayouts.SubItems[i]);
	end;

	g_pDefLayout := Layouts.aLayouts[0];
	SetCurrentLayout(g_pDefLayout);
	g_pCurrLayout.nActiveRefs := 1;
	g_pCurrLayout.bToggled := true;

end;

function TForm1.HasHKL(id: string): boolean;
begin

  Result :=  m_pHKL.FindSubItem(id)<>nil;
end;

procedure TForm1.AddHKL(id: string);
var
  sName:string;
  sc:TAIDBSection;
begin
  //

  if m_pHKL.FindSubItem(id)<>nil then exit;

  sc := m_pHKL.AddSubItem(id);
  sc.AddSubItem('Default'); // layout
end;


procedure TForm1.LoadHKL(id: string);
var
  bHasHKL:Boolean;
  i:Integer;
begin

  bHasHKL := m_pHKL.FindSubItem(id)<>nil;

  if (bHasHKL=false) or (m_pHKL.FindSubItemI(id)=0) then
  begin
    m_pLayouts := aidb.FindSubItem('Layouts');
    i := 0;
  end else
  begin
    //
    m_pLayouts := m_pHKL.FindSubItem(id);
    i := cobHKL.Items.IndexOf(id);
  end;

  cobHKL.ItemIndex := i;

  ReloadLayouts;
  DisplayLayouts;
end;


procedure TForm1.InitLayouts;
begin

  m_pHKL := aidb.FindSubItem('HKL');
  if (m_pHKL = nil) then
  begin
    m_pHKL := aidb.AddSubItem('HKL');
    AddHKL('Any');
  end;

	m_pLayouts := aidb.FindSubItem('Layouts');
	if (m_pLayouts = nil) then
	begin
		m_pLayouts := aidb.AddSubItem('Layouts');
		m_pLayouts.AddSubItem('Default');
	end;

	if (m_pLayouts.Count = 0) then
	begin
		m_pLayouts.AddSubItem('Default');
	end;

	LoadLayouts;
end;

procedure TForm1.DisplayHKL;
var
	i: integer;
  s:string;
begin
	cobHKL.Items.Clear;
	for i := 0 to m_pHKL.Count - 1 do
	begin
    s := m_pHKL.SubItems[i].Name;
		cobHKL.Items.Add(s);
	end;

  cobHKL.ItemIndex := 0;

  DisplayLayouts;
end;

procedure TForm1.DisplayLayouts;
var
	i: integer;
begin
	//

	cobLayout.Items.Clear;
	for i := 0 to m_pLayouts.Count - 1 do
	begin
		cobLayout.Items.Add(m_pLayouts.SubItems[i].Name);
	end;

	DisplayLayout(0);

end;

function GetSysKeyText(nSysKey: integer): string;
begin
	//
	result := '';
	if (nSysKey and keyShift) <> 0 then
		result := result + 'S';
	if (nSysKey and keyContorl) <> 0 then
		result := result + 'C';
	if (nSysKey and keyAlt) <> 0 then
		result := result + 'A';
end;

function GetSwitchText(nSwitchMode:integer): string;
begin
	//
	result := '';
	if nSwitchMode = cSwitchToggle then  // toggle
	begin
		result := result + '(T)';
	end else
  if nSwitchMode = cSwitchNextKey then // any key
  begin
    result := result + '(N)';
	end else
  if nSwitchMode = cSwitchKeyUpDelay then
  begin
    result := result + '(D)';
  end;
end;

function TForm1.GetModifiersText(nSysKey: integer; nSwitchMode: integer): string;
var
	s1, s2: string;
begin
	s1 := GetSysKeyText(nSysKey);
	if s1 <> '' then
		result := ' +' + s1
	else
		result := '';

	s2 := GetSwitchText(nSwitchMode);

	if s2 <> '' then
	begin
		if result <> '' then
			result := result + ' ' + s2
		else
			result := ' ' + s2;
	end;
end;

procedure TForm1.DelayedRestoreLayout;
begin
  assert(g_pCurrLayout <> g_pDefLayout);
  TimerRestoreLay.Enabled:=false;
  TimerRestoreLay.Enabled:=true;

end;





procedure TForm1.DisplayLayout(id: integer); // (db:TAIDBSection);
var
	i: integer;
	li: TListItem;
	vkc: integer;
	kdb: TAIDBSection;
	s: string;
	db: TAIDBSection;
	nS: integer;
begin
	//
	if id < 0 then
		exit;
	lvKeys.Clear;
	db := m_pLayouts.SubItems[id];
	m_pActiveLayout := db;
	cobLayout.ItemIndex := id;

	for i := 0 to db.Count - 1 do
	begin
		kdb := db.SubItems[i];
		li := lvKeys.Items.Add;
		li.Data := kdb;
		s := kdb.Name;

		vkc := strtoint(s);
		if m_KeyStates[vkc].sName <> '' then
			s := s + ' (' + m_KeyStates[vkc].sName + ')';

		li.Caption := s;
		s := kdb.GetValue('NewKeyCode', '');
		if s <> '' then
		begin
			vkc := strtoint(s);
			if m_KeyStates[vkc].sName <> '' then
				s := s + ' (' + m_KeyStates[vkc].sName + ')';

			nS := kdb.GetIntValue('SysKeys', 0);
			if nS <> 0 then
				s := s + ' +' + GetSysKeyText(nS);

			li.SubItems.Add(s);
			continue;
		end;
		li.SubItems.Add('');

		s := kdb.GetValue('Layout', '');
		if s <> '' then
		begin
			nS := kdb.GetIntValue('SysKeys', 0);

			s := s + GetModifiersText(nS, kdb.GetIntValue('SwitchMode', 0));

			li.SubItems.Add(s);
			continue;
		end;
		li.SubItems.Add('');

		s := kdb.GetValue('Text', '');
		if s <> '' then
		begin
			li.SubItems.Add(s);
			continue;
		end;
	end;
end;

procedure TForm1.ShowNewKeyDlg(bEdit: boolean);
var
	NewKeyDlg: TNewKeyDlg;
	i: integer;
begin
	NewKeyDlg := TNewKeyDlg.Create(self);
	NewKeyDlg.m_pLayout := m_pActiveLayout;
  NewKeyDlg.m_pLayouts := m_pLayouts;

	if cobLayout.ItemIndex = 0 then
	begin
		for i := 1 to cobLayout.Items.Count - 1 do
			NewKeyDlg.cobLayout2.Items.Add(cobLayout.Items[i]);
	end
	else
	begin
		NewKeyDlg.rbLayout.Enabled := false;
	end;

	if bEdit then
		NewKeyDlg.SetEditMode(lvKeys.Items[lvKeys.ItemIndex].Data);

  Inc(m_LockHKLUpdate);
	NewKeyDlg.ShowModal;
  Dec(m_LockHKLUpdate);

	if (NewKeyDlg.bOK) then
	begin
		ReloadLayouts;
		DisplayLayout(cobLayout.ItemIndex);
	end;

	NewKeyDlg.Free;
end;

procedure TForm1.TimerHKLTimer(Sender: TObject);
var
  hkl:cardinal;
begin
  if m_LockHKLUpdate > 0 then exit;
  if hhkLowLevelKybd = 0 then	exit;

  hkl := GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow()));
  if m_LastHKL = hkl then exit;

  m_LastHKL := hkl;

  Label1.Caption := GetLayoutShortNameI(hkl);
  LoadHkl(GetLayoutShortNameI(hkl));
end;

procedure TForm1.TimerRestoreLayTimer(Sender: TObject);
begin
  Assert(g_pCurrLayout<>g_pDefLayout);
  if (g_pCurrLayout = g_pDefLayout) then
    Exit;

  SetCurrentLayout(g_pCurrLayout.pPrev);

  Assert(g_pCurrLayout = g_pDefLayout);
end;

procedure TForm1.btnAddClick(Sender: TObject);
begin
	ShowNewKeyDlg(false);
end;

procedure TForm1.btnAdvancedClick(Sender: TObject);
var
	AdvSetDlg: TAdvSettingsDlg;
  stg: TAIDBSection;
begin
	stg := aidb.GetSubItem('AdvancedSettings');
	AdvSetDlg:=TAdvSettingsDlg.Create(self);
  AdvSetDlg.m_pAdvSettings := stg;
  AdvSetDlg.ShowModal;
  if AdvSetDlg.bOk then
  	LoadAdvSettings;

  AdvSetDlg.Free;

end;

procedure TForm1.LoadAdvSettings;
var
  stg: TAIDBSection;
begin
  //
  g_nDenyKeyRestore := 0;

  stg := aidb.FindSubItem('AdvancedSettings');
  if stg=nil then
  	exit;

  if stg.GetBoolValue('DenyKeyRestore', false) then
  	g_nDenyKeyRestore := stg.GetIntValue('DenyKeyRestoreTime', 500);

  TimerRestoreLay.Interval := stg.GetIntValue('LayoutRestoreDelay', 50);

end;

procedure TForm1.btnDeleteClick(Sender: TObject);
var
	sName: string;
	res: integer;
begin
	//
	if lvKeys.ItemIndex < 0 then
	begin
		Showmessage('Select key first');
		exit;
	end;

	sName := lvKeys.Items[lvKeys.ItemIndex].Caption;
  Inc(m_LockHKLUpdate);
	res := MessageDlg('Delete this key: ' + sName, mtConfirmation, [mbYes, mbNo],
		0);
  Dec(m_LockHKLUpdate);

	if res <> mrYes then
		exit;

	m_pActiveLayout.DeleteSubItemN(lvKeys.ItemIndex);

	ReloadLayouts;
	DisplayLayout(cobLayout.ItemIndex);

end;

procedure TForm1.btnDeleteLayoutClick(Sender: TObject);
var
	sName: string;
begin
	//
	if cobLayout.ItemIndex < 0 then
	begin
		Showmessage('Select layout first');
		exit;
	end;

	if cobLayout.ItemIndex = 0 then
	begin
		Showmessage('Cannot delete default layout');
		exit;
	end;

	sName := cobLayout.Items[cobLayout.ItemIndex];

  Inc(m_LockHKLUpdate);
	if MessageDlg('Delete this Layout: ' + sName, mtConfirmation, [mbYes, mbNo],
		0) <> mrYes then
  begin
    Dec(m_LockHKLUpdate);
		exit;
  end;
  Dec(m_LockHKLUpdate);

	m_pLayouts.DeleteSubItem(sName);

	ReloadLayouts;
	DisplayLayouts;
end;

procedure TForm1.btnEditClick(Sender: TObject);
begin
	if lvKeys.ItemIndex < 0 then
	begin
		Showmessage('Select key first');
		exit;
	end;

	ShowNewKeyDlg(true);
end;

procedure TForm1.btnHKLDeleteClick(Sender: TObject);
var
	sName: string;
begin
	//
	if cobHKL.ItemIndex < 0 then
	begin
		Showmessage('Select HKL layout first');
		exit;
	end;

	if cobHKL.ItemIndex = 0 then
	begin
		Showmessage('Cannot delete default HKL layout');
		exit;
	end;

	sName := cobHKL.Items[cobHKL.ItemIndex];

  Inc(m_LockHKLUpdate);
	if MessageDlg('Delete this Layout: ' + sName, mtConfirmation, [mbYes, mbNo],
		0) <> mrYes then
  begin
    Dec(m_LockHKLUpdate);
		exit;
  end;
  Dec(m_LockHKLUpdate);

	m_pHKL.DeleteSubItem(sName);

  LoadHKL('');
  DisplayHKL;
end;

procedure TForm1.btnHKLNewClick(Sender: TObject);
var
	dlg: THKLDlg;
  id:string;
begin
	dlg := THKLDlg.Create(self);

  Inc(m_LockHKLUpdate);
	dlg.ShowModal;
  Dec(m_LockHKLUpdate);

	if (dlg.bOK) then
	begin
    id := dlg.sId;
    if id = '' then
    begin
      ShowMessage('Bad HKL name');
    end;

    if (m_pHKL.FindSubItem(id)<>nil) then
    begin
      ShowMessage('Such HKL already exists');
      id := '';
    end;

    if id<>'' then
    begin
      AddHKL(id);
      cobHKL.AddItem(id, nil);
      LoadHKL(id);
    end;
	end;

	dlg.Free;
end;

procedure TForm1.btnNewLayoutClick(Sender: TObject);
var
	s: string;
begin
  Inc(m_LockHKLUpdate);
	s := InputBox('New Layout', 'Enter layout name', '');
  Dec(m_LockHKLUpdate);

	if (s = '') or (cobLayout.Items.IndexOf(s) >= 0) then
		exit;

	m_pLayouts.AddSubItem(s);
	cobLayout.Items.Add(s);
	ReloadLayouts;
	DisplayLayout(cobLayout.Items.Count - 1);

end;

procedure TForm1.btnRenameClick(Sender: TObject);
var
	s, sOld: string;
	db: TAIDBSection;
	i, j: integer;
	id: integer;
begin
	if cobLayout.ItemIndex < 0 then
		exit;

  Inc(m_LockHKLUpdate);
	s := InputBox('Rename Layout', 'Enter layout name', cobLayout.Text);
  Dec(m_LockHKLUpdate);

	if (s = cobLayout.Text) or (s = '') then
		exit;

	sOld := cobLayout.Text;
	id := cobLayout.ItemIndex;
	cobLayout.Items[id] := s;
	cobLayout.ItemIndex := id;

	db := m_pLayouts.SubItems[id];
	db.Name := s;

	for i := 0 to m_pLayouts.Count - 1 do
	begin
		for j := 0 to m_pLayouts[i].Count - 1 do
		begin
			//
			db := m_pLayouts[i].SubItems[j];

			db := db.FindSubItem('Layout');
			if db = nil then
				continue;

			if db.Value <> sOld then
				continue;

			db.Value := s;

		end;
	end;

	ReloadLayouts;
end;



procedure TForm1.HideSettings;
begin
  m_bSettings:=false;

  if WindowState = wsMaximized then
	  WindowState := wsNormal;

  BorderStyle := bsSingle;

  Clientheight:=panel1.top;
  ClientWidth := btnSettings.Left+ btnSettings.Width + btnStart.Left;
end;

procedure TForm1.btnSettingsClick(Sender: TObject);
begin
	if m_bSettings then
  begin
    HideSettings;
  end else
  begin
    //
    m_bSettings:=true;
    BorderStyle := bsSizeable;
    ClientHeight := 300;
    ClientWidth := 525;
  end;
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
	if hhkLowLevelKybd <> 0 then
		exit;

  m_LastHKL:=0;
	hhkLowLevelKybd := SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardProc,
		hInstance, 0);
	btnStop.Enabled := true;
	btnStart.Enabled := false;
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
	if hhkLowLevelKybd = 0 then
		exit;

  m_LastHKL:=0;
	UnhookWindowsHookEx(hhkLowLevelKybd);
	ResetKeys;
	hhkLowLevelKybd := 0;
	btnStop.Enabled := false;
	btnStart.Enabled := true;
  TimerRestoreLay.Enabled:=false;
end;

procedure TForm1.CheckTraySetting;
begin
  //
  if cbHideToTray.Checked then
  begin
  	InitTray(true);
  end else
  begin
  	InitTray(false);
  end;
end;

procedure TForm1.cbHideToTrayClick(Sender: TObject);
begin
	CheckTraySetting;
end;

procedure TForm1.cobHKLChange(Sender: TObject);
begin
//
  if cobHKL.ItemIndex<=0 then
  begin
    LoadHKL('');
    Exit;
  end;

  LoadHKL(cobHKL.Items[cobHKL.ItemIndex]);
end;

procedure TForm1.cobLayoutChange(Sender: TObject);
begin
	DisplayLayout(cobLayout.ItemIndex);
end;

procedure TForm1.LoadFormSettings;
var
	stg: TAIDBSection;
begin
	//
	stg := aidb.FindSubItem('MainFormSettings');
	if (stg = nil) then
		exit;

	Top := stg.GetIntValue('Top', Top);
	Left := stg.GetIntValue('Left', Left);
  cbHideToTray.Checked := stg.GetBoolValue('HideToTray', true);
  if stg.GetBoolValue('Enabled', false) then
  begin
    btnStart.Click;
  end;
end;


procedure TForm1.SaveFormSettings;
var
	stg: TAIDBSection;
begin
	//
	stg := aidb.GetSubItem('MainFormSettings');
	stg.SetIntValue('Top', Top);
	stg.SetIntValue('Left', Left);
  stg.SetBoolValue('Enabled', hhkLowLevelKybd<>0);
  stg.SetBoolValue('HideToTray', cbHideToTray.Checked);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
	// ReportMemoryLeaksOnShutdown := true; // DebugHook <> 0;
	btnStop.Enabled := false;
	Layouts := TLayouts.Create;
	aidb := TAIDBSection.Create;
	aidb.Name := 'Enhanced Keyboard';
	m_saToggled := TStringList.Create;

  hhkLowLevelKybd := 0;
  g_nDenyKeyRestore := 0;
  m_LastHKL := 0;
  m_LockHKLUpdate := 0;

  begin
    HMainIcon                := LoadImage(MainInstance,'MAINICON',IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR);  //LoadIcon(MainInstance, 'MAINICON');
    tnid.cbSize              := sizeof(TNotifyIconData);
    tnid.Wnd                 := handle;
    tnid.uID                 := 123;
    tnid.uFlags              := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    tnid.uCallbackMessage    := WM_NOTIFYICON;
    //tnid.hIcon               := Application.Icon.Handle; //HMainIcon;
    tnid.hIcon               := HMainIcon;
    tnid.szTip               := 'Enhanced Keyboard';
  end;


	if FileExists('Settings.aidb') then
  begin
		aidb.LoadFromFile('Settings.aidb');
  end;
  LoadFormSettings;


  //InitTray(true);
 // CheckTraySetting;

 { Application.MainFormOnTaskBar:=false;
  ShowWindow(Application.Handle, SW_HIDE) ;
 SetWindowLong(Application.Handle, GWL_EXSTYLE, getWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW) ;
 ShowWindow(Application.Handle, SW_SHOW) ;//}

  //InitTray(false);
	Init;
	InitLayouts;
  DisplayHKL;
//	DisplayLayouts;
  LoadAdvSettings;

	lvKeys.Column[0].Width := ColumnHeaderWidth;
	lvKeys.Column[1].Width := ColumnHeaderWidth;
	lvKeys.Column[2].Width := 100;
	lvKeys.Column[3].Width := ColumnHeaderWidth;

	HideSettings;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
	SaveFormSettings;

	if hhkLowLevelKybd <> 0 then
		btnStop.Click;


	m_saToggled.Free;
	Layouts.Free;
	aidb.SaveToFile('Settings.aidb');
	aidb.Free;
  InitTray(false);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
	//
  btnAdd.Top := panel1.Height - btnAdd.Height - 8;
  btnEdit.Top := btnAdd.Top;
  btnDelete.Top := btnAdd.Top;
  btnAdvanced.Top := btnAdd.Top;

  lvKeys.Height := btnAdd.Top - lvKeys.Top - 8;
  lvKeys.Width:=panel1.Width - lvKeys.Left*2 ;
  cbHideToTray.Top := btnAdd.Top + 4;
  cbHideToTray.Left := clientwidth - cbHideToTray.Width - 8;
  btnAdvanced.Left := cbHideToTray.Left - btnAdvanced.Width - 4;

end;

end.
