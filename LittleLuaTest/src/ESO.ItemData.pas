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
  , ESO.Server

  ;

type
  TESOItemIdIndex = (idx0, idx1, idxItemId, idx3 {, ...});

  TESOItemLink = class
  strict private
    FItemId: Integer;
    FItemLink: String;

    FItemLinkData: TArray<String>;
  private
    procedure setItemLink(const Value: String);
  public

    property ItemId: Integer read FItemId;  // write FItemId;
    property ItemLink: String read FItemLink write setItemLink;

    constructor Create(const AItemLink: String = '');
  end;


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

    FItemLink: TESOItemLink;

    RServer: TESOServer;
  private

    //procedure setItemLink(const Value: String);
    function getItemID: Integer;
    function getItemLinkString: String;
    procedure setItemLinkString(const Value: String);

  public
    property BagId: Integer read FBagId write FBagId;
    property SlotIndex: Integer read FSlotIndex write FSlotIndex;
    property SlotCount: Integer read FSlotCount write FSlotCount;

    property FilterType: Integer read FFilterType write FFilterType;
    property Quality: Integer read FQuality write FQuality;
    property Level: Integer read FLevel write FLevel;
    property CPLevel: Integer read FCPLevel write FCPLevel;

    property Name: String read FName write FName;
    property ItemInstanceOrUniqueId: String read FItemInstanceOrUniqueId write FItemInstanceOrUniqueId;

    property ItemLink: TESOItemLink read FItemLink write FItemLink;

    // Proxy Methoden - Zugriff auf FItemLink
    property ItemId: Integer read getItemID; // write FItemId;
    property ItemLinkStr: String read getItemLinkString write setItemLinkString;


    property Server: TESOServer read RServer write RServer;

    constructor Create( );
    destructor Destroy( ); override;
  end;


  //Search methods etc. for TESOItemData
  TESOItemDataHandler = class
  strict private
    // Diese Liste der Items - !nur hier freigeben und createn!
    List: TList< TESOItemData >;

   public
    // Dictionaries für jede relevante zu suchende Eigenschaft
    byName:  TDictionary< String, TESOItemData >;  // eventuell doppelt vorhanden ?
    byID:    TDictionary< Integer, TESOItemData >;
    byLink:  TDictionary< String, TESOItemData >;

    procedure AddItem( const AItem: TESOItemData );
    procedure RemoveItem( const AItem: TESOItemData );
    procedure Clear();

    function SearchByQuality( AQuality: Integer ): TList< TESOItemData >;
  end;


implementation

{ TESOItemData }


constructor TESOItemData.Create;
begin
  FItemLink := TESOItemLink.Create();
end;

destructor TESOItemData.Destroy;
begin
  FreeAndNil(FItemLink);

  inherited;
end;

function TESOItemData.getItemID: Integer;
begin
  if Assigned(FItemLink) then
     Result := FItemLink.ItemId
  else
     Result := -1;
end;

function TESOItemData.getItemLinkString: String;
begin
  if Assigned(FItemLink) then
     Result := FItemLink.ItemLink
  else
     Result := '';
end;


procedure TESOItemData.setItemLinkString(const Value: String);
begin
  if Assigned(FItemLink) then
     FItemLink.ItemLink := Value
  else
     FItemLink.ItemLink := '';
end;


{ TESOItemLink }

constructor TEsoItemLink.Create(const AItemLink: String);
begin
  inherited Create;

  ItemLink := AItemLink;
end;

procedure TEsoItemLink.setItemLink(const Value: String);
begin
  setLength( FItemLinkData, 0);

  FItemLink := Value;
  // Parse itemLink and split at : into FItemId, ...
  FItemLinkData := Value.Split([':']);

  if Length( FItemLinkData ) > ord(idxItemId)  then
     FItemId := FItemLinkData[ord(idxItemId)].ToInteger;

end;

{ TESOItemDataHandler }


procedure TESOItemDataHandler.Clear;
begin
  byName.Clear;
  byId.Clear;
  byLink.Clear;
  List.Clear;
end;

procedure TESOItemDataHandler.RemoveItem(const AItem: TESOItemData);
begin
  byName.Remove(AItem.Name);
  byId.Remove(AItem.ItemId);
  byLink.Remove(AItem.ItemLinkStr);
  List.Remove(AItem);
end;

procedure TESOItemDataHandler.AddItem(const AItem: TESOItemData);
begin
  byName.TryAdd( AItem.Name, AItem );
  byId.TryAdd(AItem.ItemId, AItem);
  byLink.TryAdd(AItem.ItemLinkStr, AItem);
  List.Add( AItem );
end;


function TESOItemDataHandler.SearchByQuality(AQuality: Integer): TList<TESOItemData>;
var
  lESOItemData: TESOItemData;
  lResult: TList<TESOItemData>;
begin
  lResult := TList<TESOItemData>.Create;

  for lESOItemData in List do
    if lESOItemData.Quality = AQuality then
      lResult.Add(lESOItemData);
  result := lResult;
end;

end.
