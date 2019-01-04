unit IIFA.Constants;

interface
  uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections

  ;
 {$ENDREGION}


  //General constants of the addon Inventory Insight from Ashes (IIfA)
  const

    //-----------------------------------------------------
    //----- Constants used for the IIfA SavedVariables file -----
    //-----------------------------------------------------
    IIFA_SV_FILENAME            = 'IIfA.lua';

    //-----------------------------------------------------
    //----- Constants used in the IIfA SavedVariables file -----
    //-----------------------------------------------------
    //[Used in both, "settings" and "data"]
    //-Defined by addon-
    BASE_SAVEDVARS_NAME           = 'Default';
    COLLECT_GUILDBANK_DATA        = 'bCollectGuildBankData';

    //[Only used in "settings"]
    //-Defined by game-
    LAST_CHAR_NAME                = '$LastCharacterName';

    //[Only used in "data"]
    //-Defined by game-
    ACCOUNT_WIDE_CHAR             = '$AccountWide';

    //-Defined by addon-
    //--Keys in the SV "data" table:
    //---Defining the general subtables
    ENTRY_DATA                    = 'Data';

    //---Defining the server types
    SERVER_EU                     = 'EU';
    SERVER_NA                     = 'NA';
    SERVER_PTS                    = 'PTS';
    //---Defining the IIfA internal database version
    IIFA_SV_DB_VERSION            = 'DBv3'; //2019-01-02

    //---defining the item locations
    ENTRY_ASSETS                  = 'assets';
    ENTRY_LOCATIONS               = 'locations';
    ENTRY_BAG_BANK                = 'Bank';
    ENTRY_BAG_VIRTUAL             = 'CraftBag';
    ENTRY_BAG_GUILDBANK_DELIMITER = '-';
    ENTRY_BAG_GUILDBANK_SUFFIX    = ENTRY_BAG_GUILDBANK_DELIMITER + 'guildBanks'; // ServerType SERVER_* + suffix, e.g. "EU-guildBanks"
    //Where is the item located in detail (abg, slotIndex)?
    ENTRY_BAGID                   = 'bagID';
    ENTRY_SLOTINDEX               = 'bagSlot';

    //---definining the assets information
    ASSETS_ALLIANCE_POINTS        = 'ap';
    ASSETS_WRIT_VOUCHERS          = 'wv';
    ASSETS_GOLD                   = 'gold';
    ASSETS_TEL_VAR_STONES         = 'tv';
    ASSETS_SPACE_MAX              = 'spaceMax';
    ASSETS_SPACE_USED             = 'spaceUsed';

    //---definining the item information
    ITEM_INFO_ITEMLINK            = 'itemLink';
    //ITEM_INFO_ITEMLINK_ENTRY_ITEM = 'item'; // Inline text inside the itemlink, at offset 3 (split by char ':')
    ITEM_INFO_NAME                = 'itemName';
    ITEM_INFO_INSTANCEORUNIQUEID  = 'itemInstanceOrUniqueId';
    ITEM_INFO_FILTERTYPE          = 'filterType';
    ITEM_INFO_QUALITY             = 'itemQuality';

    //---defining the guild bank information
    GUILDBANK_ITEMCOUNT           = 'items';
    GUILDBANK_WAS_COLLECTED       = 'bCollectData';
    GUILDBANK_LAST_COLLECTED      = 'lastCollected';

implementation
end.
