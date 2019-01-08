unit ESO.Constants;

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


  //General constants of the Game Elder Scrolls Online
  const
    //-----------------------------------------------------
    //----- Constants used in the lua script environment --
    //-----------------------------------------------------
    LUA_SCRIPT_FILE_EXTENSION = '.lua';

    //-----------------------------------------------------
    //----- Constants used in the game environment -----
    //-----------------------------------------------------
    SERVER_EU_IP              = '195.122.154.1';
    SERVER_NA_IP              = '198.20.198.110';
    SERVER_PTS_IP             = '???.???.???.???';
    SERVER_ANNOUNCEMENTS_URL  = 'https://help.elderscrollsonline.com/app/answers/detail/a_id/4320'; // get HTML result and read below "ESO SERVICE ALERTS" at the current date to check if servers are online

    //Guild banks
    ESO_GUILDBANK_MAX_ITEMCOUNT = 500;

    ESO_ITEMLINK_PREFIX         = '|H'; //An ESO itemlink starts with this, e.g. |H0 or |H1 (H0 without, H1 with surrounding [])



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////
  //Online ressources like images of items, data of items, search of items, etc.
  //////////////////////////////////////////////////////////////////////////////

  //UESP
  UESP_IMAGE_URL_BY_ITEMID  = 'http://esoitem.uesp.net/itemLinkImage.php?itemid=%s&summary&none=item.png';



   type
    (*
    --BagIds--
    BAG_WORN                  = 0;
    BAG_BACKPACK              = 1;
    BAG_BANK                  = 2;
    BAG_GUILDBANK             = 3;
    BAG_BUYBACK               = 4;
    BAG_VIRTUAL               = 5; //CraftBag
    BAG_SUBSCRIBER_BANK       = 6; //ESO+ payed members: Additional bank space!
    BAG_HOUSE_BANK_ONE        = 7; // Housing bank/chests, possible: 1 to 10
    BAG_HOUSE_BANK_TWO        = 8;
    BAG_HOUSE_BANK_THREE      = 9;
    BAG_HOUSE_BANK_FOUR       = 10;
    BAG_HOUSE_BANK_FIVE       = 11;
    BAG_HOUSE_BANK_SIX        = 12;
    BAG_HOUSE_BANK_SEVEN      = 13;
    BAG_HOUSE_BANK_EIGHT      = 14;
    BAG_HOUSE_BANK_NINE       = 15;
    BAG_HOUSE_BANK_TEN        = 16;
    BAG_DELETE                = 17; // ???
    //Iterators
    BAG_MIN_VALUE             = 0;
    BAG_MAX_VALUE             = 17;
  *)
    TESOBagIds = (BAG_WORN, BAG_BACKPACK, BAG_BANK, BAG_GUILDBANK, BAG_BUYBACK,
                  BAG_VIRTUAL, BAG_SUBSCRIBER_BANK,
                  BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TWO, BAG_HOUSE_BANK_THREE, BAG_HOUSE_BANK_FOUR, BAG_HOUSE_BANK_FIVE,
                  BAG_HOUSE_BANK_SIX, BAG_HOUSE_BANK_SEVEN, BAG_HOUSE_BANK_EIGHT, BAG_HOUSE_BANK_NINE, BAG_HOUSE_BANK_TEN,
                  BAG_DELETE);


implementation
end.
