
pageextension 50506 CompanyInfo extends "Company Information"
{
    layout
    {
        addlast(content)

        {
            group("Integración Máxino")
            {
                field("Empresa Máximo"; Rec."Empresa Máximo")
                {
                    ApplicationArea = All;
                }
            }

        }
    }
}