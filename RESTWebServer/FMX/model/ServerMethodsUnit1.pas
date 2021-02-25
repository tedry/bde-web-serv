unit ServerMethodsUnit1;

{$DEFINE DATA_EOF_BUG} // We still have this bug where EOF dose not reset on Value.Next; See in ResultDS() below

{$DEFINE Debug2}

interface

uses
  c_u_ProducersConsumersSync,
  ServerContainerUnit1,
  System.Classes,
  System.Messaging,
  System.SysUtils,
  System.Threading, // Future suport
  System.Types,
  System.JSON,
  System.JSON.Types,
  System.JSON.Readers,
  Data.DB,
  Data.FireDACJSONReflect,
  Datasnap.DSAuth, // Allows attaching the TRoleAuth custom attributes to the server class methods.
  Datasnap.DSCommonServer,
  Datasnap.DSSession,
  Datasnap.DSProviderDataModuleAdapter,
  Datasnap.DSServer,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.FMXUI.Wait,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  Datasnap.DBClient;

type

{$TYPEINFO ON}
{$METHODINFO ON}

  TByteSet = set of byte;

  TServerMethods1 = class( TDSServerModule )
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    DataSource1: TDataSource;
    FDMemTable1: TFDMemTable;
    private
      FResult_DS: string; // our global result code for Result_DS() ie. Connector callbacks
      FDataSet:   TDataSet; // scope is for the lifetime of the Connector

{$IFNDEF DATA_EOF_BUG} // If we ever get the bug fixed for ResultDS(), We can use the JSONAArray's like this

      FJArrayMeta: TJSONArray;
      FJArrayData: TJSONArray;

{$ENDIF DATA_EOF_BUG}
{$IFDEF NOTUSEDYET}

      // FRegisterIn: TStringList;
      FJArray: TJSONArray;
      function ResultDSA( Value: TDataSet ): TJSONArray;

{$ENDIF NOTUSEDYET}

      function GetSessionPassWord: string;
      function ParseJSON( const sin: string; const return_types: TJsonToken; const inx: TByteSet;
        const _name: string = ''; const delm: string = '|' ): string;
    protected
    public
      { Public declarations }
      //
      // NOTE: Custom attributes is a language feature..., like this: [TAType( 'someStringProp' )]
      // Here we can control what attributes are required to access using TRoleAuth.
      // See TWebModule1.DSAuthenticationManager1UserAuthenticate for where TRoleAuth is checked.
      // If the user roles is not aval then an "error":"{UserName} is not authorized to perform the requested action." is generated
      // from the code check in DSAuthenticationManager1UserAuthenticate.
      //
      [TRoleAuth( 'standard' )]
      function RegisterCheck( const clientID: string; const callbackID: string; sPrefetchList: string ): string;

      [TRoleAuth( 'standard' )]
      function FreshenCache( const clientID: string; const callbackID: string; sPrefetchList: string ): string;

      [TRoleAuth( 'NOstandard' )]
      function LocalDBCaheQueryAsString( const SQL, sGUID: string ): string;

      [TRoleAuth( 'NOstandard' )]
      function DoMyPreFetchs( const sList: TStringList ): string;

      [TRoleAuth( 'standard' )]
      function EchoString( Value: string ): string;

      [TRoleAuth( 'standard' )]
      function ReverseString( Value: string ): string;

      [TRoleAuth( 'standard' )]
      function GetUserName: string;

      [TRoleAuth( 'standard' )]
      procedure SetGUIDSessionID( sGUID: string );

      [TRoleAuth( 'standard' )]
      function GetGUID: string;

      [TRoleAuth( 'standard' )]
      function Client_ID: string;

      [TRoleAuth( 'standard' )]
      function Result_User( const User: string; const PW: TBytes ): string;

      [TRoleAuth( 'standard' )]
      function Result_DS( Value: OleVariant ): string;

      [TRoleAuth( 'standard' )]
      function QueryRemoteWebConnectorDS( aquery: string ): string;

      [TRoleAuth( 'standard' )]
      function ResultDS( Value: TDataSet ): string;

      [TRoleAuth( 'standard' )]
      function DataTables( Value: TDataSet; var n: integer ): TJSONObject;

      [TRoleAuth( 'standard' )]
      function Meta( Value: TDataSet ): TJSONArray;

      [TRoleAuth( 'standard' )]
      function Data( Value: TDataSet ): TJSONArray;

      [TRoleAuth( 'standard' )]
      function ResultJDS( Value: TFDJSONDataSets ): string;

      [TRoleAuth( 'standard' )]
      function ResultJArray( Value: TJSONArray ): string;

      [TRoleAuth( 'admin' )]
      function RoundTripTime( Value: int64 ): int64;

      [TRoleAuth( 'standard' )]
      function ShutDownNotice( Value: string ): string;

      [TRoleAuth( 'standard' )]
      function sRunQuery( s: string; sGUID: string = '' ): string;

      [TRoleAuth( 'standard' )]
      function aegGetClasses: string;

      [TRoleAuth( 'standard' )]
      function aegGetFamilyInfo: string;

      [TRoleAuth( 'standard' )]
      function aegGetAutoPayInfo: string;

      [TRoleAuth( 'standard' )]
      function aegGetMyStudents: string;

      [TRoleAuth( 'standard' )]
      function aegGetStudentsDetail( aStudent_ID: string ): string;

      [TRoleAuth( 'standard' )]
      function aegChangePassword( aOldpw, aNewpw: string ): string;

      [TRoleAuth( 'standard' )]
      function SearchClassQuery( const student_id, time, studentAge, gender, level, classType: string;
        const sun, mon, tue, wed, thr, fri, sat: boolean; clusive: string ): string;

      [TRoleAuth( 'standard' )]
      function aegEnrollStudent( Class_Code, student_id, aClient_ID, Teacher_Code, Tuition_Code, Entered_By, SunTime,
        MonTime, TueTime, WedTime, ThrTime, FriTime, SatTime: string ): string;

      [TRoleAuth( 'standard' )]
      function aegCharges: string;

      [TRoleAuth( 'standard' )]
      function aegPayments: string;

      [TRoleAuth( 'standard' )]
      function aegBalDue: string;

      [TRoleAuth( 'standard' )]
      function aegBalDueTotal: string;

      [TRoleAuth( 'standard' )]
      function aegMakePayment( Amount: string ): string;

      [TRoleAuth( 'standard' )]
      function aegMakeItemizedPayment( Amount: string ): string;

      [TRoleAuth( 'standard' )]
      function aegGetClassLvl: string;

      [TRoleAuth( 'standard' )]
      function aegGetClassType: string;

      [TRoleAuth( 'standard' )]
      function aegGymName: string;

      [TRoleAuth( 'standard' )]
      function aegGymAddress: string;

      [TRoleAuth( 'standard' )]
      function aegGymEmail: string;

  end;

