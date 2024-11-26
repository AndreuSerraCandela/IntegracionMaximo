// Productos BC-Maximo 
// Campo 	Nombre 
// 1 	Código Producto 
// 2 	Descripción de Producto 
// 4 	Cuenta Contable Asociada 
// 5 	Unidad de Medida 
// 6 	Costo Producto 
table 50501 Item_BC_Max
{
    DrillDownPageId = Item_BC_Max;
    LookupPageId = Item_BC_Max;
    fields
    {
        field(1; "Código Producto"; Code[20])
        {

        }
        field(2; "Descripción de Producto"; Text[50])
        {

        }
        field(3; "Tipo de Integración"; Enum TipoCodigoIntegracion)
        {

        }
        field(4; "Código Asociado"; Code[20])
        {
            TableRelation = if ("Tipo de Integración" = Const("G/L Account")) "G/L Account"."No." else
            Item."No.";

        }
        field(5; "Unidad de Medida"; Code[10])
        {

        }
        field(6; "Costo Producto"; Decimal)
        {

        }

    }
    keys
    {
        key(PK; "Código Producto")
        {
            Clustered = true;
        }
    }
}
//Crear Page List

