
// Proyecto 		
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre Proyecto 	Char 	50 
//Crear Tabla y Page de Proyecto
table 50108 Proyecto
{
    DrillDownPageId = Proyecto;
    LookupPageId = Proyecto;
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
//Crear Page List
page 50109 "Proyecto"
{
    PageType = List;
    SourceTable = Proyecto;
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
                field("Nombre Proyecto"; Rec."Nombre Proyecto")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}