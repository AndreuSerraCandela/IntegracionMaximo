tableextension 50512 "Purc_Rcpt_Line Extension" extends "Purch. Rcpt. Line"
{
    fields
    {
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