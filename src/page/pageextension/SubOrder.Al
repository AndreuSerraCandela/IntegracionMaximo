pageextension 50507 "SubOrder" extends "Purchase Order Subform"
{
    layout
    {
        addafter("No.")
        {
            field("Producto Máximo"; Rec."Item")
            {
                ApplicationArea = All;
            }
        }
    }
}
