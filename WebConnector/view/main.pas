unit main;

//
// This project is using MVVM & built in XE10.2 Style & View.
//
// The MVVM (Modle-View-ViewModel) separates your GUI from the Data & Logic.
// NOTES:
// 1. Presentation Logic = 'Views' & 'ViewModel', 'ViewModel' know notihng about the Views, LiveBinding ties View to ViewModels.
// 2. Domain Logic = 'Model' and is always NON-Visual stuff.
// 3. Data Access Logic = MVVM has nothing to say about this; howerver this could be expanded ... ie... DataModels
//
// Views(GUI) = 'ViewModel' (Model(knows nothing about the Views) -- > Model(Knows nothing about ViewModels)
// |<-livebinding->|
//
// 'View' = Is Visual & HARD to Test, these are your Forms in delphi/Visual rendering of a ViewModel, we have editboxes & forms &
// buttons for example. Use Livebinding to bind the ViewModel state & data and display it inside your view.
// HARD TO TEST! KEEP IT SMALL & SIMPLE! NO Persistance, NO Inversion Of Control IoC!
// For example: In this file unit main we have our TFormMain. HOWERVER NOTICE how we have very simple code logic that is focused
// at the GUI with little or NO focus on the "How" or Domain Logic='Model'. Also main has little or NO focus on the "What"
// or Data & Access Logic='ViewModel'.
//
// 'ViewModel' = NON-Visual/Easy to Test, is the Model of your UI, for a Form this is a model of all logic & data, UI rules, work
// flows and the proceses that a user may interact with the Form, it knows about state & processes.
//
// 'Model' = NON-Visual & Easy to Test, The Model of your Problem Domain.
// If your building an Audio/Video app it's about Audio/Video Src's, Users,Groups,Rooms, Settings, Sharing, Connecting, etc.
// If your building a iTunes app it's all about artists, sonds, plays, ratings, etc.
// In an Accounting App it's Accounts, Transactions, etc
// In SSalesForce it's Customers, Activities, Forecasts, Opportunitites, etc..etc..etc..
//
// Author - Ted Rybicki
//
interface

uses
  u_crc32,
  ModelView.Information,
  ModelView.ClientClasses,
  model.Information,
  SyncObjs,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  Data.DBXJSON,
  Data.FireDACJSONReflect,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Menus,
  FMX.Layouts,
  FMX.ListBox,
  FireDAC.Stan.StorageJSON,
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.JSON,
  FireDAC.Comp.BatchMove.DataSet;

type

  TMyCallback = class( TDBXCallback ) // Callback instance that gets registered with the with the server.
    public
      function Execute( const Arg: TJSONValue ): TJSONValue; override;
  end;

  TFormMain = class( TForm )
    PrototypeBindSource1: TPrototypeBindSource;
    lb_rows: TLabel;
    bt_qtest: TButton;
    EditCallbackID: TEdit;
    Label2: TLabel;
    EditClientID: TEdit;
    Label1: TLabel;
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    ListBox1: TListBox;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    Label3: TLabel;
    ed_WebServer: TEdit;
    bt_IPSet: TCornerButton;
    bt_browser: TButton;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    lbl_ConnectorStatus: TLabel;
    procedure FormCreate( Sender: TObject );
    procedure PrototypeBindSource1CreateAdapter( Sender: TObject; var ABindSourceAdapter: TBindSourceAdapter );
    procedure FormShow( Sender: TObject );
    procedure SendShutDownNotice( sIP: string );
    procedure Button1Click( Sender: TObject );
    procedure FormClose( Sender: TObject; var Action: TCloseAction );
    procedure bt_qtestClick( Sender: TObject );
    procedure MenuItem4Click( Sender: TObject );
    procedure bt_IPSetClick( Sender: TObject );
    procedure bt_browserClick( Sender: TObject );
    private
      FLastCRC:    LongWord;
      F_TotalRows: integer;
      FLines:      integer;
      FInfoView:   TInformationViewModel;
      FServerView: TClientClassesViewModel;
      function LoadPrefetch( var sResult: string ): boolean;
      function GetConnected: boolean;
      function GetDissconnected: boolean;
      procedure LogMsg( s: string );
      procedure ButtonBroadcast( aMsg: string );
      procedure UpdatePreFetch;
      procedure ProcessWorkRequest( var s: string );
    public
      procedure QueueLogMsg( const s: string );

  end;

