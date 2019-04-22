object fServer: TfServer
  Left = 0
  Top = 0
  Caption = 'Server'
  ClientHeight = 444
  ClientWidth = 631
  Color = clWindow
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Microsoft YaHei UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 20
  object lblVclStyle: TLabel
    Left = 46
    Top = 61
    Width = 68
    Height = 20
    Caption = 'VCL Style'
  end
  object edtIP: TLabeledEdit
    Left = 48
    Top = 24
    Width = 121
    Height = 28
    EditLabel.Width = 13
    EditLabel.Height = 20
    EditLabel.Caption = 'IP'
    LabelPosition = lpLeft
    LabelSpacing = 4
    TabOrder = 0
    Text = '127.0.0.1'
  end
  object edtPort: TLabeledEdit
    Left = 272
    Top = 24
    Width = 121
    Height = 28
    EditLabel.Width = 31
    EditLabel.Height = 20
    EditLabel.Caption = 'Port'
    LabelPosition = lpLeft
    LabelSpacing = 4
    TabOrder = 1
    Text = '7695'
  end
  object cbxVclStyles: TComboBox
    Left = 120
    Top = 58
    Width = 193
    Height = 28
    Style = csDropDownList
    TabOrder = 2
    OnChange = cbxVclStylesChange
  end
  object mmoLog: TMemo
    Left = 0
    Top = 92
    Width = 631
    Height = 352
    Align = alBottom
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btnListen: TButton
    Left = 399
    Top = 26
    Width = 75
    Height = 25
    Caption = #25171#24320
    TabOrder = 4
    OnClick = btnListenClick
  end
  object idtcpsrvr1: TIdTCPServer
    OnStatus = idtcpsrvr1Status
    Bindings = <>
    DefaultPort = 0
    OnConnect = idtcpsrvr1Connect
    OnDisconnect = idtcpsrvr1Disconnect
    OnException = idtcpsrvr1Exception
    OnExecute = idtcpsrvr1Execute
    Left = 536
    Top = 32
  end
end
