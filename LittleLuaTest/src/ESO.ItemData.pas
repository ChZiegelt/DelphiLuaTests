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

  // ESO
  , ESO.Constants
  , ESO.Account
  , ESO.Bag
  , ESO.Bank
  , ESO.Character
  , ESO.Server

  // IIfA
  , IIfA.GuildBank

 {$ENDREGION}
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

  (* ESOil_Subtype contents change on each major ESO update :-( But a "somehow" way to determine what number results in which quality and Veteran level is described in this lua code.
    !!!Attention: This will ONLY work for crafted items (where ESOil_IsCrafted = 1, but NOT for dropped items!!!

      -- Each update has its own definition of the lower bits
      -- Classic: Lower bits code quality and have "reducer" bits
      function addon:CreateSubItemId(level, champ, quality)
          quality = quality or 1
          quality = math.max(0, quality - 1)
          level = math.max(1, math.min(50, level))
          local subId
          if level < 50 or champ == nil then
              if level < 4 then
                  subId = 30
              elseif level < 6 then
                  subId = 25
              else
                  subId = 20
              end
              subId = subId + quality
          else
              if champ < 110 then
                  champ = math.max(10, champ)
                  -- introduce of vet silver and gold
                  subId = 124 + math.floor(champ / 10) + quality * 10
              elseif champ < 130 then
                  -- Craglorn
                  subId = 236 + math.floor((champ - 110) / 10) * 18 + quality
              elseif champ < 150 then
                  -- Upper Craglorn
                  subId = 272 + math.floor((champ - 130) / 10) * 18 + quality
              else
                  champ = math.min(GetChampionPointsPlayerProgressionCap(), champ)
                  subId = 308 + math.floor((champ - 150) / 10) * 58 + quality
              end
          end
          return subId
      end

   //function GetChampionPointsPlayerProgressionCap returns the maximum CP value, currently 160 at 2019-01-04
  *)

  TESOItemLink = class
  strict private
    //The integer itemId of the item (automatically split from itemLink inside function setItemLink, called in constructor)
    FItemId: Integer;
    //The itemLInk as whole string e.g. |H1:item:45810:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|hJode|h
    FItemLink: String;
    //Array of split (at char ':') itemlink -> See above at definition of TESOItemLinkParts for details
    FItemLinkData: TArray<String>;
  private
    procedure setItemLink(const Value: String);
  public

    property ItemId: Integer read FItemId;  // write FItemId;
    property ItemLink: String read FItemLink write setItemLink;

    constructor Create(const AItemLink: String = ''; bIsESOItemLink: Boolean = True);
  end;


 // Klasse für Gegenstände aus LUA Dateien
  TESOItemData= class
  strict private
    FBagId: TESOBagIds;
    FSlotIndex: Integer;
    FStackCount: Integer;
    //FItemId: Integer;
    FFilterType: Integer;
    FQuality: Integer;
    FLevel: Integer;
    FCPLevel: Integer;
    FName: String;
    FItemInstanceOrUniqueId: String;

    FItemLink: TESOItemLink;

    //References for lookup
    RAccount:     TESOAccount;
    RCharacter:   TESOCharacter;
    RServer:      TESOServer;
    RBank:        TESOBank;
  private

    //procedure setItemLink(const Value: String);
    function getItemID: Integer;
    function getItemLinkString: String;
    procedure setItemLinkString(const Value: String);

  public
    property BagId: TESOBagIds read FBagId write FBagId;
    property SlotIndex: Integer read FSlotIndex write FSlotIndex;
    property StackCount: Integer read FStackCount write FStackCount;

    property FilterType: Integer read FFilterType write FFilterType;
    property Quality: Integer read FQuality write FQuality;
    property Level: Integer read FLevel write FLevel;
    property CPLevel: Integer read FCPLevel write FCPLevel;

    property Name: String read FName write FName;
    property ItemInstanceOrUniqueId: String read FItemInstanceOrUniqueId write FItemInstanceOrUniqueId;

    property ItemLink: TESOItemLink read FItemLink write FItemLink;

    // Proxy Methoden - Zugriff auf FItemLink
    property ItemId: Integer read getItemId; // write FItemId;
    property ItemLinkStr: String read getItemLinkString write setItemLinkString;

    property Account: TESOAccount read RAccount write RAccount;
    property Character: TESOCharacter read RCharacter write RCharacter;
    property Server: TESOServer read RServer write RServer;
    property Bank: TESOBank read RBank write RBank;


    function toString(): String; override;

    constructor Create( const AItemLink: String = '' );
    destructor Destroy( ); override;
  end;


  //Search methods etc. for TESOItemData
  TESOItemDataHandler = class
  strict private
    // Diese Liste der Items - !nur hier freigeben und createn!
    List: TList< TESOItemData >;

   public
    // Dictionaries für jede relevante zu suchende Eigenschaft
    byName:       TDictionary< String,  TESOItemData >; //could be duplicate in the SavedVariables (on different servers!)
    byItemLink:   TDictionary< String,  TESOItemData >; //could be duplicate in the SavedVariables (on different servers!)
    byItemId:     TDictionary< Integer, TESOItemData >; //could be duplicate in the SavedVariables (on different servers!)

    procedure AddItem( const AItem: TESOItemData );
    procedure RemoveItem( const AItem: TESOItemData );
    procedure Clear();

    function GetItemList(): TList< TESOItemData >;
    function toStrings(): TStrings;

    function SearchByName( AName: String ): TList< TESOItemData >;
    function SearchByItemLink( AItemLink: String ): TList< TESOItemData >;
    function SearchByItemId( AItemId: Integer ): TList< TESOItemData >;
    function SearchByFilterType( AFilterType: Integer ): TList< TESOItemData >;
    function SearchByQuality( AQuality: Integer ): TList< TESOItemData >;

    constructor Create();
    destructor Destroy(); override;
  end;

  //Search Items via helper class TESOItemDataHandler
 // FItems.byLink['12345'].


implementation

{ Helper functions }
function IsInteger(value : String): Boolean;
begin
  try
    value.ToInteger();
  except
    Result := false;
    exit;
  end;
  Result:=true;
end;


{ TESOItemData }

constructor TESOItemData.Create(const AItemLink: String = '');
begin
  FItemLink := TESOItemLink.Create(AItemLink, AItemLink.Contains(ESO_ITEMLINK_PREFIX))
end;

destructor TESOItemData.Destroy;
begin
  FreeAndNil(FItemLink);

  inherited;
end;

function TESOItemData.getItemId: Integer;
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


function TESOItemData.toString: String;
  var
    sLocation: String;
begin
  if BagId = BAG_WORN then
    sLocation := 'Worn: "' + Character.Name + '"'
  else if BagId = BAG_BACKPACK then
    sLocation := 'Inventory "' + Character.Name + '"'
  else if BagId = BAG_BANK then
    sLocation := 'Bank'
  else if BagId = BAG_SUBSCRIBER_BANK then
    sLocation := 'ESO+ Bank'
  else if BagId = BAG_VIRTUAL then
    sLocation := 'Craftbag'
  else if BagId = BAG_GUILDBANK then
    sLocation := 'Guildbank "' + TIIfAGuildBank(Bank).Name + '"';

  Result := Format( '> ID: %s, Name: %s, Quality:  %s, FilterType: %s, ItemLink: %s, Location: %s, SlotIndex: %s, StackCount: %s' ,
                      [ItemId.ToString, Name, Quality.ToString, FilterType.ToString, ItemLinkStr, sLocation, SlotIndex.ToString, StackCount.ToString]);
end;

{ TESOItemLink }

constructor TEsoItemLink.Create(const AItemLink: String = ''; bIsESOItemLink: Boolean = True);
begin
  inherited Create;

  if AItemLink = '' then exit;

  //Check if the itemLink is really a link, or an itemId (from CraftBag entry e.g.)
  if (not bIsESOItemLink) or not AItemLink.Contains(ESO_ITEMLINK_PREFIX) then
  begin
    //It's no itemlink but maybe an itemId? Check if the value in ItemLink is only an integer value
    if IsInteger(AItemLink) then
      FItemId := AItemLink.ToInteger()
  end
  else
    //It's an itemlink. Call function setItemLink and try to split the itemId from the itemLink
    ItemLink := AItemLink;
end;

procedure TEsoItemLink.setItemLink(const Value: String);
begin
  setLength( FItemLinkData, 0);
  if Value = '' then exit;
  

  FItemLink := Value;
  // Parse itemLink and split at : into FItemId, ...
  FItemLinkData := Value.Split([':']);

  if Length( FItemLinkData ) > ord(ESOil_ItemId)  then
     FItemId := FItemLinkData[ord(ESOil_ItemId)].ToInteger;

end;

{ TESOItemDataHandler }

procedure TESOItemDataHandler.Clear;
begin
  if Assigned(byName) then
    byName.Clear;
  if Assigned(byItemId) then
    byItemId.Clear;
  if Assigned(byItemLink) then
    byItemLink.Clear;
  if Assigned(List) then
    List.Clear;
end;

constructor TESOItemDataHandler.Create;
begin
  inherited Create;
  byName      :=  TDictionary< String,  TESOItemData >.Create;
  byItemId    :=  TDictionary< Integer, TESOItemData >.Create;
  byItemLink  :=  TDictionary< String,  TESOItemData >.Create;
  List        :=  TList< TESOItemData >.Create;
end;

destructor TESOItemDataHandler.Destroy;
begin
  FreeAndNil(byName);
  FreeAndNil(byItemId);
  FreeAndNil(byItemLink);
  FreeAndNil(List);

  inherited Destroy;
end;

function TESOItemDataHandler.GetItemList: TList<TESOItemData>;
begin
 result := nil;
 if Assigned(List) then
  result := List;
end;

procedure TESOItemDataHandler.RemoveItem(const AItem: TESOItemData);
begin
  byName.Remove(AItem.Name);
  byItemId.Remove(AItem.ItemId);
  byItemLink.Remove(AItem.ItemLinkStr);
  List.Remove(AItem);
end;

procedure TESOItemDataHandler.AddItem(const AItem: TESOItemData);
begin
  byName.AddOrSetValue(AItem.Name, AItem);
  byItemId.AddOrSetValue(AItem.ItemId, AItem);
  byItemLink.AddOrSetValue(AItem.ItemLinkStr, AItem);
  List.Add( AItem );
end;

function TESOItemDataHandler.SearchByName(AName: String): TList<TESOItemData>;
begin

end;

function TESOItemDataHandler.SearchByItemLink(AItemLink: String): TList<TESOItemData>;
begin

end;

function TESOItemDataHandler.SearchByItemId(AItemId: Integer): TList<TESOItemData>;
begin

end;


function TESOItemDataHandler.SearchByFilterType(AFilterType: Integer): TList<TESOItemData>;
var
  lESOItemData: TESOItemData;
  lResult: TList<TESOItemData>;
begin
  lResult := TList<TESOItemData>.Create;
  for lESOItemData in List do
    if lESOItemData.FilterType = AFilterType then
      lResult.Add(lESOItemData);
  result := lResult;
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

function TESOItemDataHandler.toStrings: TStrings;
var
  lItemData: TESOItemData;
begin
  Result := TStringList.Create;

  for lItemData in Self.List do
  begin
    Result.Add( lItemData.toString() );
  end;

end;

end.
