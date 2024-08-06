
// Cuenta Cuenta Epigrafe 	
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre Epigrafe 	Char 	50 
// 3 	Cuenta 	Char 	50 
//Crear Tabla y Page de CuentasxEpigrafe
table 50109 CuentasxEpigrafe
{
    DrillDownPageId = CuentasxEpigrafe;
    LookupPageId = CuentasxEpigrafe;
    fields
    {
        field(1; "Código"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nombre Epigrafe"; Text[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Epigrafes"."Nombre Epigrafe" where("Código E" = Field("Código")));
        }
        field(3; "Cuenta"; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
    }
    keys
    {
        key(PK; "Código", "Cuenta")
        {
            Clustered = true;
        }
    }
}
//Crear Page List
page 50110 "CuentasxEpigrafe"
{
    PageType = List;
    SourceTable = CuentasxEpigrafe;
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Código"; Rec."Código")
                {
                    ApplicationArea = All;
                }
                field("Nombre Epigrafe"; Rec."Nombre Epigrafe")
                {
                    ApplicationArea = All;
                }
                field("Cuenta"; Rec."Cuenta")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
