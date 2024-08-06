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
            JsonObjSolicitud.Get('ID Proveedor', JsonToken);
            SolicitudEncabezado."ID Proveedor" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('Nombre Proveedor', JsonToken);
            SolicitudEncabezado."Nombre Proveedor" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('Teléfono', JsonToken);
            SolicitudEncabezado."Teléfono" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('Correo', JsonToken);
            SolicitudEncabezado."Correo" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('Descripción General', JsonToken);
            SolicitudEncabezado."Descripción General" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('Fecha de Creación', JsonToken);
            If Evaluate(SolicitudEncabezado."Fecha de Creación", JsonToken.AsValue().AsText()) then;
            Clear(JsonToken);
            JsonObjSolicitud.Get('Fecha de Estimada Inicio', JsonToken);
            If Evaluate(SolicitudEncabezado."Fecha de Estimada Inicio", JsonToken.AsValue().AsText()) then;
            Clear(JsonToken);
            JsonObjSolicitud.Get('Fecha estimada finalización', JsonToken);
            If Evaluate(SolicitudEncabezado."Fecha estimada finalización", JsonToken.AsValue().AsText()) then;
            Clear(JsonToken);
            JsonObjSolicitud.Get('Creado por', JsonToken);
            SolicitudEncabezado."Creado por" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('Circuito', JsonToken);
            SolicitudEncabezado."Circuito" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('Estado', JsonToken);
            SolicitudEncabezado."Estado" := JsonToken.AsValue().AsText();
            Clear(JsonToken);
            JsonObjSolicitud.Get('N solicitud necesidad', JsonToken);
            SolicitudEncabezado."N solicitud necesidad" := JsonToken.AsValue().AsText();
            SolicitudEncabezado.Modify();
            JsonObjSolicitud.Get('Lineas', JsonTokenLineas);
            JsonArrayLineas := JsonTokenLineas.AsArray();
            foreach JsonTokenLineas in JsonArrayLineas do begin
                Linea += 1;
                JsonObjLineas := JsonTokenLineas.AsObject();
                Clear(JsonToken);
                JsonObjLineas.Get('N Línea', JsonToken);
                SolicitudLineas.Init();
                SolicitudLineas."N Solicitud" := SolicitudEncabezado."N Solicitud";
                If Not Evaluate(SolicitudLineas."N Línea", JsonToken.AsValue().AsText()) then
                    SolicitudLineas."N Línea" := Linea;
                Clear(JsonToken);
                JsonObjLineas.Get('Sociedad', JsonToken);
                SolicitudLineas."Sociedad" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('OT', JsonToken);
                SolicitudLineas."OT" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('Descripción bien o servicio', JsonToken);
                SolicitudLineas."Descripción bien o servicio" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('Cantidad', JsonToken);
                If Evaluate(SolicitudLineas."Cantidad", JsonToken.AsValue().AsText()) Then;
                Clear(JsonToken);
                JsonObjLineas.Get('Cuenta activo fijo', JsonToken);
                SolicitudLineas."Cuenta activo fijo" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('N Pedido Presupuesto', JsonToken);
                SolicitudLineas."N Pedido Presupuesto" := JsonToken.AsValue().AsText();
                Clear(JsonToken);
                JsonObjLineas.Get('Epígrafe Pptop', JsonToken);
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