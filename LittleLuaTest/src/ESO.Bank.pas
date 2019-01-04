unit ESO.Bank;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections

  //ESO
  , ESO.Bag
  , ESO.Constants

  ;
 {$ENDREGION}


  type

  //Generic ESO bank class -> Inherit in each addon's plugin + in TESOGuildBank
  TESOBank = class abstract
  strict private
    FBagId:           TESOBagIds;
    FAsset_gold:      Integer;
    FAsset_bagSpace:  TESOBagSpace;

  public
    //Assets
    property Asset_gold: Integer read FAsset_gold write FAsset_gold;
    property Asset_bagSpace: TESOBagSpace read FAsset_bagSpace write FAsset_bagSpace;

    property BagId: TESOBagIds read FBagId;

    constructor Create();
    destructor  Destroy(); override;
  end;

implementation

{ TESOBank }

constructor TESOBank.Create();
begin
  inherited Create;

  FBagId := BAG_BANK;
end;

destructor TESOBank.Destroy;
begin
  inherited Destroy;
end;

end.
