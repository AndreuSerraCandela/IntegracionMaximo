//cREAR pAGE list
page 50500 "Solicitud Encabezado"
{
    PageType = List;
    SourceTable = "Solicitud Encabezado";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Solicitud Encabezado Ficha";
    layout
    {
        area(content)
        {
            repeater(Lista)
            {
                field("N Solicitud"; Rec."N Solicitud")
                {
                    ApplicationArea = All;
                }
                field("ID Proveedor"; Rec."ID Proveedor")
                {
                    ApplicationArea = All;
                }
                field("Nombre Proveedor"; Rec."Nombre Proveedor")
                {
                    ApplicationArea = All;
                }
                field("Teléfono"; Rec."Teléfono")
                {
                    ApplicationArea = All;
                }
                field("Correo"; Rec."Correo")
                {
                    ApplicationArea = All;
                }
                field("Descripción General"; Rec."Descripción General")
                {
                    ApplicationArea = All;
                }
                field("Fecha de Creación"; Rec."Fecha de Creación")
                {
                    ApplicationArea = All;
                }
                field("Fecha de Estimada Inicio"; Rec."Fecha de Estimada Inicio")
                {
                    ApplicationArea = All;
                }
                field("Fecha estimada finalización"; Rec."Fecha estimada finalización")
                {
                    ApplicationArea = All;
                }
                field("Creado por"; Rec."Creado por")
                {
                    ApplicationArea = All;
                }
                field("Circuito"; Rec."Circuito")
                {
                    ApplicationArea = All;
                }
                field("Estado"; Rec."Estado")
                {
                    ApplicationArea = All;
                }
                field("N solicitud necesidad"; Rec."N solicitud necesidad")
                {
                    ApplicationArea = All;
                }
            }

        }
    }

}
