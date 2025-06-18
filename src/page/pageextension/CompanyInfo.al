
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
                field("Apunte Automático"; Rec."Apunte Automático")
                {
                    ApplicationArea = All;
                }
                field("Maximo Username"; Rec."Maximo Username")
                {
                    ApplicationArea = All;
                }
                field("Maximo Password"; Rec."Maximo Password")
                {
                    ApplicationArea = All;
                }
            }

        }
    }
}