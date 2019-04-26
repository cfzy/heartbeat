unit uClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, IdGlobal, IdSync,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, Vcl.WinXCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Winapi.Winsock2;

const
  ReconnectInterval = 1000 * 10;

type
  TidTcpClientRcvThread = class(TThread)
  private
    _connOK: Boolean;
    _idTcpClnt: TIdTCPClient;
  protected
    procedure Execute; override;
  public
    constructor Create(Suspend: Boolean; tcpclnt: TIdTCPClient); overload;
  end;

type
  TfClient = class(TForm)
    idtcpclnt1: TIdTCPClient;
    GroupBox1: TGroupBox;
    edtIP: TLabeledEdit;
    edtPort: TLabeledEdit;
    btnConn: TButton;
    mmoLog: TMemo;
    edtSend: TLabeledEdit;
    btnSend: TButton;
    btnList: TButton;
    tmrConn: TTimer;
    procedure idtcpclnt1Connected(Sender: TObject);
    procedure btnConnClick(Sender: TObject);
    procedure idtcpclnt1Disconnected(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSendClick(Sender: TObject);
    procedure btnListClick(Sender: TObject);
    procedure idtcpclnt1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure tmrConnTimer(Sender: TObject);
  private
    { Private declarations }
    ConnCount: Integer;
    procedure ShowConnectSetSockOpt();
    procedure ShowConnectWSAIoctl();
    procedure ShowConnect();
    procedure ShowDisconnect();
  public
    { Public declarations }
  end;

procedure Display(const tip: string);

var
  fClient: TfClient;
  RcvList: TStringList;

implementation

uses
  uPublic;

{$R *.dfm}

procedure Display(const tip: string);
begin
  // 非阻塞执行，需保证内部访问数据线程安全
  TThread.Queue(nil,
    procedure
    begin
      fClient.mmoLog.Lines.Add(yyyyMMddHHmmsszzz + tip);
    end);

  // 阻塞执行
  // TThread.Synchronize(nil,
  // procedure
  // begin
  // fClient.mmoLog.Lines.Add(tip);
  // end);
end;

{ TTcpClientRcvThread }

constructor TidTcpClientRcvThread.Create(Suspend: Boolean; tcpclnt: TIdTCPClient);
begin
  _idTcpClnt := tcpclnt;
  _connOK := _idTcpClnt.Connected;

  inherited Create(Suspend);
end;

procedure TidTcpClientRcvThread.Execute;
var
  pIP: string;
  rcvMsg, sendMsg: AnsiString;
  pPort: Word;
  rcvBuff, sendBuff: TIdBytes;
  rcvLen, sendLen, n: Integer;
begin
  inherited;
  FreeOnTerminate := True;

  try
    while (_idTcpClnt.Connected) do
    begin
      _idTcpClnt.IOHandler.CheckForDataOnSource(10);

      if not(_idTcpClnt.IOHandler.InputBufferIsEmpty()) then
      begin
        pIP := _idTcpClnt.IOHandler.Host;
        pPort := _idTcpClnt.IOHandler.Port;
        rcvLen := _idTcpClnt.IOHandler.InputBuffer.Size;

        _idTcpClnt.IOHandler.ReadBytes(rcvBuff, rcvLen, False);
        SetLength(rcvMsg, rcvLen);
        Move(rcvBuff[0], rcvMsg[1], rcvLen);
        RcvList.Add(FormatDateTime('[yyyy-MM-dd HH:mm:ss]', Now()) + rcvMsg);
        Display(string(rcvMsg));

        // sendMsg := rcvMsg;
        //
        // // 发送结果
        // sendLen := Length(sendMsg);
        // SetLength(sendBuff, sendLen);
        // Move(sendMsg[1], sendBuff[0], sendLen);
        // _idTcpClnt.IOHandler.Write(sendBuff, sendLen);
      end;
    end;

    _connOK := False;
    fClient.btnConn.Caption := '连接';
    fClient.tmrConn.Enabled := False;
    fClient.tmrConn.Interval := ReconnectInterval;
    fClient.tmrConn.Enabled := True; // 这儿启动定时器重连服务端
  except
    on e: Exception do
    begin
      Display('断开.' + #13#10 + e.Message);
      _connOK := False;
      // if _idTcpClnt.Connected then
      _idTcpClnt.Disconnect();
      fClient.tmrConn.Enabled := False;
      fClient.tmrConn.Interval := ReconnectInterval;
      fClient.tmrConn.Enabled := True; // 这儿启动定时器重连服务端
    end;
  end;
end;

{ TfClient }

procedure TfClient.btnConnClick(Sender: TObject);
var
  p: Word;
  n: Integer;
begin
  if (btnConn.Caption = '连接') then
  begin
    p := StrToIntDef(edtPort.Text, 0);
    if not(p > 0) then
      Exit;

    idtcpclnt1.Host := edtIP.Text;
    idtcpclnt1.Port := p;
    try
      idtcpclnt1.Connect();
    except
      tmrConn.Enabled := False;
      tmrConn.Interval := ReconnectInterval;
      tmrConn.Enabled := True;
    end;
  end
  else if (btnConn.Caption = '断开') then
  begin
    idtcpclnt1.Disconnect();
  end;
end;

procedure TfClient.btnListClick(Sender: TObject);
begin
  if not(RcvList.Count > 0) then
  begin
    mmoLog.Lines.Add('empty queue.');
    Exit;
  end;

  mmoLog.Lines.Add('========================================');
  mmoLog.Lines.Add(RcvList.Text);
  RcvList.Clear;
end;

procedure TfClient.btnSendClick(Sender: TObject);
begin
  if idtcpclnt1.Connected then
  begin
    idtcpclnt1.IOHandler.Write(AnsiString(edtSend.Text), IndyTextEncoding_ASCII);
  end;
end;

procedure TfClient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RcvList.Free;
end;

procedure TfClient.FormCreate(Sender: TObject);
begin
  RcvList := TStringList.Create;
  ConnCount := 0;
end;

procedure TfClient.idtcpclnt1Connected(Sender: TObject);
var
  opt: DWORD;
  inKlive, outKlive: TTCP_KeepAlive;
  thRcv: TidTcpClientRcvThread;
begin
  // 心跳包 _idTcpClnt.Socket.Binding -> AContext.Binding
  opt := 1;
  if Winapi.Winsock2.setsockopt(idtcpclnt1.Socket.Binding.Handle, SOL_SOCKET, SO_KEEPALIVE, @opt, SizeOf(opt)) <> 0 then
  begin
    TIdNotify.NotifyMethod(ShowConnectSetSockOpt);
    closesocket(idtcpclnt1.Socket.Binding.Handle);
  end;

  inKlive.OnOff := 1;
  inKlive.KeepAliveTime := 1000 * 3;
  inKlive.KeepAliveInterval := 600;
  if Winapi.Winsock2.WSAIoctl(idtcpclnt1.Socket.Binding.Handle, SIO_KEEPALIVE_VALS, @inKlive, SizeOf(inKlive),
    @outKlive, SizeOf(outKlive), opt, nil, nil) = SOCKET_ERROR then
  begin
    TIdNotify.NotifyMethod(ShowConnectWSAIoctl);
    closesocket(idtcpclnt1.Socket.Binding.Handle);
  end;

  // 中文处理
  // idtcpclnt1.IOHandler.DefStringEncoding := IndyTextEncoding_UTF8();

  // 数据接收处理线程
  thRcv := TidTcpClientRcvThread.Create(True, idtcpclnt1);
  thRcv.Start;

  //
  TIdNotify.NotifyMethod(ShowConnect);
end;

procedure TfClient.idtcpclnt1Disconnected(Sender: TObject);
begin
  TIdNotify.NotifyMethod(ShowDisconnect);
end;

procedure TfClient.idtcpclnt1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  mmoLog.Lines.Add(yyyyMMddHHmmsszzz + '[OnStatus:]' + IntToStr(Ord(AStatus)) + '-' + AStatusText);
end;

procedure TfClient.ShowConnect;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmsszzz + 'Connect.');

  btnConn.Caption := '断开';
  tmrConn.Enabled := False;
end;

procedure TfClient.ShowConnectSetSockOpt;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmsszzz + 'setsockopt KeepAlive Error!');
end;

procedure TfClient.ShowConnectWSAIoctl;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmsszzz + 'WSAIoctl KeepAlive Error!');
end;

procedure TfClient.ShowDisconnect;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmsszzz + 'Disconnect.');

  btnConn.Caption := '连接';
end;

procedure TfClient.tmrConnTimer(Sender: TObject);
var
  p: Word;
  n: Integer;
begin
  tmrConn.Enabled := False;
  tmrConn.Interval := ReconnectInterval;
  Inc(ConnCount);
  mmoLog.Lines.Add(yyyyMMddHHmmsszzz + '第' + IntToStr(ConnCount) + '次断线重连。');

  p := StrToIntDef(edtPort.Text, 0);
  if not(p > 0) then
    Exit;

  idtcpclnt1.Host := edtIP.Text;
  idtcpclnt1.Port := p;
  try
    idtcpclnt1.Connect();
  except
    tmrConn.Enabled := True;
  end;
end;

end.
