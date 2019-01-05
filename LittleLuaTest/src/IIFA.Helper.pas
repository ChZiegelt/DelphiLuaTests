unit IIFA.Helper;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes
  , System.Variants

  , FMX.Dialogs
  , StrUtils
  , System.Generics.Collections
  , Lua

  //ESO
  , ESO.Bag
  , ESO.Bank
  , ESO.Character
  , ESO.Constants
  , ESO.HouseBank
  , ESO.ItemData
  , ESO.Server
  , ESO.SubscriberBank

  //IIfA
  , IIFA.Constants
  , IIFA.Account
  , IIFA.Character
  , IIfA.GuildBank

  ;
 {$ENDREGION}

type
  TIIFAHelper = class
  strict private
    FLua: TLua;

    FSavedVariablesFileName: String;

    FServers:     TDictionary<String, TESOServer>;
    FAccounts:    TDictionary<String, TIIfAAccount>;
    FCharacters:  TDictionary<String, TIIfACharacter>;

    FBanks:       TDictionary<TESOBagIds, TESOBank>;
    FHouseBanks:  TDictionary<TESOBagIds, TESOHouseBank>;
    FGuildBanks:  TDictionary<String, TIIfAGuildBank>;

    //FCraftBag:    TESOBag;

    FItems:       TESOItemDataHandler;//TList<TESOItemData>;
  private
    procedure ParseSettingsTable(const aSettingsTable: ILuaTable);
    procedure ParseDataTable(const aDataTable: ILuaTable);

  public
    property FileName: String read FSavedVariablesFileName write FSavedVariablesFileName;

    property Servers: TDictionary<String, TESOServer> read FServers;
    property Accounts: TDictionary<String, TIifaAccount> read FAccounts;
    property Characters: TDictionary<String, TIifaCharacter> read FCharacters;
    property GuildBanks: TDictionary<String, TIIfAGuildBank> read FGuildBanks;

    property Banks: TDictionary<TESOBagIds, TESOBank> read FBanks write FBanks;
    property HouseBanks: TDictionary<TESOBagIds, TESOHouseBank> read FHouseBanks write FHouseBanks;

    //property CraftBag: TESOBag read FCraftBag write FCraftBag;

    property Items: TESOItemDataHandler read FItems;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function ParseFile(const AFileName: String = ''): Boolean;
  end;


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



{ TIIFAHelper }

procedure TIIFAHelper.AfterConstruction;
begin
  inherited;
  //Build some constant values
  //Create the server entries if they are not already created
  //NA, EU, PTS
  FServers := TDictionary<String, TESOServer>.Create(3);
  FServers.Add(SERVER_NA, TESOServer.Create( SERVER_NA, SERVER_NA_IP, SERVER_ANNOUNCEMENTS_URL) );
  FServers.Add(SERVER_EU, TESOServer.Create( SERVER_EU, SERVER_EU_IP, SERVER_ANNOUNCEMENTS_URL) );
  FServers.Add(SERVER_PTS, TESOServer.Create( SERVER_PTS, SERVER_PTS_IP, SERVER_ANNOUNCEMENTS_URL) );

  //Create the object lists/dictionaries
  FAccounts   := TDictionary<String, TIIfAAccount>.Create();
  FCharacters := TDictionary<String, TIIfACharacter>.Create();
  FGuildBanks := TDictionary<String, TIIfAGuildBank>.Create();
  FBanks      := TDictionary<TESOBagIds, TESOBank>.Create();
  FHouseBanks := TDictionary<TESOBagIds, TESOHouseBank>.Create();
  FItems      := TESOItemDataHandler.Create();

  //Specify the standard SavedVariables filename
  FSavedVariablesFileName := IIFA_SV_FILENAME;

  //Load the LUAWrapper library
  FLua := TLua.Create;
  //Load additional lua libraries like String handling, OS, etc.
  //FLua.AutoOpenLibraries := [Base, StringLib {, ...}];
end;


