program aegCallBackRESTWebServer;
{$APPTYPE GUI}
{$R *.dres}

uses
  FMX.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  FormUnit1 in 'view\FormUnit1.pas' {FormMain},
  ServerMethodsUnit1 in 'model\ServerMethodsUnit1.pas' {ServerMethods1: TDSServerModule},
  ServerContainerUnit1 in 'model\ServerContainerUnit1.pas' {ServerContainer1: TDataModule},
  WebModuleUnit1 in 'model\WebModuleUnit1.pas' {WebModule2: TWebModule},
  ViewModelQuery in 'viewmodel\ViewModelQuery.pas',
  c_u_ProducersConsumersSync in 'viewmodel\c_u_ProducersConsumersSync.pas',
  u_MessageMgr in 'viewmodel\u_MessageMgr.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass:= WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;

end.