function sIndex( const aString: string; const aCases: array of string; const aCaseSensitive: boolean = true ): integer;

{$METHODINFO OFF}

const
  cERRORVAL = '!ERROR'; // This is used to check for errors from the connector

var
  ServerMethods: TServerMethods1;
  FJObj:         TJSONObject;
  FRecs:         integer;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

uses
  FormUnit1,
  u_MessageMgr,
  System.StrUtils;

const
  sOK               = 'Ok';
  sNOT              = 'No';
  FIXED_CALLBACK_ID = '000000.000000.032218';
  CALLBACK_ID       = FIXED_CALLBACK_ID;

var
  _Count:     integer; // Control the max Semaphore count in ProducersConsumersSync
  _msTimeOut: integer = {$IFDEF DEBUG} 6000000 {$ELSE} 6000 {$ENDIF};

  // -------------------------------------------------------------------------------------------------------------------------------
function sIndex( const aString: string; const aCases: array of string; const aCaseSensitive: boolean = true ): integer;
begin
  if aCaseSensitive then
    begin
      for result := 0 to Pred( Length( aCases )) do
        if ANSISameText( aString, aCases[result]) then
          exit;
    end
  else
    begin
      for result := 0 to Pred( Length( aCases )) do
        if ANSISameStr( aString, aCases[result]) then
          exit;
    end;
  result := - 1;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function RecordCount( Value: TDataSet ): integer;
begin
  result := 0;
  while not Value.Eof do
    begin
      inc( result );
      Value.Next;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function isValidPassWord( const aNewpw: string ): boolean;
begin
  result := true;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure EachSessionSearch( const Session: TDSSession );
var
  sGUID: string;
begin
  // This procedure will be called for each session in the TDSSessionManager
  if ( Session.GetData( 'GUID' ) <> '' ) and ( Session.UserName = 'user' ) then
    sGUID := Session.GetData( 'GUID' );
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.ParseJSON( const sin: string; const return_types: TJsonToken; const inx: TByteSet;
  const _name: string = ''; const delm: string = '|' ): string;
// Passing the JSON string and the TJsonToken type(s) you want it will return a string of them.
// NOTE: If pass an _name it will try to match only on the return_types that are under the _name.
var
  LStringReader:   TStringReader;
  LJsonTextReader: TJsonTextReader;
  stmp:            string;
  isMatching:      boolean;
  i:               integer;

begin
  i               := 0;
  isMatching      := false;
  LStringReader   := TStringReader.Create( sin );
  LJsonTextReader := TJsonTextReader.Create( LStringReader );
  while LJsonTextReader.Read do
    begin
      case LJsonTextReader.TokenType of
        TJsonToken.None:
          ;
        TJsonToken.StartObject:
          ;
        TJsonToken.StartArray:
          ;
        TJsonToken.StartConstructor:
          ;
        TJsonToken.PropertyName:
          if not isMatching then
            isMatching := ( _name = LJsonTextReader.Value.AsString );
        TJsonToken.Comment:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Raw:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Integer:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Float:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.String:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Boolean:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Null:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Undefined:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.EndObject:
          isMatching := false;
        TJsonToken.EndArray:
          isMatching := false;
        TJsonToken.EndConstructor:
          isMatching := false;
        TJsonToken.Date:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Bytes:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.Oid:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.RegEx:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.DBRef:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.CodeWScope:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.MinKey:
          stmp := LJsonTextReader.Value.AsString;
        TJsonToken.MaxKey:
          stmp := LJsonTextReader.Value.AsString;
      end;
      if ( LJsonTextReader.TokenType in[return_types]) and isMatching then
        begin
          if ( stmp <> '' ) and ( i in inx ) then
            result := result + stmp + delm;
          inc( i );
        end;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function sParseRec( var sJSON: string; const sDelm: string = '|' ): string;
var
  i: integer;
begin
  i := Pos( '|', sJSON );
  if ( i > 0 ) then
    begin
      result := Copy( sJSON, 1, i - 1 );
      Delete( sJSON, 1, i );
    end
  else
    result := sJSON;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.RegisterCheck( const clientID: string; const callbackID: string;
  sPrefetchList: string ): string;
// Called by Client 'Connectors' when they 1st startup in main.ShowForm(), checks if this clientID is registered in the Db.
// NOTE: All of the data in sPrefetchList was already escaped in the connector when it created the string using its TJSONObject.ToString()
var
  Session: TDSSession;
  s:       string;
  // -- Prefetch --
  sGymName:    string;
  sGymAddress: string;
  sGymEmail:   string;
  sClassLvl:   string;
  sClasType:   string;
  sClasses:    string;
