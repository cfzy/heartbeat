object fClient: TfClient
  Left = 0
  Top = 0
  Caption = 'Client'
  ClientHeight = 411
  ClientWidth = 567
  Color = clWindow
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Microsoft YaHei UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 20
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 567
    Height = 97
    Align = alTop
    TabOrder = 0
    object edtIP: TLabeledEdit
      Left = 48
      Top = 16
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
      Top = 16
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
    object btnConn: TButton
      Left = 399
      Top = 18
      Width = 75
      Height = 25
      Caption = #36830#25509
      TabOrder = 2
      OnClick = btnConnClick
    end
    object edtSend: TLabeledEdit
      Left = 104
      Top = 50
      Width = 289
      Height = 28
      EditLabel.Width = 37
      EditLabel.Height = 20
      EditLabel.Caption = 'Send'
      LabelPosition = lpLeft
      LabelSpacing = 4
      TabOrder = 3
      Text = 'www.ahyunhe.com'
    end
    object btnSend: TButton
      Left = 399
      Top = 52
      Width = 75
      Height = 25
      Caption = #21457#36865
      TabOrder = 4
      OnClick = btnSendClick
    end
    object btnList: TButton
      Left = 480
      Top = 52
      Width = 75
      Height = 25
      Caption = #38431#21015
      TabOrder = 5
      OnClick = btnListClick
    end
  end
  object mmoLog: TMemo
    Left = 0
    Top = 97
    Width = 567
    Height = 314
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object idtcpclnt1: TIdTCPClient
    OnStatus = idtcpclnt1Status
    OnDisconnected = idtcpclnt1Disconnected
    OnConnected = idtcpclnt1Connected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 488
    Top = 16
  end
  object tmrConn: TTimer
    Enabled = False
    OnTimer = tmrConnTimer
    Left = 280
    Top = 208
  end
end
