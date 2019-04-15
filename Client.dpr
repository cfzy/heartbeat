program Client;

uses
  Vcl.Forms,
  uClient in 'uClient.pas' {fClient};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfClient, fClient);
  Application.Run;
end.
