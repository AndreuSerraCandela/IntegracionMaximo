// 	Solicitud encabezado 	
// Campo 		Nombre 	Tipo 	Tamaño 
// 	1 	N Solicitud 	Char 	15 
// 	2 	ID Proveedor 	Char 	15 
// 	3 	Nombre Proveedor 	Char 	100 
// 	4 	Teléfono 	Char 	30 
// 	5 	Correo 	Char 	80 
// 	6 	Descripción General 	Char 	200 
// 	7 	Fecha de Creación 	Fecha 	  
// 	8 	Fecha de Estimada Inicio 	Fecha 	  
// 	9 	Fecha estimada finalización 	Fecha 	  
// 	10 	Creado por 	Char 	20 
// 	11 	Circuito 	Char 	30 
// 	12 	Estado 	Char 	  
// 	13 	N solicitud necesidad 	Char 	20 
//Crear Tabla Page list y Page Card
table 50100 "Solicitud Encabezado"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "N Solicitud"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "ID Proveedor"; Code[15])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Nombre Proveedor"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Teléfono"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Correo"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Descripción General"; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Fecha de Creación"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Fecha de Estimada Inicio"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Fecha estimada finalización"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Creado por"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Circuito"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Circuitos"."Código";
        }
        field(12; "Estado"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "N solicitud necesidad"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "N Solicitud")
        {
            Clustered = true;
        }
    }
}
