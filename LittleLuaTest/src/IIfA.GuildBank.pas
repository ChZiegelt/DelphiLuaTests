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

  public
    function toString(): String; override;

  end;

implementation

{ TIIfAGuildBank }

{ TIIfAGuildBank }

function TIIfAGuildBank.toString: String;
begin
  Result := Format('Guildbank Server: %s, name: %s, itemCount: %s',
                    [Server.Name, Name, Asset_bagSpace.used.ToString]
  );

end;

end.
