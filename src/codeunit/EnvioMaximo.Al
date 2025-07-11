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
        JsonBody: JsonObject;
        JsonLineas: JsonArray;
        PurchRcptLine: Record "Purch. Rcpt. Line";
        JsonObjLinea: JsonObject;
        Inf: Record "Company Information";
        Result: Text;
        ResponseText: Text;
        HttpClient: HttpClient;
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
        HttpContent: HttpContent;
        Headers: HttpHeaders;
        ApiUrl: Text;
        RequestType: Option Get,patch,put,post,delete;
        ResponseMessage: HttpResponseMessage;
    begin
        // Solo procesar si hay un número de solicitud
        if PurchRcptHeader."N Solicitud" = '' then
            exit(false);

        CompanyInfo.Get();
        Inf.Get();

        // Verificar que haya una correlación con Máximo
        if CompanyInfo."Empresa Máximo" = '' then
            exit(false);

        // Configurar credenciales por defecto si están vacías
        if Inf."Maximo Username" = '' then
            Inf."Maximo Username" := 'CGONZALEZ';
        if Inf."Maximo Password" = '' then
            Inf."Maximo Password" := 'V3t@siSp41n';

        // URL del API local
        ApiUrl := CompanyInfo."URL API Maximo";
        if ApiUrl = '' then
            ApiUrl := 'http://20.19.38.107:3005/maximo/request';

        // Crear el objeto JSON principal
        JsonObj.Add('username', Inf."Maximo Username");
        JsonObj.Add('password', Inf."Maximo Password");
        JsonObj.Add('baseUrl', 'https://termosol-prod.vetasicloud.com:9444');
        JsonObj.Add('endpoint', 'VEPR'); // Endpoint para recepciones
        JsonObj.Add('lean', '1');

        // Crear el body de la recepción
        JsonBody.Add('PR', PurchRcptHeader."N Solicitud"); // Código solicitud creado en Máximo
        JsonBody.Add('FechaRegistro', Format(PurchRcptHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>')); // Fecha de registro (recepción)
        JsonBody.Add('SITE', CompanyInfo."Empresa Máximo"); // SITE en Máximo

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

        // Añadir líneas al body
        JsonBody.Add('Lineas', JsonLineas);

        // Añadir el body al objeto principal
        JsonObj.Add('body', JsonBody);

        // Convertir a texto JSON
        JsonObj.WriteTo(Result);

        // Preparar la solicitud HTTP
        JsonObj.WriteTo(Result);
        ResponseMessage := RestApiToken(ApiUrl, RequestType::post, Result);
        // Preparar la solicitud HTTP
        ResponseMessage.Content.ReadAs(ResponseText);
        // Verificar la respuesta
        if ResponseMessage.HttpStatusCode() <> 200 then begin
            Error('Error al crear el pedido en Máximo: %1', ResponseText);
        end;



        // Registrar en el log
        RegistrarEnvioEnLog(Result, ResponseText);

        // Marcar como enviado
        PurchRcptHeader."Enviado a Maximo" := true;
        PurchRcptHeader."Fecha Envio a Maximo" := CurrentDateTime;
        PurchRcptHeader.Modify(false);

        exit(true);
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
        JsonBody: JsonObject;
        Vendor: Record Vendor;
        PurchLine: Record "Purchase Line";
        CompanyInfo: Record "Company Information";
        Inf: Record "Company Information";
        Result: Text;
        ResponseText: Text;
        Headers: HttpHeaders;
        ApiUrl: Text;
        RequestType: Option Get,patch,put,post,delete;
        ResponseMessage: HttpResponseMessage;
    begin
        Inf.Get();
        CompanyInfo.Get();

        // Verificar que tenemos los datos necesarios
        if not Vendor.Get(PurchHeader."Buy-from Vendor No.") then
            exit(false);

        // Configurar credenciales por defecto si están vacías
        if Inf."Maximo Username" = '' then
            Inf."Maximo Username" := 'CGONZALEZ';
        if Inf."Maximo Password" = '' then
            Inf."Maximo Password" := 'V3t@siSp41n';

        // URL del API local
        ApiUrl := CompanyInfo."URL API Maximo";
        if ApiUrl = '' then
            ApiUrl := 'http://20.19.38.107:3005/maximo/request';

        // Crear el objeto JSON principal
        JsonObj.Add('username', Inf."Maximo Username");
        JsonObj.Add('password', Inf."Maximo Password");
        JsonObj.Add('baseUrl', 'https://termosol-prod.vetasicloud.com:9444');
        JsonObj.Add('endpoint', 'VEPO');
        JsonObj.Add('lean', '1');

        // Crear el body del pedido
        JsonBody.Add('ponum', PurchHeader."No.");
        JsonBody.Add('siteid', CompanyInfo."Empresa Máximo");
        JsonBody.Add('description', PurchHeader."Posting Description");
        JsonBody.Add('orderdate', Format(PurchHeader."Order Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonBody.Add('cif', Vendor."VAT Registration No.");

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
                            JsonObjPoline.Add('description', PurchLine.Description);
                        end;
                    else begin
                        JsonObjPoline.Add('linetype', 'OTRO');
                        JsonObjPoline.Add('description', PurchLine.Description);
                    end;
                end;

                // Campos comunes
                JsonObjPoline.Add('orderqty', PurchLine.Quantity);
                JsonObjPoline.Add('orderunit', PurchLine."Unit of Measure Code");
                JsonObjPoline.Add('unitcost', PurchLine."Direct Unit Cost");

                // Almacén (si aplica)
                if PurchLine."Location Code" <> '' then
                    JsonObjPoline.Add('storeloc', PurchLine."Location Code");

                // Cuenta contable
                if PurchLine.Type = PurchLine.Type::"G/L Account" then
                    JsonObjPoline.Add('gldebitacct', PurchLine."No.")
                else
                    JsonObjPoline.Add('gldebitacct', '0-0');

                // Fecha de entrega
                if PurchLine."Expected Receipt Date" <> 0D then
                    JsonObjPoline.Add('vendeliverydate', Format(PurchLine."Expected Receipt Date", 0, '<Year4>-<Month,2>-<Day,2>'));

                JsonPolines.Add(JsonObjPoline);
            until PurchLine.Next() = 0;
        end;

        // Añadir líneas al body
        JsonBody.Add('poline', JsonPolines);

        // Añadir el body al objeto principal
        JsonObj.Add('body', JsonBody);

        // Convertir a texto JSON
        JsonObj.WriteTo(Result);
        ResponseMessage := RestApiToken(ApiUrl, RequestType::post, Result);
        // Preparar la solicitud HTTP
        ResponseMessage.Content.ReadAs(ResponseText);
        // Verificar la respuesta
        if ResponseMessage.HttpStatusCode() <> 200 then begin
            Error('Error al crear el pedido en Máximo: %1', ResponseText);
        end;

        // Registrar en el log
        RegistrarEnvioEnLog(Result, ResponseText);

        // Marcar como enviado
        PurchHeader."Enviado a Maximo" := true;
        PurchHeader."Fecha Envio a Maximo" := CurrentDateTime;
        PurchHeader.Modify(false);

        exit(true);
    end;

    procedure RestApiToken(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): HttpResponseMessage
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
    begin
        // RequestHeaders := Client.DefaultRequestHeaders();
        // RequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', token));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);
                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');
                    Client.Patch(URL, RequestContent, ResponseMessage);
                end;
        end;


        exit(ResponseMessage);
    end;

}