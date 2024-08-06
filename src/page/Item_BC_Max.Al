page 50001 "Item_BC_Max"
{
    PageType = List;
    SourceTable = Item_BC_Max;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Productos BC-Maximo';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Código Producto"; Rec."Código Producto")
                {
                    ApplicationArea = All;
                }
                field("Descripción de Producto"; Rec."Descripción de Producto")
                {
                    ApplicationArea = All;
                }
                field("Tipo de Integración"; Rec."Tipo de Integración")
                {
                    ApplicationArea = All;
                }
                field("Código Asociado"; Rec."Código Asociado")
                {
                    ApplicationArea = All;
                }
                field("Unidad de Medida"; Rec."Unidad de Medida")
                {
                    ApplicationArea = All;
                }
                field("Costo Producto"; Rec."Costo Producto")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}