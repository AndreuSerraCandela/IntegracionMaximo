codeunit 50520 "Envio Maximo"
{
    trigger OnRun()
    begin

    end;

    // Enviar datos a Máximo
    procedure EnviarDatosAMaximo(JsonData: JsonObject; var Result: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpResponseMessage: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        JsonText: Text;
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();

        // Verificar que la URL de Máximo esté configurada (debe estar en CompanyInfo o similar)
        // Aquí se asume que habría un campo URL Máximo en la tabla CompanyInfo
        if not IsCommunicationEnabled() then begin
            Result := 'La comunicación con Máximo no está habilitada.';
            exit(false);
        end;

        // Convertir JsonObject a texto
        JsonData.WriteTo(JsonText);

        // Registrar en el log lo que se va a enviar
        RegistrarEnvioEnLog(JsonText, '');

        // Simulación - en producción, descomentar el código real
        Result := 'OK - Simulación';
        exit(true);

        /* Código real para envío HTTP
        // Preparar el contenido HTTP
        HttpContent.WriteFrom(JsonText);
        HttpContent.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        
        // Enviar la solicitud POST a Máximo
        if not HttpClient.Post('URL_MAXIMO', HttpContent, HttpResponseMessage) then begin
            Result := 'Error al conectar con Máximo.';
            RegistrarEnvioEnLog(JsonText, Result);
            exit(false);
        end;
            
        // Verificar la respuesta
        if not HttpResponseMessage.IsSuccessStatusCode then begin
            HttpResponseMessage.Content().ReadAs(Result);
            RegistrarEnvioEnLog(JsonText, Result);
            exit(false);
        end;
        
        // Leer la respuesta exitosa
        HttpResponseMessage.Content().ReadAs(Result);
        RegistrarEnvioEnLog(JsonText, Result);
        exit(true);
        */
    end;

    // Verificar si la comunicación con Máximo está habilitada
    procedure IsCommunicationEnabled(): Boolean
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        exit(CompanyInfo."Empresa Máximo" <> '');
    end;

    // Registrar el envío en un log
    local procedure RegistrarEnvioEnLog(JsonEnviado: Text; Respuesta: Text)
    var
        LogMaximo: Record "Log Máximo";
    begin
        LogMaximo.Init();
        if LogMaximo.FindLast() then
            LogMaximo."ID" += 1
        else
            LogMaximo."ID" := 1;

        LogMaximo.Fecha := Today;
        LogMaximo.Hora := Time;
        LogMaximo.Proceso := 'Envío a Máximo';
        LogMaximo.Mensaje := CopyStr(JsonEnviado, 1, MaxStrLen(LogMaximo.Mensaje));

        if Respuesta <> '' then
            LogMaximo.Mensaje := CopyStr(LogMaximo.Mensaje + ' - Respuesta: ' + Respuesta, 1, MaxStrLen(LogMaximo.Mensaje));

        LogMaximo.Insert();
    end;

    // Enviar pedido de compra a Máximo
    procedure EnviarPedidoCompraAMaximo(var PurchHeader: Record "Purchase Header"): Boolean
    var
        CompanyInfo: Record "Company Information";
        JsonObj: JsonObject;
        JsonCabecera: JsonObject;
        JsonLineas: JsonArray;
        PurchLine: Record "Purchase Line";
        JsonObjLinea: JsonObject;
        Item: Record Item;
        GLAccount: Record "G/L Account";
        Result: Text;
    begin
        // Solo procesar si hay un número de solicitud
        if PurchHeader."N Solicitud" = '' then
            exit(false);

        CompanyInfo.Get();

        // Verificar que haya una correlación con Máximo
        if CompanyInfo."Empresa Máximo" = '' then
            exit(false);

        // Crear la cabecera del pedido
        JsonCabecera.Add('PR', PurchHeader."N Solicitud");
        JsonCabecera.Add('Fecha', Format(PurchHeader."Document Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonCabecera.Add('Estado', DeterminarEstadoMaximo(PurchHeader));
        JsonCabecera.Add('CIF', PurchHeader."Buy-from Vendor No.");
        JsonCabecera.Add('SITE', CompanyInfo."Empresa Máximo");

        // Procesar líneas del pedido
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");

        if PurchLine.FindSet() then begin
            repeat
                JsonObjLinea.Add('Line', Format(PurchLine."Line No."));
                JsonObjLinea.Add('PR', PurchHeader."N Solicitud"); // Añadir nº solicitud en cada línea
                JsonObjLinea.Add('SITE', CompanyInfo."Empresa Máximo"); // Añadir SITE/Almacén en cada línea
                If PurchLine."Item" <> '' then begin
                    JsonObjLinea.Add('CuentaContable', PurchLine."Item");
                    JsonObjLinea.Add('Descripcion', PurchLine."Description");
                end else begin
                    // Información del artículo
                    JsonObjLinea.Add('CuentaContable', PurchLine."No.");

                end;
                // Añadir la descripción 
                JsonObjLinea.Add('Descripcion', PurchLine.Description);
                JsonObjLinea.Add('Quantity', Format(PurchLine.Quantity, 0, 9));
                JsonObjLinea.Add('UnitCost', Format(PurchLine."Direct Unit Cost", 0, 9));
                JsonObjLinea.Add('OrderUnit', PurchLine."Unit of Measure Code");

                // Fecha de recepción esperada
                if PurchLine."Expected Receipt Date" <> 0D then
                    JsonObjLinea.Add('vendordate', Format(PurchLine."Expected Receipt Date", 0, '<Year4>-<Month,2>-<Day,2>'));

                JsonLineas.Add(JsonObjLinea);
                Clear(JsonObjLinea);
            until PurchLine.Next() = 0;
        end;

        // Añadir líneas al objeto principal
        JsonCabecera.Add('Lineas', JsonLineas);

        // Crear el objeto principal
        JsonObj.Add('Pedido', JsonCabecera);

        // Enviar a Máximo
        if EnviarDatosAMaximo(JsonObj, Result) then begin
            PurchHeader."Enviado a Maximo" := true;
            PurchHeader."Fecha Envio a Maximo" := CurrentDateTime;
            PurchHeader.Modify(false);
            exit(true);
        end else
            exit(false);
    end;

    // Determinar el estado del pedido en formato Máximo
    procedure DeterminarEstadoMaximo(PurchHeader: Record "Purchase Header"): Text
    var
        PurchLine: Record "Purchase Line";
        EsMaterial: Boolean;
    begin
        // Verificar si hay al menos una línea de tipo Item
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);

        EsMaterial := PurchLine.FindFirst();

        case PurchHeader.Status of
            PurchHeader.Status::Open:
                if EsMaterial then
                    exit('WMATL')
                else
                    exit('WPO');
            PurchHeader.Status::Released:
                if EsMaterial then
                    exit('TRACKMTL')
                else
                    exit('TRCKPO');
            else
                exit('');
        end;
    end;

    // Enviar recepción a Máximo
    procedure EnviarRecepcionAMaximo(var PurchRcptHeader: Record "Purch. Rcpt. Header"): Boolean
    var
        CompanyInfo: Record "Company Information";
        JsonObj: JsonObject;
        JsonCabecera: JsonObject;
        JsonLineas: JsonArray;
        PurchRcptLine: Record "Purch. Rcpt. Line";
        JsonObjLinea: JsonObject;
        GLAccount: Record "G/L Account";
        Item: Record Item;
        Result: Text;
    begin
        // Solo procesar si hay un número de solicitud
        if PurchRcptHeader."N Solicitud" = '' then
            exit(false);

        CompanyInfo.Get();

        // Verificar que haya una correlación con Máximo
        if CompanyInfo."Empresa Máximo" = '' then
            exit(false);

        // Crear el objeto JSON para enviar a Máximo
        JsonCabecera.Add('PR', PurchRcptHeader."N Solicitud"); // Código solicitud creado en Máximo
        JsonCabecera.Add('FechaRegistro', Format(PurchRcptHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>')); // Fecha de registro (recepción)
        JsonCabecera.Add('SITE', CompanyInfo."Empresa Máximo"); // SITE en Máximo

        // Procesar líneas de la recepción
        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");

        if PurchRcptLine.FindSet() then begin
            repeat
                // Solo procesar líneas con cantidad
                if PurchRcptLine.Quantity > 0 then begin
                    Clear(JsonObjLinea);
                    if PurchRcptLine."N Solicitud" <> '' then
                        JsonObjLinea.Add('PR', PurchRcptLine."N Solicitud")
                    else
                        JsonObjLinea.Add('PR', PurchRcptHeader."N Solicitud"); // Nº solicitud en cada línea
                    if PurchRcptLine.Linea <> 0 then
                        JsonObjLinea.Add('Line', Format(PurchRcptLine.Linea))
                    else
                        JsonObjLinea.Add('Line', Format(PurchRcptLine."Line No.")); // Nº línea
                    JsonObjLinea.Add('Quantity', Format(PurchRcptLine.Quantity, 0, 9)); // Cantidad recibida

                    JsonLineas.Add(JsonObjLinea);
                end;
            until PurchRcptLine.Next() = 0;
        end;

        // Añadir líneas al objeto principal
        JsonCabecera.Add('Lineas', JsonLineas);

        // Crear el objeto principal
        JsonObj.Add('Recepcion', JsonCabecera);

        // Enviar a Máximo
        if EnviarDatosAMaximo(JsonObj, Result) then begin
            PurchRcptHeader."Enviado a Maximo" := true;
            PurchRcptHeader."Fecha Envio a Maximo" := CurrentDateTime;
            PurchRcptHeader.Modify(false);
            exit(true);
        end else
            exit(false);
    end;

    // Suscripción al evento de cambio de estado del pedido de compra
    // [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterModifyEvent', '', false, false)]
    // local procedure OnAfterModifyPurchaseHeader(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; RunTrigger: Boolean)
    // begin
    //     if not RunTrigger then
    //         exit;

    //     // Verificar si el estado ha cambiado a lanzado
    //     if xRec.Status <> Rec.Status then
    //         if Rec.Status = Rec.Status::Released then
    //             EnviarPedidoCompraAMaximo(Rec);
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    // local procedure OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean; SkipWhseRequestOperations: Boolean)
    // begin
    //     if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
    //         exit;

    //     if PurchaseHeader."Tipo de Pedido" in [PurchaseHeader."Tipo de Pedido"::"TRCKPO", PurchaseHeader."Tipo de Pedido"::"TRACKMTL"] then
    //         EnviarPedidoCompraAMaximo(PurchaseHeader);
    // end;

    // [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Status', false, false)]
    // local procedure OnValidatePurchaseHeader(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    // begin
    //     if Rec."Document Type" <> Rec."Document Type"::Order then
    //         exit;

    //     if Rec."Tipo de Pedido" in [Rec."Tipo de Pedido"::"WMATL", Rec."Tipo de Pedido"::"WPO"] then
    //         EnviarPedidoCompraAMaximo(Rec);
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePosting', '', false, false)]
    // local procedure OnAfterFinalizePosting(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var ReturnShptHeader: Record "Return Shipment Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    // var
    //     PurchaseLine: Record "Purchase Line";
    // begin
    //     if PreviewMode then
    //         exit;

    //     if PurchHeader."Document Type" <> PurchHeader."Document Type"::Order then
    //         exit;

    //     if PurchRcptHeader."No." = '' then
    //         exit;
    //     if PurchHeader."Tipo de Pedido" = PurchHeader."Tipo de Pedido"::"WSUP" then begin
    //         PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
    //         PurchaseLine.SetRange("Document No.", PurchHeader."No.");
    //         PurchaseLine.SetFilter("Qty. to Receive", '<>0');
    //         if PurchaseLine.FindSet() then
    //             exit;
    //         EnviarPedidoCompraAMaximo(PurchHeader);
    //         EnviarRecepcionAMaximo(PurchRcptHeader);
    //         exit;
    //     end;
    //     PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
    //     PurchaseLine.SetRange("Document No.", PurchHeader."No.");
    //     PurchaseLine.SetFilter("Qty. to Receive", '<>0');
    //     if PurchaseLine.FindSet() then
    //         exit;
    //     EnviarRecepcionAMaximo(PurchRcptHeader);
    // end;

}