begin
  result := cERRORVAL;
  // This is called before any Web activity, ie. called when a Connector 1st connects to the server on the backchannel TCP/IP DS port.
  // 1st/earlest chanch to get a Session for this DSnap channel. NOTE: This is NOT a Web 'dsessionid' ie. same for all Web users of this GUID.
  Session := TDSSessionManager.GetThreadSession;
  if ( Session <> nil ) then
    begin
      if clientID <> '' then
        Session.PutData( 'GUID', clientID ); // Save our 'connector' path ie. back-channel GUID
      if callbackID <> '' then
        Session.PutData( 'callbackID', callbackID );
      // {$ifdef Debug}
      // i:= TMessageManager.DefaultManager.SubscribeToMessage(TMessage<UnicodeString>, DoMyPreFetchs);
      // Session.PutData('MsgMgrID', i.ToString);
      // {$endif Debug}
    end;

  // The 'Connector' provides all of the prefetch stuff that we need for later, here we parse & save it into the servers DB for quick access latter.
  s        := sParseRec( sPrefetchList, '|' );
  sGymName := ParseJSON( s, TJsonToken.String, [0], 'Name', '' );

  s := sParseRec( sPrefetchList, '|' );
  // '{"Address1":"11345 Folsom Blvd.","City":"Rancho Cordova","State":"CA","Zip":"95742-6224","Phone":"(916) 635-7900","EmailFrom":"info@techniquegym.com"}'
  sGymAddress := ParseJSON( s, TJsonToken.String, [0], 'Address1', '' ) + ' ' + ParseJSON( s, TJsonToken.String, [0],
    'City', '' ) + ', ' + ParseJSON( s, TJsonToken.String, [0], 'State', '' ) + ' ' +
    ParseJSON( s, TJsonToken.String, [0], 'Zip', '' ) + ' | ' + ParseJSON( s, TJsonToken.String, [0], 'Phone', '' );
  sGymEmail := ParseJSON( s, TJsonToken.String, [0], 'EmailFrom', '' );

  sClassLvl := sParseRec( sPrefetchList, '|' );
  sClasType := sParseRec( sPrefetchList, '|' );
  sClasses  := sParseRec( sPrefetchList, '|' );

  ServerContainer.FDQuery2.Active   := false;
  ServerContainer.FDQuery2.SQL.Text := 'select * from RegisteredClients where ClientID= :ID';
  ServerContainer.FDQuery2.Params.ParamByName( 'ID' ).AsString := clientID;
  ServerContainer.FDQuery2.Active := true;
  if ServerContainer.FDQuery2.RowsAffected = 0 then // we are adding a new client by GUID
    begin
      // Add the new client by ID, the code set ClientEnabled=0 normaly, if Debug mode the GUID is enabled with ClientEnabled=1
      if FormUnit1.FormMain.chk_AutoInsert.isChecked then
        begin
          ServerContainer.InsertClient( ServerContainer.FDQuery2, clientID, callbackID, sGymName, sGymAddress,
            sGymEmail, sClassLvl, sClasType, sClasses );

{$IFDEF Debug}                                   // special handling if we are Debug mode

          result := FormUnit1.FormMain.WebServerPort; // Pass back the web-server-port or '-1';

{$ELSE}

          result := sNOT;
          // Normaly Pass back to the calling connector that although added your are NOT yet Enabled in the system.

{$ENDIF Debug}

        end
      else
        begin
          gMsgHandler.PostMessage( 'Log AutoInsert Disabled Rejected Insert for GUID ' + clientID + '=' + callbackID );
          result := sNOT;
          exit;
        end;
    end
  else // We found a matching client ID
    begin
      if ServerContainer.FDQuery2.FieldByName( 'ClientEnabled' ).AsString = '1' then
        result := FormUnit1.FormMain.WebServerPort // Pass back the web-server-port or '-1';
      else
        result := sNOT;
      // Pass back to the calling connector that although added your are NOT yet Enabled in the system.
      ServerContainer.UpdatedClient( ServerContainer.FDQuery2, clientID, callbackID, sGymName, sGymAddress, sGymEmail,
        sClassLvl, sClasType, sClasses );
    end;
  ServerContainer.FDQuery1.Refresh; // or Table for the GUI
  gMsgHandler.PostMessage( 'GUID' + clientID + '=' + callbackID );
  gMsgHandler.PostMessage( 'Log' + clientID + ' connected with web-port of ' + result + ' returned.');
end;

function TServerMethods1.FreshenCache( const clientID: string; const callbackID: string;
  sPrefetchList: string ): string;
var
  Session: TDSSession;
  s:       string;
  // -- Prefetch --
  sGymName:    string;
  sGymAddress: string;
  sGymEmail:   string;
  sClassLvl:   string;
  sClasType:   string;
  sClasses:    string;