procedure TIIFAHelper.BeforeDestruction;
begin
  FreeAndNil( FAccounts );
  FreeAndNil( FCharacters );
  FreeAndNil( FGuildBanks );

  FreeAndNil( FBanks );
  FreeAndNil( FHouseBanks );

  FreeAndNil( FServers );

  FreeAndNil( FItems );

  FreeAndNil( FLua );

  inherited;
end;



function TIIFAHelper.ParseFile(const AFileName: String = ''): Boolean;
var
  lFile: String;

  lDataTable, lSettingsTable: ILuaTable;
  
  lAccountExtractorPair: TPair<string, TIIfAAccount>;
  lCharacterExtracted: TESOCharacter;
  lLuaCodeHelperList: TStringList;

begin
  Result := False;

  if AFileName.IsEmpty then
     lFile := FSavedVariablesFileName
  else
     lFile := AFileName;

  if not FileExists(lFile) then
     exit(False);

  //Clear the old entries in Accounts, characters, banks, items here now
  if Assigned(FAccounts) then
    FAccounts.Clear;
  if Assigned(FCharacters) then
    FCharacters.Clear;
  if Assigned(FBanks) then
    FBanks.Clear;
  if Assigned(FHouseBanks) then
    FHouseBanks.Clear;
  if Assigned(FGuildBanks) then
    FGuildBanks.Clear;
  if Assigned(FItems) then
    FItems.Clear;

  //Load the contents of the IIfA.lua SavedVariables file
  //LoadFromFile is not able to use UTF8 conversion properly!
  //FLua.LoadFromFile( lFile, True );
  //Workaround over TStringList to support UTF8 files w/o BOM
  lLuaCodeHelperList := TStringList.Create;
  lLuaCodeHelperList.LoadFromFile( lFile );
  FLua.LoadFromString( System.UTF8ToString( lLuaCodeHelperList.Text ));
  lLuaCodeHelperList.Free;

  //Get the global variable contents from lua routines: IIfA_Settings (SavedVariables object containing the account + character addon settings)
  lSettingsTable := FLua.GetGlobalVariable('IIfA_Settings').AsTable;
  ParseSettingsTable(lSettingsTable);

  // List of Accounts, containing the characters, exists now within fAccounts
  // IIFa_Settings->Accounts->Characters
  // Move the characters of FAccounts to TIIfAHelper.fCharacters
    for lAccountExtractorPair in FAccounts do
    begin
      for lCharacterExtracted in lAccountExtractorPair.Value do
      begin
        FCharacters.Add(lCharacterExtracted.ID , TIIfACharacter(lCharacterExtracted));
      end;
    end;

  //Get the global variable contents from lua routines: IIfA_Data (SavedVariables object containing the item information at each bag + character, server and account on server)
  lDataTable := FLua.GetGlobalVariable('IIfA_Data').AsTable;
  // This method will fill fServer[], fItems[] etc.
  ParseDataTable( lDataTable );

  FSavedVariablesFileName := lFile;
  Result := true;
end;

//Called from TIIFAHelper.ParseFile,
// the settings table will be parsed now to get the accounts + their characters
procedure TIIFAHelper.ParseSettingsTable(const aSettingsTable: ILuaTable);
var
  enum, enumAccounts: ILuaTableEnumerator;
  pair: TLuaKeyValuePair;
  pairAccounts: TLuaKeyValuePair;

  lTable: ILuaTable;

  lAccount: TIifaAccount;
begin
  // Wenn nicht nil, versuche den Inhalt zu verstehen
  if not Assigned(aSettingsTable) then
     exit;
  // Parse die Arrays unterhalb von IIfA_Settings
  enum := aSettingsTable.GetEnumerator;
  //Get next entry of IIfA_Settings
  while enum.MoveNext do
  begin
    pair := enum.Current;
