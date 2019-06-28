program EnhancedKeyboard;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  uKeyboard in 'uKeyboard.pas',
  uLayots in 'uLayots.pas',
  uKeyboardHelper in 'uKeyboardHelper.pas',
  uAIDB in 'uAIDB.pas',
  uNewKeyDlg in 'uNewKeyDlg.pas' {NewKeyDlg},
  sndkey32 in 'sndkey32.pas',
  uAdvSettingsDlg in 'uAdvSettingsDlg.pas' {AdvSettingsDlg},
  uHKL in 'uHKL.pas' {HKLDlg};

{$R *.res}

begin
  Application.Initialize;
//  Application.MainFormOnTaskbar := true;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(THKLDlg, HKLDlg);
  Application.Run;
end.

