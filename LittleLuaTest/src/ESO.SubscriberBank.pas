unit ESO.SubscriberBank;

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

  //Generic ESO subscriber bank (ESO+ members) class -> Inherit in each addon's plugin
  TESOSubscriberBank = class abstract (TESOBank)
  strict private
    FBagId:           TESOBagIds;

    //Reference
    rServer:          TESOServer;

  public
    property BagId: TESOBagIds read FBagId;
    property Server: TESOServer read rServer write rServer;

    constructor Create();
    destructor  Destroy(); override;
  end;

implementation

{ TESOSubscriberBank }

constructor TESOSubscriberBank.Create();
begin
  inherited Create;

  FBagId  := BAG_SUBSCRIBER_BANK;
end;

destructor TESOSubscriberBank.Destroy;
begin
  inherited Destroy;
end;

end.