////////////////////////////////////////////////////////////////////////////////
    //Is entry "Default" of IIfA_Settings?
    if pair.Key.AsString = BASE_SAVEDVARS_NAME then
    begin
      lTable := pair.Value.AsTable;
      enumAccounts := lTable.GetEnumerator;
      // Iterate through accounts
      while enumAccounts.MoveNext do
      begin
        //Create the account
        pairAccounts := enumAccounts.Current;
        lAccount := TIifaAccount.Create( pairAccounts.Key.AsString.Replace('@', '') );
        fAccounts.Add( lAccount.DisplayName, lAccount );
////////////////////////////////////////////////////////////////////////////////
        // Get each character below the currently parsed account and create it
        lAccount.ParseCharacters( pairAccounts.Value.AsTable );
      end;
    end;
  end;
end;

//Called from TIIFAHelper.ParseFile after parsing the settings table,
// the data table will be parsed now to get the items
procedure TIIFAHelper.ParseDataTable( const aDataTable: ILuaTable );
var
  enum, enumAccounts, enumAccountWide, enumData, enumAssets, enumAssetsData, enumServer, enumGuildBanks, enumGuildBanksData, enumDB, enumItems, enumItemData, enumItemLocation, enumItemLocationData, enumItemLocationDataSub: ILuaTableEnumerator;
  pair, pairAccounts, pairAccountWide, pairData, pairAssets, pairAssetsData, pairServer, pairGuildBanks, pairGuildBanksData, pairDB, pairItems, pairItemData, pairItemLocation, pairItemLocationData, pairItemLocationDataSub: TLuaKeyValuePair;
  sDisplayName, sPairServerKeyStr, sAssetCharacterId, sAssetDataStr, sItemIdOrLink, sPairItemKeyStr, sPairItemValueStr, sServerNameForGuildBank, sGuildBankStr, sGuildBankLastCollected, sItemLocationStr, sItemLocationDataStr: String;
  lTable: ILuaTable;
  lServer, lServerGuildBank: TESOServer;
  lAccount: TIIfAAccount;
  lCharacter: TIIfACharacter;
  lGuildBank: TIIfAGuildBank;
  lItem: TESOItemData;
  lBank: TESOBank;
  lHouseBank: TESOHouseBank;
  lBagSpace: TESOBagSpace;
  iBagSpaceChecked: byte;
  iServerNameForGuildBankLength, iBagId: integer;
  myDateTime: TDateTime;
  //myFs: TFormatSettings;
  arDateTime: TArray<String>;
begin
  // Wenn nicht nil, versuche den Inhalt zu verstehen
  if not Assigned(aDataTable) then
     exit;
  //Format the DateTime
(*
  with myFs do begin
    myFs.DateSeparator := '.';
    myFs.ShortDateFormat := 'dd.mm.yyyy';
    myFs.LongDateFormat  := 'dd.mm.yyyy hh:mm:ss';
  end;
*)

  // Parse tables below IIfA_Data
  enum := aDataTable.GetEnumerator;

  //Get next entry of IIfA_Data
  while enum.MoveNext do
  begin
    pair := enum.Current;
    //Is entry "Default" of IIfA_Data?
////////////////////////////////////////////////////////////////////////////////
    if pair.Key.AsString = BASE_SAVEDVARS_NAME then
    begin
      lTable := pair.Value.AsTable;
      enumAccounts := lTable.GetEnumerator;
      // Iterate over the possible accounts
      while enumAccounts.MoveNext do
      begin
        pairAccounts := enumAccounts.Current;
        sDisplayName := pairAccounts.Key.AsString;
        // TODO: Check if the currenlty read account is in IIFAHelper.hAccounts, else skip to next entry
        lAccount := nil;
        lTable := pairAccounts.Value.AsTable;
        enumAccountWide := lTable.GetEnumerator;
        while enumAccountWide.MoveNext do
        begin
          pairAccountWide := enumAccountWide.Current;
