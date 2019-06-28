unit uHKL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  THKLDlg = class(TForm)
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Button1: TButton;
    btnOk: TButton;
    Edit1: TEdit;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    bOk:Boolean;
    sId:string;
  end;

var
  HKLDlg: THKLDlg;

implementation

{$R *.dfm}

procedure THKLDlg.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure THKLDlg.btnOkClick(Sender: TObject);
begin
  bOk:=true;
  sId := Edit1.Text;
  Close;
end;

function GetLayoutShortName: String;
var
  LayoutName: array [0 .. KL_NAMELENGTH + 1] of Char;
  LangName: array [0 .. 1024] of Char;
begin
  Result := '??';
  if GetKeyboardLayoutName(@LayoutName) then
  begin
    if GetLocaleInfo(StrToInt('$' + StrPas(LayoutName)),
    LOCALE_SABBREVLANGNAME,
    @LangName, SizeOf(LangName) - 1) <> 0
  then
    Result := StrPas(LangName);
  end;

  //Result := UpperCase(Copy(Result, 1, 2));
  Result := UpperCase(Result);
end;

procedure THKLDlg.Button1Click(Sender: TObject);
var
  ln: array [0..255] of char;
begin
  //SpinEdit1.Value := GetKeyboardLayout(0);
  //GetKeyboardLayoutName(ln);
  Edit1.Text := GetLayoutShortName;
end;

procedure THKLDlg.FormCreate(Sender: TObject);
begin
  bOk:=false;
end;

end.

