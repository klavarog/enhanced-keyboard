object NewKeyDlg: TNewKeyDlg
  Left = 144
  Top = 216
  BorderStyle = bsDialog
  Caption = 'Key Replacement'
  ClientHeight = 320
  ClientWidth = 249
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
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 48
    Height = 13
    Caption = 'Key code:'
  end
  object lblKeyCode1: TLabel
    Left = 119
    Top = 11
    Width = 59
    Height = 13
    Caption = 'lblKeyCode1'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 35
    Width = 233
    Height = 246
    Caption = 'Action:'
    TabOrder = 0
    object lblKeyCode2: TLabel
      Left = 89
      Top = 42
      Width = 59
      Height = 13
      Caption = 'lblKeyCode2'
    end
    object Label2: TLabel
      Left = 32
      Top = 216
      Width = 75
      Height = 13
      Caption = 'Switch back on:'
    end
    object rbKeyCode: TRadioButton
      Left = 16
      Top = 16
      Width = 113
      Height = 17
      Caption = 'New key code:'
      TabOrder = 0
      OnClick = rbKeyCodeClick
    end
    object rbText: TRadioButton
      Left = 16
      Top = 92
      Width = 113
      Height = 17
      Caption = 'Text:'
      TabOrder = 1
      OnClick = rbTextClick
    end
    object cbShift1: TCheckBox
      Left = 32
      Top = 64
      Width = 41
      Height = 17
      Caption = 'Shift'
      TabOrder = 2
    end
    object cbCtrl1: TCheckBox
      Left = 79
      Top = 65
      Width = 34
      Height = 17
      Caption = 'Ctrl'
      TabOrder = 3
    end
    object cbAlt1: TCheckBox
      Left = 119
      Top = 65
      Width = 34
      Height = 17
      Caption = 'Alt'
      TabOrder = 4
    end
    object Edit3: TEdit
      Left = 32
      Top = 115
      Width = 185
      Height = 21
      TabOrder = 5
    end
    object rbLayout: TRadioButton
      Left = 16
      Top = 144
      Width = 113
      Height = 17
      Caption = 'Layout:'
      TabOrder = 6
      OnClick = rbLayoutClick
    end
    object cobLayout2: TComboBox
      Left = 33
      Top = 167
      Width = 137
      Height = 21
      Style = csDropDownList
      DropDownCount = 20
      TabOrder = 7
    end
    object SpinEdit2: TSpinEdit
      Left = 32
      Top = 39
      Width = 51
      Height = 22
      MaxValue = 255
      MinValue = 0
      TabOrder = 8
      Value = 0
      OnChange = SpinEdit2Change
      OnKeyDown = SpinEdit1KeyDown
      OnKeyPress = SpinEdit1KeyPress
    end
    object cobSwitchLay: TComboBox
      Left = 112
      Top = 213
      Width = 105
      Height = 21
      Style = csDropDownList
      TabOrder = 9
      Items.Strings = (
        'Key Up'
        'Toggle'
        'Next Key'
        'Key Up + Delay')
    end
  end
  object btnOk: TButton
    Left = 86
    Top = 287
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 167
    Top = 287
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object cbShift2: TCheckBox
    Left = 40
    Top = 229
    Width = 41
    Height = 17
    Caption = 'Shift'
    TabOrder = 3
  end
  object cbCtrl2: TCheckBox
    Left = 87
    Top = 229
    Width = 34
    Height = 17
    Caption = 'Ctrl'
    TabOrder = 4
  end
  object cbAlt2: TCheckBox
    Left = 127
    Top = 229
    Width = 34
    Height = 17
    Caption = 'Alt'
    TabOrder = 5
  end
  object SpinEdit1: TSpinEdit
    Left = 62
    Top = 8
    Width = 51
    Height = 22
    MaxValue = 255
    MinValue = 0
    TabOrder = 6
    Value = 0
    OnChange = SpinEdit1Change
    OnKeyDown = SpinEdit1KeyDown
    OnKeyPress = SpinEdit1KeyPress
  end
end
