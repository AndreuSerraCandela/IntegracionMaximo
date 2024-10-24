codeunit 50001 FuncionesJson
{

    [ServiceEnabled]
    procedure SolicitdWebServices(var Json: Text);
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
                JsonObjLineas.Get('epigrafe Pptop', JsonToken);
                SolicitudLineas."Epígrafe Pptop" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('Fecha activo fijo', JsonToken);
                If Evaluate(SolicitudLineas."Fecha activo fijo", JsonToken.AsValue().AsText()) then;
                Clear(JsonToken);
                JsonObjLineas.Get('Dimensión', JsonToken);
                If Evaluate(SolicitudLineas."Dimensión", JsonToken.AsValue().AsText()) then;
                Clear(JsonToken);
                JsonObjLineas.Get('Proyecto', JsonToken);
                SolicitudLineas."Proyecto" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('Importe', JsonToken);
                SolicitudLineas."Importe" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('Año', JsonToken);
                SolicitudLineas."Año" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
            end;
        end;

    end;
}