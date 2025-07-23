pageextension 50502 LocationCardExt extends "Location Card"
{
    layout
    {
        addafter(Name)
        {
            field("Site Máximo"; Rec."Site Máximo")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica el código del site en Maximo';
            }
        }
    }
}