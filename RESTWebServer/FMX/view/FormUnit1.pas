{ ********************************************************************************************************************** }
{ aegCallBackRESTWebServer ™ }
{ }
{ Copyright © 2018-2019 SWPage LLC. All rights reserved. }
{ }
{ ---------------------------------------------------------------------------------------------------------------------- }
{ File -  FormUnit1.pas 0.01.19.2017 Jan 19 2018 }
{ Author - Ted Rybicki (tr) Jan 2018 }
{ http: www.swpage.com }
{ This unit should contain all type definitions that need global scoping to our application. }
{ }
{ GLOBAL NOTES: }
{ }
{ This project is using MVVM & built in XE10.2 Style & View. }
{ }
{ The MVVM (Modle-View-ViewModel) separates your GUI from the Data & Logic. }
{ NOTES: }
{ 1. Presentation Logic = 'Views' & 'ViewModel', 'ViewModel' know notihng about the Views, LiveBinding ties View to }
{ ViewModels. }
{ 2. Domain Logic = 'Model' and is always NON-Visual stuff. }
{ 3. Data Access Logic = MVVM has nothing to say about this; howerver this could be expanded ... ie... DataModels }
{ }
{ Views(GUI) = 'ViewModel' (Model(knows nothing about the Views) -- > Model(Knows nothing about ViewModels) }
{ |<-livebinding->| }
{ }
{ 'View' = Is Visual & HARD to Test, these are your Forms in delphi/Visual rendering of a ViewModel, we have editboxes }
{ and forms and buttons for example. Use Livebinding to bind the ViewModel state & data and display it inside your }
{ view. }
{ HARD TO TEST! KEEP IT SMALL & SIMPLE! NO Persistance, NO Inversion Of Control IoC! }
{ For example: In this file unit main we have our TFormMain. HOWERVER NOTICE how we have very simple code logic that }
{ is focused at the GUI with little or NO focus on the "How" or Domain Logic='Model'. Also main has little or NO }
{ focus on the "What" or Data & Access Logic='ViewModel'. }
{ }
{ 'ViewModel' = NON-Visual/Easy to Test, is the Model of your UI, for a Form this is a model of all logic & data, }
{ UI rules, work flows and the proceses that a user may interact with the Form, it knows about state & processes. }
{ }
{ 'Model' = NON-Visual & Easy to Test, The Model of your Problem Domain. }
{ If your building an Audio/Video app it's about Audio/Video Src's, Users,Groups,Rooms, Settings, Sharing, Connecting, }
{ If your building a iTunes app it's all about artists, sonds, plays, ratings, etc. }
{ In an Accounting App it's Accounts, Transactions, etc }
{ In SSalesForce it's Customers, Activities, Forecasts, Opportunitites, etc..etc..etc.. }
{ }
{ This TFormMain: Handles ALL Shared multi & single producer/ multi & single consumer data needs }
{ On Windows OS systems: }
{ Compile using Delphi RAD Studio XE 10.2 }
{ }
{ On Linux OS systems: NOT SUPPORTED YET! }
{ }
{ ---------------------------------------------------------------------------------------------------------------------- }
{ $REVISIONS:  0.01.19.2018 Jan 19 2018 - Ted Rybicki (tr) }
{ ********************************************************************************************************************** }
unit FormUnit1;

interface

uses
  ServerContainerUnit1,
  System.Classes,
  System.Messaging,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Edit,
  IdHTTPWebBrokerBridge,
  Web.HTTPApp,
  FMX.Controls.Presentation,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.ListBox,
  System.Rtti,
  FMX.Grid.Style,
  Data.Bind.EngExt,
  FMX.Bind.DBEngExt,
  FMX.Bind.Grid,
  System.Bindings.Outputs,
  FMX.Bind.Editors,
  Data.Bind.Components,
  Data.Bind.Grid,
  Data.Bind.DBScope,
  FMX.Grid,
  Data.Bind.Controls,
  FMX.Bind.Navigator, Data.DB;

type
  TFormMain = class( TForm )
    ButtonStart: TButton;
    ButtonStop: TButton;
    EditPort: TEdit;
    Label1: TLabel;
    ButtonOpenBrowser: TButton;
    TabControl1: TTabControl;
    TabItemGUID: TTabItem;
    TabItemLog: TTabItem;
    MemoLog: TMemo;
    ListBoxGUID: TListBox;
    TabItemQuery: TTabItem;
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    Label2: TLabel;
    ed_data_port: TEdit;
    Panel1: TPanel;
    Label3: TLabel;
    bt_Echo: TButton;
    bt_Query: TButton;
    StatusBar1: TStatusBar;
    statusbar_label1: TLabel;
    NavigatorBindSourceDB1: TBindNavigator;
    ed_broadcastmsg: TEdit;
    chk_AutoInsert: TCheckBox;
    btn_EnableClient: TButton;
    btn_DisableClient: TButton;
    procedure FormCreate( Sender: TObject );
    procedure ButtonStartClick( Sender: TObject );
    procedure ButtonStopClick( Sender: TObject );
    procedure ButtonOpenBrowserClick( Sender: TObject );
    procedure FormShow( Sender: TObject );
    procedure bt_QueryClick( Sender: TObject );
    procedure MemoLogDblClick( Sender: TObject );
    procedure bt_EchoClick( Sender: TObject );
    procedure ed_data_portKeyDown( Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState );
    procedure FormDestroy( Sender: TObject );
    procedure TabItemGUIDClick( Sender: TObject );
    procedure TabItemLogClick( Sender: TObject );
    procedure TabItemQueryClick( Sender: TObject );
    procedure btn_EnableClientClick( Sender: TObject );
    procedure btn_DisableClientClick( Sender: TObject );
    private
      { Private declarations }
      FServer: TIdHTTPWebBrokerBridge;

{$IFDEF TedNotYet}

      fMsgMgrId: Integer;

{$ENDIF TedNotYet}

      procedure StartServer;
      procedure ApplicationIdle( Sender: TObject; var Done: Boolean );

{$IFDEF TedNotYet}

      procedure ProcessAppMessages( const Sender: TObject; const M: TMessage );

{$ENDIF TedNotYet}

      function GetWebServerPort: string;
      procedure SendMsg( const sMsg: string );
    public
      { Public declarations }

{$IFDEF TedNotYet}

      fMessageManager: TMessageManager;

{$ENDIF}

      procedure GUIDNewList( var sl: TStringList );
      procedure GUIDUpdate( const s: string );
      procedure MsgCallBackHandler( sMessage: string );
      property WebServerPort: string read GetWebServerPort;

  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

uses
  u_MessageMgr,
  System.JSON,
  WinApi.Windows,
  WinApi.ShellApi,
  Datasnap.DSProxy,
  Datasnap.DSSession;

// --------------------------- ----------------------------------------------------------------------------------------------------
procedure TerminateThreads;
begin
  if TDSSessionManager.Instance <> nil then
    TDSSessionManager.Instance.TerminateAllSessions;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.FormCreate( Sender: TObject );
begin
  Application.OnIdle := ApplicationIdle;
  FServer            := TIdHTTPWebBrokerBridge.Create( Self );

{$IFDEF TedNotYet}

  fMessageManager := TMessageManager.DefaultManager; // Obtaining an Instance of the Message Manager
  // Once you have an instance of TMessageManager, you can subscribe message-handling methods to specific types of messages.
  // Message-handling methods may be methods of an object or anonymous methods.
  // The following code shows how to subscribe an anonymous method:
  // fSubscriptionId:= fMessageManager.SubscribeToMessage(TMessage<UnicodeString>,
  // procedure(const Sender: TObject; const M: TMessage)
  // begin
  // ShowMessage((M as TMessage<UnicodeString>).Value);
  //
  // end);
  //
  fMsgMgrId := fMessageManager.SubscribeToMessage( TMessage< UnicodeString >, ProcessAppMessages );

{$ELSE}

  gMsgHandler := TMessageHandler.Create( MsgCallBackHandler );

{$ENDIF TedNotYet}

end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.FormDestroy( Sender: TObject );
begin
  FreeAndNil( gMsgHandler )
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.FormShow( Sender: TObject );
begin
  StartServer;
  ed_data_port.Text              := ServerContainer.DSTCPServerTransport1.Port.ToString;
  NavigatorBindSourceDB1.Visible := false; // default to only show in Query Tab

{$IFDEF TedNotYet}

  ServerContainer.MessageManager := fMessageManager;

{$ENDIF}

end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.StartServer;
begin
  if not FServer.Active then
    begin
      FServer.Bindings.Clear;
      FServer.DefaultPort := StrToInt( EditPort.Text );
      FServer.Active      := True;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.TabItemGUIDClick( Sender: TObject );
begin
  NavigatorBindSourceDB1.Visible := false;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.TabItemLogClick( Sender: TObject );
begin
  NavigatorBindSourceDB1.Visible := false;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.TabItemQueryClick( Sender: TObject );
begin
  NavigatorBindSourceDB1.Visible := True;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.ApplicationIdle( Sender: TObject; var Done: Boolean );
begin
  ButtonStart.Enabled := not FServer.Active;
  ButtonStop.Enabled  := FServer.Active;
  EditPort.Enabled    := not FServer.Active;
end;

// -------------------------------------------------------------------------------------------------------------------------------

{$IFDEF TedNotYet}

procedure TFormMain.ProcessAppMessages( const Sender: TObject; const M: TMessage );
var
  sMsg: string;
  // sid : string;
begin
  // ShowMessage((M as TMessage<UnicodeString>).Value);
  sMsg := ( M as TMessage< UnicodeString >).Value;
  if ( sMsg <> '' ) then
    MemoLog.Lines.Add( sMsg );
  // sid:= Copy(s, Pos(':', s)+1,length(s) );
end;

{$ENDIF TedNotYet}

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.MsgCallBackHandler( sMessage: string );
// Use this method to handle updates from other threads into the main thread to keep things safe.
var
  i: Integer;
begin
  if ( sMessage <> '' ) then
    begin
      if Pos( 'GUID', sMessage ) <> 0 then
        begin
          Delete( sMessage, 1, 4 );
          // delete 'GUID' { TODO -oted -cMustDo : Use a name {port GUID} insted of hard coded index ie. 7 }
          if Pos( ' delete ', sMessage ) <> 0 then
            begin
              if ( ListBoxGUID.Count > 0 ) then
                begin
                  Delete( sMessage, 1, 8 ); // delete ' delete '
                  i := ListBoxGUID.Items.IndexOfName( sMessage );
                  if ( i <> - 1 ) then
                    ListBoxGUID.Items.Delete( i );
                end;
            end
          else
            ListBoxGUID.Items.Add( sMessage );
        end
      else
        if Pos( 'Log', sMessage ) <> 0 then
          begin
            Delete( sMessage, 1, 3 ); // delete 'Log'
            MemoLog.Lines.Add( sMessage );
          end
        else
          if Pos( 'Query', sMessage ) <> 0 then
            begin
              Delete( sMessage, 1, 5 ); // delete 'Query'
            end;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.SendMsg( const sMsg: string );

{$IFDEF TedNotYet}

var
  Message: TMessage;

{$ENDIF TedNotYet}

begin

{$IFDEF TedNotYet}

  if Assigned( fMessageManager ) then
    begin
      message := TMessage< UnicodeString >.Create( sMsg );
      fMessageManager.SendMessage( Self, message, True );
    end;

{$ELSE}

  gMsgHandler.PostMessage( sMsg );

{$ENDIF}

end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.MemoLogDblClick( Sender: TObject );
begin
  MemoLog.ClearContent;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.ButtonOpenBrowserClick( Sender: TObject );
var
  LURL:  string;
  sName: string;
begin
  StartServer; // make sure we are running

  // GET a client_id GUID
  if ListBoxGUID.ItemIndex <> - 1 then // do we have somthing selected ?
    begin
      sName := ListBoxGUID.Items.Names[ListBoxGUID.ItemIndex];
      // sValue:= ListBoxGUID.Items.ValueFromIndex[ListBoxGUID.ItemIndex];
      LURL := Format( 'http://localhost:%s/GUID?%s', [EditPort.Text, sName]);
    end
  else
    begin
      statusbar_label1.Text := 'Please select a GUID...';
      LURL                  := Format( 'http://localhost:%s', [EditPort.Text]);
    end;

  ShellExecute( 0, nil, PChar( LURL ), nil, nil, SW_SHOWNOACTIVATE );
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.ButtonStartClick( Sender: TObject );
begin
  StartServer;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.ButtonStopClick( Sender: TObject );
begin
  TerminateThreads;
  FServer.Active := false;
  FServer.Bindings.Clear;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.ed_data_portKeyDown( Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState );
begin
  if ( KeyChar = #13 ) then //
    if ( ed_data_port.Text <> '' ) then
      ServerContainer.DSTCPServerTransport1.Port := ed_data_port.Text.ToInteger( );
end;

// -------------------------------------------------------------------------------------------------------------------------------
function TFormMain.GetWebServerPort: string;
begin
  Result := FServer.DefaultPort.ToString
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.GUIDNewList( var sl: TStringList );
begin
  ListBoxGUID.Clear;
  ListBoxGUID.Items.AddStrings( sl );
  ListBoxGUID.ItemIndex := 1;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.GUIDUpdate( const s: string );
var
  i: Integer;
begin
  i := ListBoxGUID.Items.IndexOf( s );
  if ( i < 0 ) then // not found
    begin
      i                     := ListBoxGUID.Items.Add( s );
      ListBoxGUID.ItemIndex := i;
    end;
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.bt_QueryClick( Sender: TObject );
var
  aResponse:     TJSONValue;
  sName, sValue: string;
begin
  // GET correct client_id & callback_id
  statusbar_label1.Text := '';
  if ListBoxGUID.ItemIndex <> - 1 then // do we have somthing selected ?
    begin
      sName  := ListBoxGUID.Items.Names[ListBoxGUID.ItemIndex];
      sValue := ListBoxGUID.Items.ValueFromIndex[ListBoxGUID.ItemIndex];
      if ( sName <> '' ) and ( sValue <> '' ) then
        begin // performs synchronous message delivery to a callback located in a client channel
          DSServer.NotifyCallback( sName, sValue, TJSONString.Create( 'query-in Select Mo_Start_Time from Classes' ),
            aResponse );
          SendMsg( aResponse.ToString );
        end;
    end
  else
    statusbar_label1.Text := 'Please select a GUID...';
end;

// -------------------------------------------------------------------------------------------------------------------------------
procedure TFormMain.btn_DisableClientClick( Sender: TObject );
var
  sID:           string;
  aResponse:     TJSONValue;
  sName, sValue: string;
  i:             Integer;
begin
  // 1. Get the selected GUID
  sID := BindSourceDB1.DataSet.FieldByName( 'ClientID' ).AsString;
  // 2. Disable the Table
  BindSourceDB1.DataSet.Edit;
  BindSourceDB1.DataSet.FieldByName( 'ClientEnabled' ).AsString := '0';
  BindSourceDB1.DataSet.Post;
  // 3. Check for active GUID in the list & snd msg
  for i := 0 to ListBoxGUID.Items.Count - 1 do
    begin
      sName  := ListBoxGUID.Items.Names[i];
      sValue := ListBoxGUID.Items.ValueFromIndex[i];
      if sName = sID then
        if ( sName <> '' ) and ( sValue <> '' ) then
          begin // performs synchronous message delivery to a callback located in a client channel
            DSServer.NotifyCallback( sName, sValue, TJSONString.Create( 'DisableClient' ), aResponse );
            SendMsg( aResponse.ToString );
          end;
    end;
end;

procedure TFormMain.btn_EnableClientClick( Sender: TObject );
var
  sID:           string;
  aResponse:     TJSONValue;
  sName, sValue: string;
  i:             Integer;
begin
  // 1. Get the selected GUID
  sID := BindSourceDB1.DataSet.FieldByName( 'ClientID' ).AsString;
  // 2. Disable the Table
  BindSourceDB1.DataSet.Edit;
  BindSourceDB1.DataSet.FieldByName( 'ClientEnabled' ).AsString := '1';
  BindSourceDB1.DataSet.Post;
  // 3. Check for active GUID in the list & snd msg
  for i := 0 to ListBoxGUID.Items.Count - 1 do
    begin
      sName  := ListBoxGUID.Items.Names[i];
      sValue := ListBoxGUID.Items.ValueFromIndex[i];
      if sName = sID then
        if ( sName <> '' ) and ( sValue <> '' ) then
          begin // performs synchronous message delivery to a callback located in a client channel
            DSServer.NotifyCallback( sName, sValue, TJSONString.Create( 'EnableClient' ), aResponse );
            SendMsg( aResponse.ToString );
          end;
    end;
end;

procedure TFormMain.bt_EchoClick( Sender: TObject );
var
  aResponse:     TJSONValue;
  sName, sValue: string;
begin
  statusbar_label1.Text := '';
  // GET a client_id & callback_id
  if ListBoxGUID.ItemIndex <> - 1 then // do we have somthing selected ?
    begin
      sName  := ListBoxGUID.Items.Names[ListBoxGUID.ItemIndex];
      sValue := ListBoxGUID.Items.ValueFromIndex[ListBoxGUID.ItemIndex];
      if ( sName <> '' ) and ( sValue <> '' ) then
        begin // performs synchronous message delivery to a callback located in a client channel
          DSServer.NotifyCallback( sName, sValue, TJSONString.Create( ed_broadcastmsg.Text ), aResponse );
          SendMsg( aResponse.ToString );
        end;
    end
  else
    statusbar_label1.Text := 'Please select a GUID...';
end;

// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
end.
