unit IIFA.Item;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua


  , ESO.ItemData
  , IIFA.Constants

  ;

type
  // Klasse für Gegenstände aus LUA Dateien
  TIifaItem = class( TList<TESOItemData> )
  strict private
  public
    constructor Create( const AItemData: TESOItemData );
  end;


implementation

{ TIifaItem }

constructor TIifaItem.Create(const AItemData: TESOItemData);
begin
  inherited Create;
end;

end.
