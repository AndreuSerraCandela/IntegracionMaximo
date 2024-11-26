// OT	
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre De OT 	Char 	20 
// 3 	Nombre Sociedad 	Char 	20 
// 4 	Código Sociedad 	Char 	20
// Crear Tabla y Page de OT
table 50506 OT
{
    DrillDownPageId = OT;
    LookupPageId = OT;
    fields
    {
        field(1; "Código"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nombre De OT"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Nombre Sociedad"; Text[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Sociedades"."Nombre Sociedad" where("Código" = Field("Código Sociedad")));
        }
        field(4; "Código Sociedad"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Sociedades"."Código";
        }
    }
    keys
    {
        key(PK; "Código")
        {
            Clustered = true;
        }
    }
}
