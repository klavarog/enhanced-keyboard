object AdvSettingsDlg: TAdvSettingsDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Advanced settings'
  ClientHeight = 129
  ClientWidth = 257
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 31
    Width = 55
    Height = 13
    Caption = 'Time dalay:'
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 89
    Height = 13
    Caption = 'Layout delay time:'
  end
  object Label3: TLabel
    Left = 175
    Top = 31
    Width = 13
    Height = 13
    Caption = 'ms'
  end
  object Label4: TLabel
    Left = 175
    Top = 64
    Width = 13
    Height = 13
    Caption = 'ms'
  end
  object cbDenyKeyRestore: TCheckBox
    Left = 8
    Top = 8
    Width = 161
    Height = 17
    Caption = 'Do not restore pressed keys '
    TabOrder = 0
    OnClick = cbDenyKeyRestoreClick
  end
  object seDenyKeyRestore: TSpinEdit
    Left = 103
    Top = 28
    Width = 66
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 1
    Value = 500
  end
  object btnOk: TButton
    Left = 94
    Top = 96
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 175
    Top = 96
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object seLayoutDelay: TSpinEdit
    Left = 103
    Top = 61
    Width = 66
    Height = 22
    MaxValue = 10000
    MinValue = 1
    TabOrder = 2
    Value = 500
  end
end
