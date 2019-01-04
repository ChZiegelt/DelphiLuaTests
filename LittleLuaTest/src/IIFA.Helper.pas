unit IIFA.Helper;

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
  , ESO.Server
  , ESO.Character
  , ESO.ItemData

  , IIFA.Constants
  , IIFA.Account
  , IIFA.Character

  ;

type
  TIIFAHelper = class
  strict private
    FLua: TLua;

    FSavedVariablesFileName: String;

    FServers:     TDictionary<String, TESOServer>;
    FAccounts:    TDictionary<String, TIIfAAccount>;
    FCharacters:  TDictionary<String, TIIfACharacter>;
    FItems:       TESOItemDataHandler;//TList<TESOItemData>;
  private

    procedure ParseSettingsTable(const aSettingsTable: ILuaTable);
    procedure ParseDataTable(const aDataTable: ILuaTable);
  public
    property FileName: String read FSavedVariablesFileName write FSavedVariablesFileName;
    property Servers: TDictionary<String, TESOServer> read FServers;
    property Accounts: TDictionary<String, TIifaAccount> read FAccounts;
    property Characters: TDictionary<String, TIifaCharacter> read FCharacters;
    property Items: TESOItemDataHandler read FItems;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function ParseFile(const AFileName: String = ''): Boolean;
  end;




implementation


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

  //Clear the old entries in Accounts, characters, items here now
  if Assigned(FAccounts) then
    FAccounts.Clear;
  if Assigned(FCharacters) then
    FCharacters.Clear;

  //TODO:  //->Error message: Pointer error! If assigned(Fitems)
  //if Assigned(FItems) then
  //FItems.Clear;

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

    //Is entry "Default" of IIfA_Settings?
    if pair.Key.AsString = BASE_SAVEDVARS_NAME then
    begin
      lTable := pair.Value.AsTable;
      enumAccounts := lTable.GetEnumerator;

      // Iterate through accounts
      while enumAccounts.MoveNext do
      begin
        pairAccounts := enumAccounts.Current;
        lAccount := TIifaAccount.Create( pairAccounts.Key.AsString.Replace('@', '') );
        fAccounts.Add( lAccount.DisplayName, lAccount );

        // Get each character below the currently parsed account
        lAccount.ParseCharacters( pairAccounts.Value.AsTable );
      end;
    end;
  end;
end;

//Called from TIIFAHelper.ParseFile after parsing the settings table,
// the data table will be parsed now to get the items
procedure TIIFAHelper.ParseDataTable( const aDataTable: ILuaTable );
var
  enum, enumAccounts, enumAccountWide, enumData, enumServer, enumDB, enumItems, enumItemData: ILuaTableEnumerator;
  pair, pairAccounts, pairAccountWide, pairData, pairServer, pairDB, pairItems, pairItemData: TLuaKeyValuePair;
  lDisplayName, pairServerKeyStr, lItemIdOrLink, sPairItemKeyStr, sPairItemValueStr: String;
  lTable: ILuaTable;
  lServer: TESOServer;
  lAccount: TIifaAccount;
  lItem: TESOItemData;
begin
  // Wenn nicht nil, versuche den Inhalt zu verstehen
  if not Assigned(aDataTable) then
     exit;

  // Parse tables below IIfA_Data
  enum := aDataTable.GetEnumerator;

  //Get next entry of IIfA_Data
  while enum.MoveNext do
  begin
    pair := enum.Current;

    //Is entry "Default" of IIfA_Data?
    if pair.Key.AsString = BASE_SAVEDVARS_NAME then
    begin
      lTable := pair.Value.AsTable;
      enumAccounts := lTable.GetEnumerator;

      // Iterate over the possible accounts
      while enumAccounts.MoveNext do
      begin
        pairAccounts := enumAccounts.Current;
        lDisplayName := pairAccounts.Key.AsString;

        // TODO: Check if the currenlty read account is in IIFAHelper.hAccounts, else skip to next entry
        lAccount := nil;

        lTable := pairAccounts.Value.AsTable;
        enumAccountWide := lTable.GetEnumerator;

        while enumAccountWide.MoveNext do
        begin
          pairAccountWide := enumAccountWide.Current;

          //Get next entry and check if it is '$AccountWide'
          if pairAccountWide.Key.AsString = ACCOUNT_WIDE_CHAR then
          begin
            lTable := pairAccountWide.Value.AsTable;
            enumData := lTable.GetEnumerator;

            //Iterate over the possible AccountWide entries
            while enumData.MoveNext do
            begin
              pairData := enumData.Current;

              //Get next entry and check if it is 'Data'
              if pairData.Key.AsString = ENTRY_DATA then
              begin
                lTable := pairData.Value.AsTable;
                enumServer := lTable.GetEnumerator;

                //Iterate over the possible server entries
                while enumServer.MoveNext do
                begin
                  pairServer := enumServer.Current;
                  pairServerKeyStr := pairServer.Key.AsString;

                  //Get next entry and check if it is one of the existing servers
                  if FServers.ContainsKey(pairServerKeyStr) then
                  begin
                    lServer := FServers.Items[pairServerKeyStr];

                    { TODO :
                    Server "lServer" is known, account "lAccount" is also known. items need to be parsed and then stored with their bagId, slotindex (if given) and the other TESOItemData fields
                    How to "connect" those (Server, account, item) now properly so one can search and see the dependencies? }
                    lTable := pairServer.Value.AsTable;
                    enumDB := lTable.GetEnumerator;


                    while enumDB.MoveNext do
                    begin
                      pairDB := enumDB.Current;
                    //Get next entry and check if it is the database version (currently DBv3, 2019-01-02)
                      if pairDB.Key.AsString = IIFA_SV_DB_VERSION then
                      begin
                        lTable := pairDB.Value.AsTable;
                        enumItems := lTable.GetEnumerator;

                        while enumItems.MoveNext do
                        begin
                          pairItems := enumItems.Current;
                          lItemIdOrLink := pairItems.Key.AsString;

                          //Create an item
                          lItem := TESOItemData.Create( lItemIdOrLink );

                          //Iterate over the other itemData and add the found information to the item
                          lTable := pairItems.Value.AsTable;
                          enumItemData := lTable.GetEnumerator;
                          while enumItemData.MoveNext do
                          begin
                            pairItemData := enumItemData.Current;
                            sPairItemKeyStr := pairItemData.Key.AsString;

                            //Read the locations of the item
                            if sPairItemKeyStr = ENTRY_LOCATIONS then
                            begin

                              //Read the subtables and get character Id, CraftBag, Bank, Guildbankname

                                //Read the subtable and get the bagSlot with more data below
                                  //Read the subtable and get the itemId = itemCount entry

                                //Read the subtable and get the bagId


                            end
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

                          // Set the items server
                          lItem.Server := lServer;
                          //Add the item to the IIfAHelper FItems (search helper) now
                          FItems.AddItem(lItem);
                        end;

                      end;

                    end;
                  end;
                end;

              end;

            end

          end;
        end
      end;
    end;
  end;
end;

end.