begin
  result := cERRORVAL;
  // This is called before any Web activity, ie. called when a Connector 1st connects to the server on the backchannel TCP/IP DS port.
  // 1st/earlest chanch to get a Session for this DSnap channel. NOTE: This is NOT a Web 'dsessionid' ie. same for all Web users of this GUID.
  Session := TDSSessionManager.GetThreadSession;
  if ( Session <> nil ) then
    begin
      if clientID <> '' then
        Session.PutData( 'GUID', clientID ); // Save our 'connector' path ie. back-channel GUID
      if callbackID <> '' then
        Session.PutData( 'callbackID', callbackID );
      // {$ifdef Debug}
      // i:= TMessageManager.DefaultManager.SubscribeToMessage(TMessage<UnicodeString>, DoMyPreFetchs);
      // Session.PutData('MsgMgrID', i.ToString);
      // {$endif Debug}
    end;

  // The 'Connector' provides all of the prefetch stuff that we need for later, here we parse & save it into the servers DB for quick access latter.
  s        := sParseRec( sPrefetchList, '|' );
  sGymName := ParseJSON( s, TJsonToken.String, [0], 'Name', '' );

  s := sParseRec( sPrefetchList, '|' );
  // '{"Address1":"11345 Folsom Blvd.","City":"Rancho Cordova","State":"CA","Zip":"95742-6224","Phone":"(916) 635-7900","EmailFrom":"info@techniquegym.com"}'
  sGymAddress := ParseJSON( s, TJsonToken.String, [0], 'Address1', '' ) + ' ' + ParseJSON( s, TJsonToken.String, [0],
    'City', '' ) + ', ' + ParseJSON( s, TJsonToken.String, [0], 'State', '' ) + ' ' +
    ParseJSON( s, TJsonToken.String, [0], 'Zip', '' ) + ' | ' + ParseJSON( s, TJsonToken.String, [0], 'Phone', '' );
  sGymEmail := ParseJSON( s, TJsonToken.String, [0], 'EmailFrom', '' );

  sClassLvl := sParseRec( sPrefetchList, '|' );
  sClasType := sParseRec( sPrefetchList, '|' );
  sClasses  := sParseRec( sPrefetchList, '|' );

  ServerContainer.FDQuery2.Active   := false;
  ServerContainer.FDQuery2.SQL.Text := 'select * from RegisteredClients where ClientID= :ID';
  ServerContainer.FDQuery2.Params.ParamByName( 'ID' ).AsString := clientID;
  ServerContainer.FDQuery2.Active := true;
  if ServerContainer.FDQuery2.RowsAffected = 0 then // we dont have this client by GUID so error
    result := sNOT
  else // We found a matching client ID
    begin
      ServerContainer.UpdatedClient( ServerContainer.FDQuery2, clientID, callbackID, sGymName, sGymAddress, sGymEmail,
        sClassLvl, sClasType, sClasses );
      ServerContainer.FDQuery1.Refresh; // or Table for the GUI
      result := sOK;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.LocalDBCaheQueryAsString( const SQL: string; const sGUID: string ): string;
// Here we are pulling from just the local DB Cahe, NOT going over the back-channel to get the same old data again and again...
var
  Query:   TFDQuery;
  ColName: string;
  i:       integer;
begin
  result := '';
  try
    Query            := TFDQuery.Create( self );
    Query.Connection := ServerContainer.FDConnection1;
    Query.Active     := false;
    Query.SQL.Add( SQL );
    Query.Params.ParamByName( 'ID' ).AsString := sGUID;
    Query.Active                              := true;
    Query.FetchAll;
    i := Query.RowsAffected;
    if ( i > 0 ) then
      begin
        Query.BeginBatch; // Don't update external references until EndBatch;
        Query.First;
        while ( not Query.Eof ) do
          begin
            for i := 0 to Query.FieldDefs.Count - 1 do
              begin
                ColName := Query.FieldDefs[i].Name;
                result  := result + Query.FieldByName( ColName ).AsString;
                Query.Next;
              end;
          end;
        Query.EndBatch;
      end
    else
      result := 'NONE'; // Nothing under that GUID found localy hum...
    Query.Free;
  except
    //
  end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.DoMyPreFetchs( const sList: TStringList ): string;
var
  sLine: string;
  s:     string;
begin
  // s  := (M as TMessage<UnicodeString>).Value;
  // sID:= Copy(s, Pos(':', s)+ 1, Length(s));
  for sLine in sList do
    begin
      s := ParseJSON( sLine, TJsonToken.String, [0], 'aaData', '' );
    end;
  result := sOK;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.EchoString( Value: string ): string;

{$IFDEF Debug2}

var
  Session: TDSSession;
  // i      : integer;
  s: string;

{$ENDIF Debug2}

begin
  result := Value;

{$IFDEF Debug2}

  Session := TDSSessionManager.GetThreadSession;
  if Assigned( Session ) then
    begin
      // i:= TDSSessionManager.Instance.GetSessionCount;
      if Session.HasData( 'GUID' ) then
        s := Session.GetData( 'GUID' );
      if Session.HasData( 'callbackID' ) then
        s := Session.GetData( 'callbackID' );
      if s <> '' then
        result := s;
    end;

{$ENDIF Debug2}

end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.ReverseString( Value: string ): string;
begin
  result := System.StrUtils.ReverseString( Value );
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.GetUserName: string;
var
  Session: TDSSession;
begin
  Session := TDSSessionManager.GetThreadSession;
  if ( Session <> nil ) then
    result := Session.GetData( 'username' ) + ':' + Session.UserName
  else
    result := '';
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerMethods1.SetGUIDSessionID( sGUID: string );
var
  Session: TDSSession;
begin
  if ( sGUID <> '' ) then
    begin
      Session := TDSSessionManager.GetThreadSession;
      if ( Session <> nil ) then
        Session.PutData( 'GUID', sGUID );
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.GetGUID: string;
var
  Session: TDSSession;
begin
  Session := TDSSessionManager.GetThreadSession;
  if ( Session <> nil ) then
    result := Session.GetData( 'GUID' )
  else
    result := '';
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.GetSessionPassWord: string;
var
  Session: TDSSession;
begin
  Session := TDSSessionManager.GetThreadSession;
  if ( Session <> nil ) then
    result := Session.GetData( 'pw' )
  else
    result := '';
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.Client_ID: string;
var
  Session: TDSSession;
begin
  Session := TDSSessionManager.GetThreadSession;
  if ( Session <> nil ) then
    result := Session.GetData( 'Client_ID' )
  else
    result := '';
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.Result_User( const User: string; const PW: TBytes ): string;
begin
  //
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.QueryRemoteWebConnectorDS( aquery: string ): string;
var
  Session: TDSSession;
  s:       string;
begin
  Session := TDSSessionManager.GetThreadSession; // access the current session
  s       := Session.GetData( 'GUID' );
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.ResultDS( Value: TDataSet ): string;
// A WebConnector client is calling in with results from a prevous query.

