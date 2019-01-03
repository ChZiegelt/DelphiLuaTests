unit IIFA.Data;

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
  , IIFA.Account
  , IIFA.Server

  ;

type
  TIifaData = class( TList<TIifaServer> )
  strict private
    FTable: ILuaTable;
    procedure setTable(const Value: ILuaTable);
  public
    property Table: ILuaTable read FTable write setTable;
  end;

implementation

{ TIifaData }

procedure TIifaData.setTable(const Value: ILuaTable);
var
  enum, enumAccounts, enumAccountWide, enumData, enumServer, enumDB, enumItems: ILuaTableEnumerator;
  pair, pairAccounts, pairAccountWide, pairData, pairServer, pairDB, pairItems: TLuaKeyValuePair;
  pairServerKeyStr: String;
  lTable: ILuaTable;
  lServer: TIifaServer;
  lServerType: TIifaServerType;
  lServerIndex: byte;
  lAccount: TIifaAccount;
  str: String;

begin
  FTable := Value;

  // Wenn nicht nil, versuche den Inhalt zu verstehen
  if not Assigned(Value) then
     exit;

  // Parse die Arrays unterhalb von IIfA_Data
  enum := Value.GetEnumerator;

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

                  //Get next entry and check if it is one of the server constants 'EU', 'NA', or 'PTS'
                  if (pairServerKeyStr = SERVER_EU)
                  or (pairServerKeyStr = SERVER_NA)
                  or (pairServerKeyStr = SERVER_PTS) then
                  begin
                    lTable := pairServer.Value.AsTable;
                    enumDB := lTable.GetEnumerator;

                    while enumDB.MoveNext do
                    begin
                      pairDB := enumDB.Current;
                    //Get next entry and check if it is the database version (currently DBv3, 2019-01-02)
                      if pairDB.Key.AsString = IIFA_SV_DB_VERSION then
                      begin
                        //TODO: How to find out if the server entry was not created already?
                        //ONLY CREATE IT ONCE AND ONLY ASSIGN THE ACCOUNTS TO EACH SERVER ONCE!
                        //Map the server String to it's id
                        lServerIndex := IIFA_SERVER_MAPPING.Values[pairServerKeyStr].ToInteger();
                        if lServerIndex > 0 then
                        begin
                          //Create a new server instance, and assign the current acount to it
                          lServerType := TIifaServerType.Create(IIFA_SERVER_DATA[lServerIndex][1], IIFA_SERVER_DATA[lServerIndex][2], IIFA_SERVER_DATA[lServerIndex][3]);
                          lServer     := TIifaServer.Create(lServerType);
                          //Create the currently selected account new and assign it to the server, if it's not already in it
                          lAccount := TIifaAccount.Create( pairAccounts.Key.AsString.Replace('@', '') );
                          if not lServer.Contains(lAccount) then
                          begin
                            lServer.Add(lAccount);
                          end;
                          //Add the created server to the data if it is not already in it
                          if not self.Contains(lServer) then
                          begin
                            self.Add(lServer);
                          end;
                        end;

                        lTable := pairDB.Value.AsTable;
                        enumItems := lTable.GetEnumerator;

                        while enumItems.MoveNext do
                        begin
                          pairItems := enumItems.Current;
                          //lItem := TItem.Create( pairItems.Key.AsString );
                          //Self.Add( lItem );
                          str := pairItems.Key.AsString;
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
