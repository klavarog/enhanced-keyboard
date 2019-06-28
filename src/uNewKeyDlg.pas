unit uNewKeyDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uAIDB, uLayots, Spin;

type
  TNewKeyDlg = class(TForm)
    Label1: TLabel;
    GroupBox1: TGroupBox;
    rbKeyCode: TRadioButton;
    rbText: TRadioButton;
    cbShift1: TCheckBox;
    cbCtrl1: TCheckBox;
    cbAlt1: TCheckBox;
    Edit3: TEdit;
    rbLayout: TRadioButton;
    cobLayout2: TComboBox;
    btnOk: TButton;
    btnCancel: TButton;
    cbShift2: TCheckBox;
    cbCtrl2: TCheckBox;
    cbAlt2: TCheckBox;
    lblKeyCode1: TLabel;
    lblKeyCode2: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    Label2: TLabel;
    cobSwitchLay: TComboBox;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure rbTextClick(Sender: TObject);
    procedure rbKeyCodeClick(Sender: TObject);
    procedure rbLayoutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    m_pLayout:TAIDBSection;
    m_pLayouts:TAIDBSection;
    m_pEdit:TAIDBSection;
    bOK:boolean;
    procedure AddKeyReplace(dbKey:TAIDBSection; nKey, nNewKey, nSysKeys:integer);
    procedure AddKeyLayout(dbKey:TAIDBSection; nKey:integer; sLayout:string; nSysKeys:integer; nMode:integer);
    procedure AddKeyText(dbKey:TAIDBSection; nKey:integer; sText:string);

    function CheckLayoutKey(nKey:integer; sLayoutName:string; var sUsedLayout:string):boolean;

    procedure SetEditMode(KeySec:TAIDBSection);
  end;


implementation

{$R *.dfm}

uses
	Unit1, uKeyboard;

procedure TNewKeyDlg.AddKeyReplace(dbKey:TAIDBSection; nKey, nNewKey, nSysKeys:integer);
begin
  //
  if dbKey = nil then
	  dbKey := m_pLayout.GetSubItem(inttostr(nKey))
  else
  	dbKey.Name := inttostr(nKey);

  dbKey.ClearSubItems;
  dbKey.SetIntValue('NewKeyCode', nNewKey);
  if nSysKeys<>0 then
	  dbKey.SetIntValue('SysKeys', nSysKeys);
end;


procedure TNewKeyDlg.AddKeyLayout(dbKey:TAIDBSection; nKey:integer; sLayout:string; nSysKeys:integer; nMode:integer);
begin
  //
  if dbKey = nil then
  	dbKey := m_pLayout.GetSubItem(inttostr(nKey))
  else
  	dbKey.Name := inttostr(nKey);

  dbKey.ClearSubItems;
  dbKey.SetValue('Layout', sLayout);
  if nSysKeys<>0 then
	  dbKey.SetIntValue('SysKeys', nSysKeys);
//  if bToggle then
	//  dbKey.SetBoolValue('Toggle', bToggle);

  dbKey.SetIntValue('SwitchMode', nMode);

end;

procedure TNewKeyDlg.AddKeyText(dbKey:TAIDBSection; nKey:integer; sText:string);
begin
  //
  if dbKey = nil then
  	dbKey := m_pLayout.GetSubItem(inttostr(nKey))
  else
  	dbKey.Name := inttostr(nKey);

  dbKey.ClearSubItems;
  dbKey.SetValue('Text', sText);
end;

procedure TNewKeyDlg.SetEditMode(KeySec:TAIDBSection);
var
  s:string;
  nS:integer;
begin
  //
  m_pEdit:=KeySec;
  SpinEdit1.Value := strtoint(KeySec.Name);
  SpinEdit1.ReadOnly:=true;
  SpinEdit1.Enabled := false;

    s:=KeySec.GetValue('NewKeyCode', '');
    if s<>'' then
    begin
    	nS:= KeySec.GetIntValue('SysKeys', 0);
    	rbKeyCode.Checked:=true;
      //edit2.Text := s;
      SpinEdit2.Value := strtoint(s);
      cbShift1.Checked := (nS and keyShift)<>0;
      cbCtrl1.Checked := (nS and keyContorl)<>0;
      cbAlt1.Checked := (nS and keyAlt)<>0;
      exit;
    end;

    s := KeySec.GetValue('Layout', '');
    if s<>'' then
    begin
    	nS:= KeySec.GetIntValue('SysKeys', 0);
    	rbLayout.Checked:=true;
      cobLayout2.ItemIndex := cobLayout2.Items.IndexOf(s);
      cbShift2.Checked := (nS and keyShift)<>0;
      cbCtrl2.Checked := (nS and keyContorl)<>0;
      cbAlt2.Checked := (nS and keyAlt)<>0;