{$WARN CONSTRUCTING_ABSTRACT OFF} // NOTE: Data.DB has 4 virtual; abstract; methods so they don't exist! just FYI; See below fix:

// http://docwiki.embarcadero.com/RADStudio/Tokyo/en/X1020_Constructing_instance_of_%27%25s%27_containing_abstract_method_%27%25s.%25s%27_(Delphi)
var
  n: integer;
begin

{$IFDEF DATA_EOF_BUG}

  // get JSON structure, including both data (aaData, an array of arrays) and metadata (aoColumns, an array of objects describing
  // the column titles & formatting style).
  FJObj := DataTables( Value, n );
  FRecs := n;

{$ELSE}

  FJArrayMeta := Meta( Value ); // new arr
  FJArrayData := Data( Value ); // new array
  // get JSON structure, including both data (aaData, an array of arrays) and metadata (aoColumns, an array of objects describing
  // the column titles & formatting style).
  // FJObj:= DataTables ( Value, n );

{$ENDIF DATA_EOF_BUG}

  if not Assigned( FDataSet ) then
    FDataSet := TDataSet.Create( self ); // Scope of 'FDataSet' is for the lifetime of the Connector
  FDataSet   := Value;

  result := FJObj.ToString;

  c_SyncObj.StopProducing; // signal the consumer this data is ready, FHasData
end;

{$WARN CONSTRUCTING_ABSTRACT ON}

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.Result_DS( Value: OleVariant ): string;
// WebConnector calling back with an OleVariant, typical for a 'query-out' or EXECsql() called in the connector.
begin
  // We can support a bunch of different results and operations so look at the Vaule as a string and scan to know.
  // ex: Valule = 'EXECSQL,OK,ROWS:1' or Value = 'EXECSQL,ERROR,ROWS:10'
  result := Variant( Value ); // Typecast back to a local Variant and return it.
  if ( Pos( 'ERROR', result )) <> 0 then
    begin
      FResult_DS := sNOT;
    end
  else
    FResult_DS := sOK;

  c_SyncObj.StopProducing; // signal the consumer this data is ready, FHasData
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.DataTables( Value: TDataSet; var n: integer ): TJSONObject;
var
  dataArray: TJSONArray;
  subArray:  TJSONArray;
  metaArray: TJSONArray;
  i:         integer;
begin
  // populate the data array
  dataArray := TJSONArray.Create;
  while not Value.Eof do
    begin
      subArray := TJSONArray.Create;

      for i := 0 to Value.FieldCount - 1 do
        subArray.Add( Value.Fields[i].AsString );

      dataArray.AddElement( subArray );
      inc( n );
      Value.Next;
    end;
  Value.First;

  // populate the meta array
  metaArray := TJSONArray.Create;
  for i := 0 to Value.FieldDefs.Count - 1 do
    begin
      metaArray.Add( TJSONObject.Create( TJSONPair.Create( 'sTitle', Value.FieldDefs[i].Name )));
    end;

  result := TJSONObject.Create;
  result.AddPair( TJSONPair.Create( 'aaData', dataArray ));
  result.AddPair( TJSONPair.Create( 'aoColumns', metaArray ));
end;

// -------------------------------------------------------------------------------------------------------------------------------

{$IFDEF NOTUSEDYET}

function TServerMethods1.ResultDSA( Value: TDataSet ): TJSONArray;
begin
  result := nil;
end;

{$ENDIF NOTUSEDYET}

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.Meta( Value: TDataSet ): TJSONArray;
var
  i: integer;
begin
  result := TJSONArray.Create; // new array
  for i  := 0 to Value.FieldDefs.Count - 1 do
    result.Add( Value.FieldDefs[i].Name );
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.Data( Value: TDataSet ): TJSONArray;
var
  i:    integer;
  jObj: TJSONObject;
begin
  result := TJSONArray.Create; // new array
  while not Value.Eof do
    begin
      jObj  := TJSONObject.Create;
      for i := 0 to Value.FieldCount - 1 do
        jObj.AddPair( Value.Fields[i].FieldName, TJSONString.Create( Value.Fields[i].AsString ));
      result.AddElement( jObj );
      Value.Next;
    end;
  Value.First;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.ResultJDS( Value: TFDJSONDataSets ): string;
begin
  FDMemTable1.Close;
  FDMemTable1.AppendData( TFDJSONDataSetsReader.GetListValue( Value, 0 ));
  FDMemTable1.Open;
  result := sOK;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.ResultJArray( Value: TJSONArray ): string;
var
  s: string;
begin
  s := Value.ToString;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.RoundTripTime( Value: int64 ): int64;
begin
  result := 0; { TODO -oScott -cShouldDo : Need to implement the calcs }
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.ShutDownNotice( Value: string ): string;
// WebConnectors call this if shutting down nicely user/soft reboot etc, we don't get this if it's going down hard.
begin
  Value := 'GUID delete ' + Value; // Add the Target and action in front of msg for processing in OnMessage Handler
  gMsgHandler.PostMessage( Value );
  result := sOK;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.sRunQuery( s: string; sGUID: string = '' ): string;
var
  sCallBack:   string;
  aMsg:        TJSONValue;
  aResponse:   TJSONValue;
  aCallResult: boolean;
