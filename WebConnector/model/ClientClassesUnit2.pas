//
// Created by the DataSnap proxy generator.
// 12/18/2017 6:49:26 PM
//

unit ClientClassesUnit2;

interface

uses
  System.JSON,
  Data.DBXCommon,
  Data.DBXClient,
  Data.DBXDataSnap,
  Data.DBXJSON,
  Datasnap.DSProxy,
  System.Classes,
  System.SysUtils,
  Data.DB,
  Data.SqlExpr,
  Data.DBXDBReaders,
  Data.DBXCDSReaders,
  Data.FireDACJSONReflect,
  Data.DBXJSONReflect;

type
  TServerMethods1Client = class( TDSAdminClient )
    private
      FEchoStringCommand    : TDBXCommand;
      FReverseStringCommand : TDBXCommand;
      FRegisterCheckCommand : TDBXCommand;
      FResult_DSCommand     : TDBXCommand;
      FResultDSCommand      : TDBXCommand;
      FResultMetaDSACommand : TDBXCommand;
      FResultDataDSACommand : TDBXCommand;
      FResultJDSCommand     : TDBXCommand;
      FResultJArrayCommand  : TDBXCommand;
      FRoundTripTimeCommand : TDBXCommand;
      FShutDownNoticeCommand: TDBXCommand;
    public
      constructor Create ( ADBXConnection: TDBXConnection ); overload;
      constructor Create ( ADBXConnection: TDBXConnection; AInstanceOwner: Boolean ); overload;
      destructor Destroy; override;
      function EchoString ( Value: string ): string;
      function ReverseString ( Value: string ): string;
      function RegisterCheck ( clientID: string; callbackID: string ): string;
      function Result_DS ( Value: OleVariant ): string;
      function ResultDS ( Value: TDataSet ): string;
      function ResultMetaDSA ( Value: TDataSet ): TJSONArray;
      function ResultDataDSA ( Value: TDataSet ): TJSONArray;
      function ResultJDS ( Value: TFDJSONDataSets ): string;
      function ResultJArray ( Value: TJSONArray ): string;
      function RoundTripTime ( Value: Int64 ): Int64;
      function ShutDownNotice ( Value: string ): string;
  end;

implementation

function TServerMethods1Client.EchoString ( Value: string ): string;
begin
  if FEchoStringCommand = nil then
    begin
      FEchoStringCommand            := FDBXConnection.CreateCommand;
      FEchoStringCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FEchoStringCommand.Text       := 'TServerMethods1.EchoString';
      FEchoStringCommand.Prepare;
    end;
  FEchoStringCommand.Parameters[0].Value.SetWideString ( Value );
  FEchoStringCommand.ExecuteUpdate;
  Result:= FEchoStringCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.ReverseString ( Value: string ): string;
begin
  if FReverseStringCommand = nil then
    begin
      FReverseStringCommand            := FDBXConnection.CreateCommand;
      FReverseStringCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FReverseStringCommand.Text       := 'TServerMethods1.ReverseString';
      FReverseStringCommand.Prepare;
    end;
  FReverseStringCommand.Parameters[0].Value.SetWideString ( Value );
  FReverseStringCommand.ExecuteUpdate;
  Result:= FReverseStringCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.RegisterCheck ( clientID: string; callbackID: string ): string;
begin
  if FRegisterCheckCommand = nil then
    begin
      FRegisterCheckCommand            := FDBXConnection.CreateCommand;
      FRegisterCheckCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FRegisterCheckCommand.Text       := 'TServerMethods1.RegisterCheck';
      FRegisterCheckCommand.Prepare;
    end;
  FRegisterCheckCommand.Parameters[0].Value.SetWideString ( clientID );
  FRegisterCheckCommand.Parameters[1].Value.SetWideString ( callbackID );
  FRegisterCheckCommand.ExecuteUpdate;
  Result:= FRegisterCheckCommand.Parameters[2].Value.GetWideString;
end;

function TServerMethods1Client.Result_DS ( Value: OleVariant ): string;
begin
  if FResult_DSCommand = nil then
    begin
      FResult_DSCommand            := FDBXConnection.CreateCommand;
      FResult_DSCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FResult_DSCommand.Text       := 'TServerMethods1.Result_DS';
      FResult_DSCommand.Prepare;
    end;
  FResult_DSCommand.Parameters[0].Value.AsVariant:= Value;
  FResult_DSCommand.ExecuteUpdate;
  Result:= FResult_DSCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.ResultDS ( Value: TDataSet ): string;
begin
  if FResultDSCommand = nil then
    begin
      FResultDSCommand            := FDBXConnection.CreateCommand;
      FResultDSCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FResultDSCommand.Text       := 'TServerMethods1.ResultDS';
      FResultDSCommand.Prepare;
    end;
  FResultDSCommand.Parameters[0].Value.SetDBXReader ( TDBXDataSetReader.Create( Value, FInstanceOwner ), True );
  FResultDSCommand.ExecuteUpdate;
  Result:= FResultDSCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.ResultMetaDSA ( Value: TDataSet ): TJSONArray;
