unit IIfA.GuildBank;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections

  //ESO
  , ESO.GuildBank

  ;
 {$ENDREGION}

type

  //IIfA guild bank class
  TIIfAGuildBank = class (TESOGuildBank)
  strict private
    FWasCollected: Boolean;
    FLastCollected: TDateTime;

  public
    property WasCollected: Boolean read FWasCollected write FWasCollected;
    property LastCollected: TDateTime read FLastCollected write FLastCollected;

    function toString(): String; override;
  end;

implementation

{ TIIfAGuildBank }


function TIIfAGuildBank.toString: String;
   var
      sWasCollected: String;
begin
  if WasCollected then
   sWasCollected := 'True'
  else
   sWasCollected := 'False';

  Result := Format('Guildbank Server: %s, name: %s, itemCount: %s, wasCollected: %s, lastCollected: %s',
                    [Server.Name, Name, Asset_bagSpace.used.ToString, sWasCollected, DateTimeToStr(LastCollected)]
  );
end;

end.
