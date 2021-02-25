object ClientModule: TClientModule
  OldCreateOrder = False
  Height = 271
  Width = 415
  object SQLConnection1: TSQLConnection
    DriverName = 'DataSnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      'HostName=localhost'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=24.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b'
      'Port=211'
      'CommunicationProtocol=tcp/ip'
      'DSAuthenticationPassword=webconnector'
      'DSAuthenticationUser=user'
      'DatasnapContext=datasnap/'
      'Filters={}'
      'CommunicationTimeout=30000'
      'ConnectTimeout=30000')
    Left = 56
    Top = 40
    UniqueId = '{2818D87A-7A0C-4085-8C36-57672A88333B}'
  end
  object DSClientCallbackChannelManager1: TDSClientCallbackChannelManager
    DSHostname = 'proschoolportal.com'
    DSPort = '21121'
    CommunicationProtocol = 'tcp/ip'
    ChannelName = 'AEGWebConnector'
    ManagerId = '31670.540941.176615'
    OnServerConnectionError = DSClientCallbackChannelManager1ServerConnectionError
    OnServerConnectionTerminate = DSClientCallbackChannelManager1ServerConnectionTerminate
    ConnectionTimeout = '50000'
    CommunicationTimeout = '50000'
    OnChannelStateChange = DSClientCallbackChannelManager1ChannelStateChange
    Left = 218
    Top = 40
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DataSource=DS_aeg'
      'User_Name=admin'
      'ODBCVersion=3.8'
      'Password=admin'
      'DriverID=ODBC'
      'LoginTimeout=30')
    FormatOptions.AssignedValues = [fvDefaultParamDataType]
    FormatOptions.DefaultParamDataType = ftString
    LoginPrompt = False
    Left = 343
    Top = 150
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      
        'select distinct s.Student_ID, s.Client_ID, s.first_name, s.last_' +
        'name as Student,'
      'p.Address1, p.City,'
      'p.State, p.Zip, p.Home_Phone'
      'from students.db s, clients.db p, enroll.db e, classes.db c'
      'where s.client_id = p.client_id'
      'and s.student_id = e.student_id'
      'and e.class_code = c.code'
      'order by s.Client_ID')
    Left = 344
    Top = 199
  end
  object FDQueryWorker: TFDQuery
    Connection = FDConnection1
    Left = 256
    Top = 200
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProvider1'
    Left = 56
    Top = 176
  end
  object DataSetProvider1: TDataSetProvider
    DataSet = FDQueryWorker
    Left = 112
    Top = 206
  end
  object bm: TFDBatchMove
    Reader = bmJSONreader
    Writer = bmJSONwriter
    Mappings = <>
    LogFileName = 'batchmove.log'
    Left = 194
    Top = 116
  end
  object bmJSONreader: TFDBatchMoveDataSetReader
    Left = 130
    Top = 102
  end
  object bmJSONwriter: TFDBatchMoveJSONWriter
    DataDef.Fields = <>
    Left = 296
    Top = 106
  end
end
