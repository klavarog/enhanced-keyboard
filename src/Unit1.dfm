object Form1: TForm1
  Left = 302
  Top = 147
  Caption = 'EnKey: Default'
  ClientHeight = 440
  ClientWidth = 523
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    523
    440)
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 8
    Top = 39
    Width = 67
    Height = 13
    Caption = 'Toggled keys:'
  end
  object lblToggledKeys: TLabel
    Left = 81
    Top = 39
    Width = 25
    Height = 13
    Caption = 'None'
  end
  object Label1: TLabel
    Left = 432
    Top = 39
    Width = 83
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = '---'
  end
  object btnStart: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = btnStopClick
  end
  object btnSettings: TButton
    Left = 170
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Settings'
    TabOrder = 2
    OnClick = btnSettingsClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 58
    Width = 523
    Height = 382
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    ExplicitHeight = 391
    DesignSize = (
      523
      382)
    object Label2: TLabel
      Left = 16
      Top = 50
      Width = 37
      Height = 13
      BiDiMode = bdLeftToRight
      Caption = 'Layout:'
      ParentBiDiMode = False
      ParentShowHint = False
      ShowHint = False
    end
    object Bevel1: TBevel
      Left = 0
      Top = 37
      Width = 523
      Height = 2
      Anchors = [akLeft, akTop, akRight]
    end
    object lbl1: TLabel
      Left = 16
      Top = 12
      Width = 87
      Height = 13
      Caption = 'Language Layout:'
    end
    object lvKeys: TListView
      Left = 8
      Top = 73
      Width = 505
      Height = 266
      Columns = <
        item
          Caption = 'KeyCode'
        end
        item
          Caption = 'New KeyCode'
        end
        item
          Caption = 'Layout'
        end
        item
          Caption = 'Insert Text'
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = btnEditClick
    end
    object btnRename: TButton
      Left = 326
      Top = 45
      Width = 61
      Height = 24
      Caption = 'Rename'
      TabOrder = 1
      OnClick = btnRenameClick
    end
    object btnEdit: TButton
      Left = 89
      Top = 348
      Width = 75
      Height = 25
      Caption = 'Edit'
      TabOrder = 2
      OnClick = btnEditClick
    end
    object btnDeleteLayout: TButton
      Left = 393
      Top = 45
      Width = 61
      Height = 24
      Caption = 'Delete'
      TabOrder = 3
      OnClick = btnDeleteLayoutClick
    end
    object btnDelete: TButton
      Left = 170
      Top = 348
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 4
      OnClick = btnDeleteClick
    end
    object btnAdd: TButton
      Left = 8
      Top = 348
      Width = 75
      Height = 25
      Caption = 'Add'
      TabOrder = 5
      OnClick = btnAddClick
    end
    object btnNewLayout: TButton
      Left = 259
      Top = 45
      Width = 61
      Height = 24
      Caption = 'New'
      TabOrder = 6
      OnClick = btnNewLayoutClick
    end
    object cobLayout: TComboBox
      Left = 59
      Top = 46
      Width = 194
      Height = 21
      Style = csDropDownList
      DropDownCount = 20
      TabOrder = 7
      OnChange = cobLayoutChange
    end
    object cbHideToTray: TCheckBox
      Left = 440
      Top = 352
      Width = 73
      Height = 17
      Caption = 'Hide to tray'
      TabOrder = 8
      OnClick = cbHideToTrayClick
    end
    object btnAdvanced: TButton
      Left = 359
      Top = 348
      Width = 75
      Height = 25
      Caption = 'Advanced'
      TabOrder = 9
      OnClick = btnAdvancedClick
    end
    object cobHKL: TComboBox
      Left = 108
      Top = 8
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 10
      OnChange = cobHKLChange
    end
    object btnHKLNew: TButton
      Left = 259
      Top = 6
      Width = 61
      Height = 25
      Caption = 'New'
      TabOrder = 11
      OnClick = btnHKLNewClick
    end
    object btnHKLDelete: TButton
      Left = 326
      Top = 6
      Width = 61
      Height = 25
      Caption = 'Delete'
      TabOrder = 12
      OnClick = btnHKLDeleteClick
    end
  end
  object TimerRestoreLay: TTimer
    Enabled = False
    OnTimer = TimerRestoreLayTimer
    Left = 312
    Top = 8
  end
  object TimerHKL: TTimer
    Interval = 200
    OnTimer = TimerHKLTimer
    Left = 416
    Top = 8
  end
end
