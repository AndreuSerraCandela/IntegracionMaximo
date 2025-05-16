// 	Solicitud_Líneas 	
// Campo 		Nombre 	Tipo 	Tamaño 
// 	1 	N Solicitud 	Char 	15 
// 	2 	N Línea 	numérico 	20 
// 	3 	Sociedad 	Char 	20 
// 	4 	OT 	Char 	20 
// 	5 	Descripción bien o servicio 	Char 	100 
// 	6 	Cantidad 	numérico 	15,2 
// 	7 	Cuenta activo fijo 	Char 	30 
// 	8 	n Pedido Presupuesto 	Char 	80 
// 	9 	Epígrafe Pptop 	Char 	  
// 	10 	Cuenta activo fijo 	Fecha 	  
// 	11 	Dimensión 	Fecha 	  
// 	12 	Proyecto 	Fecha 	50 
// 	13 	Importe 	Char 	20 
// 	14 	Año 	Char 	4 
// 	15 	Relación con el contrato 	Char 	  
//Crear Tabla y Page ListPart
table 50521 "Solicitud Líneas"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "N Solicitud"; Code[15])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Solicitud Encabezado"."N Solicitud";
        }
        field(2; "N Línea"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Sociedad"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Sociedades."Código";
        }
        field(4; "OT"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = OT."Código";
        }
        field(5; "Descripción bien o servicio"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Item"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item_BC_Max."Código Producto";
            ValidateTableRelation = false;
        }
        field(6; "Cantidad"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Cuenta activo fijo"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "N Pedido Presupuesto"; Text[80])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Pedido Presupuesto"."Código";
        }
        field(9; "Epígrafe Pptop"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Epigrafes."Código E";
        }
        field(10; "Fecha activo fijo"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Dimensión"; Date)
        {
            ObsoleteState = Removed;
            DataClassification = ToBeClassified;
        }
        field(16; "Dimension"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Proyecto"; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = Proyecto."Código";
        }
        field(13; "Importe"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Año"; Code[4])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Relación con el contrato"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Costo Unitario"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "UnidadeMedida"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Fecha de Recepción Esperada"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "N Solicitud", "N Línea")
        {
            Clustered = true;
        }
    }
}
//Crear Page ListPart
