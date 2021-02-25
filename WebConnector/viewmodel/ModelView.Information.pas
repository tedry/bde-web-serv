unit ModelView.Information;

interface

uses
  Model.Information;

type
  TInformationViewModel = class( TObject )
    strict private
      FInfo: TInfo;
    protected
    //
    public
      constructor Create;
      destructor Destroy; override;
      property Info: TInfo read FInfo write FInfo; // expose part of our model
  end;

implementation

{ TInformationViewModel }
// ---------------------------------------------------------------------------------------------------------------------
constructor TInformationViewModel.Create;
begin
  inherited;
  FInfo:= TInfo.Create;
end;

// ---------------------------------------------------------------------------------------------------------------------
destructor TInformationViewModel.Destroy;
begin
  if Assigned(FInfo) then
   FInfo.Free; // Don't use FreeAndNil() so we don't need System.SysUtils
  FInfo:= nil;
  inherited;
end;

end.