begin
  sCallBack := CALLBACK_ID;

  if ( sGUID = '' ) then
    sGUID := GetGUID; // Point at the correct WebConnector

  if ( sGUID <> '' ) then
    begin
      aMsg        := TJSONString.Create( s );
      aCallResult := DSServer.NotifyCallback( sGUID, sCallBack, aMsg, aResponse, _msTimeOut );
      // synchronous to a callback
      if aCallResult then
        result := TJSONString( aResponse ).Value // result can containe errors from connector side SQL processing
      else
        result := 'Network ' + cERRORVAL; // NotifyCallback() error ie. Network issues
    end
  else
    result := 'NO-Session ' + cERRORVAL; // NO Session
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGetClasses: string;
begin
  { TODO 2 -oScott -cShouldDo : Verify this query is correct. There may be need to add more conditions to the query. }
  result := sRunQuery
    ( 'query-in Select name, type, sunday, monday, tuesday, wednesday, thursday, friday, saturday from Classes' );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGetFamilyInfo: string;
var
  sQuery: string;
begin
  sQuery := 'query-in ' + 'SELECT ' +
    'Cl.Sort_first, Cl.Sort_Last, Cl.Email, Cl.Home_Phone, Cl.Address1, Cl.City, Cl.State, Cl.Zip, ' + '(' +
    ' SELECT SUM(Ch.Balance)' + ' FROM Charges Ch' + ' WHERE (Ch.Balance > 0) and Ch.Client_ID = ' +
    QuotedStr( Client_ID ) + ' ' + ') as Total_Balance, ' + '(' + ' SELECT SUM(Ch.Amount)' + ' FROM Charges Ch' +
    ' WHERE Ch.Client_ID = ' + QuotedStr( Client_ID ) + ' ' + ') as Total_Charges, ' + '(' + ' SELECT SUM(Pa.Amount)' +
    ' FROM Payments Pa' + ' WHERE Pa.Client_ID = ' + QuotedStr( Client_ID ) + ' ' + ') as Total_Payments, ' +
    'Total_Payments - Total_Charges as Credit, ' + 'Total_Balance - Credit as Adjusted_Balance, ' + '(' +
    ' SELECT Payment_Date ' + ' FROM Payments ' +
    ' WHERE Payment_ID = (SELECT MAX(Payment_ID) FROM Payments WHERE Client_ID = ' + QuotedStr( Client_ID ) + ')' +
    ') as Payment_Date,' + '(' + ' SELECT Amount ' + ' FROM Payments ' +
    ' WHERE Payment_ID = (SELECT MAX(Payment_ID) FROM Payments WHERE Client_ID = ' + QuotedStr( Client_ID ) + ')' +
    ') as Amount' + ' FROM ' + 'Clients Cl ' + 'WHERE ' + 'Cl.Client_ID = ' + QuotedStr( Client_ID ) + ';';

  result := sRunQuery( sQuery );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGetAutoPayInfo: string;
begin
  result := sRunQuery
    ( 'query-in SELECT ExpDate, CardName, CardAddr, CardCity, CardState, CardZip, PassCardType, PassCardNum' +
    ' FROM AutoPay ' + 'WHERE Client_ID = ' + QuotedStr( Client_ID ));
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGetMyStudents: string;
begin
  result := sRunQuery
    ( 'query-in Select Student_ID, First_Name, Last_Name, Birthdate, Sex, Date_Registered, Date_Quit from Students where Client_ID = '
    + QuotedStr( Client_ID ));
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGetClassLvl: string;
begin
  result := sRunQuery( 'query-in Select Code, Description from ClassLvl' );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGetClassType: string;
begin
  result := sRunQuery( 'query-in Select Code, Description from ClasType' );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGymName: string;
begin
  result := sRunQuery( 'query-in Select Name from Config' );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGymAddress: string;
begin
  result := sRunQuery( 'query-in Select Address1, City, State, Zip, Phone from Config' );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGymEmail: string;
begin
  result := sRunQuery( 'query-in Select EmailFrom from Config' );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegGetStudentsDetail( aStudent_ID: string ): string;
var
  s: string;
begin
  s := 'Select En.Class_Code as Code, Cl.Name as Class, En.Start_Date as Start, Te.Name as Teacher, St.Birthdate, St.Sex '
    + 'From Enroll En, Classes Cl, Teacher Te, Students St Where En.Class_code = Cl.Code And En.Teacher_Code = Te.Code '
    + 'And En.Student_ID = St.Student_ID and St.Student_ID = ' + aStudent_ID;
  { TODO 2 -oScott -cMustDo : Need to add tuition cost from tuition. Type in Tuition: M = Monthly, S = Session, H = Hourly, W = Weekly. Simular 1 from Tuition db is the cost $ Value }
  result := sRunQuery( 'query-in ' + s );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
// 3. Allow the user to be able to change their password.
function TServerMethods1.aegChangePassword( aOldpw, aNewpw: string ): string;
var
  sCurrentPW: string;
  sQuery:     string;
begin
  result     := sNOT; // release the clients Browser
  sCurrentPW := GetSessionPassWord;
  if ( sCurrentPW <> '' ) then
    if ( sCurrentPW = aOldpw ) then
      begin
        sQuery := 'query-out UPDATE WebUsers SET Password=' + QuotedStr( aNewpw )+ ' where Client_ID=' +
          QuotedStr( Client_ID );
        result := sRunQuery( sQuery );
        if Pos( cERRORVAL, result ) = 0 then // We expect no 'ERROR' contained in result
          result := '0'                      // sOK
        else
          begin
            ServerContainer.SendMsg( GetGUID + ' ' + result );
            if Pos( 'Connector Disabled', result ) = 0 then
              result := '1' // SQL Exec error tyring to update password
            else
              result := '4'; // Recevied Connector Disabled
          end;
      end
    else
      result := '2' // '!ERROR - Orginal password does NOT match.'
  else
    result := '3' // '!ERROR - Must login before changing password.';
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.SearchClassQuery( const student_id, time, studentAge, gender, level, classType: string;
  const sun, mon, tue, wed, thr, fri, sat: boolean; clusive: string ): string;
var
  i:      integer;
  sQuery: string;
  sWhere: string;

