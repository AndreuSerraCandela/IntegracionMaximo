pageextension 50505 "Order" extends "Purchase Order"
{
    layout
    {
        addafter("Posting Date")
        {
            field("N Solicitud"; Rec."N Solicitud")
            {
                ApplicationArea = All;
            }
            field("Tipo de Pedido"; Rec."Tipo de Pedido")
            {
                ApplicationArea = All;
            }
        }
    }
}