const
  cMaxSQLWait = 30000;
  cERRORVAL   = '!ERROR';
  sOK         = 'Ok';
  sNOT        = 'No';

{$IFDEF Debug}

  cMaxQueryToLoadPreFetch = 10;

{$ELSE}

  cMaxQueryToLoadPreFetch = 250;

{$ENDIF Debug}

var
  FormMain: TFormMain;
  _gMutex:  TMutex;

implementation

{$R *.fmx}

uses
  Winapi.ShellAPI,
  Winapi.Windows,
  FireDAC.Comp.Client, // TFDQuery
  FireDAC.Stan.Intf,   // fsJSON
  Data.DB,             // TDataSet
  Datasnap.DBClient,   // TClientDataSet
  Datasnap.DSProxy,
  ClientModuleUnit;

{ TMyCallback }
// -------------------------------------------------------------------------------------------------------------------------------
function TMyCallback.Execute( const Arg: TJSONValue ): TJSONValue;
var
  s:       string;
  mResult: TWaitResult;
begin
  // This is making a call from it's own thread ie. outside of the main thread for incomming pkts from the server.
  try
    // -Fixed BUG- double escaping a string here if we use: Arg.ToString() so dont' use .ToString() insted use .Value
    s := TJsonString( Arg ).Value;
    // Server performed ToString() escaping the data in NotifyCallback(), so pull out the string un-escaping the string.
    mResult := _gMutex.WaitFor( cMaxSQLWait );
    // serilize all connector processing out-to cMaxSQLWait times (querys complete in < 5s

    if mResult = wrSignaled then
      begin
        FormMain.ProcessWorkRequest( s ); // process the request in our main thread
      end
    else
      begin
        case mResult of // returned when/if we hit wrTimeout, wrAbandoned, wrError, wrIOCompletion condition(s)
          wrTimeout:
            s := cERRORVAL + ' - Timeout occured processing: ' + s;
          wrAbandoned:
            s := cERRORVAL + ' - Abandoned processing: ' + s;
          wrIOCompletion:
            s := cERRORVAL + ' - IOCompletion processing: ' + s;
          else
            s := cERRORVAL + ' - Unknown error processing: ' + s;
        end; // case
      end;
    Result := TJsonString.Create( s );
  finally
    _gMutex.Release;
  end;

end;

