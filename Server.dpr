program Server;

uses
  Vcl.Forms,
  uServer in 'uServer.pas' {fServer},
  Vcl.Themes,
  Vcl.Styles,
  uPublic in 'uPublic.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Server Demo';
  Application.CreateForm(TfServer, fServer);
  Application.Run;

end.
