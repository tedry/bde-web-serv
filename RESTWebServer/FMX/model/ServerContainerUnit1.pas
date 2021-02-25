unit ServerContainerUnit1;

interface

uses
  WebModuleUnit1,
  System.SysUtils,
  System.Classes,
{$IFDEF TedNotYet}
  System.Messaging,
{$ELSE}
  u_MessageMgr,
{$ENDIF}
  Datasnap.DSServer,
  Datasnap.DSSession,
  Datasnap.DSCommonServer,
  IPPeerServer,
  IPPeerAPI,
  Datasnap.DSAuth,
  Datasnap.DSTCPServerTransport,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.FMXUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Moni.Base,
  FireDAC.Moni.RemoteClient,
  FireDAC.Moni.FlatFile;

type
  // This TDataModule MUST be created first in the order of things to allow for the WebModule to ref the Server and
  // AuthenticationManager. Therfore I have force it's creation order by using the initialization section at the bottom of this
  // code and it's instance is held the the life of this process in FModule. All others use ServerContainer() to get the ref.
  TServerContainer1 = class(TDataModule)
    // DSServer1 is the core DataSnap server component, gluing together all the various components of this architecture.
    // Despite the fact it has only a couple of properties, its role is central.
    DSServer1: TDSServer;

    // DSServerClass1 is the component that refers to the class exposing its methods as REST services, creates and manages the
    // lifetime of objects of this class. Its role parallels that of a class factory in COM. The actual class this Server Class
    // refers to is returned in the OnGetClass event handler of the component, in a reference parameter.
    DSServerClass1: TDSServerClass;

    DSTCPServerTransport1: TDSTCPServerTransport;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDQuery1: TFDQuery;
    FDConnection1: TFDConnection;
    DSAuthenticationManager1: TDSAuthenticationManager;
    FDQuery2: TFDQuery;
    procedure DSServerClass1GetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
    // <-- OnGetClass()
    procedure DSAuthenticationManager1UserAuthenticate(Sender: TObject; const Protocol, Context, User, Password: string; var valid: Boolean; UserRoles: TStrings);
    procedure DSAuthenticationManager1UserAuthorize(Sender: TObject; AuthorizeEventObject: TDSAuthorizeEventObject; var valid: Boolean);
    private
      { Private declarations }
{$IFDEF TedNotYet}
      fMessageManager: TMessageManager;
{$ELSE}
{$ENDIF}
      function openCheckDb: Boolean;
      function parse_ID_Name_PW(const sJSON: string; var Clients_ID: string; var UserName: string; var Pw: string): Boolean;
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure AfterConstruction; override;
      procedure SendMsg(const sMsg: string);
      function GetUserAndPassword(aUser: string; sID: string; var Client_ID: string; var UserName: string; var Pass: string): Boolean;
      function getGUIDList(var aQuery: TFDQuery): integer;
      procedure InsertClient(var aQuery: TFDQuery; const clientID: string; const callbackID: string; const GymName: string; const GymAddress: string; const GymEmail: string;
        const ClassLvl: string; const SelectClassType: string; const ClassSchedules: string);
      procedure UpdatedClient(var aQuery: TFDQuery; const clientID: string; const callbackID: string; const GymName: string; const GymAddress: string; const GymEmail: string;
        const ClassLvl: string; const SelectClassType: string; const ClassSchedules: string);
{$IFDEF TedNotYet}
      property MessageManager: TMessageManager read fMessageManager write fMessageManager;
{$ENDIF}
  end;

function ServerContainer: TServerContainer1; // NOTE: Specialy added to expose the FModule
function DSServer: TDSServer;
function DSServer_web(aWebModule: TWebModule2): TDSServer;
function DSAuthenticationManager: TDSAuthenticationManager;
function single_esc(const aString: String): String;
procedure EachSessionSearch(const Session: TDSSession);

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

uses
  System.Rtti,
  // Allows Iterator.AsString {TJSONIterator.GetAsString()} to use Inlining vs. calling. removes the Hint H2443
  ServerMethodsUnit1,
  System.JSON,
  System.JSON.Builders,
  System.JSON.Types,
  System.JSON.Readers,
  System.JSON.Writers;

// ThreadVar VDSSession: TDSSession; { Session for the current thread }

const
  sOK  = 'Ok';
  sNOT = 'No';
  cERRORVAL = '!ERROR';

var
  FModule  : TServerContainer1; // NOTE: By default FModule is Tcomponent I re-typed it to TServerContainer1 as that's what we actualy need/want here.
  FDSServer               : TDSServer;
  FDSAuthenticationManager: TDSAuthenticationManager;

