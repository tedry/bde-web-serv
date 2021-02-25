unit ClientModuleUnit;

// proschoolportal.com
interface

uses
  System.SysUtils,
  System.Classes,
  ClientClassesUnit,
  Data.DBXDataSnap,
  Data.DBXCommon,
  IPPeerClient,
  Data.DB,
  Data.SqlExpr,
  Datasnap.DSCommon,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.ODBC,
  FireDAC.Phys.ODBCDef,
  FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Datasnap.DBClient,
  Datasnap.Provider,
  FireDAC.Comp.BatchMove.JSON,
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.DataSet;

type
  TClientModule = class(TDataModule)
    SQLConnection1: TSQLConnection;
    DSClientCallbackChannelManager1: TDSClientCallbackChannelManager;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDQueryWorker: TFDQuery;
    ClientDataSet1: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    bm: TFDBatchMove;
    bmJSONreader: TFDBatchMoveDataSetReader;
    bmJSONwriter: TFDBatchMoveJSONWriter;
    procedure DSClientCallbackChannelManager1ServerConnectionError(Sender: TObject);
    procedure DSClientCallbackChannelManager1ServerConnectionTerminate(Sender: TObject);
    procedure DSClientCallbackChannelManager1ChannelStateChange(Sender: TObject; const EventItem: TDSClientChannelEventItem);
    private
      FInstanceOwner       : Boolean;
      FServerMethods1Client: TServerMethods1Client;
      function GetServerMethods1Client: TServerMethods1Client;
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      property InstanceOwner: Boolean read FInstanceOwner write FInstanceOwner;
      property ServerMethods1Client: TServerMethods1Client read GetServerMethods1Client write FServerMethods1Client;

  end;

var
  ClientModule: TClientModule;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

uses
  main;

// -------------------------------------------------------------------------------------------------------------------------------
constructor TClientModule.Create(AOwner: TComponent);
begin
  inherited;
  // proschoolportal.com
  FInstanceOwner:= True;
end;

// -------------------------------------------------------------------------------------------------------------------------------
destructor TClientModule.Destroy;
begin
  FServerMethods1Client.Free;
  inherited;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TClientModule.DSClientCallbackChannelManager1ChannelStateChange(Sender: TObject; const EventItem: TDSClientChannelEventItem);
begin
  FormMain.QueueLogMsg('Log - INFO - Channel: ' + EventItem.TunnelChannelName + ' State Changed.');
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TClientModule.DSClientCallbackChannelManager1ServerConnectionError(Sender: TObject);
begin
  FormMain.QueueLogMsg('Log - ERROR - Server Connection Error. Retyring... ');
  SQLConnection1.Connected:= True;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TClientModule.DSClientCallbackChannelManager1ServerConnectionTerminate(Sender: TObject);
begin
  FormMain.QueueLogMsg('Log - ERROR - Server Connection Terminated. Retyring... ');
  SQLConnection1.Connected:= True;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TClientModule.GetServerMethods1Client: TServerMethods1Client;
begin
  if FServerMethods1Client = nil then
    begin
      SQLConnection1.Open;
      FServerMethods1Client:= TServerMethods1Client.Create(SQLConnection1.DBXConnection, FInstanceOwner);
    end;
  Result:= FServerMethods1Client;
end;

// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
end.