//      cbToggle.Checked := KeySec.GetBoolValue('Toggle', false);
      cobSwitchLay.ItemIndex := KeySec.GetIntValue('SwitchMode', 0);
      
      exit;
    end;


    s:=KeySec.GetValue('Text', '');
    if s<>'' then
    begin
    	rbText.Checked:=true;
      edit3.Text := s;
    end;


end;


procedure TNewKeyDlg.SpinEdit1Change(Sender: TObject);
var
	vkc:integer;
begin
	vkc := SpinEdit1.Value;
  if (vkc<0) or (vkc>255) then
  	exit;

	lblKeyCode1.Caption := m_KeyStates[vkc].sName;
end;

procedure TNewKeyDlg.SpinEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	if TSpinEdit(Sender).ReadOnly then
  	exit;

	if key=VK_SHIFT then
  begin
    if (GetKeyState(VK_LSHIFT) and $80)<>0 then
    	key:=VK_LSHIFT
    else
	    key:=VK_RSHIFT;
  end else
  if key=VK_CONTROL then
  begin
    if (GetKeyState(VK_LCONTROL) and $80)<>0 then
    	key:=VK_LCONTROL
    else
	    key:=VK_RCONTROL;
  end else
  if key=VK_MENU then
  begin
    if (GetKeyState(VK_LMENU) and $80)<>0 then
    	key:=VK_LMENU
    else
	    key:=VK_RMENU;
  end;

	TSpinEdit(Sender).Value := key;
  key:=0;
end;

procedure TNewKeyDlg.SpinEdit1KeyPress(Sender: TObject; var Key: Char);
begin
	if TSpinEdit(Sender).ReadOnly then
  	exit;
	Key:=#0;
end;

procedure TNewKeyDlg.SpinEdit2Change(Sender: TObject);
var
	vkc:integer;
begin
	vkc := SpinEdit2.Value;
  if (vkc<0) or (vkc>255) then
  	exit;

	lblKeyCode2.Caption := m_KeyStates[vkc].sName;
end;

function TNewKeyDlg.CheckLayoutKey(nKey:integer; sLayoutName:string; var sUsedLayout:string):boolean;
var
  i, j:integer;
  db, kdb:TAIDBSection;
  s:string;
  nKey1:integer;
begin
  //
  result:=false;
  sUsedLayout := '';
  if m_pLayouts = nil then
    exit;

  for i:=0 to m_pLayouts.Count - 1 do
  begin
    //
    db := m_pLayouts.SubItems[i];

    for j := 0 to db.Count - 1 do
    begin
      kdb := db.SubItems[j];
      s := kdb.GetValue('Layout', '');
      if (s <> '') and (s = sLayoutName) then
      begin
        // check for switch mode >>>
        begin
          s := kdb.GetValue('SwitchMode', '');
          
          if (s<>'') and (s = '2') then
            continue;
        end;
        // check for switch mode <<<
        nKey1 := strtoint(kdb.Name);
        if nKey1 = nKey then
        begin
          result:=true;
          sUsedLayout := db.name;
          exit;
        end;
      end;
    end;
  end;

end;

procedure TNewKeyDlg.btnOkClick(Sender: TObject);
var
	nKey1, nKey2:integer;
  nSysKey:integer;
  db:TAIDBSection;
  sUsedLayout:string;
  nSwitchMode:integer;
