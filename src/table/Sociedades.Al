
// Sociedad 		
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre Sociedad 	Char 	20 
//Crear Tabla y Page de Sociedades
table 50104 Sociedades
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
//Crear Page List
page 50105 "Sociedades"
{
    PageType = List;
    SourceTable = Sociedades;
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
                field("Nombre Sociedad"; Rec."Nombre Sociedad")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
