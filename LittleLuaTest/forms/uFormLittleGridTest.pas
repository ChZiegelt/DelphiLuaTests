unit uFormLittleGridTest;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid;

type
  TformGrid = class(TForm)
    sgrid: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    StringColumn4: TStringColumn;
    StringColumn5: TStringColumn;
    DateColumn1: TDateColumn;
    TimeColumn1: TTimeColumn;
    IntegerColumn1: TIntegerColumn;
    IntegerColumn2: TIntegerColumn;
    IntegerColumn3: TIntegerColumn;
    IntegerColumn4: TIntegerColumn;
    IntegerColumn5: TIntegerColumn;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  formGrid: TformGrid;

implementation

{$R *.fmx}

end.