begin
  { TODO 1 -oScott -cShould-Do : Add an order-by statment }
  // Items to consider
  // SkilLevels
  // Skills
  // StudentSkils

  sQuery := 'query-in SELECT Cl.Portal_Enrollable, Cl.Code, Cl.name, Cy.Description, Te.Code as Teacher_Code, Te.Name as Teacher, '
    + 'Cl.Tuition_Code, Cl.sunday, Cl.monday, Cl.tuesday, Cl.wednesday, Cl.thursday, Cl.friday, Cl.saturday, Cl.Su_Start_time, '
    + 'Cl.Mo_Start_Time, Cl.Tu_Start_Time, Cl.We_Start_Time, Cl.Th_Start_Time, Cl.Fr_Start_Time, Cl.Sa_Start_Time, Tu.Type, Tu.Similar1 '
    + 'FROM Classes Cl, Teacher Te, ClassTeachers Ct, ClasType Cy, Tuition Tu '; { TODO -oScott + Alex -cShouldDo :
    Add the Future Class info in select so we can have this added to the browser.
    Browser can then pass this back in when a class is select to enrole into. }

  sWhere := ' WHERE (Cl.Code = Ct.Class_Code) and (Ct.Teacher_Code = Te.Code) and (Cy.Code = Cl.Type) and (Cl.Portal_Visible = True) and (Cl.Tuition_Code = Tu.Code)';

  if ( sun ) then
    sWhere := sWhere + ' and (Cl.Sunday = True)'
  else
    if ( clusive = 'false' ) then
      sWhere := sWhere + ' and (Cl.Sunday = False)';

  if ( mon ) then
    sWhere := sWhere + ' and (Cl.Monday = True)'
  else
    if ( clusive = 'false' ) then
      sWhere := sWhere + ' and (Cl.Monday = False)';

  if ( tue ) then
    sWhere := sWhere + ' and (Cl.Tuesday = True)'
  else
    if ( clusive = 'false' ) then
      sWhere := sWhere + ' and (Cl.Tuesday = False)';

  if ( wed ) then
    sWhere := sWhere + ' and (Cl.Wednesday = True)'
  else
    if ( clusive = 'false' ) then
      sWhere := sWhere + ' and (Cl.Wednesday = False)';

  if ( thr ) then
    sWhere := sWhere + ' and (Cl.Thursday = True)'
  else
    if ( clusive = 'false' ) then
      sWhere := sWhere + ' and (Cl.Thursday = False)';

  if ( fri ) then
    sWhere := sWhere + ' and (Cl.Friday = True)'
  else
    if ( clusive = 'false' ) then
      sWhere := sWhere + ' and (Cl.Friday = False)';

  if ( sat ) then
    sWhere := sWhere + ' and (Cl.Saturday = True)'
  else
    if ( clusive = 'false' ) then
      sWhere := sWhere + ' and (Cl.Saturday = False)';

  case sIndex( studentAge,['', '0-1']) of
    0:          // BLANK
      i := - 1; // unset case
    1:          // '0-1'
      i := 1;   // use 1 always
    else
      i := studentAge.ToInteger( );
  end;

  if ( i > 0 ) then
    sWhere := sWhere + ' and (Cl.Min_Age <= ' + i.ToString + ')' + ' and (Cl.Max_Age >= ' + i.ToString + ')';

  case sIndex( gender,['Coed', 'Boy', 'Girl']) of
    0: // Coed
      sWhere := sWhere + ' and (Cl.Sex_Requirement = ' + QuotedStr( 'C' )+ ')';
    1: // Boy
      sWhere := sWhere + ' and (Cl.Sex_Requirement = ' + QuotedStr( 'M' )+ ')';
    2: // Girl
      sWhere := sWhere + ' and (Cl.Sex_Requirement = ' + QuotedStr( 'F' )+ ')';
  end;

  if ( level ) <> '' then
    sWhere := sWhere + ' and (Cl.Lvl = ' + QuotedStr( level )+ ')';

  if ( classType ) <> '' then
    sWhere := sWhere + ' and (Cl.Type = ' + QuotedStr( classType )+ ')';

  sQuery := sQuery + sWhere;
  result := sRunQuery( sQuery );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegEnrollStudent( Class_Code, student_id, aClient_ID, Teacher_Code, Tuition_Code, Entered_By,
  SunTime, MonTime, TueTime, WedTime, ThrTime, FriTime, SatTime: string ): string;
var
  sQuery: string;
begin
  if ( student_id <> '' ) and ( Class_Code <> '' ) then
    begin
      sQuery := 'query-out INSERT INTO Enroll (Class_Code, Student_ID, Client_ID, Start_Date, Teacher_Code, Tuition_Code, EnteredBy, EnteredOn, UpdatedBy, UpdatedOn, FutureClass) '
        + 'VALUES (' + QuotedStr( Class_Code )+ ',' + student_id + ', ' + QuotedStr( Client_ID ) + ', ' + '<#now>' +
        ', ' + QuotedStr( Teacher_Code ) + ', ' + QuotedStr( Tuition_Code ) + ', ' + QuotedStr( Entered_By ) + ', ' +
        '<#now>' + ', ' + QuotedStr( Entered_By ) + ', ' + '<#now>' + ', ' + 'FALSE' + ')';

      result := sRunQuery( sQuery );
      if Pos( cERRORVAL, result ) = 0 then // We expect no 'ERROR' contained in result
        result := sOK
      else
        begin
          ServerContainer.SendMsg( GetGUID + ' ' + result );
          // result := sNOT; // release the clients Browser
        end;
    end
  else
    begin
      ServerContainer.SendMsg( 'ERROR in aegEnrollStudent() ID or Class_Code not valid.' );
      result := cERRORVAL + ' missing Student ID or Classcode'; // release the clients Browser
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegCharges: string;
var
  sQuery: string;
