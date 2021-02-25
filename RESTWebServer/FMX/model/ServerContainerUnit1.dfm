object ServerContainer1: TServerContainer1
  OldCreateOrder = False
  Height = 355
  Width = 584
  object DSServer1: TDSServer
    Left = 32
    Top = 23
  end
  object DSServerClass1: TDSServerClass
    OnGetClass = DSServerClass1GetClass
    Server = DSServer1
    Left = 64
    Top = 85
  end
  object DSTCPServerTransport1: TDSTCPServerTransport
    Port = 21121
    Server = DSServer1
    Filters = <>
    KeepAliveEnablement = kaEnabled
    Left = 90
    Top = 154
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 337
    Top = 128
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from RegisteredClients')
    Left = 480
    Top = 150
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=SQLite'
      'Database=..\..\GUID.sdb'
      'SharedCache=False'
      'LockingMode=Normal'
      'Synchronous=Full'
      'BusyTimeout=15000'
      'CacheSize=20000')
    UpdateOptions.AssignedValues = [uvLockMode, uvLockWait]
    UpdateOptions.LockMode = lmOptimistic
    UpdateOptions.LockWait = True
    LoginPrompt = False
    Left = 489
    Top = 77
  end
  object DSAuthenticationManager1: TDSAuthenticationManager
    OnUserAuthenticate = DSAuthenticationManager1UserAuthenticate
    OnUserAuthorize = DSAuthenticationManager1UserAuthorize
    Roles = <>
    Left = 399
    Top = 15
  end
  object FDQuery2: TFDQuery
    Connection = FDConnection1
    Left = 470
    Top = 224
  end
end
