program aegWebConnector;

uses
  System.StartUpCopy,
  FMX.Forms,
  main in 'view\main.pas' {FormMain},
  ClientClassesUnitOld in 'model\ClientClassesUnitOld.pas',
  ClientModuleUnit in 'model\ClientModuleUnit.pas' {ClientModule: TDataModule},
  ModelView.Information in 'viewmodel\ModelView.Information.pas',
  model.information in 'model\model.information.pas',
  ModelView.ClientClasses in 'viewmodel\ModelView.ClientClasses.pas',
  ClientClassesUnit in 'model\ClientClassesUnit.pas',
  u_crc32 in 'model\u_crc32.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TClientModule, ClientModule);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
