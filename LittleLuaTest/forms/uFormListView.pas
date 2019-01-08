unit uFormListView;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.TreeView, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FMX.Edit;

type
  TformListView = class(TForm)
    listItems: TListBox;
    cbServer: TComboBox;
    LabServer: TLabel;
    edSearch: TEdit;
    sedSearch: TSearchEditButton;
    labCharname: TLabel;
    cbCharacter: TComboBox;
    cbAccount: TComboBox;
    labAccount: TLabel;
    cbQuality: TComboBox;
    labQuality: TLabel;
    cbLevel: TComboBox;
    labLevel: TLabel;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  formListView: TformListView;

implementation

{$R *.fmx}

end.
