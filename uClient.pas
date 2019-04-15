unit uClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, IdGlobal,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type
  TfClient = class(TForm)
    idtcpclnt1: TIdTCPClient;
    procedure idtcpclnt1Connected(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fClient: TfClient;

implementation

uses
  uPublic;

{$R *.dfm}

procedure TfClient.idtcpclnt1Connected(Sender: TObject);
begin
  idtcpclnt1.IOHandler.DefStringEncoding := IndyTextEncoding_UTF8();
end;

end.
