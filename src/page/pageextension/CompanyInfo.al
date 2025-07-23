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
                field("URL API Maximo"; Rec."URL API Maximo")
                {
                    ApplicationArea = All;
                }
                field("Api Key Maximo"; Rec."Api Key Maximo")
                {
                    ApplicationArea = All;
                }
                field("Default Site Máximo"; Rec."Default Site Máximo")
                {
                    ApplicationArea = All;
                }
                field("Endpoint Máximo Recepciones"; Rec."Endpoint Máximo Recepciones")
                {
                    ApplicationArea = All;
                }
                field("Endpoint Máximo Pedidos"; Rec."Endpoint Máximo Pedidos")
                {
                    ApplicationArea = All;
                }

            }

        }
    }
}