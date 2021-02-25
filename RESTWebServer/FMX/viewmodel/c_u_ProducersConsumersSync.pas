{ ********************************************************************************************************************** }
{ TProduceConsumeSync ™ }
{ }
{ Copyright © 2018 SWPage LLC. All rights reserved. }
{ }
{ ---------------------------------------------------------------------------------------------------------------------- }
{ File -  c_u_ProduConsuSync.pas 0.01.19.2017 Jan 19 2018 }
{ Author - Ted Rybicki (tr) Jan 2018 }
{ http: www.swpage.com }
{ This unit should contain all type definitions that need global scoping to our application. }
{ GLOBAL NOTES: }
{ }
{ This class-unit-ProducerConsumer-Sync: Handles ALL Shared multi & single producer/ multi & single consumer data needs }
{ On Windows OS systems: }
{ Compile using Delphi RAD Studio XE 10.2 }
{ }
{ On Linux OS systems: NOT SUPPORTED YET! }
{ }
{ }
{ }
{ }
{ ---------------------------------------------------------------------------------------------------------------------- }
{ $REVISIONS:  0.01.19.2018 Jan 19 2018 - Ted Rybicki (tr) }
{ ********************************************************************************************************************** }
unit c_u_ProducersConsumersSync;

interface

uses
  Windows,
  SysUtils;

const
  MaxBuffers = 127;

type
  TProduceConsumeSync = class
    private
      m_timeout : DWORD;
      FHasData  : THandle; { a semaphore }
      FNeedsData: THandle; { a semaphore }
    protected
    public
      constructor Create ( var aBufferCount: integer; const aTimeout: DWORD );
      destructor Destroy; override;

      function StartProducing: DWORD;
      procedure StopProducing;

      function StartConsuming: DWORD;
      procedure StopConsuming;
  end;

var
  c_SyncObj: TProduceConsumeSync;

implementation

// ----------------------------------------------------------Helper routines------------------------------------------------------------
// {$ifdef Delphi2009}
// procedure GetRandomObjName(aDest : PAnsiChar; const aRootName : string);
// {$else}
procedure GetRandomObjName ( aDest: PChar; const aRootName: string );
// {$endif}
var
  Len: integer;
  i  : integer;
begin
  Len:= length ( aRootName );
  // {$ifdef Delphi2009}
  // StrCopy(aDest, PAnsiChar(aRootName));
  // {$else}
  StrCopy ( aDest, PChar( aRootName ));
  // {$endif}
  inc ( aDest, Len );
  aDest^:= '/';
  inc ( aDest );
  for i:= 1 to 10 do
    begin
      // {$ifdef Delphi2009}
      // aDest^ := AnsiChar(Random(26) + ord('A'));
      // {$else}
      aDest^:= chr ( Random( 26 ) + ord( 'A' ));
      // {$endif}
      inc ( aDest );
    end;
  aDest^:= #0;
end;

// -------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------TProduceConsumeSync----------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------------
constructor TProduceConsumeSync.Create ( var aBufferCount: integer; const aTimeout: DWORD );
var
  // {$ifdef Delphi2009}
  // NameZ : array [0..MAX_PATH] of AnsiChar;
  // {$else}
  NameZ: array [0 .. MAX_PATH] of Char;
  // {$endif}
begin
  inherited Create;
  { create the primitive synchronization objects; note that the "needs
    data" semaphore is set up with the required count so that the
    producer can start immediately }
  m_timeout:= aTimeout; // You can also pass INFINITE  here

  FNeedsData:= INVALID_HANDLE_VALUE;

  GetRandomObjName ( NameZ, 'HasData' );

  if ( aBufferCount > MaxBuffers ) or ( aBufferCount <= 0 ) then
    aBufferCount:= MaxBuffers;

  FHasData:= CreateSemaphore ( nil, 0, aBufferCount, NameZ );
  if ( FHasData = INVALID_HANDLE_VALUE ) then
    RaiseLastOSError;

  GetRandomObjName ( NameZ, 'NeedsData' );
  FNeedsData:= CreateSemaphore ( nil, aBufferCount, aBufferCount, NameZ );
  // Start with NeedsData = aBfferCount ie. All empty slots
  if ( FNeedsData = INVALID_HANDLE_VALUE ) then
    RaiseLastOSError;
end;

// -------------------------------------------------------------------------------------------------------------------------------------
destructor TProduceConsumeSync.Destroy;
begin
  Try
    if ( FHasData <> INVALID_HANDLE_VALUE ) then
      CloseHandle ( FHasData );
    if ( FNeedsData <> INVALID_HANDLE_VALUE ) then
      CloseHandle ( FNeedsData );
    inherited Destroy;
  Except
  end;
end;

// -------------------------------------------------------------------------------------------------------------------------------------
function TProduceConsumeSync.StartProducing: DWORD;
begin
  { to start producing, the "needs data" semaphore needs to be signalled }
  Result:= WaitForSingleObject ( FNeedsData, m_timeout );
end;

// -------------------------------------------------------------------------------------------------------------------------------------
procedure TProduceConsumeSync.StopProducing;
begin
  { if we've produced some more data, we should signal the consumer to use it up }
  ReleaseSemaphore ( FHasData, 1, nil );
end;

// -------------------------------------------------------------------------------------------------------------------------------------
function TProduceConsumeSync.StartConsuming: DWORD;
begin
  { to start consuming, the "has data" semaphore needs to be signalled, Result = 0 is ok = object is signaled }
  Result:= WaitForSingleObject ( FHasData, m_timeout );
end;

// -------------------------------------------------------------------------------------------------------------------------------------
procedure TProduceConsumeSync.StopConsuming;
begin
  { if we've consumed some data, we should signal the producer to generate some more }
  ReleaseSemaphore ( FNeedsData, 1, nil );
end;

// -------------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------------
end.
