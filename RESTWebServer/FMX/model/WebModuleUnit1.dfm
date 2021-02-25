object WebModule2: TWebModule2
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  Actions = <
    item
      Name = 'ReverseStringAction'
      PathInfo = '/ReverseString'
      Producer = ReverseString
    end
    item
      Name = 'ServerFunctionInvokerAction'
      PathInfo = '/ServerFunctionInvoker'
      Producer = ServerFunctionInvoker
    end
    item
      Name = 'ViewStudents'
      PathInfo = '/ViewStudents'
      Producer = ViewStudents
    end
    item
      Name = 'tile'
      PathInfo = '/tile'
      Producer = tile
    end
    item
      Default = True
      Name = 'DefaultAction'
      PathInfo = '/'
      Producer = index
      OnAction = WebModuleDefaultAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  Height = 333
  Width = 414
  object DSHTTPWebDispatcher1: TDSHTTPWebDispatcher
    DSHostname = ''
    DSPort = 21121
    Filters = <>
    WebDispatch.PathInfo = 'datasnap*'
    Left = 88
    Top = 49
  end
  object ServerFunctionInvoker: TPageProducer
    HTMLFile = 'templates/serverfunctioninvoker.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 62
    Top = 184
  end
  object ReverseString: TPageProducer
    HTMLFile = 'templates/reversestring.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 214
    Top = 116
  end
  object WebFileDispatcher1: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/x-png'
        Extensions = 'png'
      end
      item
        MimeType = 'text/html'
        Extensions = 'htm;html'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpg;jpeg;jpe'
      end
      item
        MimeType = 'image/gif'
        Extensions = 'gif'
      end>
    BeforeDispatch = WebFileDispatcher1BeforeDispatch
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '.'
    VirtualPath = '/'
    Left = 64
    Top = 126
  end
  object DSProxyGenerator1: TDSProxyGenerator
    ExcludeClasses = 'DSMetadata'
    MetaDataProvider = DSServerMetaDataProvider1
    Writer = 'Java Script REST'
    Left = 62
    Top = 246
  end
  object DSServerMetaDataProvider1: TDSServerMetaDataProvider
    Left = 204
    Top = 246
  end
  object index: TPageProducer
    HTMLFile = 'templates/index.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 216
    Top = 54
  end
  object ViewStudents: TPageProducer
    HTMLFile = 
      'C:\Users\tedry\Documents\GitHub\aeg\RESTWebServer\Widows\FMX\tem' +
      'plates\jRestStudents.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 318
    Top = 56
  end
  object tile: TPageProducer
    HTMLFile = 
      'C:\Users\tedry\Documents\GitHub\aeg\RESTWebServer\Widows\FMX\tem' +
      'plates\tile.htm'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 316
    Top = 120
  end
  object main: TPageProducer
    HTMLFile = 'C:\ALab\DX\aeg\RESTWebServer\Widows\FMX\templates\main.html'
    OnHTMLTag = ServerFunctionInvokerHTMLTag
    Left = 314
    Top = 188
  end
end
