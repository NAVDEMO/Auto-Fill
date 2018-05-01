codeunit 50100 LookupAddressInfo
{
    procedure LookupAddressInfo(Rec: Record Customer)
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
        Content.WriteFrom('{"domain":"'+Rec.Name+'"}');
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
        Rec.Name := GetTokenAsText(ResContent, 'name', '');
        Rec.Address := GetTokenAsText(ResLocation, 'addressLine1', '');
        Rec.City := GetTokenAsText(ResLocation, 'city', '');
        Rec."Post Code" := GetTokenAsText(ResLocation, 'postalCode', '');
        Rec."Country/Region Code" := GetTokenAsText(ResLocation, 'countryCode', '');
        Rec.County := GetTokenAsText(ResLocation, 'country', '');
        Rec."Phone No." := GetTokenAsText(ResPhone, 'value', '');
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