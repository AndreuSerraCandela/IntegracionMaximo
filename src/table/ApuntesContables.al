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
    begin
        rLinDiaGen.ChangeCompany(pEmpresa);
        Cuentas.ChangeCompany(pEmpresa);
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
                rLinDiaGen.INSERT;
                Apunte.Procesado := TRUE;
                Apunte.MODIFY;
            UNTIL Apunte.NEXT = 0;


    end;
}