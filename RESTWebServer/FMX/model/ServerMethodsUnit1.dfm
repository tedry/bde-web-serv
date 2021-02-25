object ServerMethods1: TServerMethods1
  OldCreateOrder = False
  Height = 213
  Width = 315
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 105
    Top = 80
  end
  object DataSource1: TDataSource
    Left = 232
    Top = 84
  end
  object FDMemTable1: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 172
    Top = 148
  end
end
