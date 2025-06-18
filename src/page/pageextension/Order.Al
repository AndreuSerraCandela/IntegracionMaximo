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
    actions
    {
        addlast(processing)
        {
            action("Probar Envío a Máximo")
            {
                ApplicationArea = All;
                Caption = 'Probar Envío a Máximo';
                Image = SendElectronicDocument;
                ToolTip = 'Envía este pedido a Máximo usando la integración real.';
                trigger OnAction()
                var
                    EnvioMaximo: Codeunit "Envio Maximo";
                begin
                    if EnvioMaximo.EnviarPedidoCompraAMaximoReal(Rec) then
                        Message('Pedido enviado correctamente a Máximo.')
                    else
                        Message('No se pudo enviar el pedido a Máximo.');
                end;
            }
        }
    }
}
