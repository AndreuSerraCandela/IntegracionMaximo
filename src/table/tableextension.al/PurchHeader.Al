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
    }

}
