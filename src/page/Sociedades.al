//Crear Page List
page 50505 "Sociedades"
{
    PageType = List;
    SourceTable = Sociedades;
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
                field("Nombre Sociedad"; Rec."Nombre Sociedad")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
