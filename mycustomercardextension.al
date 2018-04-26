pageextension 50100 MyCustomerCardExtension extends "Customer Card"
{
    layout
    {
        modify(Name)
        {
            trigger OnAfterValidate()
            begin
                if Name.EndsWith('.com') or Name.EndsWith('.dk') or Name.EndsWith('.net') then begin
                    if Confirm('Do you want to collect information about the company associated with ' + Name) then begin
                        LookupAddressInfo();
                    end;
                end;
            end;
        }
    }

    local procedure LookupAddressInfo()
    var
        Client: HttpClient;
        Content: HttpContent;
        ResponseMessage: HttpResponseMessage;
        Result: Text;
        ResContent: JsonObject;
        ResDetails: JsonObject;
        ResLocations: JsonArray;
        ResLocation: JsonObject;
        ResPhones: JsonArray;
        ResPhone: JsonObject;
    begin
        Content.WriteFrom('{"domain":"'+Name+'"}');
        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer SUfiCHhXogrjkU0wuQl9Vkq467YysNzF');
        Client.Post('https://api.fullcontact.com/v3/company.enrich', Content, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then
            Error('Error connecting to Web Service');
        ResponseMessage.Content().ReadAs(Result);
        if not ResContent.ReadFrom(Result) then
            Error('Invalid response from Web Service');
        ResDetails := GetTokenAsObject(ResContent, 'details', 'Invalid response from Web Service');
        ResLocations := GetTokenAsArray(ResDetails, 'locations', 'No locations available');
        ResLocation := GetArrayElementAsObject(ResLocations, 0, 'Location not available');
        ResPhones := GetTokenAsArray(ResDetails, 'phones', '');
        ResPhone := GetArrayElementAsObject(ResPhones, 0, '');
        Name := GetTokenAsText(ResContent, 'name', '');
        Address := GetTokenAsText(ResLocation, 'addressLine1', '');
        City := GetTokenAsText(ResLocation, 'city', '');
        "Post Code" := GetTokenAsText(ResLocation, 'postalCode', '');
        "Country/Region Code" := GetTokenAsText(ResLocation, 'countryCode', '');
        County := GetTokenAsText(ResLocation, 'country', '');
        "Phone No." := GetTokenAsText(ResPhone, 'value', '');
    end;

    procedure GetTokenAsText(JsonObject: JsonObject; TokenKey: Text; Error: Text): Text;
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then begin
            if Error <> '' then
                Error(Error);
            exit('');
        end;
        exit(JsonToken.AsValue.AsText);
    end;

    procedure GetTokenAsObject(JsonObject: JsonObject; TokenKey: Text; Error: Text): JsonObject;
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            if Error <> '' then
                Error(Error);
        exit(JsonToken.AsObject());
    end;

    procedure GetTokenAsArray(JsonObject: JsonObject; TokenKey: Text; Error: Text): JsonArray;
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            if Error <> '' then
                Error(Error);
        exit(JsonToken.AsArray());
    end;

    procedure GetArrayElementAsObject(JsonArray: JsonArray; Index: Integer; Error: Text): JsonObject;
    var
        JsonToken: JsonToken;
    begin
        if not JsonArray.Get(Index, JsonToken) then
            if Error <> '' then
                Error(Error);
        exit(JsonToken.AsObject());
    end;
}