////////////////////////////////////////////////////////////////////////////////
          //Get next entry and check if it is '$AccountWide'
          if pairAccountWide.Key.AsString = ACCOUNT_WIDE_CHAR then
          begin
            lTable := pairAccountWide.Value.AsTable;
            enumData := lTable.GetEnumerator;
            //Iterate over the possible AccountWide entries
            while enumData.MoveNext do
            begin
              pairData := enumData.Current;
////////////////////////////////////////////////////////////////////////////////
              //Get next entry and check if it is 'Data'
              if pairData.Key.AsString = ENTRY_DATA then
              begin
                lTable := pairData.Value.AsTable;
                enumServer := lTable.GetEnumerator;
                //Iterate over the possible server entries
                while enumServer.MoveNext do
                begin
                  pairServer := enumServer.Current;
                  sPairServerKeyStr := pairServer.Key.AsString;
////////////////////////////////////////////////////////////////////////////////
                  //Get next entry and check if it is one of the existing servers
                  if FServers.ContainsKey(sPairServerKeyStr) then
                  begin
                    lServer := Servers[sPairServerKeyStr];
                    { TODO :
                    Server "lServer" is known, account "lAccount" is also known. items need to be parsed and then stored with their bagId, slotindex (if given) and the other TESOItemData fields
                    How to "connect" those (Server, account, item) now properly so one can search and see the dependencies? }
                    lTable := pairServer.Value.AsTable;
                    enumDB := lTable.GetEnumerator;
                    while enumDB.MoveNext do
                    begin
                      pairDB := enumDB.Current;
////////////////////////////////////////////////////////////////////////////////
                      //Get next entry and check if it is the database version (currently DBv3, 2019-01-02)
                      if pairDB.Key.AsString = IIFA_SV_DB_VERSION then
                      begin
                        lTable := pairDB.Value.AsTable;
                        enumItems := lTable.GetEnumerator;
                        while enumItems.MoveNext do
                        begin
                          pairItems := enumItems.Current;
                          sItemIdOrLink := pairItems.Key.AsString;
                          //Create an item
                          lItem := TESOItemData.Create( sItemIdOrLink );
                          //Iterate over the other itemData and add the found information to the item
                          lTable := pairItems.Value.AsTable;
                          enumItemData := lTable.GetEnumerator;
                          while enumItemData.MoveNext do
                          begin
                            pairItemData := enumItemData.Current;
                            sPairItemKeyStr := pairItemData.Key.AsString;
////////////////////////////////////////////////////////////////////////////////
                            //Read the locations of the item
                            if sPairItemKeyStr = ENTRY_LOCATIONS then
                            begin
                              //Read the subtables and get character Id, CraftBag, Bank, Guildbank Name or houseBank collection Id
                              lTable := pairItemData.Value.AsTable;
                              enumItemLocation := lTable.GetEnumerator;
                              while enumItemLocation.MoveNext do
                              begin
                                pairItemLocation := enumItemLocation.Current;
                                sItemLocationStr := pairItemLocation.Key.AsString; //Contains location like an Integer HouseBank collectionId, Strings like "CraftBag", "Bank", or a character Id
                                //Read the subtable and get the bagID or get the bagSlot with more data below
                                lTable := pairItemLocation.Value.AsTable;
                                enumItemLocationData := lTable.GetEnumerator;
                                while enumItemLocationData.MoveNext do
                                begin
                                  pairItemLocationData := enumItemLocationData.Current;
                                  sItemLocationDataStr := pairItemLocationData.Key.AsString; //Contains bagSlot, bagID
