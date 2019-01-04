unit ESO.Bag;

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
  // Class for ESO bags
  TESOBag = class
  strict private
    FBagId: TESOBagIds;
  public
    property BagId: TESOBagIds read FBagId write FBagId;

    constructor Create( const ABagId: TESOBagIds );
  end;



implementation

{ TESOBag }

constructor TESOBag.Create(const ABagId: TESOBagIds);
begin
  inherited Create;

  FBagId := ABagId;
end;

end.
