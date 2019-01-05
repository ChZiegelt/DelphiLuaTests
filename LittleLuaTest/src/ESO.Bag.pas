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
 {$ENDREGION}

type
  TESOBagSpace = record
    used: Integer;
    max:  Integer;
  End;

  // Class for ESO bags
  TESOBag = class
  strict private
    FBagId: TESOBagIds;
    FBagSpace: TESOBagSpace;

  public
    property BagId: TESOBagIds read FBagId write FBagId;
    property BagSpace: TESOBagSpace read FBagSpace write FBagSpace;

    constructor Create( const ABagId: TESOBagIds; const ABagSpace: TESOBagSpace );
    destructor Destroy; override;
  end;



implementation

{ TESOBag }

constructor TESOBag.Create(const ABagId: TESOBagIds; const ABagSpace: TESOBagSpace);
begin
  inherited Create;

  FBagId    := ABagId;
  FBagSpace := ABagSpace;
end;

destructor TESOBag.Destroy;
begin

  inherited;
end;

end.
