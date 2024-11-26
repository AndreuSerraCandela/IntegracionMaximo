//Crear una page para la tabla ApuntesContables
page 50506 "ApuntesContables"
{
    PageType = List;
    SourceTable = ApuntesContables;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Apuntes Contables';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Empresa; Rec.Empresa)
                {
                    ApplicationArea = All;
                }
                field("Id Apunte"; Rec."Id Apunte")
                {
                    ApplicationArea = All;
                }
                field("Fecha"; Rec."Fecha")
                {
                    ApplicationArea = All;
                }
                field("Concepto"; Rec."Concepto")
                {
                    ApplicationArea = All;
                }
                field("Importe"; Rec."Importe")
                {
                    ApplicationArea = All;
                }
                field("Cuenta"; Rec."Cuenta")
                {
                    ApplicationArea = All;
                }
                field("Descripción"; Rec."Descripción")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action("Generar Asiento")
            {
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                begin
                    Rec.Contabilizar(Rec.Empresa);
                end;
            }

        }
        area(Promoted)
        {
            actionref(GenerarAsiento; "Generar Asiento")
            {
            }
        }
    }
}
