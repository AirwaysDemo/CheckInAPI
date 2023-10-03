import ballerina/http;
import ballerina/regex;
import ballerina/io;

configurable string BritishToken = ?;
configurable string BritishClientId = ?;
configurable string BritishClientSecret = ?;

configurable string QatarToken = ?;
configurable string QatarClientId = ?;
configurable string QatarClientSecret = ?;


public type Request record {
    string bookReference;
    string passengerName;
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
        io:print(britishResponse);
        if (britishResponse is json) {
            json modifiedBritishResponse = check modifyPassengerName(britishResponse);
            response.push(modifiedBritishResponse);
        } else {
            // Handle the error appropriately, e.g., return an error response
        }

        json|error qatarResponse = qatarEP->/.post(payload);
        io:print(qatarResponse);
        if (qatarResponse is json) {
            json modifiedQatarResponse = check modifyPassengerName(qatarResponse);
            response.push(modifiedQatarResponse);
        } else {
            // Handle the error appropriately, e.g., return an error response
        }

        json aggregatedResponse = {"checkInInfo": response};
        return aggregatedResponse;
    }

}

function modifyPassengerName(json inputJson) returns json|error {
    string passengerName = (check inputJson.passengerName).toString();
    // Split the passengerName into firstName and lastName
    string[] names = regex:split(passengerName, " ");
    string firstName = names[0];
    string lastName = names.length() > 1 ? names[names.length() - 1] : "";

    // Create the modified JSON response
    json modifiedJsonResponse = {
        
        "customerId": check inputJson.customerId,
        "firstName": firstName,
        "lastName": lastName,
        "flightNumber": check inputJson.flightNumber,
        "seatNumber": check inputJson.seatNumber,
        "from": check inputJson.fromWhere,
        "To": check inputJson.whereTo,
        "flightDistance": check inputJson.flightDistance
    };

    io:print(modifiedJsonResponse);
    return modifiedJsonResponse;
}
