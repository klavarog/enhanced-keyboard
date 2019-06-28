object HKLDlg: THKLDlg
  Left = 0
  Top = 0
  Caption = 'Enter Keybord Language'
  ClientHeight = 94
  ClientWidth = 353
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 270
    Top = 63
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = btnCancelClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 49
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 129
      Height = 13
      Caption = 'Keyboard Language (HKL):'
    end
    object Button1: TButton
      Left = 255
      Top = 11
      Width = 75
      Height = 25
      Caption = 'SetCurrent'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 143
      Top = 13
      Width = 106
      Height = 21
      TabOrder = 1
    end
  end
  object btnOk: TButton
    Left = 189
    Top = 63
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    TabOrder = 2
    OnClick = btnOkClick
  end
end
