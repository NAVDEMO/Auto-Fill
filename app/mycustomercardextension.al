pageextension 50100 MyCustomerCardExtension extends "Customer Card"
{
    layout
    {
        modify(Name)
        {
            trigger OnAfterValidate()
            var
                LookupAddressInfo: Codeunit LookupAddressInfo;
            begin
                if Name.EndsWith('.com') or 
                   Name.EndsWith('.dk') or 
                   Name.EndsWith('.de') or 
                   Name.EndsWith('.nl') or 
                   Name.EndsWith('.net') then begin
                    if Confirm('Do you want to collect information about the company associated with ' + Name) then begin
                        LookupAddressInfo.LookupAddressInfo(Rec);
                    end;
                end;
            end;
        }
    }

}