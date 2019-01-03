unit ESO.Server;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua

  , ESO.Constants

  ;

type
  TESOServer = class
  strict private
    FName:           String;
    FIP:             String;
    FOnlineCheckURL: String;
  public
    property Name: String read FName write FName;
    property IP: String read FIP write FIP;
    property OnlineCheckURL: String read FOnlineCheckURL write FOnlineCheckURL;

    constructor Create( Name, IP, OnlineCheckURL: String );
  end;


implementation


{ TIifaServer }

constructor TESOServer.Create(Name, IP, OnlineCheckURL: String);
begin
  inherited Create;

  FName           := Name;
  FIP             := IP;
  FOnlineCheckURL := OnlineCheckURL;
end;

end.