begin
  // SELECT Cr.Charge_Date, Cr.Amount, Cr.Category, Cr.Paid, Cr.Balance, Cr.Memo as Comment, ChgDTail.Memo, ChgDTail.Amount, ChgDTail.Paid
  // FROM Charges Cr
  // INNER join ChgDTail on Cr.Charge_ID = ChgDTail.Charge_ID
  // WHERE (Cr.Balance > 0) and Cr.Client_ID = single_esc(Client_ID) + ';';

  sQuery := 'query-in SELECT False as Checked, Cr.Charge_Date, Cr.Category,Cr.Memo as Comment, Cr.Amount, Cr.Paid, Cr.Balance, Cr.Charge_ID, Cr.Trans_ID  '
    + 'FROM Charges Cr ' + 'WHERE Cr.Client_ID = ' + QuotedStr( Client_ID ) + ';';

  // Charges
  // ChgDTail
  // DetailAdjustmetments
  // DisountPayments
  // PayDetail
  // Payments
  //
  result := sRunQuery( sQuery );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegPayments: string;
var
  sQuery: string;
begin
  // Need to show the Date, Type, Check#, Memo, Amount.
  // sQuery:= 'query-in SELECT Cr.Charge_Date, Cr.Amount, Cr.Category, Cr.Paid, Cr.Balance, Cr.Memo as Comment ' + 'FROM Charges Cr '
  // + 'WHERE Cr.Client_ID = ' + single_esc ( Client_ID ) + ';';
  sQuery := 'query-in SELECT Payment_Date, Type, Check_Num, Voided, Amount' + ' FROM Payments ' + 'WHERE Client_ID = ' +
    single_esc( Client_ID ) + ';';
  result := sRunQuery( sQuery );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegBalDue: string;
var
  sQuery: string;
begin
  // SELECT Cr.Charge_Date, Cr.Amount, Cr.Category, Cr.Paid, Cr.Balance, Cr.Memo as Comment, ChgDTail.Memo, ChgDTail.Amount, ChgDTail.Paid
  // FROM Charges Cr
  // INNER join ChgDTail on Cr.Charge_ID = ChgDTail.Charge_ID
  // WHERE (Cr.Balance > 0) and Cr.Client_ID = single_esc(Client_ID) + ';';

  sQuery := 'query-in SELECT Cr.Charge_Date, Cr.Amount, Cr.Category, Cr.Paid, Cr.Balance, Cr.Memo as Comment ' +
    'FROM Charges Cr ' + 'WHERE (Cr.Balance > 0) and Cr.Client_ID = ' + QuotedStr( Client_ID ) + ';';

  // Charges
  // ChgDTail
  // DetailAdjustmetments
  // DisountPayments
  // PayDetail
  // Payments
  //
  result := sRunQuery( sQuery );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegBalDueTotal: string;
var
  sQuery: string;
begin
  sQuery := 'query-in SELECT sum(Cr.Balance) as TotalDue ' + 'FROM Charges Cr ' +
    'WHERE (Cr.Balance > 0) and Cr.Client_ID = ' + QuotedStr( Client_ID ) + ';';
  result := sRunQuery( sQuery );
  if Pos( cERRORVAL, result ) <> 0 then // We expect no 'ERROR' contained in result
    begin
      ServerContainer.SendMsg( GetGUID + ' ' + result );
      // result := sNOT;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegMakeItemizedPayment( Amount: string ): string;
{ TODO 1 -oScott -cMustDo : Update this query/test to get itemized payments working. }
var
  sQuery: string;
begin
  // Select all Charges with Balance > 0 and set them to $0 skipping the CC stuff for now where we INSERT into Payments & PayDTail.
  if ( Amount <> '' ) and ( Amount <> '0' ) and ( Amount <> '.00' ) then
    begin
      sQuery := 'query-out UPDATE Charges ' + 'SET Balance = 0, Paid = Amount ' + 'WHERE Balance > 0 and Client_ID = ' +
        QuotedStr( Client_ID ) + ';';
      result := sRunQuery( sQuery );
      if Pos( cERRORVAL, result ) = 0 then // We expect no 'ERROR' contained in result
        result := sOK
      else
        begin
          ServerContainer.SendMsg( GetGUID + ' ' + result );
          // result := sNOT;
        end;
    end
  else
    begin
      ServerContainer.SendMsg( 'ERROR in aegMakeItemizedPayment() Amount valid.' );
      result := cERRORVAL + ' missing Amount '; // release the clients Browser
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerMethods1.aegMakePayment( Amount: string ): string;
{ TODO 1 -oScott -cMustDo : Update this query and test it }
var
  sQuery: string;
begin
  // Select all Charges with Balance > 0 and set them to $0 skipping the CC stuff for now where we INSERT into Payments & PayDTail.
  if ( Amount <> '' ) and ( Amount <> '0' ) and ( Amount <> '.00' ) then
    begin
      sQuery := 'query-out UPDATE Charges ' + 'SET Balance = 0, Paid = Amount ' + 'WHERE Balance > 0 and Client_ID = ' +
        QuotedStr( Client_ID ) + ';';
      result := sRunQuery( sQuery );
      if Pos( cERRORVAL, result ) = 0 then // We expect no 'ERROR' contained in result
        result := sOK
      else
        begin
          ServerContainer.SendMsg( GetGUID + ' ' + result );
          // result := sNOT;
        end;
    end
  else
    begin
      ServerContainer.SendMsg( 'ERROR in aegMakePayment() Amount valid.' );
      result := cERRORVAL + ' missing Amount '; // release the clients Browser
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
initialization

// ServerMethods:= TServerMethods1.Create(nil);
_Count    := 1; // only allow 1 Result to be waiting
c_SyncObj := TProduceConsumeSync.Create( _Count, _msTimeOut );

finalization

// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
end.
