pageextension 50501 UnitOfMeasureExt extends "Units of Measure"
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