// -------------------------------------------------------------------------------------------------------------------------------
function ServerContainer: TServerContainer1;
// Expose this entire TServerContainer1 class
begin
  Result:= FModule;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function DSServer: TDSServer;
// Expose DSServer to our WebModuleUnit.
begin
  Result:= FDSServer;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function DSServer_web(aWebModule: TWebModule2): TDSServer;
// Expose DSServer to our WebModuleUnit.
begin
  WebModule:= aWebModule;
  Result   := FDSServer;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function DSAuthenticationManager: TDSAuthenticationManager;
// Expose DSAuthenticationManager to our WebModuleUnit.
begin
  Result:= FDSAuthenticationManager;
end;

// -------------------------------------------------------------------------------------------------------------------------------
function single_esc(const aString: String): String;
// Single escaped string for string query parms example: SELECT * from clients where UserName = '+single_esc(usersnamestr);
begin
  Result:= '''' + aString + ''''; // NOTE: These are NOT double quotes=(#34) they are single quotes=(#39)
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure EachSessionSearch(const Session: TDSSession);
var
  sGUID: string;
begin
  // This procedure will be called for each session in the TDSSessionManager
  if (Session.GetData('GUID') <> '') and (Session.UserName = 'user') then
    sGUID:= Session.GetData('GUID');
end;

// -------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------- TServerContainer1 -----------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
constructor TServerContainer1.Create(AOwner: TComponent);
begin
  inherited;
  FDSServer               := DSServer1;
  FDSAuthenticationManager:= DSAuthenticationManager1;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerContainer1.AfterConstruction;
begin
  inherited;
  openCheckDb;
end;

// -------------------------------------------------------------------------------------------------------------------------------
destructor TServerContainer1.Destroy;
begin
  inherited;
  FDSServer:= nil;
  FDSAuthenticationManager := nil;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerContainer1.SendMsg(const sMsg: string);
{$IFDEF TedNotYet}
var
  Message: TMessage;
{$ENDIF}
begin
{$IFDEF TedNotYet}
  if Assigned(fMessageManager) then
    begin
      Message:= TMessage<UnicodeString>.Create(sMsg);
      fMessageManager.SendMessage(self, Message, True);
    end;
{$ELSE}
  if Assigned(gMsgHandler) then
    gMsgHandler.PostMessage('Log' + sMsg);
{$ENDIF}
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerContainer1.parse_ID_Name_PW(const sJSON: string; var Clients_ID: string; var UserName: string; var Pw: string): Boolean;
var
  i       : integer;
  s       : string;
  sr      : TStringReader;
  tr      : TJsonTextReader;
  Iterator: TJSONIterator;
{$IFDEF Debug2} // Handy if you are steping through this code and want to see more.. else don't set it.
  LType: TJsonToken;
  inx  : integer;
{$ENDIF Debug2}
begin
  // Example data:
  // s:= '{"aaData":[["16443","tedry",""]],"aoColumns":[{"sTitle":"Clients_ID"},{"sTitle":"UserName"},{"sTitle":"Password"}]}';
  sr      := TStringReader.Create(sJSON);
  tr      := TJsonTextReader.Create(sr);
  Iterator:= TJSONIterator.Create(tr);

  // 2nd get the data via "aaData".
  while Iterator.Next do // Next(), reader moves to the first JSON token
    begin
{$IFDEF Debug2}
      LType:= Iterator.&Type; // indicates the type of the token.
{$ENDIF Debug2}
      case Iterator.&Type of
        TJsonToken.StartObject, TJsonToken.EndObject:
          begin
            Iterator.Recurse;
          end;

        TJsonToken.StartArray:
          begin
            Iterator.Recurse;
{$IFDEF Debug2}
            inx:= Iterator.Index; // obtain the index of the current token
{$ENDIF Debug2}
          end;
        else
          s:= s + Iterator.AsString + ','
      end;
    end;

  if (s <> '') then
    begin
      i         := Pos(',', s);
      Clients_ID:= Copy(s, 1, i - 1);
      Delete(s, 1, i);
      i       := Pos(',', s);
      UserName:= Copy(s, 1, i - 1);
      Delete(s, 1, i);
      i := Pos(',', s);
      Pw:= Copy(s, 1, i - 1);
    end;

  Result:= (Clients_ID <> '') and (UserName <> '') and (Pw <> '');
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerContainer1.GetUserAndPassword(aUser: string; sID: string; var Client_ID: string; var UserName: string; var Pass: string): Boolean;
var
  sResult: string;
  sQuery:  string;
