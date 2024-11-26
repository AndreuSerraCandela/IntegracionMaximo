//Crear Page List
page 50504 "Pedido Presupuesto"
{
    PageType = List;
    SourceTable = "Pedido Presupuesto";
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
                field("Nombre P. Presupuesto"; Rec."Nombre P. Presupuesto")
                {
                    ApplicationArea = All;
                }
                field("Cuenta"; Rec."Cuenta")
                {
                    ApplicationArea = All;
                }
                field("Dimensión"; Rec."Dimensión")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
