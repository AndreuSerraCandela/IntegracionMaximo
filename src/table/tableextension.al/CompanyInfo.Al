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