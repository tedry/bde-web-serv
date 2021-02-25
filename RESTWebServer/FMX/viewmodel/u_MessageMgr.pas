unit u_MessageMgr;

interface

uses
  Classes;

type
  tAllOSMessage = procedure(sMessage: string) of object;

  TMessageHandler = class
    private
      fOnMessage: tAllOSMessage;
    public
      constructor Create(aMessageCallBack: tAllOSMessage);
      procedure PostMessage(sMessage: string);
  end;

var
  gMsgHandler: TMessageHandler;

implementation

// -------------------------------------------------------------------------------------------------------------------------------------------------------------
constructor TMessageHandler.Create(aMessageCallBack: tAllOSMessage);
begin
  fOnMessage:= aMessageCallBack;
end;

// -------------------------------------------------------------------------------------------------------------------------------------------------------------
procedure TMessageHandler.PostMessage(sMessage: string);
begin
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(fOnMessage) then
        fOnMessage(sMessage);
    end);
end;

end.
