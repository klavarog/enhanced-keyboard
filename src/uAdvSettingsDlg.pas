unit uAdvSettingsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uAIDB, Spin;

type
  TAdvSettingsDlg = class(TForm)
    cbDenyKeyRestore: TCheckBox;
    Label1: TLabel;
    seDenyKeyRestore: TSpinEdit;
    btnOk: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    seLayoutDelay: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    procedure cbDenyKeyRestoreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_pAdvSettings:TAIDBSection;
    bOK:boolean;
  end;

var
  AdvSettingsDlg: TAdvSettingsDlg;

implementation

{$R *.dfm}

procedure TAdvSettingsDlg.btnCancelClick(Sender: TObject);
begin
	Close;
end;

procedure TAdvSettingsDlg.btnOkClick(Sender: TObject);
begin
	bOK := true;
  m_pAdvSettings.SetBoolValue('DenyKeyRestore', cbDenyKeyRestore.Checked);
  m_pAdvSettings.SetIntValue('DenyKeyRestoreTime', seDenyKeyRestore.Value);

  m_pAdvSettings.SetIntValue('LayoutRestoreDelay', seLayoutDelay.Value);

  close;
end;

procedure TAdvSettingsDlg.cbDenyKeyRestoreClick(Sender: TObject);
begin
	seDenyKeyRestore.Enabled := cbDenyKeyRestore.Checked;
end;

procedure TAdvSettingsDlg.FormCreate(Sender: TObject);
begin
	m_pAdvSettings := nil;
  bOK := false;
end;

procedure TAdvSettingsDlg.FormShow(Sender: TObject);
begin
  cbDenyKeyRestore.Checked := m_pAdvSettings.GetBoolValue('DenyKeyRestore', false);
	seDenyKeyRestore.Value := m_pAdvSettings.GetIntValue('DenyKeyRestoreTime', 500);

  seLayoutDelay.Value := m_pAdvSettings.GetIntValue('LayoutRestoreDelay', 50);

  seDenyKeyRestore.Enabled := cbDenyKeyRestore.Checked;
end;

end.

