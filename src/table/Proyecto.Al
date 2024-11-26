
// Proyecto 		
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre Proyecto 	Char 	50 
//Crear Tabla y Page de Proyecto
table 50508 Proyecto
{
    DrillDownPageId = "Proyecto Máximo";
    LookupPageId = "Proyecto Máximo";
    fields
    {
        field(1; "Código"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nombre Proyecto"; Text[50])
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
