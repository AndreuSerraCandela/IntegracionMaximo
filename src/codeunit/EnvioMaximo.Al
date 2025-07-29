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
        Location: Record Location;
        Item: Record Item;
        ItemMaximo: Record Item_BC_Max;
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
                            //JsonObjPoline.Add('linetype', 'ITEM');
                            JsonObjPoline.Add('itemsetid', 'ITEMFORM');
                            JsonObjPoline.Add('storeloc', CompanyInfo."Empresa Máximo");
                            JsonObjPoline.Add('itemnum', PurchLine."No.");
                            if Item.Get(PurchLine."No.") then begin

                                if Item."Maximo Item" <> '' then
                                    JsonObjPoline.Add('itemnum', Item."Maximo Item") else begin
                                    ItemMaximo.SetRange("Código Asociado", PurchLine."No.");
                                    if ItemMaximo.FindFirst() then
                                        JsonObjPoline.Add('itemnum', ItemMaximo."Código Producto");
                                end;
                            end
                            else
                                JsonObjPoline.Add('itemnum', PurchLine.Item);
                        end;
                    PurchLine.Type::"G/L Account":
                        begin
                            JsonObjPoline.Add('linetype', 'MATERIAL');
                            JsonObjPoline.Add('storeloc', CompanyInfo."Empresa Máximo");
                            // Descripción
                            JsonObjPoline.Add('description', PurchLine.Description);
                        end;
                    else begin
                        JsonObjPoline.Add('linetype', 'OTRO');
                        JsonObjPoline.Add('storeloc', CompanyInfo."Empresa Máximo");
                        JsonObjPoline.Add('description', PurchLine.Description);
                    end;
                end;

                // Cantidad
                JsonObjPoline.Add('orderqty', PurchLine.Quantity);
                // Unidad
                JsonObjPoline.Add('orderunit', PurchLine."Unit of Measure Code");
                // Costo unitario
                JsonObjPoline.Add('unitcost', PurchLine."Direct Unit Cost");
                // Almacén (si aplica)
                // if PurchLine."Location Code" <> '' then begin
                //     If not Location.Get(PurchLine."Location Code") then Location.Init;
                //     If Location."Location Máximo" <> '' Then
                //         JsonObjPoline.Add('storeloc', Location."Location Máximo")
                //     else
                //         JsonObjPoline.Add('storeloc', PurchLine."Location Code");
                // end;
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
        ItemMaximo: Record Item_BC_Max;
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
        Location: Record Location;
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
        if Inf."Api Key Maximo" = '' then
            Inf."Api Key Maximo" := 'ukTkioaof88744D8E3EEf73AwYv8754EN';
        if CompanyInfo."Default Site Máximo" = '' then
            CompanyInfo."Default Site Máximo" := 'FORMS';
        if CompanyInfo."Endpoint Máximo Recepciones" = '' then
            CompanyInfo."Endpoint Máximo Recepciones" := 'VEPR';
        // URL del API local
        ApiUrl := CompanyInfo."URL API Maximo";
        if ApiUrl = '' then
            ApiUrl := 'http://20.19.38.107:3005/maximo/apikey';

        // Crear el objeto JSON principal
        JsonObj.Add('username', Inf."Maximo Username");
        JsonObj.Add('password', Inf."Maximo Password");
        JsonObj.Add('baseUrl', 'https://termosol-prod.vetasicloud.com:9444');
        JsonObj.Add('endpoint', CompanyInfo."Endpoint Máximo Recepciones"); // Endpoint para recepciones
        JsonObj.Add('apikey', Inf."Api Key Maximo");
        JsonObj.Add('lean', '1');

        // Crear el body de la recepción
        JsonBody.Add('PR', PurchRcptHeader."N Solicitud"); // Código solicitud creado en Máximo
        JsonBody.Add('FechaRegistro', Format(PurchRcptHeader."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>')); // Fecha de registro (recepción)
        If not Location.Get(PurchRcptHeader."Location Code") Then Location.Init;
        If Location."Site Máximo" <> '' Then
            JsonBody.Add('SITE', Location."Site Máximo")
        else
            JsonBody.Add('SITE', CompanyInfo."Default Site Máximo"); // SITE en Máximo


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
        Item: Record Item;
        Unit: Record "Unit of Measure";
        ItemMaximo: Record Item_BC_Max;
        Location: Record Location;
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
        if Inf."Api Key Maximo" = '' then
            Inf."Api Key Maximo" := 'ukTkioaof88744D8E3EEf73AwYv8754EN';
        if CompanyInfo."Default Site Máximo" = '' then
            CompanyInfo."Default Site Máximo" := 'FORMS';
        if CompanyInfo."Endpoint Máximo Pedidos" = '' then
            CompanyInfo."Endpoint Máximo Pedidos" := 'VEPO';

        // URL del API local
        ApiUrl := CompanyInfo."URL API Maximo";
        if ApiUrl = '' then
            ApiUrl := 'http://20.19.38.107:3005/maximo/apikey';

        // Crear el objeto JSON principal
        JsonObj.Add('username', Inf."Maximo Username");
        JsonObj.Add('password', Inf."Maximo Password");
        JsonObj.Add('baseUrl', 'https://solclef-prod-mif.vetasicloud.com:9444');
        JsonObj.Add('endpoint', CompanyInfo."Endpoint Máximo Pedidos");
        JsonObj.Add('apikey', Inf."Api Key Maximo");
        JsonObj.Add('lean', '1');

        // Crear el body del pedido
        JsonBody.Add('ponum', PurchHeader."No.");
        If not Location.Get(PurchHeader."Location Code") Then Location.Init;
        If Location."Site Máximo" <> '' Then
            JsonBody.Add('siteid', Location."Site Máximo")
        else
            JsonBody.Add('siteid', CompanyInfo."Default Site Máximo");
        JsonBody.Add('description', PurchHeader."Posting Description");
        JsonBody.Add('orderdate', Format(PurchHeader."Order Date", 0, '<Year4>-<Month,2>-<Day,2>'));
        JsonBody.Add('cif', Vendor."VAT Registration No.");

        // Procesar líneas del pedido
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        //         "poline": [
        //             {
        //                 "polinenum": 1,
        //                 "itemsetid": "ITEMFORM",
        //                 "tositeid": "FORMS",
        //                 "itemnum": "0-800-695-051",
        //                 "orderqty": 1,
        //                 "orderunit": "EA",
        //                 "unitcost": 135.79,
        //                 "storeloc": "ALM01",
        //                 "gldebitacct": "0-0",
        //                 "vendeliverydate": "2025-05-15"
        //             },
        //             {
        //                 "polinenum": 2,
        //                 "tositeid": "FORMS",
        //                 "linetype": "MATERIAL",
        //                 "description": "Material Test",
        //                 "orderqty": 1,
        //                 "orderunit": "EA",
        //                 "unitcost": 123.45,
        //                 "gldebitacct": "0-0",
        //                 "vendeliverydate": "2025-05-15"
        //             }
        //         ]
        //     }


        if PurchLine.FindSet() then begin
            repeat
                Clear(JsonObjPoline);
                JsonObjPoline.Add('polinenum', PurchLine."Line No.");
                If not Location.Get(PurchLine."Location Code") Then Location.Init;
                If Location."Site Máximo" <> '' Then
                    JsonObjPoline.Add('tositeid', Location."Site Máximo")
                else
                    JsonObjPoline.Add('tositeid', CompanyInfo."Default Site Máximo");
                ItemMaximo.init;
                // Tipo de línea
                case PurchLine.Type of
                    PurchLine.Type::Item:
                        begin
                            //JsonObjPoline.Add('linetype', 'ITEM');
                            JsonObjPoline.Add('itemsetid', 'ITEMFORM');
                            JsonObjPoline.Add('storeloc', CompanyInfo."Empresa Máximo");
                            if Item.Get(PurchLine."No.") then begin

                                if Item."Maximo Item" <> '' then
                                    JsonObjPoline.Add('itemnum', Item."Maximo Item") else begin
                                    ItemMaximo.SetRange("Código Asociado", PurchLine."No.");
                                    if ItemMaximo.FindFirst() then
                                        JsonObjPoline.Add('itemnum', ItemMaximo."Código Producto");
                                end;
                            end
                            else
                                JsonObjPoline.Add('itemnum', PurchLine.Item);


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
                if ItemMaximo."Unidad de Medida" <> '' then
                    JsonObjPoline.Add('orderunit', ItemMaximo."Unidad de Medida")
                else begin
                    if Unit.Get(PurchLine."Unit of Measure Code") then
                        JsonObjPoline.Add('orderunit', Unit."Maximo Item")
                    else
                        JsonObjPoline.Add('orderunit', PurchLine."Unit of Measure Code");
                end;
                JsonObjPoline.Add('unitcost', PurchLine."Direct Unit Cost");

                // Almacén (si aplica)
                // if PurchLine."Location Code" <> '' then begin
                //     If not Location.Get(PurchLine."Location Code") then Location.Init;
                //     If Location."Location Máximo" <> '' Then
                //         JsonObjPoline.Add('storeloc', Location."Location Máximo")
                //     else
                //         JsonObjPoline.Add('storeloc', PurchLine."Location Code");
                // end;


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