
// Sociedad 		
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre Sociedad 	Char 	20 
//Crear Tabla y Page de Sociedades
table 50504 Sociedades
{
    DrillDownPageId = Sociedades;
    LookupPageId = Sociedades;
    fields
    {
        field(1; "Código"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nombre Sociedad"; Text[20])
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
