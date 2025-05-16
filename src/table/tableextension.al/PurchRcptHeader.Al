tableextension 50515 "Purch. Rcpt. Header Ext." extends "Purch. Rcpt. Header"
{
    fields
    {
        field(50100; "N Solicitud"; Code[15])
        {
            Caption = 'Nº Solicitud Máximo';
            DataClassification = CustomerContent;
        }
        field(50101; "Enviado a Maximo"; Boolean)
        {
            Caption = 'Enviado a Máximo';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50102; "Fecha Envio a Maximo"; DateTime)
        {
            Caption = 'Fecha de Envío a Máximo';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }


}