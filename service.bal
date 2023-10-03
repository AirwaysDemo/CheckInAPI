import ballerina/http;

configurable string BritishToken = ?;
configurable string BritishClientId = ?;
configurable string BritishClientSecret = ?;

configurable string QatarToken = ?;
configurable string QatarClientId = ?;
configurable string QatarClientSecret = ?;

// Define configurable variables, including the HR endpoint
// configurable string britishEndpoint = ?;
// configurable string qatarEndpoint = ?;

public type Request record {
    string bookReference;
    string passengerName;
};

public type CheckIn record {
    string customerId;
    string flightNumber;
    string seatNumber;
    string passengerName;
    string fromWhere;
    string whereTo;
    float flightDistance;
};

service / on new http:Listener(9094) {

    // Define your resource functions here
    resource function post checkin(@http:Payload Request payload) returns json|error {
        http:Client britishEP = check new ("https://b48cc93e-fa33-4420-a155-bc653b4d46be-dev.e1-us-east-azure.choreoapis.dev/jexg/british-airways-check-in/british-checkin-5c6/v1.0/britishairways/checkin",
            auth = {
                tokenUrl: BritishToken,
                clientId: BritishClientId,
                clientSecret: BritishClientSecret
            }

        );
        http:Client qatarEP = check new ("https://b48cc93e-fa33-4420-a155-bc653b4d46be-dev.e1-us-east-azure.choreoapis.dev/jexg/qatar-airways-check-in/qatarairways-a68/v1.0/checkin",
            auth = {
                tokenUrl: QatarToken,
                clientId: QatarClientId,
                clientSecret: QatarClientSecret
            }
        );

        json[] response = [];

        json|error britishResponse = britishEP->/.post(payload);

        response.push(check britishResponse);

        json|error qatarResponse = qatarEP->/.post(payload);

        response.push(check qatarResponse);

        json aggregatedResponse = {"checkInInfo": response};
        return aggregatedResponse;
    }
}
