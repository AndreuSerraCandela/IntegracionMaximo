//Crear Page List
page 50507 "OT"
{
    PageType = List;
    SourceTable = OT;
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
                field("Nombre De OT"; Rec."Nombre De OT")
                {
                    ApplicationArea = All;
                }
                field("Código Sociedad"; Rec."Código Sociedad")
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
