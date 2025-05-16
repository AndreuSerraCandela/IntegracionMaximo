tableextension 50510 "Purchase Header Extension" extends "Purchase Header"
{
    fields
    {
        field(50100; "N Solicitud"; Code[15])
        {
            DataClassification = CustomerContent;
        }
        field(50101; "Order No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(50102; "Enviado a Maximo"; Boolean)
        {
            Caption = 'Enviado a Máximo';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50103; "Fecha Envio a Maximo"; DateTime)
        {
            Caption = 'Fecha de Envío a Máximo';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50104; "Estado Maximo"; Text[30])
        {
            Caption = 'Estado Máximo';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50105; "Tipo de Pedido"; Option)
        {
            Caption = 'Tipo de Pedido';
            DataClassification = CustomerContent;
            OptionMembers = "WMATL","WPO","TRACKMTL","TRCKPO","WSUP";
        }
    }


}
