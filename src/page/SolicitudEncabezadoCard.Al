//cREAR pAGE list
page 50502 "Solicitud Encabezado Ficha"
{
    PageType = Card;
    SourceTable = "Solicitud Encabezado";
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            Group(General)
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
            part("SolicitudLineas"; "Solicitud Líneas")
            {
                ApplicationArea = All;
                Caption = 'Líneas';
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
                    LineNo: Integer;
                    ItemMaximo: Record "Item_BC_Max";
                begin
                    OrderHeader.Init();

                    If not Vendor.Get(Rec."ID Proveedor") then begin
                        Vendor.SetRange("VAT Registration No.", Rec."ID Proveedor");
                        If Not Vendor.FindSet() then
                            Error('Proveedor no encontrado');
                    end;
                    OrderHeader."Document Type" := OrderHeader."Document Type"::Order;
                    OrderHeader."Order Date" := WORKDATE;
                    OrderHeader.Insert(true);
                    OrderHeader.Validate("Buy-from Vendor No.", Vendor."No.");
                    if Rec.Divisa <> '' then
                        OrderHeader.Validate("Currency Code", Rec.Divisa);
                    OrderHeader."N Solicitud" := Rec."N Solicitud";
                    OrderHeader."Posting Description" := copyStr(Rec."Descripción General", 1, 50);
                    OrderHeader.Modify(true);

                    SolicitudLineas.SetRange("N Solicitud", Rec."N Solicitud");
                    If SolicitudLineas.FindSet() then begin
                        LineNo := 10000;
                        repeat
                            OrderLine.Init();
                            OrderLine."Document Type" := OrderLine."Document Type"::Order;
                            OrderLine."Document No." := OrderHeader."No.";
                            OrderLine."Line No." := LineNo;
                            OrderLine.Linea := SolicitudLineas."N Línea";
                            OrderLine."N Solicitud" := SolicitudLineas."N Solicitud";
                            OrderLine."Buy-from Vendor No." := Vendor."No.";
                            If SolicitudLineas."Cuenta activo fijo" <> '' then begin
                                OrderLine.Type := OrderLine.Type::"G/L Account";
                                OrderLine.Validate("No.", SolicitudLineas."Cuenta activo fijo");
                            end else begin
                                OrderLine.Type := OrderLine.Type::"G/L Account";
                                If Not ItemMaximo.Get(SolicitudLineas."Item") Then
                                    OrderLine.Validate("No.", SolicitudLineas."Item")
                                else
                                    OrderLine.Validate("No.", ItemMaximo."Código Asociado");
                            end;
                            OrderLine.Description := SolicitudLineas."Descripción bien o servicio";
                            OrderLine.Quantity := SolicitudLineas."Cantidad";
                            OrderLine.Validate("Direct Unit Cost", SolicitudLineas."Costo Unitario");
                            OrderLine.Insert(true);
                            LineNo += 10000;
                        until SolicitudLineas.Next() = 0;
                    end;

                    Message('Pedido de compra %1 creado correctamente.', OrderHeader."No.");
                end;

            }

        }
    }
}
