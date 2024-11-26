//Crear Page List
page 50508 "Epigrafes"
{
    PageType = List;
    SourceTable = Epigrafes;
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Código E"; Rec."Código E")
                {
                    ApplicationArea = All;
                }
                field("Nombre Epigrafe"; Rec."Nombre Epigrafe")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
