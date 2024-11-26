
// Cuenta Cuenta Epigrafe 	
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre Epigrafe 	Char 	50 
// 3 	Cuenta 	Char 	50 
//Crear Tabla y Page de CuentasxEpigrafe
table 50509 CuentasxEpigrafe
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
