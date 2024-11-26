//Crear Page List
page 50510 "CuentasxEpigrafe"
{
    PageType = List;
    SourceTable = CuentasxEpigrafe;
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
                field("Nombre Epigrafe"; Rec."Nombre Epigrafe")
                {
                    ApplicationArea = All;
                }
                field("Cuenta"; Rec."Cuenta")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
