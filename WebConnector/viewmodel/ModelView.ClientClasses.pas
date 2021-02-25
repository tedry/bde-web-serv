unit ModelView.ClientClasses;

interface
uses
  Data.DBXCommon,
  ClientClassesUnit;

type
  TClientClassesViewModel = class( TObject )
    strict private
      FServer: TServerMethods1Client;
    protected
    //
    public
      constructor Create(ADBXConnection: TDBXConnection);
      destructor Destroy; override;
      property Server: TServerMethods1Client read FServer write FServer; // expose part of our model
  end;

implementation

// ---------------------------------------------------------------------------------------------------------------------
constructor TClientClassesViewModel.Create(ADBXConnection: TDBXConnection);
begin
  // inherited;
  FServer:= TServerMethods1Client.Create(ADBXConnection);
end;

// ---------------------------------------------------------------------------------------------------------------------
destructor TClientClassesViewModel.Destroy;
begin
  if Assigned(FServer) then
   FServer.Free; // Don't use FreeAndNil() so we don't need System.SysUtils
  FServer:= nil;
  inherited;
end;

end.