begin
  if FResultMetaDSACommand = nil then
    begin
      FResultMetaDSACommand            := FDBXConnection.CreateCommand;
      FResultMetaDSACommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FResultMetaDSACommand.Text       := 'TServerMethods1.ResultMetaDSA';
      FResultMetaDSACommand.Prepare;
    end;
  FResultMetaDSACommand.Parameters[0].Value.SetDBXReader ( TDBXDataSetReader.Create( Value, FInstanceOwner ), True );
  FResultMetaDSACommand.ExecuteUpdate;
  Result:= TJSONArray ( FResultMetaDSACommand.Parameters[1].Value.GetJSONValue( FInstanceOwner ));
end;

function TServerMethods1Client.ResultDataDSA ( Value: TDataSet ): TJSONArray;
begin
  if FResultDataDSACommand = nil then
    begin
      FResultDataDSACommand            := FDBXConnection.CreateCommand;
      FResultDataDSACommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FResultDataDSACommand.Text       := 'TServerMethods1.ResultDataDSA';
      FResultDataDSACommand.Prepare;
    end;
  FResultDataDSACommand.Parameters[0].Value.SetDBXReader ( TDBXDataSetReader.Create( Value, FInstanceOwner ), True );
  FResultDataDSACommand.ExecuteUpdate;
  Result:= TJSONArray ( FResultDataDSACommand.Parameters[1].Value.GetJSONValue( FInstanceOwner ));
end;

function TServerMethods1Client.ResultJDS ( Value: TFDJSONDataSets ): string;
begin
  if FResultJDSCommand = nil then
    begin
      FResultJDSCommand            := FDBXConnection.CreateCommand;
      FResultJDSCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FResultJDSCommand.Text       := 'TServerMethods1.ResultJDS';
      FResultJDSCommand.Prepare;
    end;
  if not Assigned ( Value ) then
    FResultJDSCommand.Parameters[0].Value.SetNull
  else
    begin
      FMarshal:= TDBXClientCommand ( FResultJDSCommand.Parameters[0].ConnectionHandler ).GetJSONMarshaler;
      try
        FResultJDSCommand.Parameters[0].Value.SetJSONValue ( FMarshal.Marshal( Value ), True );
        if FInstanceOwner then
          Value.Free
      finally
        FreeAndNil ( FMarshal )
      end
    end;
  FResultJDSCommand.ExecuteUpdate;
  Result:= FResultJDSCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.ResultJArray ( Value: TJSONArray ): string;
begin
  if FResultJArrayCommand = nil then
    begin
      FResultJArrayCommand            := FDBXConnection.CreateCommand;
      FResultJArrayCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FResultJArrayCommand.Text       := 'TServerMethods1.ResultJArray';
      FResultJArrayCommand.Prepare;
    end;
  FResultJArrayCommand.Parameters[0].Value.SetJSONValue ( Value, FInstanceOwner );
  FResultJArrayCommand.ExecuteUpdate;
  Result:= FResultJArrayCommand.Parameters[1].Value.GetWideString;
end;

function TServerMethods1Client.RoundTripTime ( Value: Int64 ): Int64;
begin
  if FRoundTripTimeCommand = nil then
    begin
      FRoundTripTimeCommand            := FDBXConnection.CreateCommand;
      FRoundTripTimeCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FRoundTripTimeCommand.Text       := 'TServerMethods1.RoundTripTime';
      FRoundTripTimeCommand.Prepare;
    end;
  FRoundTripTimeCommand.Parameters[0].Value.SetInt64 ( Value );
  FRoundTripTimeCommand.ExecuteUpdate;
  Result:= FRoundTripTimeCommand.Parameters[1].Value.GetInt64;
end;

function TServerMethods1Client.ShutDownNotice ( Value: string ): string;
begin
  if FShutDownNoticeCommand = nil then
    begin
      FShutDownNoticeCommand            := FDBXConnection.CreateCommand;
      FShutDownNoticeCommand.CommandType:= TDBXCommandTypes.DSServerMethod;
      FShutDownNoticeCommand.Text       := 'TServerMethods1.ShutDownNotice';
      FShutDownNoticeCommand.Prepare;
    end;
  FShutDownNoticeCommand.Parameters[0].Value.SetWideString ( Value );
  FShutDownNoticeCommand.ExecuteUpdate;
  Result:= FShutDownNoticeCommand.Parameters[1].Value.GetWideString;
end;

constructor TServerMethods1Client.Create ( ADBXConnection: TDBXConnection );
begin
  inherited Create ( ADBXConnection );
end;

constructor TServerMethods1Client.Create ( ADBXConnection: TDBXConnection; AInstanceOwner: Boolean );
begin
  inherited Create ( ADBXConnection, AInstanceOwner );
end;

destructor TServerMethods1Client.Destroy;
begin
  FEchoStringCommand.DisposeOf;
  FReverseStringCommand.DisposeOf;
  FRegisterCheckCommand.DisposeOf;
  FResult_DSCommand.DisposeOf;
  FResultDSCommand.DisposeOf;
  FResultMetaDSACommand.DisposeOf;
  FResultDataDSACommand.DisposeOf;
  FResultJDSCommand.DisposeOf;
  FResultJArrayCommand.DisposeOf;
  FRoundTripTimeCommand.DisposeOf;
  FShutDownNoticeCommand.DisposeOf;
  inherited;
end;

end.
