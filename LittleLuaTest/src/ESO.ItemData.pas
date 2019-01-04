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

  , ESO.Constants
  , ESO.Account
  , ESO.Character
  , ESO.Server
  , ESO.Bag

  , IIFA.Constants
  , IIFA.Character

  ;

type
  //ESO itemLink will be of this format:
  //|H%d:item:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s|hItemNameAsString|h
  //Example: |H1:item:45810:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hJode|h
  // Get more information at: https://wiki.esoui.com/ZO_LinkHandler_CreateLink#ITEM_LINK_TYPE
  // and https://en.uesp.net/wiki/Online:Item_Link
  TESOItemLinkParts = ( ESOil_LinkStyle,                    //1
                        ESOil_LinkType,                     //2
                        ///////////////////////////////////
                        // Itemlink'S data starts here (21 entries)
                        ///////////////////////////////////
                        ESOil_ItemId,                       //3
                        ESOil_Subtype,                      //4 Quality + VR level info
                        ESOil_Level,                        //5 Only 1 too 50, no VR level. VR level is indicated with subtype field above. No way known to calculate quality and VR level from these values outside of the game :-( Inside you can use API functions GetItemLinkQuality(itemLink) etc.
                        ESOil_EnchantId,                    //6
                        ESOil_EnchantSubType,               //7
                        ESOil_EnchantLevel,                 //8
                        ESOil_TransmuteTraitOrMasterWrit1,  //9 Holds transmutation trait of transmuted items, or the Master writ's requirement 1
                        ESOil_MasterWrit2,                  //10
                        ESOil_MasterWrit3,                  //11
                        ESOil_MasterWrit4,                  //12
                        ESOil_MasterWrit5,                  //13
                        ESOil_MasterWrit6,                  //14
                        ESOil_unknown1,                     //15  still unknown
                        ESOil_unknown2,                     //16  still unknown
                        ESOil_unknown3,                     //17  still unknown
                        ESOil_ItemStyle,                    //18
                        ESOil_IsCrafted,                    //19
                        ESOil_IsBound,                      //20
                        ESOil_IsStolen,                     //21
                        ESOil_EnchantChargesOrCondition,    //22
                        ESOil_PotionDataOrWritReward        //23
  );

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
    FBagId: TESOBag;
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

    //References for lookup
    RServer:      TESOServer;
  private

    //procedure setItemLink(const Value: String);
    function getItemID: Integer;
    function getItemLinkString: String;
    procedure setItemLinkString(const Value: String);

  public
    property BagId: TESOBag read FBagId write FBagId;
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

  //Search Items via helper class TESOItemDataHandler
 // FItems.byLink['12345'].


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

  if Length( FItemLinkData ) > ord(ESOil_ItemId)  then
     FItemId := FItemLinkData[ord(ESOil_ItemId)].ToInteger;

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
