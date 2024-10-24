tableextension 50100 "Purchase Header Extension" extends "Purchase Header"
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
tableextension 50101 "Purchase Line Extension" extends "Purchase Line"
{
    fields
    {
        field(50100; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
    }

}