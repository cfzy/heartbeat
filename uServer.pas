unit uServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, IdGlobal, IdYarn,
  Winapi.Winsock2, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.Themes, IdContext, IdScheduler, IdSchedulerOfThread, IdThreadSafe,
  IdTCPConnection, IdSync;

type
  TMyContext = class(TIdServerContext)
  public
    Tag: Integer;
    Queue: TIdThreadSafeStringList;

    constructor Create(AConnection: TIdTCPConnection; AYarn: TIdYarn; AList: TIdContextThreadList = nil); override;
    destructor Destroy; override;
  end;

type
  TfServer = class(TForm)
    idtcpsrvr1: TIdTCPServer;
    edtIP: TLabeledEdit;
    edtPort: TLabeledEdit;
    lblVclStyle: TLabel;
    cbxVclStyles: TComboBox;
    mmoLog: TMemo;
    btnListen: TButton;
    procedure cbxVclStylesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure idtcpsrvr1Connect(AContext: TIdContext);
    procedure idtcpsrvr1Exception(AContext: TIdContext; AException: Exception);
    procedure idtcpsrvr1Disconnect(AContext: TIdContext);
    procedure idtcpsrvr1Execute(AContext: TIdContext);
    procedure btnListenClick(Sender: TObject);
    procedure idtcpsrvr1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
  private
    { Private declarations }
    procedure ShowConnectSetSockOpt();
    procedure ShowConnectWSAIoctl();
    // procedure ShowConnect(tcpID: Cardinal; tcpIP: string; tcpPort: Word);
    procedure ShowConnect();
    procedure ShowDisconnect();
    procedure ShowException();
  public
    { Public declarations }
  end;

var
  fServer: TfServer;

implementation

uses
  uPublic;

{$R *.dfm}
{ TMyContext }

constructor TMyContext.Create(AConnection: TIdTCPConnection; AYarn: TIdYarn; AList: TIdContextThreadList);
begin
  inherited;
  Queue := TIdThreadSafeStringList.Create;
end;

destructor TMyContext.Destroy;
begin
  Queue.Free;
  inherited;
end;

{ TfServer }

procedure TfServer.btnListenClick(Sender: TObject);
var
  p: Word;
  n: Integer;
  L: TList;
begin
  if (btnListen.Caption = '关闭') then
  begin
    L := idtcpsrvr1.Contexts.LockList;
    try
      for n := 0 to L.Count - 1 do
      begin
        TIdServerContext(L.Items[n]).Connection.Disconnect;
      end;
    finally
      idtcpsrvr1.Contexts.UnlockList;
    end;
    idtcpsrvr1.Active := False;
    btnListen.Caption := '打开';
  end
  else if (btnListen.Caption = '打开') then
  begin
    p := StrToIntDef(edtPort.Text, 0);
    if not(p > 0) then
      Exit;

    idtcpsrvr1.Bindings.Clear;
    idtcpsrvr1.Bindings.Add.IP := edtIP.Text;
    idtcpsrvr1.Bindings.Add.Port := p;
    idtcpsrvr1.Active := True;
    btnListen.Caption := '关闭';
  end;
end;

procedure TfServer.cbxVclStylesChange(Sender: TObject);
begin
  TStyleManager.SetStyle(cbxVclStyles.Text);
end;

procedure TfServer.FormCreate(Sender: TObject);
var
  StyleName: string;
begin
  for StyleName in TStyleManager.StyleNames do
    cbxVclStyles.Items.Add(StyleName);

  cbxVclStyles.ItemIndex := cbxVclStyles.Items.IndexOf(TStyleManager.ActiveStyle.Name);

  //
  idtcpsrvr1.ContextClass := TMyContext;
end;

procedure TfServer.idtcpsrvr1Connect(AContext: TIdContext);
var
  opt: DWORD;
  inKlive, outKlive: TTCP_KeepAlive;
begin
  // 这里不能直接操作VCL控件，OnConnect，OnDisConnect,OnException,OnExecute都是在线程里面执行

  // 心跳包 AContext.Connection.Socket.Binding -> AContext.Binding
  opt := 1;
  if Winapi.Winsock2.setsockopt(AContext.Binding.Handle, SOL_SOCKET, SO_KEEPALIVE, @opt, SizeOf(opt)) <> 0 then
  begin
    TIdNotify.NotifyMethod(ShowConnectSetSockOpt);
    closesocket(AContext.Binding.Handle);
  end;

  inKlive.OnOff := 1;
  inKlive.KeepAliveTime := 1000 * 3;
  inKlive.KeepAliveInterval := 1000;
  if Winapi.Winsock2.WSAIoctl(AContext.Binding.Handle, SIO_KEEPALIVE_VALS, @inKlive, SizeOf(inKlive), @outKlive,
    SizeOf(outKlive), opt, nil, nil) = SOCKET_ERROR then
  begin
    TIdNotify.NotifyMethod(ShowConnectWSAIoctl);
    closesocket(AContext.Binding.Handle);
  end;

  // 中文处理
  // AContext.Connection.IOHandler.DefStringEncoding := IndyTextEncoding_UTF8();

  //
  TMyContext(AContext).Queue.Clear;
  // ??idtcpsrvr1.Contexts.LockList.Count也要进行UnLockList，之前调试一直出现问题无法退出程序就是此处原因
  TMyContext(AContext).Tag := idtcpsrvr1.Contexts.LockList.Count + 1;
  try

  finally
    idtcpsrvr1.Contexts.UnlockList;
  end;

  //
  // mmoLog.Lines.Add('【' + IntToStr(AContext.Binding.Handle) + '|' + AContext.Binding.PeerIP + ':' +
  // IntToStr(AContext.Binding.PeerPort) + '】Connect.');
  // TIdNotify.NotifyMethod(ShowConnect(AContext.Binding.Handle, AContext.Binding.PeerIP, AContext.Binding.PeerPort));
  TIdNotify.NotifyMethod(ShowConnect);
