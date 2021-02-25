{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$ZEROBASEDSTRINGS ON} // default this for all new application so it's the same in Windows as in Moble apps
{$POINTERMATH ON}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE ON}
{$WARN UNSAFE_CODE ON}
{$WARN UNSAFE_CAST ON}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN NON_PORTABLE_TYPECAST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
{$WARN IMMUTABLE_STRINGS ON}
unit model.information;

interface

uses
  System.IniFiles,
  System.Classes;

type
  TInfoStatus = ( current, update, refreshed );

  Tinfo = class( TPersistent )
    strict private
      { private declarations }
      FTitle       : string;
      FVersion     : string;
      FIP          : string;
      FPORT        : string; // DataSnap Port
      FWEBPORT     : string; // Web-server Port
      FMyGUID      : TGUID;
      FMyClientID  : string;
      FMyCallbackID: string;
      FClientEnabled: boolean;
    private
      function GetKeys ( const aKey: string ): string;
      procedure SetKeys ( const aKey: string; const aValue: string );
    protected
      { protected declarations }
    public
      { public declarations }
      constructor Create;
      destructor Destroy; override;
      function StringInfo ( const aString: String ): String;

      property Title: string read FTitle write FTitle;
      property Version: string read FVersion write FVersion;
      property ClientID: string read FMyClientID;
      property CallbackID: string read FMyCallbackID write FMyCallbackID;
      property Port: string read FPORT write FPORT;
      property WebPort: string read FWEBPORT write FWEBPORT;
      property IP: string read FIP write FIP;
      property ClientEnabled: boolean read FClientEnabled write FClientEnabled;
  end;

implementation