////////////////////////////////////////////////////////////////////////////////
                                  //Check the bagId and update it in the item
                                  if sItemLocationDataStr = ENTRY_BAGID then
                                  begin
                                    iBagId := pairItemLocationData.Value.AsInteger;

                                    if sItemLocationStr = ENTRY_BAG_BANK then
                                    begin
                                      //BagId is BAG_BANK or BAG_SUBSCRIBER_BANK
                                      lItem.BagId := TESOBagIds(iBagId);
                                    end;
                                    if sItemLocationStr = ENTRY_BAG_VIRTUAL then
                                      lItem.BagId := BAG_VIRTUAL
                                    else
                                    begin
                                      //Is the entry a numeric value only and a character Id?
                                      if Characters.ContainsKey(sItemLocationStr) then
                                      begin
                                        //BagId is BAG_WORN or BAG_BACKPACK
                                        lItem.BagId := TESOBagIds(iBagId);
                                        //Get the character and reference it to the item
                                        lCharacter := Characters[sItemLocationStr];
                                        if Assigned(lCharacter) then
                                          lItem.Character := lCharacter;
                                      end
                                      //Is the entry a guild bank name?
                                      else if GuildBanks.ContainsKey(sItemLocationStr) then
                                      begin
                                        lItem.BagId := BAG_GUILDBANK;
                                        //Get the guildbank and reference it to the item
                                        lGuildBank := GuildBanks[sItemLocationStr];
                                        if Assigned(lGuildBank) then
                                          lItem.Bank := lGuildBank;
                                      end
                                      //Is the key an integer value, then it might be a house bank bag
                                      else if IsInteger(sItemLocationStr) then
                                      begin
                                        lItem.BagId := TESOBagIds(iBagId);
                                        // Create the house bank if not yet created
                                        if HouseBanks.ContainsKey(TESOBagIds(iBagId)) then
                                          lHouseBank := HouseBanks[TESOBagIds(iBagId)]
                                        else
                                        begin
                                          //Create the housebank here and assign it to IIfA.HouseBanks
                                          lHouseBank := TESOHouseBank.Create('', TESOBagIds(iBagId));
                                          if Assigned (lBank) then
                                            HouseBanks.Add(TESOBagIds(iBagId), lHouseBank);
                                        end;
                                      end

                                    end
                                  end
////////////////////////////////////////////////////////////////////////////////
                                  else
                                    begin
                                      if sItemLocationDataStr = ENTRY_SLOTINDEX then
                                      begin
                                        //Read the subtable and get the [slotIndex] = itemCount entry
                                        lTable := pairItemLocationData.Value.AsTable;
                                        enumItemLocationDataSub := lTable.GetEnumerator;
                                        while enumItemLocationDataSub.MoveNext do
                                        begin
                                          pairItemLocationDataSub := enumItemLocationDataSub.Current;
                                          lItem.SlotIndex   := pairItemLocationDataSub.Key.AsInteger;    //Contains slotIndex
                                          lItem.StackCount  := pairItemLocationDataSub.Value.AsInteger;  //Contains itemCount
                                        end;
                                      end;
                                    end;
                                end;
                              end
                            end
////////////////////////////////////////////////////////////////////////////////
                            else
                            begin
                              // Get the value of the current table key as string
                              sPairItemValueStr := pairItemData.Value.AsString;
                              //Read other data like filterType, quality, name, itemInstanceOrUniqueId or the itemlink (CraftBag item)
                              if sPairItemKeyStr = ITEM_INFO_ITEMLINK then
                              begin
                                //ItemLinkStr will also set TESOItemData.ItemLink(TESOItemLink).ItemLink
                                lItem.ItemLinkStr := sPairItemValueStr;
                              end
                              else if sPairItemKeyStr = ITEM_INFO_NAME then
                              begin
                                lItem.Name := sPairItemValueStr;
                              end
                              else if sPairItemKeyStr = ITEM_INFO_INSTANCEORUNIQUEID then
                              begin
                                lItem.ItemInstanceOrUniqueId := sPairItemValueStr;
                              end
                              else if sPairItemKeyStr = ITEM_INFO_FILTERTYPE then
                              begin
                                lItem.FilterType := sPairItemValueStr.ToInteger;
                              end
                              else if sPairItemKeyStr = ITEM_INFO_QUALITY then
                              begin
                                lItem.Quality := sPairItemValueStr.ToInteger;
                              end;
                            end
                          end;
