table 50516 "Log Máximo"
{
    DrillDownPageId = Log;
    LookupPageId = Log;
    fields
    {
        field(1; "ID"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Fecha"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Hora"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Proceso"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(5; "Mensaje"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "ID")
        {
            Clustered = true;
        }
    }
}
//Crear una page para la tabla Log
page 50116 "Log"
{
    PageType = List;
    SourceTable = "Log Máximo";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Log';
    layout
    {
        area(content)
        {
            repeater(Detalle)
            {
                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                }
                field("Fecha"; Rec."Fecha")
                {
                    ApplicationArea = All;
                }
                field("Hora"; Rec."Hora")
                {
                    ApplicationArea = All;
                }
                field("Proceso"; Rec."Proceso")
                {
                    ApplicationArea = All;
                }
                field("Mensaje"; Rec."Mensaje")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}