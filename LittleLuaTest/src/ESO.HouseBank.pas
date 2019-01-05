unit ESO.HouseBank;

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

  //Generic ESO house bank (chests) class -> Inherit in each addon's plugin
  TESOHouseBank = class abstract (TESOBank)
  strict private
    FChestName:       String;
    FBagId:           TESOBagIds;

    //Reference
    rServer:          TESOServer;

  public
    property ChestName:  String read FChestName write FChestName;
    property BagId: TESOBagIds read FBagId;
    property Server: TESOServer read rServer write rServer;

    constructor Create( const AChestName: String = ''; ABagId: TESOBagIds = BAG_HOUSE_BANK_ONE );
    destructor  Destroy(); override;
  end;

implementation

{ TESOHouseBank }

constructor TESOHouseBank.Create(const AChestName: String = ''; ABagId: TESOBagIds = BAG_HOUSE_BANK_ONE);
begin
  inherited Create;

  FChestName  := AChestName;
  FBagId      := ABagId;
end;

destructor TESOHouseBank.Destroy;
begin
  inherited Destroy;
end;

end.