////////////////////////////////////////////////////////////////////////////////
                          // Set the items server
                          lItem.Server := lServer;
                          //Add the item to the IIfAHelper FItems (search helper) now
                          FItems.AddItem(lItem);
                        end;
                      end;
                    end;
                  end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
                  //Entry in data was no server, so check for other entries
                  else
                  begin
////////////////////////////////////////////////////////////////////////////////
                    //Entry is the "assets" of each character?
                    if sPairServerKeyStr = ENTRY_ASSETS then
                    begin
                      lTable := pairServer.Value.AsTable;
                      enumAssets := lTable.GetEnumerator;
                      while enumAssets.MoveNext do
                      begin
                        pairAssets := enumAssets.Current;
                        sAssetCharacterId := pairAssets.Key.AsString;
////////////////////////////////////////////////////////////////////////////////
                        //Check if character is in Accounts->Characters
                        if Characters.ContainsKey(sAssetCharacterId) then
                        begin
                          //Yes: Add the assets to this character
                          lTable := pairAssets.Value.AsTable;
                          enumAssetsData := lTable.GetEnumerator;
                          //Get the character
                          lCharacter := Characters[sAssetCharacterId];
                          if Assigned(lCharacter) then
                          begin
                            iBagSpaceChecked := 0;
                            while enumAssetsData.MoveNext do
                            begin
                              pairAssetsData := enumAssetsData.Current;
                              sAssetDataStr := pairAssetsData.Key.AsString;
                              if sAssetDataStr = ASSETS_ALLIANCE_POINTS then
                                lCharacter.Asset_ap := pairAssetsData.Value.AsInteger
                              else if sAssetDataStr = ASSETS_WRIT_VOUCHERS then
                                lCharacter.Asset_wv := pairAssetsData.Value.AsInteger
                              else if sAssetDataStr = ASSETS_GOLD then
                                lCharacter.Asset_gold := pairAssetsData.Value.AsInteger
                              else if sAssetDataStr = ASSETS_TEL_VAR_STONES then
                                lCharacter.Asset_tv := pairAssetsData.Value.AsInteger
                              else if sAssetDataStr = ASSETS_SPACE_MAX then
                              begin
                                lBagSpace.max := pairAssetsData.Value.AsInteger;
                                inc(iBagSpaceChecked);
                              end
                              else if sAssetDataStr = ASSETS_SPACE_USED then
                              begin
                                lBagSpace.used := pairAssetsData.Value.AsInteger;
                                inc(iBagSpaceChecked);
                              end;
                              if iBagSpaceChecked >= 2 then
                                lCharacter.Asset_bagSpace := lBagSpace;
                            end;
                          end;
                        end;
                      end;
                    end // if spairServerKeyStr = ENTRY_ASSETS then
