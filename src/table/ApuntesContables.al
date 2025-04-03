// //Covertir en una tabla el siguiente json: 
// {
//   "empresas": [
//     {
//       "nombre": "Empresa XYZ",
//       "apuntes_contables": [
//         {
//           "id_apunte": "1",
//           "fecha": "2024-10-15",
//           "concepto": "Esistencias Iniciales",
//           "importe": -1000.00,
//           "cuenta": "300000000",
//           "descripcion": "Existencias"
//         },
//         {
//           "id_apunte": "2",
//           "fecha": "2024-10-15",
//           "concepto": "Consumo",
//           "importe": 500.00,
//           "cuenta": "610000000",
//           "descripcion": "Variación Existencias"
//         },
// 	{
//           "id_apunte": "3",
//           "fecha": "2024-10-15",
//           "concepto": "Esistencias finales",
//           "importe": 500.00,
//           "cuenta": "300000000",
//           "descripcion": "Existencias"
//         }

//       ]
//     },
//     {
//       "nombre": "Empresa ABC",
//       "apuntes_contables": [
//         {
//           "id_apunte": "1",
//           "fecha": "2024-10-15",
//           "concepto": "Esistencias Iniciales",
//           "importe": -2000.00,
//           "cuenta": "300000000",
//           "descripcion": "Existencias"
//         },
//         {
//           "id_apunte": "2",
//           "fecha": "2024-10-15",
//           "concepto": "Consumo",
//           "importe": 500.00,
//           "cuenta": "610000000",
//           "descripcion": "Variación Existencias"
//         },
// 	{
//           "id_apunte": "3",
//           "fecha": "2024-10-15",
//           "concepto": "Esistencias finales",
//           "importe": 1500.00,
//           "cuenta": "300000000",
//           "descripcion": "Existencias"
//         }
//       ]
//     }
//   ]
// }
table 50505 ApuntesContables
{
    DrillDownPageId = ApuntesContables;
    LookupPageId = ApuntesContables;
    fields
    {
        field(1; Empresa; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "ID Apunte"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Fecha"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Concepto"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Importe"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Cuenta"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Descripción"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(8; Procesado; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Error; boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Proyecto"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Dimension 1"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Dimension 2"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Empresa, "ID Apunte")
        {
            Clustered = true;
        }
    }

    procedure Contabilizar(pEmpresa: Text[100])
    var
        Apunte: Record "ApuntesContables";
        rLinDiaGen: Record "Gen. Journal Line";
        wLinea: Integer;
        Cuentas: Record "g/l account";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        rLinDiaGen.ChangeCompany(pEmpresa);
        Cuentas.ChangeCompany(pEmpresa);
        SourceCodeSetup.ChangeCompany(pEmpresa);
        rLinDiaGen.RESET;
        rLinDiaGen.SETRANGE("Journal Template Name", 'GENERAL');
        rLinDiaGen.SETRANGE("Journal Batch Name", 'MAXIMO');
        if rLinDiaGen.FIND('+') THEN
            wLinea := rLinDiaGen."Line No.";
        Apunte.SetRange(Empresa, pEmpresa);
        Apunte.SetRange(Procesado, FALSE);
        Apunte.SetRange(Error, FALSE);
        if Apunte.FINDSET THEN
            REPEAT
                rLinDiaGen.INIT;
                rLinDiaGen."Journal Template Name" := 'GENERAL';
                rLinDiaGen."Journal Batch Name" := 'MAXIMO';
                rLinDiaGen."Line No." := wLinea;
                wLinea += 10000;
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
                rLinDiaGen."Bal. Account No." := '0';
                rLinDiaGen."Bal. Account Type" := rLinDiaGen."Bal. Account Type"::"G/L Account";
                rLinDiaGen."Shortcut Dimension 1 Code" := Apunte."Dimension 1";
                rLinDiaGen."Shortcut Dimension 2 Code" := Apunte."Dimension 2";
                rLinDiaGen."Dimension Set ID" :=
                    GetRecDefaultDimID(
                    SourceCodeSetup."General Journal",
                    rLinDiaGen."Shortcut Dimension 1 Code", rLinDiaGen."Shortcut Dimension 2 Code",
                     rLinDiaGen."Dimension Set ID", DATABASE::"Gen. Journal Line", Apunte.Empresa);
                UpdateGlobalDimFromDimSetID(rLinDiaGen."Dimension Set ID", rLinDiaGen."Shortcut Dimension 1 Code", rLinDiaGen."Shortcut Dimension 2 Code");
                rLinDiaGen.INSERT;
                Apunte.Procesado := TRUE;
                Apunte.MODIFY;
            UNTIL Apunte.NEXT = 0;


    end;

    procedure GetRecDefaultDimID(
Sales: Code[10];
var ShortcutDimension1Code: Code[20];
var ShortcutDimension2Code: Code[20];
var DimensionSetID: Integer;
TableId: Integer; EmpresaOrigen: Text[100]): Integer
    var

    begin
        exit(pGetRecDefaultDimID(Sales, ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID, TableId, EmpresaOrigen));
    end;

    procedure pGetRecDefaultDimID(ppcSourceCode: Code[20];
   var pCGlobalDim1Code: Code[20]; var pCGlobalDim2Code: Code[20];
   piInheritFromDimSetID: Integer; piInheritFromTableNo: Integer; Empresa: Text): Integer
    var
        lDimValue: Record "Dimension Value";
        lDefaultDimPriority1: Record "Default Dimension Priority";
        lDefaultDimPriority2: Record "Default Dimension Priority";
        lDefaultDim: Record "Default Dimension";
        lDimSetEntryTMP: Record "Dimension Set Entry" temporary;
        lDimSetEntryTMP0: Record "Dimension Set Entry" temporary;
        i: Integer;
        j: Integer;
        lCNoFilterarray: array[5] of Code[20];
        liNewDimSetID: Integer;
        IsHandled: Boolean;
        lGenLedgerSetupShortcutDimCodeArray: array[5] of Code[20];
        DimValueArray: array[5] of Code[20];
        lGenLedgerSetup: Record "General Ledger Setup";
    begin
        lGenLedgerSetup.ChangeCompany(Empresa);
        lGenLedgerSetup.Get;
        lGenLedgerSetupShortcutDimCodeArray[1] := lGenLedgerSetup."Global Dimension 1 Code";
        lGenLedgerSetupShortcutDimCodeArray[2] := lGenLedgerSetup."ShortCut Dimension 2 Code";
        DimValueArray[1] := pCGlobalDim1Code;
        DimValueArray[2] := pCGlobalDim2Code;
        for i := 1 to 2 do begin

            if lDimValue.Get(lGenLedgerSetupShortcutDimCodeArray[i], DimValueArray[i]) Then begin
                lDimSetEntryTMP."Dimension Code" := lGenLedgerSetupShortcutDimCodeArray[i];
                lDimSetEntryTMP."Dimension Value Code" := DimValueArray[i];
                lDimSetEntryTMP."Dimension Value ID" := lDimValue."Dimension Value ID";
                lDimSetEntryTMP.Insert();
            end;
        end;
        liNewDimSetID := GetDimensionSetID(lDimSetEntryTMP, Empresa);

        exit(liNewDimSetID);
    end;

    procedure UpdateGlobalDimFromDimSetID(piDimSetID: Integer; var pCGlobalDimVal1: Code[20]; var pCGlobalDimVal2: Code[20])
    var
        lCShortcutDimCodeArray: array[8] of Code[20];
    begin
        GetShortcutDimensions(piDimSetID, lCShortcutDimCodeArray);
        pCGlobalDimVal1 := lCShortcutDimCodeArray[1];
        pCGlobalDimVal2 := lCShortcutDimCodeArray[2];


    end;

    procedure GetShortcutDimensions(piDimSetID: Integer; var pCShortcutDimCodeArray: array[8] of Code[20])
    var
        lcGetShortcutDimensionValues: Codeunit "Get Shortcut Dimension Values";
    begin
        lcGetShortcutDimensionValues.GetShortcutDimensions(piDimSetID, pCShortcutDimCodeArray);
    end;

    procedure GetDimensionSetID(var DimSetEntry: Record "Dimension Set Entry"; Empresa: Text): Integer
    var
        DimSetEntry2: Record "Dimension Set Entry";
        DimSetTreeNode: Record "Dimension Set Tree Node";
        Found: Boolean;
    begin
        DimSetEntry2.Copy(DimSetEntry);
        if DimSetEntry."Dimension Set ID" > 0 then
            DimSetEntry.SetRange("Dimension Set ID", DimSetEntry."Dimension Set ID");

        DimSetEntry.SetCurrentKey("Dimension Value ID");
        DimSetEntry.SetFilter("Dimension Code", '<>%1', '');
        DimSetEntry.SetFilter("Dimension Value Code", '<>%1', '');

        if not DimSetEntry.FindSet() then begin
            DimSetEntry.Copy(DimSetEntry2);
            exit(0);
        end;

        Found := true;
        DimSetTreeNode.ChangeCompany(Empresa);
        DimSetTreeNode."Dimension Set ID" := 0;
        repeat
            DimSetEntry.TestField("Dimension Value ID");
            if Found then
                if not DimSetTreeNode.Get(DimSetTreeNode."Dimension Set ID", DimSetEntry."Dimension Value ID") then begin
                    Found := false;
                    DimSetTreeNode.LockTable();
                end;
            if not Found then begin
                DimSetTreeNode."Parent Dimension Set ID" := DimSetTreeNode."Dimension Set ID";
                DimSetTreeNode."Dimension Value ID" := DimSetEntry."Dimension Value ID";
                DimSetTreeNode."Dimension Set ID" := 0;
                DimSetTreeNode."In Use" := false;
                if not DimSetTreeNode.Insert(true) then
                    DimSetTreeNode.Get(DimSetTreeNode."Parent Dimension Set ID", DimSetTreeNode."Dimension Value ID");
            end;
        until DimSetEntry.Next() = 0;
        if not DimSetTreeNode."In Use" then begin
            if Found then begin
                DimSetTreeNode.LockTable();
                DimSetTreeNode.Get(DimSetTreeNode."Parent Dimension Set ID", DimSetTreeNode."Dimension Value ID");
            end;
            DimSetTreeNode."In Use" := true;
            DimSetTreeNode.Modify();
            InsertDimSetEntries(DimSetEntry, DimSetTreeNode."Dimension Set ID");
        end;

        DimSetEntry.Copy(DimSetEntry2);

        exit(DimSetTreeNode."Dimension Set ID");
    end;

    procedure InsertDimSetEntries(var DimSetEntry: Record "Dimension Set Entry"; NewID: Integer)
    var
        DimSetEntry2: Record "Dimension Set Entry";
    begin
        DimSetEntry2.LockTable();
        if DimSetEntry.FindSet() then
            repeat
                DimSetEntry2 := DimSetEntry;
                DimSetEntry2."Dimension Set ID" := NewID;
                DimSetEntry2."Global Dimension No." := DimSetEntry2.GetGlobalDimNo();
                If DimSetEntry2.Insert() Then;
            until DimSetEntry.Next() = 0;
    end;
}