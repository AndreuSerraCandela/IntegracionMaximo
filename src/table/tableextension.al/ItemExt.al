tableextension 50500 ItemExt extends Item
{
    fields
    {
        field(50500; "Maximo Item"; Text[50])
        {
            Caption = 'Maximo Item';
            DataClassification = SystemMetadata;
        }
    }
}
//unitextension 50500 ItemExt extends Item
tableextension 50501 UnitExt extends "Unit of Measure"
{
    fields
    {
        field(50500; "Maximo Item"; Text[50])
        {
            Caption = 'Maximo Item';
            DataClassification = SystemMetadata;
        }
    }
}
tableextension 50503 LocationExt extends Location
{
    fields
    {
        field(50500; "Site Máximo"; Text[50])
        {
            Caption = 'Site Máximo';
            DataClassification = SystemMetadata;
        }
        field(50501; "Location Máximo"; Text[50])
        {
            Caption = 'Location Máximo';
            DataClassification = SystemMetadata;
        }
    }
}
//extender paginas
