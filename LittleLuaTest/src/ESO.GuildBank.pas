unit ESO.GuildBank;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections

  //ESO
  , ESO.Constants
  , ESO.Bag
  , ESO.Bank
  , ESO.Server

  ;
 {$ENDREGION}

  type

  //Generic ESO guild bank class -> Inherit in each addon's plugin
  TESOGuildBank = class abstract (TESOBank)
  strict private
    FName:            String;
    FBagId:           TESOBagIds;

    //Reference
    rServer:          TESOServer;

  public
    property Name:  String read FName write FName;
    property BagId: TESOBagIds read FBagId;
    property Server: TESOServer read rServer write rServer;

    constructor Create( const AName: String = '');
    destructor  Destroy(); override;
  end;

implementation

{ TESOGuildBank }

constructor TESOGuildBank.Create(const AName: String = '');
begin
  inherited Create;

  FName   := AName;
  FBagId  := BAG_GUILDBANK;
end;

destructor TESOGuildBank.Destroy;
begin
  inherited Destroy;
end;

end.
