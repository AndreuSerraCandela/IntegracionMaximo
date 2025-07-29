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
            field("Location Máximo"; Rec."Location Máximo")
            {
                ApplicationArea = All;
                ToolTip = 'Especifica el código del location en Maximo';
            }
        }
    }
}