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
const fs = require("fs");
const util = require("util");
const webClient = require("./webClient");
exports.KUDU_DEPLOYMENT_CONSTANTS = {
    SUCCESS: 4,
    FAILED: 3
};
class KuduServiceManagementClient {
    constructor(scmUri, accessToken) {
        this._accesssToken = accessToken;
        this._scmUri = scmUri;
    }
    beginRequest(request, reqOptions, contentType) {
        return __awaiter(this, void 0, void 0, function* () {
            request.headers = request.headers || {};
            request.headers["Authorization"] = "Basic " + this._accesssToken;
            request.headers['Content-Type'] = contentType || 'application/json; charset=utf-8';
            let retryCount = reqOptions && util.isNumber(reqOptions.retryCount) ? reqOptions.retryCount : 5;
            while (retryCount >= 0) {
                try {
                    let httpResponse = yield webClient.sendRequest(request, reqOptions);
                    return httpResponse;
                }
                catch (exception) {
                    let exceptionString = exception.toString();
                    if (exceptionString.indexOf("Hostname/IP doesn't match certificates's altnames") != -1
                        || exceptionString.indexOf("unable to verify the first certificate") != -1
                        || exceptionString.indexOf("unable to get local issuer certificate") != -1) {
                        console.warn(('ASE_SSLIssueRecommendation'));
                    }
                    if (retryCount > 0 && exceptionString.indexOf('Request timeout') != -1 && (!reqOptions || reqOptions.retryRequestTimedout)) {
                        console.debug('encountered request timedout issue in Kudu. Retrying again');
                        retryCount -= 1;
                        continue;
                    }
                    throw new Error(exceptionString);
                }
            }
        });
    }
    getRequestUri(uriFormat, queryParameters) {
        uriFormat = uriFormat[0] == "/" ? uriFormat : "/" + uriFormat;
        if (queryParameters && queryParameters.length > 0) {
            uriFormat = uriFormat + '?' + queryParameters.join('&');
        }
        return this._scmUri + uriFormat;
    }
    getScmUri() {
        return this._scmUri;
    }
}
exports.KuduServiceManagementClient = KuduServiceManagementClient;
class Kudu {
    constructor(scmUri, username, password) {
        var base64EncodedCredential = (new Buffer(username + ':' + password).toString('base64'));
        this._client = new KuduServiceManagementClient(scmUri, base64EncodedCredential);
    }
    updateDeployment(requestBody) {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'PUT';
            httpRequest.body = JSON.stringify(requestBody);
            httpRequest.uri = this._client.getRequestUri(`/api/deployments/${requestBody.id}`);
            try {
                let webRequestOptions = { retriableErrorCodes: [], retriableStatusCodes: [], retryCount: 1, retryIntervalInSeconds: 5, retryRequestTimedout: true };
                var response = yield this._client.beginRequest(httpRequest, webRequestOptions);
                console.debug(`updateDeployment. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    console.log("Successfullyupdateddeploymenthistory " + response.body.url);
                    return response.body.id;
                }
                throw response;
            }
            catch (error) {
                throw Error(('Failedtoupdatedeploymenthistory ' + this._getFormattedError(error)));
            }
        });
    }
    getContinuousJobs() {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/continuouswebjobs`);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getContinuousJobs. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToGetContinuousWebJobs ' + this._getFormattedError(error)));
            }
        });
    }
    startContinuousWebJob(jobName) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log(('StartingWebJob' + jobName));
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'POST';
            httpRequest.uri = this._client.getRequestUri(`/api/continuouswebjobs/${jobName}/start`);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`startContinuousWebJob. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    console.log(('StartedWebJob' + jobName));
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToStartContinuousWebJob' + jobName + this._getFormattedError(error)));
            }
        });
    }
    stopContinuousWebJob(jobName) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log(('StoppingWebJob' + jobName));
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'POST';
            httpRequest.uri = this._client.getRequestUri(`/api/continuouswebjobs/${jobName}/stop`);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`stopContinuousWebJob. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    console.log(('StoppedWebJob' + jobName));
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToStopContinuousWebJob' + jobName + this._getFormattedError(error)));
            }
        });
    }
    installSiteExtension(extensionID) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log(("InstallingSiteExtension" + extensionID));
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'PUT';
            httpRequest.uri = this._client.getRequestUri(`/api/siteextensions/${extensionID}`);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`installSiteExtension. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    console.log(("SiteExtensionInstalled" + extensionID));
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToInstallSiteExtension' + extensionID + this._getFormattedError(error)));
            }
        });
    }
    getSiteExtensions() {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/siteextensions`, ['checkLatest=false']);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getSiteExtensions. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToGetSiteExtensions' + this._getFormattedError(error)));
            }
        });
    }
    getAllSiteExtensions() {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/extensionfeed`);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getAllSiteExtensions. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToGetAllSiteExtensions' + this._getFormattedError(error)));
            }
        });
    }
    getProcess(processID) {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/processes/${processID}`);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getProcess. status code: ${response.statusCode} - ${response.statusMessage}`);
                if (response.statusCode == 200) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToGetProcess' + this._getFormattedError(error)));
            }
        });
    }
    killProcess(processID) {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'DELETE';
            httpRequest.uri = this._client.getRequestUri(`/api/processes/${processID}`);
            var reqOptions = {
                retriableErrorCodes: ["ETIMEDOUT"],
                retriableStatusCodes: [503],
                retryCount: 1,
                retryIntervalInSeconds: 5,
                retryRequestTimedout: true
            };
            try {
                var response = yield this._client.beginRequest(httpRequest, reqOptions);
                console.debug(`killProcess. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 502) {
                    console.debug(`Killed Process ${processID}`);
                    return;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToKillProcess' + this._getFormattedError(error)));
            }
        });
    }
    getAppSettings() {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/settings`);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getAppSettings. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToFetchKuduAppSettings' + this._getFormattedError(error)));
            }
        });
    }
    listDir(physicalPath) {
        return __awaiter(this, void 0, void 0, function* () {
            physicalPath = physicalPath.replace(/[\\]/g, "/");
            physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1) : physicalPath;
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/`);
            httpRequest.headers = {
                'If-Match': '*'
            };
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`listFiles. Data: ${JSON.stringify(response)}`);
                if ([200, 201, 204].indexOf(response.statusCode) != -1) {
                    return response.body;
                }
                else if (response.statusCode === 404) {
                    return null;
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw Error(('FailedToListPath' + physicalPath + this._getFormattedError(error)));
            }
        });
    }
    getFileContent(physicalPath, fileName) {
        return __awaiter(this, void 0, void 0, function* () {
            physicalPath = physicalPath.replace(/[\\]/g, "/");
            physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1) : physicalPath;
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/${fileName}`);
            httpRequest.headers = {
                'If-Match': '*'
            };
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getFileContent. Status code: ${response.statusCode} - ${response.statusMessage}`);
                if ([200, 201, 204].indexOf(response.statusCode) != -1) {
                    return response.body;
                }
                else if (response.statusCode === 404) {
                    return null;
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw Error(('FailedToGetFileContent' + physicalPath + fileName + this._getFormattedError(error)));
            }
        });
    }
    uploadFile(physicalPath, fileName, filePath) {
        return __awaiter(this, void 0, void 0, function* () {
            physicalPath = physicalPath.replace(/[\\]/g, "/");
            physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1) : physicalPath;
            if (!fs.statSync(filePath)) {
                throw new Error(('FilePathInvalid' + filePath));
            }
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'PUT';
            httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/${fileName}`);
            httpRequest.headers = {
                'If-Match': '*'
            };
            httpRequest.body = fs.createReadStream(filePath);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`uploadFile. Data: ${JSON.stringify(response)}`);
                if ([200, 201, 204].indexOf(response.statusCode) != -1) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToUploadFile' + physicalPath + fileName + this._getFormattedError(error)));
            }
        });
    }
    createPath(physicalPath) {
        return __awaiter(this, void 0, void 0, function* () {
            physicalPath = physicalPath.replace(/[\\]/g, "/");
            physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1) : physicalPath;
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'PUT';
            httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/`);
            httpRequest.headers = {
                'If-Match': '*'
            };
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`createPath. Data: ${JSON.stringify(response)}`);
                if ([200, 201, 204].indexOf(response.statusCode) != -1) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToCreatePath' + physicalPath + this._getFormattedError(error)));
            }
        });
    }
    runCommand(physicalPath, command) {
        return __awaiter(this, void 0, void 0, function* () {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'POST';
            httpRequest.uri = this._client.getRequestUri(`/api/command`);
            httpRequest.headers = {
                'Content-Type': 'multipart/form-data ',
                'If-Match': '*'
            };
            httpRequest.body = JSON.stringify({
                'command': command,
                'dir': physicalPath
            });
            try {
                console.debug('Executing Script on Kudu. Command: ' + command);
                let webRequestOptions = { retriableErrorCodes: null, retriableStatusCodes: null, retryCount: 5, retryIntervalInSeconds: 5, retryRequestTimedout: false };
                var response = yield this._client.beginRequest(httpRequest, webRequestOptions);
                console.debug(`runCommand. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return;
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw Error(error.toString());
            }
        });
    }
    extractZIP(webPackage, physicalPath) {
        return __awaiter(this, void 0, void 0, function* () {
            physicalPath = physicalPath.replace(/[\\]/g, "/");
            physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1) : physicalPath;
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'PUT';
            httpRequest.uri = this._client.getRequestUri(`/api/zip/${physicalPath}/`);
            httpRequest.headers = {
                'Content-Type': 'multipart/form-data ',
                'If-Match': '*'
            };
            httpRequest.body = fs.createReadStream(webPackage);
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`extractZIP. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return;
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw Error(('Failedtodeploywebapppackageusingkuduservice' + this._getFormattedError(error)));
            }
        });
    }
    zipDeploy(webPackage, queryParameters) {
        return __awaiter(this, void 0, void 0, function* () {
            let httpRequest = new webClient.WebRequest();
            httpRequest.method = 'POST';
            httpRequest.uri = this._client.getRequestUri(`/api/zipdeploy`, queryParameters);
            httpRequest.body = fs.createReadStream(webPackage);
            try {
                let response = yield this._client.beginRequest(httpRequest, null, 'application/octet-stream');
                console.debug(`ZIP Deploy response: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    console.debug('Deployment passed');
                    return null;
                }
                else if (response.statusCode == 202) {
                    let pollableURL = response.headers.location;
                    if (!!pollableURL) {
                        console.debug(`Polling for ZIP Deploy URL: ${pollableURL}`);
                        return yield this._getDeploymentDetailsFromPollURL(pollableURL);
                    }
                    else {
                        console.debug('zip deploy returned 202 without pollable URL.');
                        return null;
                    }
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw new Error(('PackageDeploymentFailed' + this._getFormattedError(error)));
            }
        });
    }
    warDeploy(webPackage, queryParameters) {
        return __awaiter(this, void 0, void 0, function* () {
            let httpRequest = new webClient.WebRequest();
            httpRequest.method = 'POST';
            httpRequest.uri = this._client.getRequestUri(`/api/wardeploy`, queryParameters);
            httpRequest.body = fs.createReadStream(webPackage);
            try {
                let response = yield this._client.beginRequest(httpRequest);
                console.debug(`War Deploy response: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    console.debug('Deployment passed');
                    return null;
                }
                else if (response.statusCode == 202) {
                    let pollableURL = response.headers.location;
                    if (!!pollableURL) {
                        console.debug(`Polling for War Deploy URL: ${pollableURL}`);
                        return yield this._getDeploymentDetailsFromPollURL(pollableURL);
                    }
                    else {
                        console.debug('war deploy returned 202 without pollable URL.');
                        return null;
                    }
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw new Error(('PackageDeploymentFailed' + this._getFormattedError(error)));
            }
        });
    }
    getDeploymentDetails(deploymentID) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                var httpRequest = new webClient.WebRequest();
                httpRequest.method = 'GET';
                httpRequest.uri = this._client.getRequestUri(`/api/deployments/${deploymentID}`);
                ;
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getDeploymentDetails. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToGetDeploymentLogs' + this._getFormattedError(error)));
            }
        });
    }
    getDeploymentLogs(log_url) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                var httpRequest = new webClient.WebRequest();
                httpRequest.method = 'GET';
                httpRequest.uri = log_url;
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`getDeploymentLogs. Data: ${JSON.stringify(response)}`);
                if (response.statusCode == 200) {
                    return response.body;
                }
                throw response;
            }
            catch (error) {
                throw Error(('FailedToGetDeploymentLogs' + this._getFormattedError(error)));
            }
        });
    }
    deleteFile(physicalPath, fileName) {
        return __awaiter(this, void 0, void 0, function* () {
            physicalPath = physicalPath.replace(/[\\]/g, "/");
            physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1) : physicalPath;
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'DELETE';
            httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/${fileName}`);
            httpRequest.headers = {
                'If-Match': '*'
            };
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`deleteFile. Data: ${JSON.stringify(response)}`);
                if ([200, 201, 204, 404].indexOf(response.statusCode) != -1) {
                    return;
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw Error(('FailedToDeleteFile' + physicalPath + fileName + this._getFormattedError(error)));
            }
        });
    }
    deleteFolder(physicalPath) {
        return __awaiter(this, void 0, void 0, function* () {
            physicalPath = physicalPath.replace(/[\\]/g, "/");
            physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1) : physicalPath;
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'DELETE';
            httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}`);
            httpRequest.headers = {
                'If-Match': '*'
            };
            try {
                var response = yield this._client.beginRequest(httpRequest);
                console.debug(`deleteFolder. Data: ${JSON.stringify(response)}`);
                if ([200, 201, 204, 404].indexOf(response.statusCode) != -1) {
                    return;
                }
                else {
                    throw response;
                }
            }
            catch (error) {
                throw Error(('FailedToDeleteFolder' + physicalPath + this._getFormattedError(error)));
            }
        });
    }
    _getDeploymentDetailsFromPollURL(pollURL) {
        return __awaiter(this, void 0, void 0, function* () {
            let httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = pollURL;
            while (true) {
                let response = yield this._client.beginRequest(httpRequest);
                if (response.statusCode == 200 || response.statusCode == 202) {
                    var result = response.body;
                    console.debug(`POLL URL RESULT: ${JSON.stringify(result)}`);
                    if (result.status == exports.KUDU_DEPLOYMENT_CONSTANTS.SUCCESS || result.status == exports.KUDU_DEPLOYMENT_CONSTANTS.FAILED) {
                        return result;
                    }
                    else {
                        console.debug(`Deployment status: ${result.status} '${result.status_text}'. retry after 5 seconds`);
                        yield webClient.sleepFor(5);
                        continue;
                    }
                }
                else {
                    throw response;
                }
            }
        });
    }
    _getFormattedError(error) {
        if (error && error.statusCode) {
            return `${error.statusMessage} (CODE: ${error.statusCode})`;
        }
        else if (error && error.message) {
            if (error.statusCode) {
                error.message = `${typeof error.message.valueOf() == 'string' ? error.message : error.message.Code + " - " + error.message.Message} (CODE: ${error.statusCode})`;
            }
            return error.message;
        }
        return error;
    }
}
exports.Kudu = Kudu;
