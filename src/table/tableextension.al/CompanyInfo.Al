//Añadir cun  campo en la tabla Company Info que relacione el campo emresa de apuntes contables con la empresa actu
tableextension 50502 CompanyInfoExt extends "Company Information"
{
    fields
    {
        field(50100; "Empresa Máximo"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50101; "Apunte Automático"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(50501; "Maximo Username"; Text[50])
        {
            Caption = 'Maximo Username';
            DataClassification = SystemMetadata;
        }
        field(50502; "Maximo Password"; Text[50])
        {
            Caption = 'Maximo Password';
            DataClassification = SystemMetadata;
        }
        field(50503; "URL API Maximo"; Text[250])
        {
            Caption = 'URL API Maximo';
            DataClassification = SystemMetadata;
        }
    }
    procedure DevuelveEmpresa(var pEmpresa: Text; var BcEmpresa: Text[30]): Boolean
    var
        CompanyInfo: Record "Company Information";
        Company: Record Company;
    begin
        If Company.FindSet() then
            repeat
                If CompanyInfo.ChangeCompany(Company.Name) then
                    if CompanyInfo.Get() then
                        If CompanyInfo."Empresa Máximo" = pEmpresa then begin
                            BcEmpresa := Company.Name;
                            exit(true);
                        end;

            until Company.Next = 0;
        exit(false);
    end;

}