begin
  Result:= false;
  if (aUser <> '') then
    begin
      sResult:= single_esc(aUser);
      sQuery:= 'query-in SELECT Client_ID, UserName, Password, Email FROM WebUsers where UserName = ' + sResult;
      sResult:= ServerMethods.sRunQuery(sQuery, sID);
      if Pos(cERRORVAL,sResult) <> 0 then // We expect no 'ERROR' contained in result
       begin
         SendMsg('Log' + sID + ' ' + sResult);
         Result:= False;
       end
      else
       if (sResult <> '') then
        begin
          Result:= True;
          parse_ID_Name_PW(sResult, Client_ID, UserName, Pass);
        end;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerContainer1.DSAuthenticationManager1UserAuthenticate(Sender: TObject; const Protocol, Context, User, Password: string; var valid: Boolean; UserRoles: TStrings);
// AUTHENTICATION
// This event is called when a user tries to connect (invoke a method) for the first time, and takes as input parameters
// connection information such as the user name and password, and allows you to set a value for the in/out parameter valid.
// In general, you’ll look-up in a database or configuration file or operating system mechanism to validate the users and their
// passwords.
//
var
  Session     : TDSSession;
  RealID      : string;
  RealUser    : string;
  RealPassword: string;
  sGUID       : string;
  sUser       : string;
begin
  valid  := false;
  Session:= TDSSessionManager.GetThreadSession; // access the current session
  // TDSSessionManager.Instance.ForEachSession(EachSessionSearch);
  // sGUID:= ServerMethods.GetGUIDSessionID;
  // sGUID:= ServerMethodsUnit1.ServerMethods.GetGUIDSessionID;

  // SESSIONS
  // The first time a client calls the server, it creates a new session ID and returns it in a custom header (‘dssession’).
  // After the user and its session are authenticated, the method is not called again.
  // Subsequent requests from the client should include a ‘Pragma’ header with the session ID, so that the server recognizes the
  // request comes from the same client.
  // A session lasts until it expires (by default 1200 seconds, that is, 20 minutes) or it is forced to
  // close using the special CloseSession URL. If you pass a session that doesn’t exist (for
  // example, because in the meantime you closed and reopened the server) you’ll receive an
  // exception and the session ID is reset.
  // HOWEVER this is a MODIFYED system as follows to support GUID Mapping in our framework.
  // 1. The GUID is configured/generated for the 1st time at the "connector".
  // 2. When the "connector" connects to the web-server it will RegisterCheck() with the server, pushing it's GUID along with prefetch data. NOTE the server can
  // reject the "connector" if it has been disable in the local DB server RegisteredClients table via the IsEnabled field.
  // Now the server knows about the "connector" and its back-channel path via the registered GUID.
  // 3. Next the server receives a new web browser request from a gym web page some where with same GUID: example: https://www.mygym.com/GUID?B049786C-B2E0-4F88-901E-EF6650C26E6D
  // When the landing page index.html is process it will load any prefetch data directly from the servers cahe using the GUID; However at this point the user
  // has NOT logged into the system so only prefetch data that dosn't care about the users idenity can be mapped. ie. No user specific data yet.
  // 4. The user selects "LOG IN" and provides email/userid and password. Here is whare a little magic will take place, the framwork dose support user level
  // tracking via a generated "dsessionid" key and stores this key into the browsers local cahe as a cookie. It is used for session state tracking between
  // the browser and server on all subsequent calls until time out (20 min defaule) or user logoff. HOWEVER this dose NOT support the GUID mapping requirements
  // that we need to make sure the correct "connector" back-channel is use to comlunicate with the ProSchool application database at some gym.
  // To acheve this we MAP the url GUID onto the back of the users login name. Example user = 'thebruce' and the url GUID = B049786C-B2E0-4F88-901E-EF6650C26E6D
  // the framwork passes 'thebruce_B049786C-B2E0-4F88-901E-EF6650C26E6D' to the servers AuthenticationManager and then we arive here at this handler code.
  // 5. Now we are going to strip off the real users name "thebruce" and the "GUID" to the store the GUID into the newly creaated session object that will now
  // track our subsequent calls with the GUID now MAPPED to the "connector" and the "dsessionid". And then armed with this mapping we can make our 1st real call
  // down the "connector" back-channel and query for the real users name and verify the password. If both match we can authenticate the user and continue with
  // the users UserAuthorization next.
  // NOTE: This MAPPING between the "connector" back-channel GUID and "dsessionid" only last until time-out or the user loggs of whichever comes first.
  //
  if (Session <> nil) then
    begin
      sGUID:= Copy(Session.UserName, Pos('_', Session.UserName)+ 1, Length(Session.UserName));
      sUser:= Copy(Session.UserName, 1, Pos('_', Session.UserName)- 1);
      Session.PutData('GUID', sGUID); // save our connector back-channel path
      Session.PutData('LogonUser', sUser);

      if GetUserAndPassword(sUser, sGUID, RealID, RealUser, RealPassword) then
        begin
          valid:= (sUser = RealUser) and (Password = RealPassword) and (RealID <> '');
{$IFDEF DEBUG}
          if (User = 'admin') or (User = '') and (RealUser = '') and (RealPassword = '') and (RealID = '') then
            valid:= True;
{$ENDIF DEBUG}
          if valid then
           begin
             Session.PutData('RealUser', RealUser);
             Session.PutData('pw', RealPassword);
             Session.PutData('Client_ID', RealID);

             // ROLES AND AUTHORIZATION
             UserRoles.Add('standard'); // Add the default role
             // Only the 'admin' user has access to /TServerMehods
             if User = 'admin' then
              UserRoles.Add('admin');
           end;
        end ;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerContainer1.DSAuthenticationManager1UserAuthorize(Sender: TObject; AuthorizeEventObject: TDSAuthorizeEventObject; var valid: Boolean);
{$IFDEF Debug2}
var
  Session: TDSSession;
{$ENDIF Debug2}
begin
  

