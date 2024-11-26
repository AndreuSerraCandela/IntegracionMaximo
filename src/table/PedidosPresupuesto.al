
// Pedido Presupuesto 	
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	5 
// 2 	Nombre P. Presupuesto 	Char 	20 
// 3 	Cuenta 	Char 	10 
// 4 	Dimensión 	Char 	20 
//Crear Tabla y Page de Pedido Presupuesto
table 50503 "Pedido Presupuesto"
{
    DataClassification = ToBeClassified;
    DrillDownPageId = "Pedido Presupuesto";
    LookupPageId = "Pedido Presupuesto";
    fields
    {
        field(1; "Código"; Code[5])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nombre P. Presupuesto"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Cuenta"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account"."No.";
        }
        field(4; "Dimensión"; Code[20])
        {
            DataClassification = ToBeClassified;
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
