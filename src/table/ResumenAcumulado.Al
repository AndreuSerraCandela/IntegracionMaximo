table 50522 "Resumen Acumulado"
{
    Caption = 'Resumen Acumulado';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Empresa; Text[100])
        {
            Caption = 'Empresa';
            DataClassification = CustomerContent;
        }
        field(2; Anio; Integer)
        {
            Caption = 'Año';
            DataClassification = CustomerContent;
        }
        field(3; Mes; Integer)
        {
            Caption = 'Mes';
            DataClassification = CustomerContent;
        }
        field(4; ImporteAcumulado; Decimal)
        {
            Caption = 'Importe Acumulado';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Empresa, Anio, Mes)
        {
            Clustered = true;
        }
    }
}