unit uFormLittleTest;

interface

uses
  {$REGION 'Uses'}
    System.SysUtils
  , System.StrUtils
  , System.Types
  , System.UITypes
  , System.Classes

  , System.Generics.Collections
  , Lua

  // ESO
  , ESO.Constants
  , ESO.GuildBank
  , ESO.ItemData

  // IIFA
  , IIFA.Account
  , IIFA.GuildBank
  , IIFA.Helper

  // Zum Formular gehörend
  , System.Variants
  , FMX.Types
  , FMX.Controls
  , FMX.Forms
  , FMX.Graphics
  , FMX.Dialogs
  , FMX.ScrollBox
  , FMX.Memo
  , FMX.Controls.Presentation
  , FMX.StdCtrls, FMX.Edit

  //Grid Formular
  , uFormLittleGridTest
  ;
  {$ENDREGION}

type
  TformMemo = class(TForm)
    memo: TMemo;
    Button2: TButton;
    edSearch: TEdit;
    sedSearch: TSearchEditButton;
    procedure Button2Click(Sender: TObject);

    procedure sedSearchClick(Sender: TObject);
    procedure edSearchKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);  private

    IifaHelper: TIIFAHelper;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

  public

  end;

  TSearchOption = (soIgnoreCase, soFromStart, soWrap);
  TSearchOptions = set of TSearchOption;


var
  formMemo: TformMemo;


implementation

function SearchText(Control: TMemo; Search: string; SearchOptions: TSearchOptions): Boolean;
var
  Text: string;
  Index: Integer;
begin
  if soIgnoreCase in SearchOptions then
  begin
    Search := LowerCase(Search);
    Text := LowerCase(Control.Text);
  end
  else
    Text := Control.Text;

  Index := 0;
  if not (soFromStart in SearchOptions) then
    Index := PosEx(Search, Text, Control.SelStart + Control.SelLength + 1);

  if (Index = 0) and
      ((soFromStart in SearchOptions) or
       (soWrap in SearchOptions)) then
    Index := PosEx(Search, Text, 1);

  Result := Index > 0;
  if Result then
  begin
    Control.SelStart := Index - 1;
    Control.SelLength := Length(Search);
    //Show selected text even if control got no focus
    Control.HideSelectionOnExit := False;
    // Or set teh focus (or both)
    //Control.SetFocus;
  end;
end;

{$R *.fmx}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}

procedure TformMemo.AfterConstruction;
begin
  inherited;
  //Create InventoryInsightFromAshes file parser and specify the filename of the IIfA SavedVariables
  IIfAHelper := TIIFAHelper.Create;
  FormGrid := TFormGrid.Create(formMemo);
end;



procedure TformMemo.BeforeDestruction;
begin
  FreeAndNil(IifaHelper);
  inherited;
end;

procedure TformMemo.Button2Click(Sender: TObject);
var
  lAccount: TIIfAAccount;
  lItem:    TESOItemData;
  lItemList:  TList<TESOItemData>;
  lGuildBank: TIIfAGuildBank;
  lStrings: TStrings;
  sLocation: String;
  iRow: Integer;
begin
  //Parse the IIfA.lua SavedVariables file if given
  if not String.IsNullOrEmpty(IIfAHelper.FileName) and FileExists(IIfAHelper.FileName) then
  begin
    IifaHelper.ParseFile();

    ////////////////////
    //  OUTPUT MEMO   //
    ////////////////////

    // AccountName
    //   Charaktername, CharakterId, Einstellung GildenBankLesen, Gold und andere Vermögen
    memo.Lines.Clear;


    memo.Lines.Add('[Accounts & characters]');
    for lAccount in IifaHelper.Accounts.Values do
    begin
      lStrings := lAccount.ToStrings();
      memo.Lines.AddStrings( lStrings );
      FreeAndNil(lStrings);
    end;

    //Guild Banks
    memo.Lines.Add('');
    memo.Lines.Add('[Guild Banks]');
    for lGuildBank in IifaHelper.GuildBanks.Values do
    begin
      memo.Lines.Add( lGuildBank.toString() );
    end;

    //Items
    memo.Lines.Add('');
    memo.Lines.Add('[Items]');
    lItemList := IifaHelper.Items.GetItemList();
    if Assigned(lItemList)  then
      for lItem in lItemList do
      begin
        memo.Lines.Add( lItem.toString() );
      end;

    ////////////////////
    //  OUTPUT GRID   //
    ////////////////////

    // AccountName
    //   Charaktername, CharakterId, Einstellung GildenBankLesen, Gold und andere Vermögen
    if Assigned(formGrid) then
    begin
      if not formGrid.sgrid.Cells[1, 1].IsEmpty then
        formGrid.sgrid.ClearContent;
     //Items
      if Assigned(lItemList)  then
        iRow := 0;
        for lItem in lItemList do
        begin
          formGrid.sgrid.RowCount := iRow + 1;
          //5xString
          formGrid.sgrid.Cells[0, iRow] := lItem.Name;
          if Assigned(lItem.Character) then
            formGrid.sgrid.Cells[1, iRow] := lItem.Character.Name
          else
            formGrid.sgrid.Cells[1, iRow] := '';
          if (Assigned(lItem.Bank)) and (TESOGuildBank(lItem.Bank).Name <> '') then
            formGrid.sgrid.Cells[2, iRow] := TESOGuildBank(lItem.Bank).Name;
          formGrid.sgrid.Cells[3, iRow] := '';
          formGrid.sgrid.Cells[4, iRow] := '';
          //5xInteger
          formGrid.sgrid.Cells[5, iRow] := lItem.FilterType.ToString;
          formGrid.sgrid.Cells[6, iRow] := lItem.Level.ToString;
          formGrid.sgrid.Cells[7, iRow] := lItem.Quality.ToString;

          if lItem.BagId = BAG_WORN then
            sLocation := 'Worn'
          else if lItem.BagId = BAG_BACKPACK then
            sLocation := 'Inventory'
          else if lItem.BagId = BAG_BANK then
            sLocation := 'Bank'
          else if lItem.BagId = BAG_SUBSCRIBER_BANK then
            sLocation := 'ESO+ Bank'
          else if lItem.BagId = BAG_VIRTUAL then
            sLocation := 'Craftbag'
          else if lItem.BagId = BAG_GUILDBANK then
            if (Assigned(lItem.Bank)) then
              sLocation := 'Guildbank "' + TESOGuildBank(lItem.Bank).Name + '"'
            else
              sLocation := 'Guildbank <wasn''t created yet>';
          formGrid.sgrid.Cells[8, iRow] := sLocation;
          formGrid.sgrid.Cells[9, iRow] := lItem.SlotIndex.ToString;
          //1xDate
          //1xTime

          inc(iRow);
        end;
      formGrid.Visible := True;
      formGrid.Show;
    end;
  end;
end;


procedure TformMemo.edSearchKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = 13 then
    sedSearch.OnClick(Sender);
end;

procedure TformMemo.sedSearchClick(Sender: TObject);
begin
  if (Memo.Text <> '') and (edSearch.Text <> '') then
    SearchText(Memo, edSearch.Text, [soIgnoreCase, soWrap]);
end;

end.
