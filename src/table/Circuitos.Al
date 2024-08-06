// Circuito 		
// Campo 	Nombre 	Tipo 	Tamaño 
// 1 	Código 	Char 	20 
// 2 	Nombre Circuito 	Char 	30 
//Crear Tabla y Page de Circuitos
table 50102 Circuitos
{
    DrillDownPageId = Circuitos;
    LookupPageId = Circuitos;
    fields
    {
        field(1; "Código"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Nombre Circuito"; Text[30])
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
page 50103 "Circuitos"
{
    PageType = List;
    SourceTable = Circuitos;
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
                field("Nombre Circuito"; Rec."Nombre Circuito")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
