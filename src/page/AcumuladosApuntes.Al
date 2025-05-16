page 50530 "Acumulados Mensuales"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Resumen Acumulado";
    SourceTableTemporary = true;
    Caption = 'Acumulados Mensuales por Sociedad';
    Editable = true;

    layout
    {
        area(Content)
        {
            group(Filtros)
            {
                Caption = 'Filtros';

                field(FechaDesdeFilter; FechaDesde)
                {
                    ApplicationArea = All;
                    Caption = 'Fecha Desde';
                    ToolTip = 'Especifica la fecha de inicio del período para calcular los acumulados.';

                    trigger OnValidate()
                    begin
                        ValidarFechas();
                    end;
                }
                field(FechaHastaFilter; FechaHasta)
                {
                    ApplicationArea = All;
                    Caption = 'Fecha Hasta';
                    ToolTip = 'Especifica la fecha de fin del período para calcular los acumulados.';

                    trigger OnValidate()
                    begin
                        ValidarFechas();
                    end;
                }
                field(EmpresaFilter; EmpresaFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Sociedad';
                    ToolTip = 'Especifica la sociedad para filtrar los acumulados. Deja en blanco para mostrar todas.';
                    TableRelation = ApuntesContables.Empresa;

                    trigger OnValidate()
                    begin
                        CargarDatos();
                    end;
                }
            }
            repeater(Group)
            {
                Editable = false;
                field(Empresa; Rec.Empresa)
                {
                    ApplicationArea = All;
                    Caption = 'Sociedad';
                }
                field(Anio; Rec.Anio)
                {
                    ApplicationArea = All;
                    Caption = 'Año';
                }
                field(Mes; Rec.Mes)
                {
                    ApplicationArea = All;
                    Caption = 'Mes (Núm.)';
                }
                field(NombreMes; GetNombreMes(Rec.Mes))
                {
                    ApplicationArea = All;
                    Caption = 'Mes';
                }
                field(ImporteAcumulado; Rec.ImporteAcumulado)
                {
                    ApplicationArea = All;
                    Caption = 'Importe Acumulado';
                    StyleExpr = ImporteStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Actualizar';
                Image = Refresh;

                trigger OnAction()
                begin
                    CargarDatos();
                end;
            }
            action(ExportToExcel)
            {
                ApplicationArea = All;
                Caption = 'Exportar a Excel';
                Image = ExportToExcel;

                trigger OnAction()
                var
                    TempExcelBuffer: Record "Excel Buffer" temporary;
                    ExcelFileName: Text;
                    SheetName: Text;
                begin
                    SheetName := 'Acumulados Mensuales';
                    ExcelFileName := 'Acumulados_Mensuales.xlsx';

                    TempExcelBuffer.Reset();
                    TempExcelBuffer.DeleteAll();

                    // Cabeceras
                    TempExcelBuffer.NewRow();
                    TempExcelBuffer.AddColumn('Sociedad', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('Año', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('Mes (Núm.)', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('Mes', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('Importe Acumulado', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

                    // Datos
                    if Rec.FindSet() then
                        repeat
                            TempExcelBuffer.NewRow();
                            TempExcelBuffer.AddColumn(Rec.Empresa, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn(Rec.Anio, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                            TempExcelBuffer.AddColumn(Rec.Mes, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                            TempExcelBuffer.AddColumn(GetNombreMes(Rec.Mes), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn(Rec.ImporteAcumulado, false, '', false, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
                        until Rec.Next() = 0;

                    TempExcelBuffer.CreateNewBook(SheetName);
                    TempExcelBuffer.WriteSheet(SheetName, CompanyName, UserId);
                    TempExcelBuffer.CloseBook();
                    TempExcelBuffer.OpenExcel();
                end;
            }
        }
        area(Navigation)
        {
            action(ApuntesContables)
            {
                ApplicationArea = All;
                Caption = 'Apuntes Contables';
                Image = List;
                RunObject = page ApuntesContables;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Por defecto, mostramos el último mes completo
        FechaHasta := CalcDate('<CM>', Today());
        if Date2DMY(Today(), 2) = Date2DMY(FechaHasta, 2) then
            FechaHasta := CalcDate('<-1M+CM>', Today());

        FechaDesde := CalcDate('<-CM>', FechaHasta);

        CargarDatos();
    end;

    procedure ValidarFechas()
    begin
        if FechaHasta < FechaDesde then
            Error('La fecha fin no puede ser anterior a la fecha inicio.');

        CargarDatos();
    end;

    procedure CargarDatos()
    var
        ApuntesContables: Record ApuntesContables;
        Anio: Integer;
        Mes: Integer;
    begin
        CurrPage.Update(false);

        // Limpiar datos existentes
        Rec.Reset();
        Rec.DeleteAll();

        // Filtrar apuntes del período
        ApuntesContables.Reset();
        ApuntesContables.SetFilter(Fecha, '%1..%2', FechaDesde, FechaHasta);

        // Filtrar por empresa si se ha especificado
        if EmpresaFilter <> '' then
            ApuntesContables.SetRange(Empresa, EmpresaFilter);

        if ApuntesContables.FindSet() then
            repeat
                Anio := Date2DMY(ApuntesContables.Fecha, 3);
                Mes := Date2DMY(ApuntesContables.Fecha, 2);

                // Asegurarnos de que el mes esté dentro del rango válido
                if (Mes >= 1) and (Mes <= 12) then begin
                    Rec.Reset();
                    Rec.SetRange(Empresa, ApuntesContables.Empresa);
                    Rec.SetRange(Anio, Anio);
                    Rec.SetRange(Mes, Mes);

                    if Rec.FindFirst() then begin
                        Rec.ImporteAcumulado += ApuntesContables.Importe;
                        Rec.Modify();
                    end else begin
                        Rec.Init();
                        Rec.Empresa := ApuntesContables.Empresa;
                        Rec.Anio := Anio;
                        Rec.Mes := Mes;
                        Rec.ImporteAcumulado := ApuntesContables.Importe;
                        Rec.Insert();
                    end;
                end;
            until ApuntesContables.Next() = 0;

        Rec.Reset();

        // Mostrar información del filtro de fechas
        CurrPage.Caption := StrSubstNo('Acumulados Mensuales por Sociedad (%1 - %2)', Format(FechaDesde, 0, '<Day,2>/<Month,2>/<Year4>'), Format(FechaHasta, 0, '<Day,2>/<Month,2>/<Year4>'));

        CurrPage.Update(false);
    end;

    local procedure GetNombreMes(MesNum: Integer): Text
    var
        NombresMeses: array[12] of Text;
    begin
        if (MesNum < 1) or (MesNum > 12) then
            exit('');

        NombresMeses[1] := 'Enero';
        NombresMeses[2] := 'Febrero';
        NombresMeses[3] := 'Marzo';
        NombresMeses[4] := 'Abril';
        NombresMeses[5] := 'Mayo';
        NombresMeses[6] := 'Junio';
        NombresMeses[7] := 'Julio';
        NombresMeses[8] := 'Agosto';
        NombresMeses[9] := 'Septiembre';
        NombresMeses[10] := 'Octubre';
        NombresMeses[11] := 'Noviembre';
        NombresMeses[12] := 'Diciembre';

        exit(NombresMeses[MesNum]);
    end;

    var
        ImporteStyle: Text;
        FechaDesde: Date;
        FechaHasta: Date;
        EmpresaFilter: Text;
}