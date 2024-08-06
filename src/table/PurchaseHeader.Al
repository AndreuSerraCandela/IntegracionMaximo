tableextension 50100 "Purchase Header Extension" extends "Purchase Header"
{
    fields
    {
        field(50100; "N Solicitud"; Code[15])
        {
            DataClassification = CustomerContent;
        }
    }

}