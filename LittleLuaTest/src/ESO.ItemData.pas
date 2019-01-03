unit ESO.ItemData;

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
  , IIFA.Character

  ;

type
 // Klasse für Gegenstände aus LUA Dateien
  TESOItemData= class
  strict private
    FBagId: Integer; //or maybe "TIifaBag" -> yet to create
    FSlotIndex: Integer;
    FSlotCount: Integer;
    FItemId: Integer;
    FFilterType: Integer;
    FQuality: Integer;
    FLevel: Integer;
    FCPLevel: Integer;
    FName: String;
    FItemInstanceOrUniqueId: String;
    FItemLink: String;
  private
    procedure setItemLink(const Value: String);
  public
    property BagId: Integer read FBagId write FBagId;
    property SlotIndex: Integer read FSlotIndex write FSlotIndex;
    property SlotCount: Integer read FSlotCount write FSlotCount;
    property ItemId: Integer read FItemId write FItemId;
    property FilterType: Integer read FFilterType write FFilterType;
    property Quality: Integer read FQuality write FQuality;
    property Level: Integer read FLevel write FLevel;
    property CPLevel: Integer read FCPLevel write FCPLevel;

    property Name: String read FName write FName;
    property ItemInstanceOrUniqueId: String read FItemInstanceOrUniqueId write FItemInstanceOrUniqueId;
    property ItemLink: String read FItemLink write setItemLink;

    constructor Create( );
  end;


implementation

{ TESOItemData }

constructor TESOItemData.Create;
begin
 inherited Create;
end;

function GetItemIdFromItemLink(ItemLink: String)
var itemId: Integer;
begin
  result := itemId;
end

procedure TESOItemData.setItemLink(const Value: String);
begin
  FItemLink := Value;
  //Check if the itemId is already set. If not: Read it from the itemLink and set it too
  if ( Value <> '') and (FItemId = 0) then
  begin
    FItemId := self.GetItemIdFromItemLink(Value)
  end;

end;

end.
