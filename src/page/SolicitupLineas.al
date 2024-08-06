page 50101 "Solicitud Líneas"
{
    PageType = ListPart;
    SourceTable = "Solicitud Líneas";
    DelayedInsert = true;
    AutoSplitKey = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field("N Línea"; Rec."N Línea")
                {
                    ApplicationArea = All;

                }
                field("Sociedad"; Rec."Sociedad")
                {
                    ApplicationArea = All;
                }
                field("OT"; Rec."OT")
                {
                    ApplicationArea = All;
                }
                field("Descripción bien o servicio"; Rec."Descripción bien o servicio")
                {
                    ApplicationArea = All;
                }
                field("Cantidad"; Rec."Cantidad")
                {
                    ApplicationArea = All;
                }
                field("Cuenta activo fijo"; Rec."Cuenta activo fijo")
                {
                    ApplicationArea = All;
                }
                field("N Pedido Presupuesto"; Rec."N Pedido Presupuesto")
                {
                    ApplicationArea = All;
                }
                field("Epígrafe Pptop"; Rec."Epígrafe Pptop")
                {
                    ApplicationArea = All;
                }
                field("Fecha activo fijo"; Rec."Fecha activo fijo")
                {
                    ApplicationArea = All;
                }
                field("Dimensión"; Rec."Dimensión")
                {
                    ApplicationArea = All;
                }
                field("Proyecto"; Rec."Proyecto")
                {
                    ApplicationArea = All;
                }
                field("Importe"; Rec."Importe")
                {
                    ApplicationArea = All;
                }
                field("Año"; Rec."Año")
                {
                    ApplicationArea = All;
                }
                field("Relación con el contrato"; Rec."Relación con el contrato")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}