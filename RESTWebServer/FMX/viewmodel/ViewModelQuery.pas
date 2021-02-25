unit ViewModelQuery;

interface

uses
  System.Classes;

type

  TQueries = class( TObject )
    private
{$IFDEF NOTUSEDYET}
      f_GUID: string;
      procedure query_login ( const user: string; const passwd: string );
{$ENDIF NOTUSEDYET}
    public
{$IFDEF NOTUSEDYET}
      constructor Create ( AOwner: TComponent ); override;
{$ENDIF NOTUSEDYET}
      destructor Destroy; override;
  end; // TQuery

implementation

{ TQueries }

{$IFDEF NOTUSEDYET}
constructor TQueries.Create ( AOwner: TComponent );
begin
  inherited;
end;
{$ENDIF NOTUSEDYET}

destructor TQueries.Destroy;
begin

  inherited;
end;

// -------------------------------------------------------------------------------------------------------------------------------
{$IFDEF NOTUSEDYET}

procedure TQueries.query_login ( const user: string; const passwd: string );
var
  // aResponse    : TJSONValue;
  sName, sValue: string;
begin
  // GET correct client_id & callback_id
  // if ListBoxGUID.ItemIndex <> - 1 then // do we have somthing selected ?
  begin
    (* sName := ListBoxGUID.Items.Names[ListBoxGUID.ItemIndex];
      sValue:= ListBoxGUID.Items.ValueFromIndex[ListBoxGUID.ItemIndex];
     if ( sName <> '' ) and ( sValue <> '' ) then
     begin // performs synchronous message delivery to a callback located in a client channel
     // DSServer.NotifyCallback ( sName, sValue, TJSONString.Create( 'query-in Select * from Clients' ), aResponse );
     DSServer.NotifyCallback ( sName, sValue, TJSONString.Create( 'query-in Select * from Classes' ), aResponse );
     Memo1.Lines.Add ( aResponse.ToString );

     end;
    *)
  end;
end;
{$ENDIF NOTUSEDYET}

end.
