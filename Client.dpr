program Client;

uses
  Vcl.Forms,
  uClient in 'uClient.pas' {fClient},
  uPublic in 'uPublic.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfClient, fClient);
  Application.Run;
end.
