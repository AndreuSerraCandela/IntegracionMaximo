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
        JsonPolines: JsonArray;
        PurchLine: Record "Purchase Line";
        JsonObjPoline: JsonObject;
        Result: Text;
        Vendor: Record Vendor;
    begin
        // Solo procesar si hay un número de pedido
        if PurchHeader."No." = '' then
            exit(false);

        CompanyInfo.Get();

        // Verificar que haya una correlación con Máximo
        if CompanyInfo."Empresa Máximo" = '' then
            exit(false);

        // Obtener datos del proveedor
        if not Vendor.Get(PurchHeader."Buy-from Vendor No.") then
            exit(false);

        // Cabecera del pedido
        JsonObj.Add('ponum', PurchHeader."No.");
        JsonObj.Add('siteid', CompanyInfo."Empresa Máximo");
        JsonObj.Add('description', PurchHeader."Posting Description");
        JsonObj.Add('orderdate', Format(PurchHeader."Order Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonObj.Add('cif', Vendor."VAT Registration No.");

        // Procesar líneas del pedido
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");

        if PurchLine.FindSet() then begin
            repeat
                Clear(JsonObjPoline);
                JsonObjPoline.Add('polinenum', PurchLine."Line No.");
                JsonObjPoline.Add('tositeid', CompanyInfo."Empresa Máximo");
                // Tipo de línea
                case PurchLine.Type of
                    PurchLine.Type::Item:
                        begin
                            JsonObjPoline.Add('linetype', 'ITEM');
                            JsonObjPoline.Add('itemnum', PurchLine."No.");
                        end;
                    PurchLine.Type::"G/L Account":
                        begin
                            JsonObjPoline.Add('linetype', 'MATERIAL');
                        end;
                    else
                        JsonObjPoline.Add('linetype', 'OTRO');
                end;
                // Descripción
                JsonObjPoline.Add('description', PurchLine.Description);
                // Cantidad
                JsonObjPoline.Add('orderqty', PurchLine.Quantity);
                // Unidad
                JsonObjPoline.Add('orderunit', PurchLine."Unit of Measure Code");
                // Costo unitario
                JsonObjPoline.Add('unitcost', PurchLine."Direct Unit Cost");
                // Almacén (si aplica)
                if PurchLine."Location Code" <> '' then
                    JsonObjPoline.Add('storeloc', PurchLine."Location Code");
                // Cuenta contable
                if PurchLine.Type = PurchLine.Type::"G/L Account" then
                    JsonObjPoline.Add('gldebitacct', PurchLine."No.")
                else
                    JsonObjPoline.Add('gldebitacct', '');
                // Fecha de entrega
                if PurchLine."Expected Receipt Date" <> 0D then
                    JsonObjPoline.Add('vendeliverydate', Format(PurchLine."Expected Receipt Date", 0, '<Year4>-<Month,2>-<Day,2>'));
                JsonPolines.Add(JsonObjPoline);
            until PurchLine.Next() = 0;
        end;

        // Añadir líneas al objeto principal
        JsonObj.Add('poline', JsonPolines);

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

    procedure EnviarPedidoCompraAMaximoReal(var PurchHeader: Record "Purchase Header"): Boolean
    var
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        JsonObj: JsonObject;
        JsonPolines: JsonArray;
        JsonObjPoline: JsonObject;
        Vendor: Record Vendor;
        PurchLine: Record "Purchase Line";
        CompanyInfo: Record "Company Information";
        Cookie: Text;
        Result: Text;
        JSessionId: Text;
        LoginUrl: Text;
        AddPOUrl: Text;
        LogoutUrl: Text;
        LoginContent: HttpContent;
        LoginBody: Text;
        Headers: HttpHeaders;
        ResponseText: Text;
        SetCookieValues: List of [Text];
        Inf: Record "Company Information";
    begin
        Inf.Get();
        if Inf."Maximo Username" = '' then Inf."Maximo Username" := 'CGONZALEZ';
        if Inf."Maximo Password" = '' then Inf."Maximo Password" := 'V3t@siSp41n';
        // 1. LOGIN
        LoginUrl := 'https://termosol-prod.vetasicloud.com:9444/maxrest/j_security_check';
        LoginBody := 'j_username=' + Inf."Maximo Username" + '&j_password=' + Inf."Maximo Password";

        LoginContent.WriteFrom(LoginBody);
        LoginContent.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        // LOGIN
        Clear(HttpRequest);
        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(LoginUrl);
        HttpRequest.Content := LoginContent;

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error('No se pudo conectar al servidor de login.');

        // Obtener la cookie de sesión
        if not HttpResponse.Headers().GetValues('Set-Cookie', SetCookieValues) then
            Error('No se recibió cookie de sesión.');
        JSessionId := GetJSessionIdFromSetCookie(SetCookieValues.Get(1));

        // 2. CREAR JSON DEL PEDIDO (igual que tu función ajustada)
        CompanyInfo.Get();
        if not Vendor.Get(PurchHeader."Buy-from Vendor No.") then
            exit(false);

        JsonObj.Add('ponum', PurchHeader."No.");
        JsonObj.Add('siteid', CompanyInfo."Empresa Máximo");
        JsonObj.Add('description', PurchHeader."Posting Description");
        JsonObj.Add('orderdate', Format(PurchHeader."Order Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonObj.Add('cif', Vendor."VAT Registration No.");

        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        if PurchLine.FindSet() then begin
            repeat
                Clear(JsonObjPoline);
                JsonObjPoline.Add('polinenum', PurchLine."Line No.");
                JsonObjPoline.Add('tositeid', CompanyInfo."Empresa Máximo");
                case PurchLine.Type of
                    PurchLine.Type::Item:
                        begin
                            JsonObjPoline.Add('linetype', 'ITEM');
                            JsonObjPoline.Add('itemnum', PurchLine."No.");
                        end;
                    PurchLine.Type::"G/L Account":
                        begin
                            JsonObjPoline.Add('linetype', 'MATERIAL');
                        end;
                    else
                        JsonObjPoline.Add('linetype', 'OTRO');
                end;
                JsonObjPoline.Add('description', PurchLine.Description);
                JsonObjPoline.Add('orderqty', PurchLine.Quantity);
                JsonObjPoline.Add('orderunit', PurchLine."Unit of Measure Code");
                JsonObjPoline.Add('unitcost', PurchLine."Direct Unit Cost");
                if PurchLine."Location Code" <> '' then
                    JsonObjPoline.Add('storeloc', PurchLine."Location Code");
                if PurchLine.Type = PurchLine.Type::"G/L Account" then
                    JsonObjPoline.Add('gldebitacct', PurchLine."No.")
                else
                    JsonObjPoline.Add('gldebitacct', '');
                if PurchLine."Expected Receipt Date" <> 0D then
                    JsonObjPoline.Add('vendeliverydate', Format(PurchLine."Expected Receipt Date", 0, '<Year4>-<Month,2>-<Day,2>'));
                JsonPolines.Add(JsonObjPoline);
            until PurchLine.Next() = 0;
        end;
        JsonObj.Add('poline', JsonPolines);

        // 3. ENVIAR PEDIDO
        AddPOUrl := 'https://termosol-prod.vetasicloud.com:9444/maxrest/oslc/os/VEPO?lean=1';
        JsonObj.WriteTo(Result);

        HttpContent.WriteFrom(Result);
        HttpContent.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');
        Headers.Add('Cookie', JSessionId);
        Headers.Add('Accept', 'application/json');

        // ENVIAR PEDIDO
        Clear(HttpRequest);
        HttpRequest.Method := 'POST';
        HttpRequest.SetRequestUri(AddPOUrl);
        HttpRequest.Content := HttpContent;

        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error('No se pudo conectar al servidor de pedidos.');

        HttpResponse.Content().ReadAs(ResponseText);

        if HttpResponse.HttpStatusCode() <> 201 then
            Error('Error al crear el pedido en Máximo: %1', ResponseText);

        // 4. LOGOUT
        LogoutUrl := 'https://termosol-prod.vetasicloud.com:9444/maxrest/oslc/logout';
        Clear(HttpRequest);
        HttpRequest.Method := 'GET';
        HttpRequest.SetRequestUri(LogoutUrl);
        HttpRequest.GetHeaders(Headers);
        Headers.Add('Cookie', JSessionId);
        if not HttpClient.Send(HttpRequest, HttpResponse) then
            Error('No se pudo cerrar la sesión en Máximo.');

        // Marcar como enviado
        PurchHeader."Enviado a Maximo" := true;
        PurchHeader."Fecha Envio a Maximo" := CurrentDateTime;
        PurchHeader.Modify(false);
        exit(true);
    end;

    // Función auxiliar para extraer el JSESSIONID de la cabecera Set-Cookie
    local procedure GetJSessionIdFromSetCookie(SetCookie: Text): Text
    var
        StartPos: Integer;
        EndPos: Integer;
    begin
        StartPos := StrPos(SetCookie, 'JSESSIONID=');
        if StartPos = 0 then
            exit('');
        EndPos := StrPos(CopyStr(SetCookie, StartPos, MaxStrLen(SetCookie)), ';');
        if EndPos = 0 then
            EndPos := StrLen(SetCookie) + 1;
        exit(CopyStr(SetCookie, StartPos, EndPos - 1));
    end;

}