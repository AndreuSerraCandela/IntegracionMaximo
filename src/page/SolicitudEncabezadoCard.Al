//cREAR pAGE list
page 50102 "Solicitud Encabezado Ficha"
{
    PageType = Card;
    SourceTable = "Solicitud Encabezado";
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(Group)
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
    actions
    {
        area(processing)
        {
            action("Create Order")
            {
                ApplicationArea = All;
                Caption = 'Crear Pedido';
                ToolTip = 'Crear';
                Image = Create;
                trigger OnAction()
                var
                    SolicitudEncabezado: Record "Solicitud Encabezado";
                    SolicitudLineas: Record "Solicitud Líneas";
                    OrderHeader: Record "Purchase Header";
                    OrderLine: Record "Purchase Line";
                    Vendor: Record Vendor;
                begin
                    OrderHeader.Init();
                    If not Vendor.Get(SolicitudEncabezado."ID Proveedor") then begin
                        Vendor.SetRange("VAT Registration No.", SolicitudEncabezado."ID Proveedor");
                        If Not Vendor.FindSet() then
                            Error('Proveedor no encontrado');
                    end;
                    OrderHeader."Document Type" := OrderHeader."Document Type"::Order;
                    OrderHeader."Order Date" := WORKDATE;
                    OrderHeader.Insert(true);
                    OrderHeader.Validate("Buy-from Vendor No.", SolicitudEncabezado."ID Proveedor");
                    OrderHeader."N Solicitud" := SolicitudEncabezado."N Solicitud";
                    OrderHeader.Modify(true);
                    SolicitudLineas.SetRange("N Solicitud", SolicitudEncabezado."N Solicitud");
                    If SolicitudLineas.FindSet() then
                        repeat
                            OrderLine.Init();
                            OrderLine."Document Type" := OrderLine."Document Type"::Order;
                            OrderLine."Line No." := OrderLine."Line No." + 1;
                            OrderLine."Buy-from Vendor No." := SolicitudEncabezado."ID Proveedor";
                            OrderLine."Description" := SolicitudLineas."Descripción bien o servicio";
                            OrderLine."Quantity" := SolicitudLineas."Cantidad";
                            OrderLine.Type := OrderLine.Type::"G/L Account";
                            OrderLine."No." := SolicitudLineas."Cuenta activo fijo";
                            OrderLine."Direct Unit Cost" := SolicitudLineas."Importe";
                            OrderLine."Posting Date" := WORKDATE;
                            OrderLine."Order No." := OrderHeader."Order No.";
                            OrderLine.Insert(true);
                            OrderLine.Validate("Buy-from Vendor No.", SolicitudEncabezado."ID Proveedor");
                            OrderLine.Modify(true);
                        until SolicitudLineas.Next() = 0;
                end;

            }

        }
    }
}
