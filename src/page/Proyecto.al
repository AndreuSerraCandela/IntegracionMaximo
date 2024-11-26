//Crear Page List
page 50509 "Proyecto Máximo"
{
    PageType = List;
    SourceTable = Proyecto;
    DelayedInsert = true;
    ApplicationArea = All;
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Código"; Rec."Código")
                {
                    ApplicationArea = All;
                }
                field("Nombre Proyecto"; Rec."Nombre Proyecto")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}