{$IFDEF Debug2}
  Session:= TDSSessionManager.GetThreadSession; // access the current session
  TDSSessionManager.Instance.ForEachSession(EachSessionSearch);
{$ENDIF Debug2}
  valid:= True; // so we just always indicate all calls are valid.
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerContainer1.DSServerClass1GetClass(DSServerClass: TDSServerClass; var PersistentClass: TPersistentClass);
// Loads our ServerMethods called from OnGetClass telling what kind of server we want to instantiat.
begin
  //NOTE: We must have our TDSServerClass running with the expected LifeCycle for our architechure. <-- Here it MUST be "Server"
  PersistentClass:= ServerMethodsUnit1.TServerMethods1;
end;


// -------------------------------------------------------------------------------------------------------------------------------
function TServerContainer1.openCheckDb: Boolean;
// 1-st setup correct driver & Parms for our local SQLite Database.
// 2-nd Try to Open() the Database.
// 3-rd Try to read all current GUID's from the RegisteredClients table.
// 4-th & on Exception = 'no such table' or 'db' dose NOT exist yet then
// 5-th Create the RegisteredClients table.
// 6-th Database should be ready for select's & insert's now
var
  s: string;
  n: integer;
begin
  n:= 0;
  Try
    // Remember this is our Servers local SQLite DataBase we are talking to...
    // NOTES: For SQLite do these settings to support multiple threads updating the same DB
    // SQLite Transactions, Locking, Threads and Cursors see:  http://docwiki.embarcadero.com/RADStudio/XE8/en/Using_SQLite_with_FireDAC#Hooking_Database_Updates
    // Locking and Concurrent Updates
    // Read the following original SQLite articles:
    // BEGIN TRANSACTION
    // SQLite Shared-Cache Mode
    // Corruption Following Busy
    // SQLite, as a file-server DBMS, locks the database tables at updates. The following settings affect the concurrent access:
    //
    // when multiple threads are updating the same database, set the SharedCache connection parameter to False. This helps you avoid some possible deadlocks.
    // when multiple processes or threads are updating the same database tables, set LockingMode to Normal to enable concurrent access to the tables. Also set
    // the Synchronous connection parameter to Full or Normal. In this way, SQLite updates a database file right after the transaction is finished and other
    // connections see the updates on the predictable basis.
    // to avoid locking conflicts between connections, set UpdateOptions.LockWait to True and BusyTimeout to a higher value.
    // to avoid locking conflicts between long running updating transactions, set TADConnection.TxOptions.Isolation to xiSnapshot or xiSerializible.
    // All of these are set in the design-time parms of FDConnection1
    FDConnection1.Params.Clear;
    FDConnection1.Params.Add('DriverID=SQLite');
    FDConnection1.Params.Add('Database=' + '..\..\GUID.sdb');
    FDConnection1.Open();
    n:= getGUIDList(FDQuery1);
  Except
    on E: Exception do
      begin
        s:= E.Message;
        if Pos('no such table', s) <> 0 then
          begin
            FDQuery1.SQL.Clear;
            FDQuery1.SQL.Add('CREATE TABLE RegisteredClients(ClientID varchar(38), CallbackID varchar(20), ClientEnabled varchar(1), GymName varchar(60), ' +
              'GymAddress varchar(350), GymEmail varchar(200), ClassLvl varchar(1000), SelectClassType varchar(3000), ClassSchedules varchar(500000), ' +
              'LastAccess varchar(22))');
            FDQuery1.ExecSQL;
            n:= getGUIDList(FDQuery1);
          end;
      end;
  End;
  Result:= (n <> 0);
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TServerContainer1.getGUIDList(var aQuery: TFDQuery): integer;
begin
  // Update our GUID list on the pannel
  aQuery.Active:= false;
  aQuery.SQL.Clear;
  aQuery.SQL.Add('select * from RegisteredClients');
  aQuery.Active:= True;
  Result       := aQuery.RowsAffected;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerContainer1.InsertClient(var aQuery: TFDQuery; const clientID: string; const callbackID: string; const GymName: string; const GymAddress: string;
  const GymEmail: string; const ClassLvl: string; const SelectClassType: string; const ClassSchedules: string);
