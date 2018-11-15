"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const util = require("util");
const fs = require("fs");
const httpClient = require("typed-rest-client/HttpClient");
let proxyUrl = process.env["agent.proxyurl"];
var requestOptions = proxyUrl ? {
    proxy: {
        proxyUrl: proxyUrl,
        proxyUsername: process.env["agent.proxyusername"],
        proxyPassword: process.env["agent.proxypassword"],
        proxyBypassHosts: process.env["agent.proxybypasslist"] ? JSON.parse(process.env["agent.proxybypasslist"]) : null
    }
} : {};
let ignoreSslErrors = process.env["VSTS_ARM_REST_IGNORE_SSL_ERRORS"];
requestOptions.ignoreSslError = ignoreSslErrors && ignoreSslErrors.toLowerCase() == "true";
var httpCallbackClient = new httpClient.HttpClient(process.env["AZURE_HTTP_USER_AGENT"] || "GitHubAgent", null, requestOptions);
class WebRequest {
}
exports.WebRequest = WebRequest;
class WebResponse {
}
exports.WebResponse = WebResponse;
class WebRequestOptions {
}
exports.WebRequestOptions = WebRequestOptions;
function sendRequest(request, options) {
    return __awaiter(this, void 0, void 0, function* () {
        let i = 0;
        let retryCount = options && options.retryCount ? options.retryCount : 5;
        let retryIntervalInSeconds = options && options.retryIntervalInSeconds ? options.retryIntervalInSeconds : 2;
        let retriableErrorCodes = options && options.retriableErrorCodes ? options.retriableErrorCodes : ["ETIMEDOUT", "ECONNRESET", "ENOTFOUND", "ESOCKETTIMEDOUT", "ECONNREFUSED", "EHOSTUNREACH", "EPIPE", "EA_AGAIN"];
        let retriableStatusCodes = options && options.retriableStatusCodes ? options.retriableStatusCodes : [408, 409, 500, 502, 503, 504];
        let timeToWait = retryIntervalInSeconds;
        while (true) {
            try {
                if (request.body && typeof (request.body) !== 'string' && !request.body["readable"]) {
                    request.body = fs.createReadStream(request.body["path"]);
                }
                let response = yield sendRequestInternal(request);
                if (retriableStatusCodes.indexOf(response.statusCode) != -1 && ++i < retryCount) {
                    console.debug(util.format("Encountered a retriable status code: %s. Message: '%s'.", response.statusCode, response.statusMessage));
                    yield sleepFor(timeToWait);
                    timeToWait = timeToWait * retryIntervalInSeconds + retryIntervalInSeconds;
                    continue;
                }
                return response;
            }
            catch (error) {
                if (retriableErrorCodes.indexOf(error.code) != -1 && ++i < retryCount) {
                    console.debug(util.format("Encountered a retriable error:%s. Message: %s.", error.code, error.message));
                    yield sleepFor(timeToWait);
                    timeToWait = timeToWait * retryIntervalInSeconds + retryIntervalInSeconds;
                }
                else {
                    if (error.code) {
                        console.log("##vso[task.logissue type=error;code=" + error.code + ";]");
                    }
                    throw error;
                }
            }
        }
    });
}
exports.sendRequest = sendRequest;
function sleepFor(sleepDurationInSeconds) {
    return new Promise((resolve, reject) => {
        setTimeout(resolve, sleepDurationInSeconds * 1000);
    });
}
exports.sleepFor = sleepFor;
function sendRequestInternal(request) {
    return __awaiter(this, void 0, void 0, function* () {
        console.debug(util.format("[%s]%s", request.method, request.uri));
        var response = yield httpCallbackClient.request(request.method, request.uri, request.body, request.headers);
        return yield toWebResponse(response);
    });
}
function toWebResponse(response) {
    return __awaiter(this, void 0, void 0, function* () {
        var res = new WebResponse();
        if (response) {
            res.statusCode = response.message.statusCode;
            res.statusMessage = response.message.statusMessage;
            res.headers = response.message.headers;
            var body = yield response.readBody();
            if (body) {
                try {
                    res.body = JSON.parse(body);
                }
                catch (error) {
                    console.debug("Could not parse response: " + JSON.stringify(error));
                    console.debug("Response: " + JSON.stringify(res.body));
                    res.body = body;
                }
            }
        }
        return res;
    });
}
