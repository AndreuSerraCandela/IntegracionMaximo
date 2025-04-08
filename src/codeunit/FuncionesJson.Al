codeunit 50501 FuncionesJson
{
    Permissions = tabledata "Dimension Set Entry" = RIMD,
    tabledata "Default Dimension Priority" = RIMD,
    tabledata "Default Dimension" = RIMD,
    tabledata "Dimension Set Tree Node" = RIMD,
    tabledata "Dimension Value" = RIMD;
    [ServiceEnabled]
    procedure Ping(): Text
    begin
        exit('Pong');
    end;

    [ServiceEnabled]
    procedure solicitudwebservices(Json: Text): text
    var
        Result: Text;
    begin
        If Not Trysolicitudwebservices(Json, Result) then begin
            Result := GetLastErrorText();
            LogError(Result, 'Solicitudes');
            exit(Result);
        end;
        exit(Result);
    end;

    [TryFunction]
    procedure Trysolicitudwebservices(Json: Text; var Result: text)
    var
        JsonObj: JsonObject;
        JsonArraySolicitudes: JsonArray;
        JsonTokenSolicitud: JsonToken;
        JsonObjSolicitud: JsonObject;
        JsonTokenLineas: JsonToken;
        JsonObjLineas: JsonObject;
        JsonToken: JsonToken;
        JsonArrayLineas: JsonArray;
        SolicitudEncabezado: Record "Solicitud Encabezado";
        SolicitudLineas: Record "Solicitud Líneas";
        Linea: Integer;
    begin
        JsonObj.ReadFrom(Json);
        JsonObj.Get('Solicitudes', JsonToken);
        JsonArraySolicitudes := JsonToken.AsArray();
        foreach JsonTokenSolicitud in JsonArraySolicitudes do begin
            JsonObjSolicitud := JsonTokenSolicitud.AsObject();
            Clear(JsonToken);
            JsonObjSolicitud.Get('N Solicitud', JsonToken);
            SolicitudEncabezado.Init();
            SolicitudEncabezado."N Solicitud" := JsonToken.AsValue().AsText();
            SolicitudEncabezado.Insert();
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
            Clear(JsonToken);
            JsonObjSolicitud.Get('Id_Proveedor', JsonToken);
            SolicitudEncabezado."ID Proveedor" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('nombre_proveedor', JsonToken);
            SolicitudEncabezado."Nombre Proveedor" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('telefono', JsonToken);
            SolicitudEncabezado."Teléfono" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('correo', JsonToken);
            SolicitudEncabezado."Correo" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('descripcion_general', JsonToken);
            SolicitudEncabezado."Descripción General" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('fecha_creacion', JsonToken);
            If Evaluate(SolicitudEncabezado."Fecha de Creación", JsonToken.AsValue().AsText()) then;
            Clear(JsonToken);
            JsonObjSolicitud.Get('fecha_estimada_inicio', JsonToken);
            If Evaluate(SolicitudEncabezado."Fecha de Estimada Inicio", JsonToken.AsValue().AsText()) then;
            Clear(JsonToken);
            JsonObjSolicitud.Get('fecha_estimada_finalizacion', JsonToken);
            If Evaluate(SolicitudEncabezado."Fecha estimada finalización", JsonToken.AsValue().AsText()) then;
            Clear(JsonToken);
            JsonObjSolicitud.Get('creado_por', JsonToken);
            SolicitudEncabezado."Creado por" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('circuito', JsonToken);
            SolicitudEncabezado."Circuito" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('estado', JsonToken);
            SolicitudEncabezado."Estado" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('n_solicitud_necesidad', JsonToken);
            SolicitudEncabezado."N solicitud necesidad" := JsonToken.AsValue().AsText();
            SolicitudEncabezado.Modify();
            JsonObjSolicitud.Get('lineas', JsonTokenLineas);
            JsonArrayLineas := JsonTokenLineas.AsArray();
            foreach JsonTokenLineas in JsonArrayLineas do begin
                Linea += 1;
                JsonObjLineas := JsonTokenLineas.AsObject();
                Clear(JsonToken);
                JsonObjLineas.Get('n_linea', JsonToken);
                SolicitudLineas.Init();
                SolicitudLineas."N Solicitud" := SolicitudEncabezado."N Solicitud";
                If Not Evaluate(SolicitudLineas."N Línea", JsonToken.AsValue().AsText()) then
                    SolicitudLineas."N Línea" := Linea;
                Clear(JsonToken);
                JsonObjLineas.Get('sociedad', JsonToken);
                SolicitudLineas."Sociedad" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('ot', JsonToken);
                SolicitudLineas."OT" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('descripcion_bien_o_servicio', JsonToken);
                SolicitudLineas."Descripción bien o servicio" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('cantidad', JsonToken);
                If Evaluate(SolicitudLineas."Cantidad", JsonToken.AsValue().AsText()) Then;
                Clear(JsonToken);
                JsonObjLineas.Get('cuenta_activo_fijo', JsonToken);
                SolicitudLineas."Cuenta activo fijo" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('n_Pedido_presupuesto', JsonToken);
                SolicitudLineas."N Pedido Presupuesto" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('epigrafe_pptop', JsonToken);
                SolicitudLineas."Epígrafe Pptop" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('fecha_activo_fijo', JsonToken);
                If Evaluate(SolicitudLineas."Fecha activo fijo", JsonToken.AsValue().AsText()) then;
                Clear(JsonToken);
                JsonObjLineas.Get('dimension', JsonToken);
                If Evaluate(SolicitudLineas."Dimension", JsonToken.AsValue().AsText()) then;
                Clear(JsonToken);
                JsonObjLineas.Get('proyecto', JsonToken);
                SolicitudLineas."Proyecto" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('importe', JsonToken);
                If Evaluate(SolicitudLineas."Importe", JsonToken.AsValue().AsText()) Then;
                Clear(JsonToken);
                JsonObjLineas.Get('anyo', JsonToken);
                SolicitudLineas."Año" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
            end;
        end;
        Result := 'Ok';
    end;

    [ServiceEnabled]
    procedure productos_bc_max(Json: Text): text
    var
        Result: Text;
    begin
        If Not Tryproductos_bc_max(Json, Result) then begin
            Result := GetLastErrorText();
            LogError(Result, 'Productos BC Max');
            exit(Result);
        end;
        exit(Result);
    end;

    [TryFunction]
    procedure Tryproductos_bc_max(Json: Text; var Result: text)
    var
        JsonObj: JsonObject;
        JsonArrayProductos: JsonArray;
        JsonTokenProducto: JsonToken;
        JsonObjProducto: JsonObject;
        JsonToken: JsonToken;
        Producto: Record "Item_BC_Max";
        Producto2: Record "Item_BC_Max";
    begin
        JsonObj.ReadFrom(Json);
        JsonObj.Get('Productos', JsonTokenProducto);
        JsonArrayProductos := JsonTokenProducto.AsArray();
        foreach JsonTokenProducto in JsonArrayProductos do begin
            JsonObjProducto := JsonTokenProducto.AsObject();
            Clear(JsonToken);
            JsonObjProducto.Get('codigo_producto', JsonToken);
            Producto.Init();
            Producto."Código Producto" := JsonToken.AsValue().AsText();
            If Not Producto2.Get(JsonToken.AsValue().AsText()) then
                Producto.Insert();
            // 	1 	Código Producto 	Char 	20 
            // 	2 	Descripción de Producto 	Char 	100 
            // 	3 	Tipo de Integración 	Char 	20 
            // 	4 	Código Asociado 	Char 	20 
            // 	5 	Unidad de Medida 	Char 	10 
            // 	6 	Costo Producto 	Decimal 	28 
            Clear(JsonToken);
            JsonObjProducto.Get('descripcion_producto', JsonToken);
            Producto."Descripción de Producto" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            If JsonObjProducto.Get('tipo_integracion', JsonToken) Then begin
                case JsonToken.AsValue().AsText() of
                    'G/L Account':
                        Producto."Tipo de Integración" := Producto."Tipo de Integración"::"G/L Account";
                    'Item':
                        Producto."Tipo de Integración" := Producto."Tipo de Integración"::Item;

                end;
            end;
            Clear(JsonToken);
            If JsonObjProducto.Get('codigo_asociado', JsonToken) then
                Producto."Código Asociado" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            if JsonObjProducto.Get('unidad_medida', JsonToken) then
                Producto."Unidad de Medida" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            if JsonObjProducto.Get('costo_producto', JsonToken) then
                If Evaluate(Producto."Costo Producto", JsonToken.AsValue().AsText()) then;
            Producto.Modify();
        end;
        Result := 'Ok';

    end;

    [ServiceEnabled]
    procedure apuntescontables(Json: Text): text
    var
        Result: Text;
    begin
        If Not Tryapuntescontables(Json, Result) then begin
            Result := GetLastErrorText();
            LogError(Result, 'Apuntes Contables');
            exit(Result);
        end;

        exit(Result);
    end;

    [TryFunction]
    procedure TrySimularapuntescontables(ApuntesTemp: Record ApuntesContables; var Result: text)
    var
        Apunte: Record "ApuntesContables" temporary;
        Empresa: Text[100];
        rInf: Record "Company Information";
        BcEmpresa: Text[30];
        GlAcount: Record "G/L Account";
        Job: Record Job;
        Descripción: Text;
        Automatico: Boolean;

    begin
        // Implement your error logging here
        //Crear el metodo para gramar error en la tabla "Log Maximo"
        Apunte := ApuntesTemp;
        If Apunte.Descripción = '' then
            Descripción := Apunte.Concepto else
            "Descripción" := Apunte.Descripción;
        Apunte."Descripción" := Descripción;
        // Buscamos la posición después de la cuenta
        if StrPos(Descripción, Apunte.Cuenta) > 0 then begin
            // Tomamos el texto después de la cuenta
            Descripción := CopyStr(Descripción, StrPos(Descripción, Apunte.Cuenta), StrLen(Descripción));

            // Si hay un guión después de la cuenta, procesamos las dimensiones
            if StrPos(Descripción, '-') > 0 then begin
                Apunte."Dimension 1" := CopyStr(Descripción, StrPos(Descripción, '-') + 1, 2);
                "Descripción" := CopyStr(Descripción, StrPos(Descripción, '-') + 3, 40);
                if StrPos(Descripción, '-') > 0 then begin
                    Apunte."Dimension 2" := CopyStr(Descripción, StrPos(Descripción, '-') + 1, 20);

                end;
            end;
        end;
        ApuntesTemp."Dimension 1" := Apunte."Dimension 1";
        ApuntesTemp."Dimension 2" := Apunte."Dimension 2";
        ApuntesTemp."Descripción" := Apunte."Descripción";
        ApuntesTemp.Modify;
        //Apunte.Insert();
        Empresa := ApuntesTemp.Empresa;
        If not rInf.DevuelveEmpresa(Empresa, BcEmpresa) then begin
            Result := 'No se ha encontrado la empresa ' + Empresa;
            LogError(Result, 'Apuntes Contables');
            exit;
        end;

        // Intentamos contabilizar el apunte
        if not TryContabilizarApunte(ApuntesTemp, BcEmpresa) then begin
            ApuntesTemp.Error := true;
            ApuntesTemp.Modify();
            LogError(GetLastErrorText(), 'Contabilización Apunte ' + ApuntesTemp."ID Apunte");
            Result += GetLastErrorText() + 'Contabilización Apunte ' + ApuntesTemp."ID Apunte";
        end;



        Result += 'Ok Empresa BC ' + BcEmpresa + ' Empresa Maximo ' + Apunte.Empresa;
        exit;
    end;

    [TryFunction]
    procedure Tryapuntescontables(Json: Text; var Result: Text)
    var
        JsonObj: JsonObject;
        JsonArrayEmpresas: JsonArray;
        JsonTokenEmpresa: JsonToken;
        JsonObjEmpresa: JsonObject;
        JsonArrayApuntes: JsonArray;
        JsonTokenApunte: JsonToken;
        JsonObjApunte: JsonObject;
        JsonToken: JsonToken;
        Apunte: Record "ApuntesContables";
        Empresa: Text[100];
        rInf: Record "Company Information";
        BcEmpresa: Text[30];
        GlAcount: Record "G/L Account";
        Job: Record Job;
        Descripción: Text;
        Automatico: Boolean;
        ErrorApunte: Text;
        rLinDiaGen: Record "Gen. Journal Line";
    begin
        rInf.Get();
        Automatico := rInf."Apunte Automático";
        JsonObj.ReadFrom(Json);
        JsonObj.Get('empresas', JsonTokenEmpresa);
        JsonArrayEmpresas := JsonTokenEmpresa.AsArray();
        foreach JsonTokenEmpresa in JsonArrayEmpresas do begin
            JsonObjEmpresa := JsonTokenEmpresa.AsObject();
            Clear(JsonToken);
            JsonObjEmpresa.Get('nombre', JsonToken);
            Empresa := JsonToken.AsValue().AsText();
            JsonObjEmpresa.Get('apuntes_contables', JsonTokenApunte);
            JsonArrayApuntes := JsonTokenApunte.AsArray();
            foreach JsonTokenApunte in JsonArrayApuntes do begin
                JsonObjApunte := JsonTokenApunte.AsObject();
                Clear(JsonToken);
                Apunte.Init();
                Apunte.Empresa := Empresa;
                If not rInf.DevuelveEmpresa(Empresa, BcEmpresa) then begin
                    Result := 'No se ha encontrado la empresa ' + Empresa + ' En el apunte ' + Apunte."ID Apunte" + ' de la empresa ' + Apunte.Empresa;
                    LogError(Result, 'Apuntes Contables');
                    exit;
                end;
                // 	1 	Empresa 	Char 	100 
                // 	2 	ID Apunte 	Char 	20 
                // 	3 	Fecha 	Fecha 	  
                // 	4 	Concepto 	Char 	100 
                // 	5 	Importe 	Decimal 	28 
                // 	6 	Cuenta 	Char 	20 
                // 	7 	Descripción 	Char 	100 
                // 	8 	Procesado 	Boolean 	  
                // 	9 	Error 	Boolean 	  
                Clear(JsonToken);
                JsonObjApunte.Get('id_apunte', JsonToken);
                Apunte."ID Apunte" := JsonToken.AsValue().AsText();
                Apunte.Insert();
                Clear(JsonToken);
                JsonObjApunte.Get('fecha', JsonToken);
                If Evaluate(Apunte.Fecha, JsonToken.AsValue().AsText()) then;
                Clear(JsonToken);
                JsonObjApunte.Get('concepto', JsonToken);
                Apunte.Concepto := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjApunte.Get('importe', JsonToken);
                Apunte.Importe := JsonToken.AsValue().AsDecimal();
                Clear(JsonToken);
                JsonObjApunte.Get('cuenta', JsonToken);
                Apunte.Cuenta := JsonToken.AsValue().AsText();
                GlAcount.ChangeCompany(BcEmpresa);
                if not GlAcount.Get(Apunte.Cuenta) then begin
                    Result := 'No se ha encontrado la cuenta ' + Apunte.Cuenta + ' En el apunte ' + Apunte."ID Apunte" + ' de la empresa ' + Apunte.Empresa;
                    LogError(Result, 'Apuntes Contables');
                    If Apunte.Delete() then;
                    exit;
                end;
                Clear(JsonToken);
                If JsonObjApunte.Get('proyecto', JsonToken) Then begin
                    Apunte.Proyecto := JsonToken.AsValue().AsText();
                    if Apunte.Proyecto <> '' then begin
                        if not Job.Get(Apunte.Proyecto) then begin
                            Result := 'No se ha encontrado el proyecto ' + Apunte.Proyecto + 'Se procede a crearlo. ';
                            LogError(Result, 'Apuntes Contables');
                            //exit;
                            Job.Init();
                            Job."No." := Apunte.Proyecto;
                            Job.Description := Apunte.Proyecto;
                            Job.Insert();
                        end;
                    end;
                end;
                Clear(JsonToken);
                JsonObjApunte.Get('descripcion', JsonToken);
                //Conciliacion 2025-03-14 para la cuenta 6100001-T1-MEDIO AMBIENTE
                // Separo descripcion en 3 partes, la primera parte es la descripcion la segunda parte es Dimension 1 y la tercera parte es Dimension 2
                //El guin antes de T1 es el separador de dimensiones
                Descripción := JsonToken.AsValue().AsText();
                Apunte."Descripción" := Descripción;
                // Buscamos la posición después de la cuenta
                if StrPos(Descripción, Apunte.Cuenta) > 0 then begin
                    // Tomamos el texto después de la cuenta
                    Descripción := CopyStr(Descripción, StrPos(Descripción, Apunte.Cuenta), StrLen(Descripción));

                    // Si hay un guión después de la cuenta, procesamos las dimensiones
                    if StrPos(Descripción, '-') > 0 then begin
                        Apunte."Dimension 1" := CopyStr(Descripción, StrPos(Descripción, '-') + 1, 2);
                        "Descripción" := CopyStr(Descripción, StrPos(Descripción, '-') + 3, 40);
                        if StrPos(Apunte.Descripción, '-') > 0 then begin
                            Apunte."Dimension 2" := CopyStr(Descripción, StrPos(Descripción, '-') + 1, 20);

                        end;
                    end;
                end;

                Apunte.Modify();
                If Automatico then

                    // Intentamos contabilizar el apunte
                    if not TryContabilizarApunte(Apunte, BcEmpresa) then begin
                        rLinDiaGen.ChangeCompany(BcEmpresa);
                        If rLinDiagen.Get(Apunte.RecId) Then
                            If rLinDiaGen.Delete() then;
                        If Apunte.Delete Then;
                        LogError(GetLastErrorText(), 'Contabilización Apunte ' + Apunte."ID Apunte" + ' de la empresa ' + Apunte.Empresa);
                        ErrorApunte += GetLastErrorText() + 'Contabilización Apunte ' + Apunte."ID Apunte" + ' de la empresa ' + Apunte.Empresa;
                        Result += 'No Ok' + ' ' + ErrorApunte;
                        exit;
                    end;
            end;

        end;
        Result += 'Ok';// + ' ' + ErrorApunte;
    end;

    [TryFunction]
    procedure TryContabilizarApunte(Apunte: Record "ApuntesContables"; BcEmpresa: Text[30])
    var
        rLinDiaGen: Record "Gen. Journal Line";
        wLinea: Integer;
        Cuentas: Record "g/l account";
        SourceCodeSetup: Record "Source Code Setup";
        Dim1: Code[20];
        Dim3: Code[20];
    begin
        rLinDiaGen.ChangeCompany(BcEmpresa);
        Cuentas.ChangeCompany(BcEmpresa);
        SourceCodeSetup.ChangeCompany(BcEmpresa);

        rLinDiaGen.RESET;
        rLinDiaGen.SETRANGE("Journal Template Name", 'GENERAL');
        rLinDiaGen.SETRANGE("Journal Batch Name", 'MAXIMO');
        if rLinDiaGen.FIND('+') THEN
            wLinea := rLinDiaGen."Line No.";

        rLinDiaGen.INIT;
        rLinDiaGen."Journal Template Name" := 'GENERAL';
        rLinDiaGen."Journal Batch Name" := 'MAXIMO';
        wLinea += 10000;
        rLinDiaGen."Line No." := wLinea;
        rLinDiaGen.Validate("Document No.", Format(Apunte.Fecha));
        rLinDiaGen.Validate("Posting Date", Apunte.Fecha);

        if not Cuentas.GET(Apunte.Cuenta) THEN begin
            Cuentas.INIT;
            Cuentas."Account Type" := Cuentas."Account Type"::Posting;
            If CopyStr(Apunte.Cuenta, 1, 1) in ['6,7'] THEN
                Cuentas."Income/Balance" := Cuentas."Income/Balance"::"Income Statement"
            ELSE
                Cuentas."Income/Balance" := Cuentas."Income/Balance"::"Balance Sheet";
            Cuentas."No." := Apunte.Cuenta;
            Cuentas.Name := Apunte.Descripción;
            Cuentas.INSERT;
        END;

        rLinDiaGen.Validate("Account No.", Apunte.Cuenta);
        rLinDiaGen."Description" := Apunte.Concepto;
        rLinDiaGen.Validate("Amount", Apunte.Importe);
        rLinDiaGen."Bal. Account No." := '';
        rLinDiaGen."Bal. Account Type" := rLinDiaGen."Bal. Account Type"::"G/L Account";
        rLinDiaGen."Shortcut Dimension 1 Code" := Apunte."Dimension 1";
        //rLinDiaGen."Shortcut Dimension 2 Code" := Apunte."Dimension 2";
        Dim1 := Apunte."Dimension 1";
        Dim3 := Apunte."Dimension 2";
        rLinDiaGen."Dimension Set ID" := 0;
        rLinDiaGen."Dimension Set ID" :=
            Apunte.GetRecDefaultDimID(
            SourceCodeSetup."General Journal",
            Dim1, Dim3,
             rLinDiaGen."Dimension Set ID", DATABASE::"Gen. Journal Line", BcEmpresa);
        //Apunte.UpdateGlobalDimFromDimSetID(rLinDiaGen."Dimension Set ID", Dim1, Dim3);
        rLinDiaGen."Shortcut Dimension 1 Code" := Apunte."Dimension 1";
        Dim3 := Apunte."Dimension 2";
        rLinDiaGen.Insert();
        Apunte.ValidateShortcutDimValues(1, rLinDiaGen."Shortcut Dimension 1 Code", rLinDiaGen."Dimension Set ID", BcEmpresa);
        Apunte.ValidateShortcutDimValues(3, Dim3, rLinDiaGen."Dimension Set ID", BcEmpresa);
        rLinDiaGen.Modify();

        Apunte.Procesado := TRUE;
        Apunte.RecId := rLinDiaGen.RecordId;
        Apunte.MODIFY;

    end;

    procedure LogError(ErrorMessage: Text; Proceso: Text)
    var
        Log: Record "Log Máximo";
        a: Integer;
    begin
        // Implement your error logging here
        //Crear el metodo para gramar error en la tabla "Log Maximo"
        If Log.FindLast() then
            a := Log."ID" + 1
        else
            a := 1;
        Log.Init();
        Log."ID" := a;
        Log.Fecha := Today;
        Log.Hora := TIME;
        Log.Proceso := Proceso;
        Log.Mensaje := ErrorMessage;
        Log.Insert();
    end;
}