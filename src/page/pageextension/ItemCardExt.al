pageextension 50500 ItemCardExt extends "Item Card"
{
    layout
    {
        addafter(Description)
        {
            field("Maximo Item"; Rec."Maximo Item")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica el código del item en Maximo';
            }
        }
    }
}