begin
  Try
    aQuery.Active:= false;
    aQuery.SQL.Clear;
    aQuery.SQL.Add('INSERT INTO RegisteredClients (ClientID, CallbackID, ClientEnabled, GymName, GymAddress, GymEmail, ClassLvl, SelectClassType, ClassSchedules, LastAccess)');
    aQuery.SQL.Add('VALUES (:ClientID, :CallbackID, :ClientEnabled, :GymName, :GymAddress, :GymEmail, :ClassLvl, :SelectClassType, :ClassSchedules, :LastAccess)');
    aQuery.Params.ParamByName('ClientID').Value  := clientID;
    aQuery.Params.ParamByName('CallbackID').Value:= callbackID;
{$ifdef Debug}
    aQuery.Params.ParamByName('ClientEnabled').Value := '1'; // In Debug mode only New clients are added and enabled='1' for testing.
{$else}
    aQuery.Params.ParamByName('ClientEnabled').Value := '0'; // New clients are added by GUID and disabled='0' by default
{$endif Debug}
    aQuery.Params.ParamByName('GymName').Value        := GymName;
    aQuery.Params.ParamByName('GymAddress').Value     := GymAddress;
    aQuery.Params.ParamByName('GymEmail').Value       := GymEmail;
    aQuery.Params.ParamByName('ClassLvl').Value       := ClassLvl;
    aQuery.Params.ParamByName('SelectClassType').Value:= SelectClassType;
    aQuery.Params.ParamByName('ClassSchedules').Value := ClassSchedules;
    aQuery.Params.ParamByName('LastAccess').Value     := DateTimeToStr(now);
    aQuery.ExecSQL;
    aQuery.Close;
  Except
    on E: Exception do
      begin
        SendMsg('Query Exception - in InsertClient() ' + E.Message);
        SendMsg(aQuery.SQL.Text);
      end;
  End;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TServerContainer1.UpdatedClient(var aQuery: TFDQuery;const clientID: string;const callbackID: string; const GymName: string;const GymAddress: string;
  const GymEmail: string;const ClassLvl: string; const SelectClassType: string;const ClassSchedules: string);
var
  s: string;
begin
  Try
    aQuery.Active:= false;
    aQuery.SQL.Clear;

    s:= 'UPDATE RegisteredClients SET GymName = ' + QuotedStr(GymName) + ', GymAddress = ' + QuotedStr(GymAddress) + ', GymEmail = ' + QuotedStr(GymEmail) +
    ', ClassLvl = ' + QuotedStr(ClassLvl) + ' WHERE ClientID = ' + QuotedStr(clientID);
    aQuery.SQL.Add(s);
    aQuery.ExecSQL;

    aQuery.SQL.Clear;
    s:= 'UPDATE RegisteredClients SET SelectClassType = ' + QuotedStr(SelectClassType) + ' WHERE ClientID = ' + QuotedStr(clientID);
    aQuery.SQL.Add(s);
    aQuery.ExecSQL;

    aQuery.SQL.Clear;
    s:= 'UPDATE RegisteredClients SET ClassSchedules = ' + QuotedStr(ClassSchedules) + ' WHERE ClientID = ' + QuotedStr(clientID);
    aQuery.SQL.Add(s);
    aQuery.ExecSQL;
  Except
    on E: Exception do
      begin
        SendMsg('Query Exception - in UpdateClient() ' + E.Message);
        SendMsg(aQuery.SQL.Text);
      end;
  End;
end;

// -------------------------------------------------------------------------------------------------------------------------------
initialization

// Creates a initial Server Container at start, it holds the server.
FModule:= TServerContainer1.Create(nil);

finalization

FModule.Free;

// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
end.