// -------------------------------------------------------------------------------------------------------------------------------
function single_esc( const aString: string ): string;
// Single escaped string for string query parms example: SELECT * from clients where UserName = '+single_esc(usersnamestr);
begin
  Result := '''' + aString + ''''; // NOTE: These are NOT double quotes=(#34) they are single quotes=(#39)
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure doublequote_clean( var aString: string );
// - FixIt BUG - On the Server TJSONString() must be used to send vai NotifyCallback(), Howerver TJSONstring's get confused about
// single quote's(#39) if it see them it assume they are double quotes(#34) when converting back to a string : ( uhg!.
// This will BREAK all SQL parm values on a single line as we must do here. So simply remove the extra double quotes first.
begin
  while Pos( #34, aString ) <> 0 do
    Delete( aString, Pos( #34, aString ), 1 );
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure breathe( const iCount: integer; const iSleep: integer );
var
  i: integer;
begin
  for i := 1 to iCount do
    begin
      sleep( iSleep );
      Application.ProcessMessages;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function MemStreamToString( ms: TMemoryStream ): string;
// Quickly copies a memory stream contents into a string
begin
  SetString( Result, PAnsiChar( ms.Memory ), ms.Size );
end;

// -------------------------------------------------------------------------------------------------------------------------------
function FDQueryToMemStream( const aQuery: TFDQuery; ms: TMemoryStream ): integer;
// Get's the entire Query dataset (including some of headers) into a stream that is saved into the stream as JSON; Can be over Kill
// so use FDQueryToJSONString() for small query(s).
var
  fdMemTable: TFDMemTable;
begin
  fdMemTable := TFDMemTable.Create( nil );
  fdMemTable.CloneCursor( aQuery, true, true );
  fdMemTable.SaveToStream( ms, sfJSON );
  ms.Position := 0;
  fdMemTable.Close;
  Result := ms.Size;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function FDQueryBatchToJSONString( const aQuery: TFDQuery ): string;
var
  ss: TStringStream;
begin

{$IF CompilerVersion <= 32.0} // Delphi 10.2 Rio and below

  // {$MESSAGE FATAL 'JSON BatchMode NOT fully supported in 10.2 and below, Use call to FDQueryToJSONString() insted '}

{$ENDIF}

  ss := TStringStream.Create;
  try
    ClientModule.bmJSONreader.DataSet := aQuery;
    try
      ClientModule.bmJSONwriter.Stream := ss;
      ClientModule.bm.Execute;
      Result := ss.DataString;
    except
    end;
  finally
    ss.Free;
  end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function FDQueryToJSONString( const aQuery: TFDQuery ): string;
// Fast copy FDQuery resultset to JSON
var
  i:        integer;
  ColName:  string;
  ColValue: string;
  LJsonObj: TJSONObject;
begin
  LJsonObj := TJSONObject.Create;
  aQuery.BeginBatch; // Don't update external references until EndBatch;
  aQuery.First;
  while ( not aQuery.EOF ) do
    begin
      for i := 0 to aQuery.FieldDefs.Count - 1 do
        begin
          ColName  := aQuery.FieldDefs[i].Name;
          ColValue := aQuery.FieldByName( ColName ).AsString; // <-- Here values are single quotes '
          LJsonObj.AddPair( TJSONPair.Create( TJsonString.Create( ColName ), TJsonString.Create( ColValue )));
          // <-- Now proper JSON double quotes "data"
        end;
      aQuery.Next;
    end;
  aQuery.EndBatch;
  Result := LJsonObj.ToString;
  LJsonObj.Free;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function DataTables( Value: TDataSet; var n: integer ): TJSONObject;
var
  dataArray: TJSONArray;
  subArray:  TJSONArray;
  metaArray: TJSONArray;
  i:         integer;
begin
  dataArray := TJSONArray.Create;
  // populate the data array
  while not Value.EOF do
    begin
      subArray := TJSONArray.Create;

      for i := 0 to Value.FieldCount - 1 do
        subArray.Add( Value.Fields[i].AsString );

      dataArray.AddElement( subArray );
      inc( n );
      Value.Next;
    end;

  Value.First;

  metaArray := TJSONArray.Create;
  // populate the meta array
  for i := 0 to Value.FieldDefs.Count - 1 do
    begin
      metaArray.Add( TJSONObject.Create( TJSONPair.Create( 'sTitle', Value.FieldDefs[i].Name )));
    end;

  Result := TJSONObject.Create;
  Result.AddPair( TJSONPair.Create( 'aaData', dataArray ));
  Result.AddPair( TJSONPair.Create( 'aoColumns', metaArray ));
end;

// -------------------------------------------------------------------------------------------------------------------------------
// -----------------------------------------------------TFormMain-----------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.PrototypeBindSource1CreateAdapter( Sender: TObject; var ABindSourceAdapter: TBindSourceAdapter );
begin
  // Change over from design-time fields in the PrototypebindSource to the real-time instance of our ViewModel
  FInfoView := TInformationViewModel.Create; // Need this created before we can do the Adapter
  // Create a BindSourceAdapter
  ABindSourceAdapter := TObjectBindSourceAdapter< TInfo >.Create( PrototypeBindSource1, FInfoView.Info, False );
  // Because our fields in the ProtoTypeFields match the names of our fields in the ViewModel the live bindings work.
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.FormCreate( Sender: TObject );
begin
  FLines      := 0;
  F_TotalRows := 0;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.FormShow( Sender: TObject );
begin

{$IFNDEF DEBUG}

  Label3.Visible       := False;
  ed_WebServer.Visible := False;
  bt_IPSet.Visible     := False;
  lb_rows.Visible      := False;

{$ENDIF  DEBUG}

  GetConnected; // Our 1st try at contacting the server.
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.SendShutDownNotice( sIP: string );
var
  s: string;
begin
  try
    // Try and disconnect nicely
    s := FServerView.Server.ShutDownNotice( FInfoView.Info.ClientID ); // Return the GUID to the calling Server
    breathe( 10, 2 );
  except
    // Just eat'em yum.. as we don't care now.
  end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.FormClose( Sender: TObject; var Action: TCloseAction );
begin
  SendShutDownNotice( FInfoView.Info.ClientID );
  GetDissconnected;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TFormMain.LoadPrefetch( var sResult: string ): boolean;
var
  stmp:   string;
  i:      integer;
  Query:  TFDQuery;
  FJObj:  TJSONObject;
  sQuery: string;
  sWhere: string;
begin
  Result  := true;
  Query   := TFDQuery.Create( self );
  sResult := '';
  try
    try
      Query.Connection := ClientModule.FDConnection1;
      Query.Active     := False;
      Query.SQL.Add( 'Select Name from Config' );
      Query.Active := true;
      Query.FetchAll;
      i := Query.RowsAffected;
      if ( i > 0 ) then

{$LEGACYIFEND ON}
{$IF CompilerVersion >= 33.0} // Delphi 10.3 Rio and above

        sResult := FDQueryBatchToJSONString( Query ) // Batch only good in 10.3 and above

{$ELSE}

        sResult := FDQueryToJSONString( Query ) // use the older method in 10.2 and below

{$IFEND}

      else
        sResult := '[{"Name":"unknown"}]';

      Query.Active := False;
      Query.SQL.Clear;
      Query.SQL.Add( 'Select Address1, City, State, Zip, Phone, EmailFrom from Config' );
      Query.Active := true;
      Query.FetchAll;
      i := Query.RowsAffected;
      if ( i > 0 ) then

{$LEGACYIFEND ON}
{$IF CompilerVersion >= 33.0} // Delphi 10.3 Rio and above

        stmp := FDQueryBatchToJSONString( Query ) // Batch only good in 10.3 and above

{$ELSE}

        stmp := FDQueryToJSONString( Query ) // use the older method in 10.2 and below

{$IFEND}

      else
        stmp := '[{"Address1":"unknown","City":"unknown","State":"??","Zip":"unknown","Phone":"(000) 000-0000","EmailFrom":"unknown"}]';
      sResult := sResult + '|' + stmp;

      Query.Active := False;
      Query.SQL.Clear;
      Query.SQL.Add( 'Select Code, Description from ClassLvl' );
      Query.Active := true;
      Query.FetchAll;
      i := Query.RowsAffected;
      if ( i > 0 ) then
        begin
          FJObj := DataTables( Query, i ); // get data & metadata in "datatables" format
          stmp  := FJObj.ToString;         // escapes the data
        end
      else
        stmp  := '{"aaData":[["nodata","nodata"]],"aoColumns":[{"sTitle":"Code"},{"sTitle":"Description"}]}';
      sResult := sResult + '|' + stmp;

      Query.Active := False;
      Query.SQL.Clear;
      Query.SQL.Add( 'Select Code, Description from ClasType' );
      Query.Active := true;
      Query.FetchAll;
      i := Query.RowsAffected;
      if ( i > 0 ) then
        begin
          FJObj := DataTables( Query, i ); // get data & metadata in "datatables" format
          stmp  := FJObj.ToString;         // escapes the data
        end
      else
        stmp  := '{"aaData":[["nodata","nodata"]],"aoColumns":[{"sTitle":"Code"},{"sTitle":"Description"}]}';
      sResult := sResult + '|' + stmp;

      Query.Active := False;
      Query.SQL.Clear;
      sQuery := 'SELECT Cl.Portal_Enrollable, Cl.Code, Cl.name, Cy.Description, Te.Code as Teacher_Code, Te.Name as Teacher, '
        + 'Cl.Tuition_Code, Cl.sunday, Cl.monday, Cl.tuesday, Cl.wednesday, Cl.thursday, Cl.friday, Cl.saturday, Cl.Su_Start_time, '
        + 'Cl.Mo_Start_Time, Cl.Tu_Start_Time, Cl.We_Start_Time, Cl.Th_Start_Time, Cl.Fr_Start_Time, Cl.Sa_Start_Time, Tu.Type, Tu.Similar1 '
        + 'FROM Classes Cl, Teacher Te, ClassTeachers Ct, ClasType Cy, Tuition Tu ';
      sWhere := ' WHERE (Cl.Code = Ct.Class_Code) and (Ct.Teacher_Code = Te.Code) and (Cy.Code = Cl.Type) and (Cl.Portal_Visible = True) and (Cl.Tuition_Code = Tu.Code)';
      Query.SQL.Text := sQuery + sWhere;
      Query.Active   := true;
      Query.FetchAll;
      i := Query.RowsAffected;
      if ( i > 0 ) then
        begin

{$IFDEF Debug2}
{$IF CompilerVersion >= 33.0} // Delphi 10.3 Rio and above

          stmp := FDQueryBatchToJSONString( Query ) // Batch only good in 10.3 and above

{$ELSE}

          stmp := FDQueryToJSONString( Query ) // use the older method in 10.2 and below

{$IFEND}

            i := Length( stmp );   // for debug
          i   := Pos( #39, stmp ); // do we have some '
          i   := stmp.IndexOfAnyUnquoted([#39], #34, #34 );
          sl  := TStringList.Create;
          sl.Add( stmp );
          sl.SaveToFile( 'Classes_query.txt' );
          sl.Free;
          Query.First; // reset to the top

{$ENDIF Debug2}

          FJObj := DataTables( Query, i ); // get data & metadata in "datatables" format
          stmp  := FJObj.ToString;         // escapes the data
          // i:= Pos(#39, s); // do we have some '
        end
      else
        stmp  := '{"aaData":[["nodata","nodata"]],"aoColumns":[{"sTitle":"Code"},{"sTitle":"Description"}]}';
      sResult := sResult + '|' + stmp;

    except
      on E: Exception do
        begin
          ListBox1.Items.Add( '- Local Query Failed - ' + E.ClassName + ' error raised, with message :  ' + E.Message );
          Result := False;
        end;
    end;
  finally
    if Assigned( Query ) then
      Query.Free;
  end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TFormMain.GetConnected: boolean;
var
  s:    string;
  spre: string;
begin
  Result                       := False;
  FInfoView.Info.ClientEnabled := False;

  try
    try
      // ALEART! WATCH OUT the CallbackChannelManager and SQLConnection.Params need to agree/stay in sync for Hostname & Port!
      // So here I'm going to take the values set in the ChannelManager and update SQLConnection.Params with them.
      // Or we will get a BAD msg 'Connection Rejected' that looks just like a FW port issue but this keeps them in sync.
      // NOTE: Set the HostName & Port you want in the CallbackChannelManager, then this code does the sync for us.
      ClientModule.SQLConnection1.Params.Values['HostName'] := ClientModule.DSClientCallbackChannelManager1.DSHostname;
      ed_WebServer.Text := ClientModule.DSClientCallbackChannelManager1.DSHostname;
      ClientModule.SQLConnection1.Params.Values['Port'] := ClientModule.DSClientCallbackChannelManager1.DSPort;
      FInfoView.Info.IP                                 := ClientModule.DSClientCallbackChannelManager1.DSHostname;
      FInfoView.Info.Port                               := ClientModule.DSClientCallbackChannelManager1.DSPort;
      ClientModule.DSClientCallbackChannelManager1.ManagerId := FInfoView.Info.ClientID;
      // The server will callback to the client connector via its NotifyCallback() so map it up here.
      ClientModule.DSClientCallbackChannelManager1.RegisterCallback( FInfoView.Info.CallbackID, TMyCallback.Create );

{$IFDEF Debug}

      // Specifies the time, in milliseconds, expected for the connection to be established.
      ClientModule.DSClientCallbackChannelManager1.ConnectionTimeout := '600000'; // 6-min
      // Specifies the timeout, in milliseconds, for a response, after the connection is established.
      ClientModule.DSClientCallbackChannelManager1.CommunicationTimeout := '600000'; // 6-min

{$ENDIF Debug}

    except
      on E: Exception do
        begin
          ShowMessage( E.ClassName + ' Error raised tyring to configure Callback Channel, with message: ' + E.Message );
        end;
    end;
  finally
  end;

  try
    try
      ClientModule.SQLConnection1.Connected := true;
      FServerView := TClientClassesViewModel.Create( ClientModule.SQLConnection1.DBXConnection );
    except
      on E: Exception do
        begin
          ShowMessage( E.ClassName + ' Error tyring to connect to Web-Server, with message: ' + E.Message +
            ' Possible local network issues or server is down, Please try again later' );
        end;
    end
  finally
  end;

  if LoadPrefetch( spre ) then
    begin
      FLastCRC := _CRC32Str( spre );
      // 1st DataSnap Call is RegisterCheck() we validate ID and CallbackID, Server can reject us if we are NOT a valid GUID & NOT set as active.
      // pass in our prefetch's in spre.
      s := FServerView.Server.RegisterCheck( FInfoView.Info.ClientID, FInfoView.Info.CallbackID, spre );
      // returns web-server port or -1 as rejected.
      if ( s = cERRORVAL ) then
        ListBox1.Items.Add
          ( 'ERROR - Calling RegisterCheck() failed, possible network issues or server is down, Please try again later.' )
      else
        begin
          FInfoView.Info.WebPort := s;
          FormMain.Caption := FInfoView.Info.Title + FInfoView.Info.Version + ' 2019  ' + FInfoView.Info.ClientID + ' '
            + FInfoView.Info.IP + ':' + FInfoView.Info.WebPort + '(' + FInfoView.Info.Port + ')';
          Result := true;

          if ( s = 'No' ) then
            ListBox1.Items.Add
              ( 'WARN - Although registered this system is NOT curently enabled, Please contact Auburn Electronics Group Customer Support: techsupp@aegroup.com or Call: +1 916.852.2900' );

          FInfoView.Info.ClientEnabled := true;
        end;

      EditClientID.Text   := FInfoView.Info.ClientID;
      EditCallbackID.Text := FInfoView.Info.CallbackID;
    end;

  // if we get to here and result = false down the client because not curently enabled or errors of some kind
  if not Result then
    ClientModule.SQLConnection1.Connected := False; // down the client

end;

// -------------------------------------------------------------------------------------------------------------------------------
function TFormMain.GetDissconnected: boolean;
begin
  try
    ClientModule.SQLConnection1.Connected := False;
    breathe( 10, 10 );
    if ( Assigned( FServerView )) then
      FreeAndNil( FServerView );
    Result              := true;
    EditClientID.Text   := '';
    EditCallbackID.Text := '';
  except
    Result := False;
  end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.LogMsg( s: string );
var
  inx:  integer;
  stmp: string;
begin

{$IFNDEF Debug} // if we are NOT in Debug then you must put 'Log' in the start of msg to show it

  stmp := Copy( s, 1, 3 );
  if stmp = 'Log' then
    begin
      Delete( s, 1, 3 ); // remove 'Log'

{$ELSE}

  stmp := Copy( s, 1, 3 );
  if stmp = 'Log' then
    Delete( s, 1, 3 );

{$ENDIF Debug}

  if ( ListBox1 <> nil ) then
    begin
      inx := ListBox1.Items.Add( FLines.ToString + '| ' + DateTimeToStr( Now ) + '- (' + Length( s ).ToString +
        ')' + s );
      ListBox1.ItemIndex := inx;
      inc( FLines );
    end;

{$IFNDEF Debug}

end;

{$ENDIF Debug}

end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.MenuItem4Click( Sender: TObject );
begin
  // ClientModule.DSClientCallbackChannelManager1.DSHostname:= ed_WebServer.Text;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.bt_browserClick( Sender: TObject );
var
  LURL:  string;
  sName: string;
begin
  // GET a client_id GUID
  if EditClientID.Text <> '' then // do we have a GUID to access?
    begin
      sName := EditClientID.Text;
      LURL  := Format( 'http://%s:%s/GUID?%s', [FInfoView.Info.IP, FInfoView.Info.WebPort, sName]);
      ShellExecute( 0, nil, PChar( LURL ), nil, nil, SW_SHOWNOACTIVATE );
    end
  else
    QueueLogMsg( 'LogPlease select a GUID...' );
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.bt_IPSetClick( Sender: TObject );
begin
  if ( ed_WebServer.Text <> '' ) then // we will try again to connect to the IP or hostname
    begin
      SendShutDownNotice( FInfoView.Info.ClientID );
      GetDissconnected;
      ClientModule.DSClientCallbackChannelManager1.DSHostname := ed_WebServer.Text;
      GetConnected;
    end;
end;

procedure ProcessTags( var s: string );
// Look for and handel any specia any tags passed in via query-out.
var
  i:    integer;
  stmp: string;
begin
  while Pos( '<#', s ) <> 0 do
    begin

      i := Pos( '<#now>', s );
      // Server is asking for the local time of this system ie. Connector-Time NOT server system time.
      if i > 0 then
        begin
          Delete( s, i, 6 );
          stmp := QuotedStr( DateTimeToStr( Now ));
          insert( stmp, s, i );
        end;

    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.UpdatePreFetch;
var
  s:   string;
  crc: LongWord;
begin
  if LoadPrefetch( s ) then
    crc := _CRC32Str( s )
  else
    crc := 0;
  if ( crc <> FLastCRC ) then
    begin
      s := FServerView.Server.FreshenCache( FInfoView.Info.ClientID, FInfoView.Info.CallbackID, s );
      if ( s = sOK ) then
        FLastCRC := crc;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.ProcessWorkRequest( var s: string );
// -- WARNING --- Don't call direclty from std-code!, only call via TThread.queue().

{$IFOPT J-}{$DEFINE Assignable_WasOFF}{$J+}{$ENDIF}

const
  cQueryCount: integer = 0;

{$IFDEF Assignable_WasOFF}{$UNDEF Assignable_WasOFF}{$J-}{$ENDIF}

var
  i:     integer;
  Query: TFDQuery;
  JObj:  TJSONObject;

begin
  inc( cQueryCount, 1 );

  if Pos( 'DisableClient', s ) <> 0 then
    begin
      FInfoView.Info.ClientEnabled := False;
      QueueLogMsg( 'LogDisable Client' );
      lbl_ConnectorStatus.Text := 'Connector Disabled';
    end
  else
    if Pos( 'EnableClient', s ) <> 0 then
      begin
        FInfoView.Info.ClientEnabled := true;
        QueueLogMsg( 'LogEnabled Client' );
        lbl_ConnectorStatus.Text := 'Connector Enabled';
      end
    else
      if ( s = 'Server-is-Stoping' ) then
        begin
          QueueLogMsg( 'LogServer is Stopping' );
        end
      else
        if Pos( 'echo', s ) <> 0 then
          begin
            s := FServerView.Server.EchoString( '- Web-Connector - Author Ted Rybicki May 2019' );
            QueueLogMsg( 'Log' + s );
          end
        else
          if FInfoView.Info.ClientEnabled then
            begin
                if Pos( 'query-in ', s ) <> 0 then
                  // This is a query comming into the connector, ie. we use std SQL() with results expected from the query.
                  begin
                    Delete( s, 1, Length( 'query-in ' ));
                    try
                      Query            := TFDQuery.Create( self );
                      Query.Connection := ClientModule.FDConnection1;
                      Query.Active     := False;
                      Query.SQL.Add( s );

                      Query.Active := true;
                      Query.FetchAll;

                      JObj := DataTables( Query, i ); // get data & metadata in "datatables" format
                      s    := JObj.ToString;          // escapes the data

                      i := Query.RowsAffected;
                      inc( F_TotalRows, i );
                      lb_rows.Text := F_TotalRows.ToString;

                    except
                      on E: Exception do
                        begin
                          s := cERRORVAL + ' - Connector Local Query Failed - ' + s + ' ' + E.ClassName +
                            ' error raised, with message :  ' + E.Message;
                          ListBox1.Items.Add( '- Local Query Failed - ' + E.ClassName +
                            ' error raised, with message :  ' + E.Message );
                        end;
                    end;
                    QueueLogMsg( 'Log' + s );
                  end
                else
                  if Pos( 'query-out', s ) <> 0 then
                    // This is a command query, ie. we use ExecSQL() no result sets expected from the query.
                    begin
                      Delete( s, 1, Length( 'query-out ' ));

                      ProcessTags( s );

                      Query            := TFDQuery.Create( self );
                      Query.Connection := ClientModule.FDConnection1;
                      Query.Active     := False;
                      try
                        Query.ExecSQL( s );
                      except
                        s := cERRORVAL + ' - ' + s;
                        s := 'EXECSQL,ERROR,ROWS:' + Query.RowsAffected.ToString + s
                      end;

                      if ( Query.RowsAffected <> 0 ) then
                        begin
                          s := 'EXECSQL,OK,ROWS:' + Query.RowsAffected.ToString + ' SUCCESS - ' + s;

{$IFDEF DEBUG}

                          QueueLogMsg( 'Log' + s );

{$ENDIF DEBUG}

                        end;
                    end
                  else
            end
          else
            s := cERRORVAL + ' Connector Disabled';

  if ( cQueryCount >= cMaxQueryToLoadPreFetch ) then
    begin
      UpdatePreFetch;
      cQueryCount := 0;
    end;

end;

// -------------------------------------------------------------------------------------------------------------------------------
// Thread-safe call to TFormClient.LogMsg.
procedure TFormMain.QueueLogMsg( const s: string );
begin
  TThread.Queue( nil, procedure
    begin // The thread-safe version of our “LogMsg” method, so it could be called from a different thread.
      LogMsg( s );
    end );
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.ButtonBroadcast( aMsg: string );
var
  AClient: TDSAdminClient;
begin
  AClient := TDSAdminClient.Create( ClientModule.SQLConnection1.DBXConnection );
  try
    AClient.BroadcastToChannel( ClientModule.DSClientCallbackChannelManager1.ChannelName, TJsonString.Create( aMsg ));
  finally
    AClient.Free;
  end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.bt_qtestClick( Sender: TObject );
var
  username: string;
  s:        string;
begin
  username := single_esc( 'tedry' );
  s        := 'query-in SELECT Clients_ID, UserName, Password FROM ClientsUsers where UserName = ' + username;
  QueueLogMsg( 'LogTest Query ok' );
  ButtonBroadcast( 'TestQuery' );
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.Button1Click( Sender: TObject );
begin
  ButtonBroadcast( FInfoView.Info.ClientID );
end;

initialization

_gMutex := SyncObjs.TMutex.Create( nil, False, 'gConnectorConnections' );

finalization

_gMutex.Free;

// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
end.