end;

procedure TfServer.idtcpsrvr1Disconnect(AContext: TIdContext);
begin
  // 这里不能直接操作VCL控件，OnConnect，OnDisConnect,OnException,OnExecute都是在线程里面执行
  TMyContext(AContext).Queue.Clear;
  // 连接断开
  // mmoLog.Lines.Add('【' + AContext.Binding.PeerIP + ':' + IntToStr(AContext.Binding.PeerPort) + '】Disconnect.');
  TIdNotify.NotifyMethod(ShowDisconnect);
end;

procedure TfServer.idtcpsrvr1Exception(AContext: TIdContext; AException: Exception);
begin
  // 这里不能直接操作VCL控件，OnConnect，OnDisConnect,OnException,OnExecute都是在线程里面执行
  // mmoLog.Lines.Add('客户端' + AContext.Binding.PeerIP + '异常断开');
  if AContext.Connection.Connected then
    AContext.Connection.Disconnect;
  TIdNotify.NotifyMethod(ShowException);
end;

procedure TfServer.idtcpsrvr1Execute(AContext: TIdContext);
var
  pIP: string;
  rcvMsg, sendMsg: AnsiString;
  pPort: Word;
  rcvBuff, sendBuff: TIdBytes;
  rcvLen, sendLen, n: Integer;
  L, Q: TStringList;
  MyContext: TMyContext;
begin
  // 这里不能直接操作VCL控件，OnConnect，OnDisConnect,OnException,OnExecute都是在线程里面执行
  AContext.Connection.IOHandler.CheckForDataOnSource(10);

  if not(AContext.Connection.IOHandler.InputBufferIsEmpty()) then
  begin
    pIP := AContext.Binding.PeerIP;
    pPort := AContext.Binding.PeerPort;
    rcvLen := AContext.Connection.IOHandler.InputBuffer.Size;

    AContext.Connection.IOHandler.ReadBytes(rcvBuff, rcvLen, False);
    SetLength(rcvMsg, rcvLen);
    Move(rcvBuff[0], rcvMsg[1], rcvLen);

    //
    L := nil;
    try
      MyContext := TMyContext(AContext);
      Q := MyContext.Queue.Lock;
      try
        if (Q.Count > 0) then
        begin
          L := TStringList.Create;
          L.Assign(Q);
          Q.Clear;
        end;
      finally
        MyContext.Queue.Unlock;
      end;
      // mmoLog.Lines.Add(pIP + ':' + IntToStr(pPort) + '>>' + rcvMsg);

      if L <> nil then
      begin
        for n := 0 to Q.Count - 1 do
        begin
          // AContext.Connection.IOHandler.Write(Q.Strings[n]);
        end;
      end;

      // 处理数据
      // sendMsg := ProcessAbnormal(True, rcvMsg);
      sendMsg := rcvMsg;

      // 发送结果
      sendLen := Length(sendMsg);
      SetLength(sendBuff, sendLen);
      Move(sendMsg[1], sendBuff[0], sendLen);
      AContext.Connection.IOHandler.Write(sendBuff, sendLen);

      mmoLog.Lines.Add('TCP发送数据：' + sendMsg);
    finally
      L.Free;
    end;
  end;
end;

procedure TfServer.idtcpsrvr1Status(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin

end;

// procedure TfServer.ShowConnect(tcpID: Cardinal; tcpIP: string; tcpPort: Word);
procedure TfServer.ShowConnect;
begin
  // mmoLog.Lines.Add('【' + IntToStr(tcpID) + '|' + tcpIP + ':' + IntToStr(tcpPort) + '】Connect.');
  mmoLog.Lines.Add(yyyyMMddHHmmss + 'Connect.');
end;

procedure TfServer.ShowConnectSetSockOpt;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmss + 'setsockopt KeepAlive Error!');
end;

procedure TfServer.ShowConnectWSAIoctl;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmss + 'WSAIoctl KeepAlive Error!');
end;

procedure TfServer.ShowDisconnect;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmss + 'Disconnect.');
end;

procedure TfServer.ShowException;
begin
  mmoLog.Lines.Add(yyyyMMddHHmmss + 'Exception.');
end;

end.