////////////////////////////////////////////////////////////////////////////////
                    //Check for guild banks: Does the entry contain the guildBanks substring?
                    else if ContainsText(sPairServerKeyStr, ENTRY_BAG_GUILDBANK_SUFFIX) then
                    begin
                      //Seperate the servername from the entry text
                      iServerNameForGuildBankLength := sPairServerKeyStr.IndexOf(ENTRY_BAG_GUILDBANK_DELIMITER);
                      sServerNameForGuildBank := sPairServerKeyStr.Substring(0, iServerNameForGuildBankLength);
                      //The servername was read from the string and the server does exist?
                      if not String.IsNullOrEmpty(sServerNameForGuildBank) and Servers.ContainsKey(sServerNameForGuildBank) then
                      begin
                        lTable := pairServer.Value.AsTable;
                        enumGuildBanks := lTable.GetEnumerator;
                        //Iterate over the possible guild bank
                        while enumGuildBanks.MoveNext do
                        begin
                          pairGuildBanks := enumGuildBanks.Current;
                          //The guildbanks name
                          sGuildBankStr := pairGuildBanks.Key.AsString;
                          //Create new guild bank
                          lGuildBank := TIIfAGuildBank.Create(sGuildBankStr);
                          //Get the server of the guild bank
                          lServerGuildBank := Servers[sServerNameForGuildBank];
                          //Assign the guild bank to the correct server
                          if Assigned(lGuildBank) and Assigned(lServerGuildBank) then
                          begin
                            lGuildBank.Server := lServerGuildBank;
                            //Get the guild banks data
                            lTable := pairGuildBanks.Value.AsTable;
                            enumGuildBanksData := lTable.GetEnumerator;
                            //Iterate over the possible guild bank data
                            while enumGuildBanksData.MoveNext do
                            begin
                              pairGuildBanksData := enumGuildBanksData.Current;
                              sGuildBankStr := pairGuildBanksData.Key.AsString;
                              if sGuildBankStr = GUILDBANK_ITEMCOUNT then
                              begin
                                lBagSpace.used := pairGuildBanksData.Value.AsInteger;
                                lBagSpace.max  := ESO_GUILDBANK_MAX_ITEMCOUNT;
                                lGuildBank.Asset_bagSpace := lBagSpace;
                              end
                              else if sGuildBankStr = GUILDBANK_WAS_COLLECTED then
                                lGuildBank.WasCollected := pairGuildBanksData.Value.AsBoolean
                              else if sGuildBankStr = GUILDBANK_LAST_COLLECTED then
                              begin
                                //Get the date and time from pairGuildBanksData.Value.AsString
                                //and then add it to the guildbank.LastCollected attribute
                                sGuildBankLastCollected := pairGuildBanksData.Value.AsString;
                                if not String.IsNullOrEmpty(sGuildBankLastCollected) then
                                begin
                                  //Split the string of the SV last collected info (e.g. "20181101@190801") into date and time parts
                                  arDateTime := sGuildBankLastCollected.Split(['@']);
                                  if Length(arDateTime) = 2 then
                                  begin
                                    //Date "20181101" is now in arDateTime[0]
                                    sGuildBankLastCollected := '';
                                    sGuildBankLastCollected := arDateTime[0].Substring(6, 2); //Day
                                    sGuildBankLastCollected := sGuildBankLastCollected + '.';
                                    sGuildBankLastCollected := sGuildBankLastCollected + arDateTime[0].Substring(4, 2); //Month
                                    sGuildBankLastCollected := sGuildBankLastCollected + '.';
                                    sGuildBankLastCollected := sGuildBankLastCollected + arDateTime[0].Substring(0, 4); //Year
                                    //Time "190801" is now in arDateTime[1]
                                    sGuildBankLastCollected := sGuildBankLastCollected + ' ' + arDateTime[1].Substring(0, 2); //Hours
                                    sGuildBankLastCollected := sGuildBankLastCollected + ':';
                                    sGuildBankLastCollected := sGuildBankLastCollected + arDateTime[1].Substring(2, 2); //Minutes
                                    sGuildBankLastCollected := sGuildBankLastCollected + ':';
                                    sGuildBankLastCollected := sGuildBankLastCollected + arDateTime[1].Substring(4, 2); //Seconds
                                    try
                                      myDateTime := VarToDateTime(sGuildBankLastCollected);
                                      lGuildBank.LastCollected := myDateTime;
                                    except
                                      on EVariantTypeCastError do
                                      //ShowMessage('DateTimeConversion not possible for: ' + sGuildBankLastCollected);
                                    end;
                                  end;
                                end;
                              end;
                            end;
                            //Add the found guild bank to the IIfAHelper.GuildBanks
                            GuildBanks.Add(lGuildBank.Name, lGuildBank)
                          end;
                        end;
                      end;
                    end; // Check for guildbanks (// if spairServerKeyStr = ENTRY_ASSETS then)
////////////////////////////////////////////////////////////////////////////////
                  end;
                end;
              end;       // DATA in "Data"
////////////////////////////////////////////////////////////////////////////////
            end;
          end;          // DATA in "$AccountWide"
        end;
      end;
    end;
  end;
end;

end.