uses
{$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.NativeActivity,
{$ENDIF ANDROID}
{$IFDEF MACOS}
  Macapi.CoreFoundation,
{$ENDIF MACOS}
  System.SysUtils,
{$IFDEF MSWINDOWS}
  Datasnap.DSSession,
  Winapi.Windows;
{$ENDIF MSWINDOWS}

const
  HEADTITLE = 'AEG Web-Connector';
  INIFILE   = '.\Web-Connector.ini';
  FIXED_CALLBACK_ID = '000000.000000.032218';

{$IFDEF ANDROID}
// ---------------------------------------------------------------------------------------------------------------------
function GetPackageInfo: JPackageInfo;
var
  Activity: JActivity;
begin
  Activity:= TJNativeActivity.Wrap ( PANativeActivity( System.DelphiActivity )^.clazz );
  Result  := Activity.getPackageManager.GetPackageInfo ( Activity.getPackageName, 0 );
end;

// ---------------------------------------------------------------------------------------------------------------------
function GetAppVersionStr: string;
var
  Info: JPackageInfo;
begin
  Info  := GetPackageInfo;
  Result:= Format ( 'versionName: "%s", versionCode: %d', [JStringToString( Info.versionName ), Info.versionCode]);
end;
{$ENDIF ANDROID}

//
{$IFDEF IOS}
{$ENDIF IOS}
//
{$IFDEF MACOS}
// ---------------------------------------------------------------------------------------------------------------------
function GetAppVersionStr: string;
var
  CFStr: CFStringRef;
  Range: CFRange;
begin
  CFStr         := CFBundleGetValueForInfoDictionaryKey ( CFBundleGetMainBundle, kCFBundleVersionKey );
  Range.location:= 0;
  Range.length  := CFStringGetLength ( CFStr );
  SetLength ( Result, Range.length );
  CFStringGetCharacters ( CFStr, Range, PChar( Result ));
end;
{$ENDIF MACOS}
//
{$IFDEF MSWINDOWS}
// ---------------------------------------------------------------------------------------------------------------------
function GetAppVersionStr: string;
var
  Exe         : string;
  Size, Handle: longword;
  Buffer      : TBytes;
  FixedPtr    : PVSFixedFileInfo;
begin
  Exe := ParamStr ( 0 );
  Size:= GetFileVersionInfoSize ( PChar( Exe ), Handle );
  if Size = 0 then
    RaiseLastOSError;
  SetLength ( Buffer, Size );
  if not GetFileVersionInfo ( PChar( Exe ), Handle, Size, Buffer ) then
    RaiseLastOSError;
  if not VerQueryValue ( Buffer, '\', Pointer( FixedPtr ), Size ) then
    RaiseLastOSError;
  {$Warnings Off}
  Result:= Format ( '%d.%d.%d.%d',
            [1,5,0,134]);
 { TODO -oted -cShouldDo :
FileVersionMS offsets seem to now fail.. Need to look into this latter.
For now I'll use ProductVersion as it seems to still work. }
(*
  Result:= Format ( '%d.%d.%d.%d',
           [LongRec(FixedPtr.dwProductVersionMS ).Hi,
            LongRec(FixedPtr.dwProductVersionMS ).Lo,
            LongRec(FixedPtr.dwProductVersionLS ).Hi,
            LongRec(FixedPtr.dwProductVersionLS ).Lo]);

  Result:= Format ( '%d.%d.%d.%d', [LongRec( FixedPtr.dwFileVersionMS ).Hi, // major
    LongRec( FixedPtr.dwFileVersionMS ).Lo,  // minor
    LongRec( FixedPtr.dwFileVersionLS ).Hi,  // release
    LongRec( FixedPtr.dwFileVersionLS ).Lo]) // build
*)
  {$Warnings On}
end;
{$ENDIF MSWINDOWS}

// ---------------------------------------------------------------------------------------------------------------------
function stripbraces ( const s: string ): string;
var
  i: integer;
begin
  Result:= s;
  i     := Pos ( '{', Result );
  if i > 0 then
    Delete ( Result, i, 1 );
  i:= Pos ( '}', Result );
  if i > 0 then
    Delete ( Result, i, 1 );
end;

{ Tinfo }
// ---------------------------------------------------------------------------------------------------------------------
constructor Tinfo.Create;
var
  s: string;
begin
  FTitle  := HEADTITLE + ' ';
  FVersion:= GetAppVersionStr;

  s:= GetKeys ( 'client_id' );
  if ( s = '' ) then
    begin
      CreateGUID ( FMyGUID );
      FMyClientID:= stripbraces ( GUIDToString( FMyGUID ));
      SetKeys ( 'client_id', FMyClientID );
    end
  else
    FMyClientID:= s;

  s:= GetKeys ( 'callback_id' );
  if ( s = '' ) then
    begin
{$ifdef GetUniqueSessionID}
      FMyCallbackID:= TDSTunnelSession.GenerateSessionId;
{$else}
      FMyCallbackID:= FIXED_CALLBACK_ID; // We can just about always use a fixed ID, every client on same channel
{$endif}
      SetKeys ( 'callback_id', FMyCallbackID );
    end
  else
    FMyCallbackID:= s;
end;

// ---------------------------------------------------------------------------------------------------------------------
destructor Tinfo.Destroy;
begin
  inherited;
end;

// ---------------------------------------------------------------------------------------------------------------------
function Tinfo.GetKeys ( const aKey: string ): string;
Var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create ( INIFILE);
  try
    Result:= Ini.ReadString ( 'GUID', aKey, '' );
  finally
    Ini.Free;
  end;
end;

// ---------------------------------------------------------------------------------------------------------------------
procedure Tinfo.SetKeys ( const aKey: string; const aValue: string );
Var
  Ini: TIniFile;
begin
  Ini:= TIniFile.Create ( INIFILE );
  try
    Ini.WriteString ( 'GUID', aKey, aValue );
  finally
    Ini.Free;
  end;
end;

// ---------------------------------------------------------------------------------------------------------------------
function Tinfo.StringInfo ( const aString: String ): String;
begin
  Result:= 'Addr: ' + IntToStr ( integer( Pointer( aString ) )) + ', SizeOf: ' + sizeof ( aString ).ToString ( ) + ', Len: ' +
    aString.length.ToString + // IntToStr ( length( aString )) +
    ', ElemtSize: ' + StringElementSize ( aString ).ToString ( ) + ', CPage: ' + StringCodePage ( aString ).ToString ( ) +
    ', Ref: ' + StringRefCount ( aString ).ToString ( ) + // IntToStr ( PInteger( Integer( pointer(aString) ) - 8 )^) +
    ', Val: ' + aString;
end;

end.
