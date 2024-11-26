//Crear Page List
page 50503 "Circuitos"
{
    PageType = List;
    SourceTable = Circuitos;
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;
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
                field("Nombre Circuito"; Rec."Nombre Circuito")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
