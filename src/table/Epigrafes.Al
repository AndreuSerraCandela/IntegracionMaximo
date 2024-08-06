// Epigrafe 		
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código E 	Char 	20 
// 2 	Nombre Epigrafe 	Char 	50 
//Crear Tabla y Page de Epigrafes
table 50107 Epigrafes
{
    DrillDownPageId = Epigrafes;
    LookupPageId = Epigrafes;
    fields
    {
        field(1; "Código E"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nombre Epigrafe"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Código E")
        {
            Clustered = true;
        }
    }
}
//Crear Page List
page 50108 "Epigrafes"
{
    PageType = List;
    SourceTable = Epigrafes;
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Código E"; Rec."Código E")
                {
                    ApplicationArea = All;
                }
                field("Nombre Epigrafe"; Rec."Nombre Epigrafe")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