begin

	nKey1 := 999;

  nKey1 := SpinEdit1.value;

  if (nKey1<=0) or (nKey1 > 255) then
  begin
    ShowMessage('This key is not supported #'+inttostr(nKey1));
    exit;
  end;

  nSwitchMode:=-1;

  if m_pEdit=nil then
  if m_pLayout.FindSubItem(SpinEdit1.Text)<>nil then
  begin
    ShowMessage('This key is already used in "'+m_pLayout.Name+'" layout');
    exit;
  end;

  if CheckLayoutKey(nKey1, m_pLayout.Name, sUsedLayout) then
  begin
    ShowMessage('This key is already used in "'+sUsedLayout+'" layout');
    exit;
  end;

  nSysKey:=0;


  if rbKeyCode.checked then
  begin
    //
    nKey2 := Spinedit2.Value;
    if (nKey2<=0) or (nKey2 > 255) then
    begin
      ShowMessage('This key is not supported #'+inttostr(nKey2));
      exit;
    end;

    if cbShift1.Checked then
    	nSysKey := nSysKey or keyShift;
    if cbCtrl1.Checked then
    	nSysKey := nSysKey or keyContorl;
    if cbAlt1.Checked then
    	nSysKey := nSysKey or keyAlt;

    AddKeyReplace(m_pEdit, nKey1, nKey2, nSysKey);
  end else
  if rbText.checked then
  begin
    //
    AddKeyText(m_pEdit, nKey1, Edit3.Text);
  end else
  if rbLayout.checked then
  begin
    //
    if cobLayout2.Text='' then
    begin
      Showmessage('No layout was selected');
      exit;
    end;

    db := m_pLayouts.FindSubItem(cobLayout2.Text);
    if db=nil then
    begin
      ShowMessage('Wrong Layout name');
      exit;
    end;

    nSwitchMode := cobSwitchLay.ItemIndex;

    if (nSwitchMode<>2) and (db.FindSubItem(SpinEdit1.Text)<>nil) then
    begin
      //
      ShowMessage('This key is already used in "'+cobLayout2.Text+'" layout');
      exit;
    end;



    if cbShift2.Checked then
    	nSysKey := nSysKey or keyShift;
    if cbCtrl2.Checked then
    	nSysKey := nSysKey or keyContorl;
    if cbAlt2.Checked then
    	nSysKey := nSysKey or keyAlt;

    AddKeyLayout(m_pEdit, nKey1, cobLayout2.Text, nSysKey, nSwitchMode);
  end;

  bOk:=true;
	Close;
end;

procedure TNewKeyDlg.btnCancelClick(Sender: TObject);
begin
	Close;
end;


procedure TNewKeyDlg.FormCreate(Sender: TObject);
begin
	rbKeyCode.Checked:=true;
  bOK:=false;
  m_pEdit := nil;
  lblKeyCode1.Caption:='';
  lblKeyCode2.Caption:='';
end;

procedure TNewKeyDlg.rbKeyCodeClick(Sender: TObject);
begin
  SpinEdit2.Enabled:=true;
  cbShift1.Enabled:=true;
  cbCtrl1.Enabled:=true;
  cbAlt1.Enabled:=true;
  //
  Edit3.Enabled:=false;
  //
  cobLayout2.Enabled:=false;
  cbShift2.Enabled:=false;
  cbCtrl2.Enabled:=false;
  cbAlt2.Enabled:=false;
//  cbToggle.Enabled:=false;
  cobSwitchLay.Enabled:=false;
end;

procedure TNewKeyDlg.rbTextClick(Sender: TObject);
begin
	SpinEdit2.Enabled:=false;
  cbShift1.Enabled:=false;
  cbCtrl1.Enabled:=false;
  cbAlt1.Enabled:=false;
  //
  Edit3.Enabled:=true;
  //
  cobLayout2.Enabled:=false;
  cbShift2.Enabled:=false;
  cbCtrl2.Enabled:=false;
  cbAlt2.Enabled:=false;
//  cbToggle.Enabled:=false;
  cobSwitchLay.Enabled:=false;
end;

procedure TNewKeyDlg.rbLayoutClick(Sender: TObject);
begin
	SpinEdit2.Enabled:=false;
  cbShift1.Enabled:=false;
  cbCtrl1.Enabled:=false;
  cbAlt1.Enabled:=false;
  //
  Edit3.Enabled:=false;
  //
  cobLayout2.Enabled:=true;
  cbShift2.Enabled:=true;
  cbCtrl2.Enabled:=true;
  cbAlt2.Enabled:=true;
  //cbToggle.Enabled:=true;
  cobSwitchLay.Enabled:=true;
end;

end.

