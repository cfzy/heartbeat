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
  PixelsPerInch = 96
  TextHeight = 20
  object idtcpclnt1: TIdTCPClient
    OnConnected = idtcpclnt1Connected
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 248
    Top = 232
  end
end
