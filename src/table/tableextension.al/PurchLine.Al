tableextension 50511 "Purchase Line Extension" extends "Purchase Line"
{
    fields
    {
        field(50100; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(50103; "Item"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item_BC_Max."Código Producto";
            ValidateTableRelation = false;
        }
        field(50101; "N Solicitud"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50102; Linea; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

}