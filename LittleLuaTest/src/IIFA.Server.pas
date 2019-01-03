unit IIFA.Server;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua

  , IIFA.Constants
  , IIFA.Account

  ;

type
  TIifaServerType = class
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

  // Klasse für die IIfA Daten
  //|-> beinhällt die Accounts
  //|--> beinhalten jeweils die Charaktere je Account
  //|---> beinhalten wiederum jeweils die Bags je Charakter
  //|----> Beinhalten wiederum jeweils die Items je Bag
  TIifaServer = class( TList<TIifaAccount> )
  strict private
    FServerType: TIifaServerType;
  private
  public

    constructor Create( const AServerType: TIifaServerType );
  end;


implementation

{ TIifaServer }

constructor TIifaServer.Create(const AServerType: TIifaServerType);
begin
  inherited Create;

  FServerType := AServerType;
end;


{ TIifaServerType }

constructor TIifaServerType.Create(Name, IP, OnlineCheckURL: String);
begin
  inherited Create;

  FName           := Name;
  FIP             := IP;
  FOnlineCheckURL := OnlineCheckURL;
end;

end.
