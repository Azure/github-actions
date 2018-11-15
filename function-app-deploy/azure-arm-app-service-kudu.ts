import fs = require('fs');
import util = require('util');
import webClient = require('./webClient');
import Q = require('q');

export const KUDU_DEPLOYMENT_CONSTANTS = {
    SUCCESS: 4,
    FAILED: 3
}

export interface WebJob {
    name: string;
    status: string;
    runCommand: string;
    log_url: string;
    url: string;
    type: string;
}

export interface SiteExtension {
    id: string;
    title: string;
    description: string;
    extension_url: string;
    local_path: string;
    version: string;
    project_url: string;
    authors: Array<string>;
    provisioningState: string;
    local_is_latest_version: boolean;
}

export class KuduServiceManagementClient {
    private _scmUri;
    private _accesssToken: string;

    constructor(scmUri: string, accessToken: string) {
        this._accesssToken = accessToken;
        this._scmUri = scmUri;
    }

    public async beginRequest(request: webClient.WebRequest, reqOptions?: webClient.WebRequestOptions, contentType?: string): Promise<webClient.WebResponse> {
        request.headers = request.headers || {};
        request.headers["Authorization"] = "Basic " + this._accesssToken;
        request.headers['Content-Type'] = contentType || 'application/json; charset=utf-8';
        
        let retryCount = reqOptions && util.isNumber(reqOptions.retryCount) ? reqOptions.retryCount : 5;

        while(retryCount >= 0) {
            try {
                let httpResponse = await webClient.sendRequest(request, reqOptions);
                return httpResponse;
            }
            catch(exception) {
                let exceptionString: string = exception.toString();
                if(exceptionString.indexOf("Hostname/IP doesn't match certificates's altnames") != -1
                    || exceptionString.indexOf("unable to verify the first certificate") != -1
                    || exceptionString.indexOf("unable to get local issuer certificate") != -1) {
                        console.warn(('ASE_SSLIssueRecommendation'));
                }

                if(retryCount > 0 && exceptionString.indexOf('Request timeout') != -1 && (!reqOptions || reqOptions.retryRequestTimedout)) {
                    console.debug('encountered request timedout issue in Kudu. Retrying again');
                    retryCount -= 1;
                    continue;
                }

                throw new Error(exceptionString);
            }
        }

    }

    public getRequestUri(uriFormat: string, queryParameters?: Array<string>) {
        uriFormat = uriFormat[0] == "/" ? uriFormat : "/" + uriFormat;

        if(queryParameters && queryParameters.length > 0) {
            uriFormat = uriFormat + '?' + queryParameters.join('&');
        }

        return this._scmUri + uriFormat;
    }

    public getScmUri(): string {
        return this._scmUri;
    }
}

export class Kudu {
    private _client: KuduServiceManagementClient;

    constructor(scmUri: string, username: string, password: string) {
        var base64EncodedCredential = (new Buffer(username + ':' + password).toString('base64'));
        this._client = new KuduServiceManagementClient(scmUri, base64EncodedCredential);
    }

    public async updateDeployment(requestBody: any): Promise<string> {
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'PUT';
        httpRequest.body = JSON.stringify(requestBody);
        httpRequest.uri = this._client.getRequestUri(`/api/deployments/${requestBody.id}`);

        try {
            let webRequestOptions: webClient.WebRequestOptions = {retriableErrorCodes: [], retriableStatusCodes: [], retryCount: 1, retryIntervalInSeconds: 5, retryRequestTimedout: true};
            var response = await this._client.beginRequest(httpRequest, webRequestOptions);
            console.debug(`updateDeployment. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                console.log("Successfullyupdateddeploymenthistory " + response.body.url);
                return response.body.id;
            }

            throw response;
        }
        catch(error) {
            throw Error(('Failedtoupdatedeploymenthistory ' + this._getFormattedError(error)));
        }
    }


    public async getContinuousJobs(): Promise<Array<WebJob>> {
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = this._client.getRequestUri(`/api/continuouswebjobs`);
        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getContinuousJobs. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return response.body as Array<WebJob>;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToGetContinuousWebJobs ' + this._getFormattedError(error)))
        }
    }

    public async startContinuousWebJob(jobName: string): Promise<WebJob> {
        console.log(('StartingWebJob' + jobName));
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'POST';
        httpRequest.uri = this._client.getRequestUri(`/api/continuouswebjobs/${jobName}/start`);

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`startContinuousWebJob. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                console.log(('StartedWebJob' + jobName));
                return response.body as WebJob;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToStartContinuousWebJob' + jobName + this._getFormattedError(error)));
        }
    }

    public async stopContinuousWebJob(jobName: string): Promise<WebJob> {
        console.log(('StoppingWebJob' + jobName));
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'POST';
        httpRequest.uri = this._client.getRequestUri(`/api/continuouswebjobs/${jobName}/stop`);

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`stopContinuousWebJob. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                console.log(('StoppedWebJob' + jobName));
                return response.body as WebJob;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToStopContinuousWebJob' + jobName + this._getFormattedError(error)));
        }
    }

    public async installSiteExtension(extensionID: string): Promise<SiteExtension> {
        console.log(("InstallingSiteExtension" + extensionID));
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'PUT';
        httpRequest.uri = this._client.getRequestUri(`/api/siteextensions/${extensionID}`);
        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`installSiteExtension. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                console.log(("SiteExtensionInstalled" + extensionID));
                return response.body;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToInstallSiteExtension' + extensionID + this._getFormattedError(error)))
        }
    }

    public async getSiteExtensions(): Promise<Array<SiteExtension>> {
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = this._client.getRequestUri(`/api/siteextensions`, ['checkLatest=false']);
        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getSiteExtensions. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return response.body as Array<SiteExtension>;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToGetSiteExtensions' + this._getFormattedError(error)))
        }
    }

    public async getAllSiteExtensions(): Promise<Array<SiteExtension>> {
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = this._client.getRequestUri(`/api/extensionfeed`);
        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getAllSiteExtensions. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return response.body as Array<SiteExtension>;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToGetAllSiteExtensions' + this._getFormattedError(error)))
        }
    }

    public async getProcess(processID: number): Promise<any> {
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = this._client.getRequestUri(`/api/processes/${processID}`);
        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getProcess. status code: ${response.statusCode} - ${response.statusMessage}`);
            if(response.statusCode == 200) {
                return response.body;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToGetProcess' + this._getFormattedError(error)))
        }
    }

    public async killProcess(processID: number): Promise<void> {
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'DELETE';
        httpRequest.uri = this._client.getRequestUri(`/api/processes/${processID}`);
        var reqOptions: webClient.WebRequestOptions = {
            retriableErrorCodes: ["ETIMEDOUT"],
            retriableStatusCodes: [503],
            retryCount: 1,
            retryIntervalInSeconds: 5,
            retryRequestTimedout: true
        };
        try {
            var response = await this._client.beginRequest(httpRequest, reqOptions);
            console.debug(`killProcess. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 502) {
                console.debug(`Killed Process ${processID}`);
                return;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToKillProcess' + this._getFormattedError(error)))
        }
    }

    public async getAppSettings(): Promise<Map<string, string>> {
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = this._client.getRequestUri(`/api/settings`);

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getAppSettings. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return response.body;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToFetchKuduAppSettings' + this._getFormattedError(error)));
        }
    }

    public async listDir(physicalPath: string): Promise<void> {
        physicalPath = physicalPath.replace(/[\\]/g, "/");
        physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1): physicalPath;
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/`);
        httpRequest.headers = {
            'If-Match': '*'
        };

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`listFiles. Data: ${JSON.stringify(response)}`);
            if([200, 201, 204].indexOf(response.statusCode) != -1) {
                return response.body;
            }
            else if(response.statusCode === 404) {
                return null;
            }
            else {
                throw response;
            }
        }
        catch(error) {
            throw Error(('FailedToListPath' + physicalPath + this._getFormattedError(error)));
        }
    }

    public async getFileContent(physicalPath: string, fileName: string): Promise<string> {
        physicalPath = physicalPath.replace(/[\\]/g, "/");
        physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1): physicalPath;
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/${fileName}`);
        httpRequest.headers = {
            'If-Match': '*'
        };

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getFileContent. Status code: ${response.statusCode} - ${response.statusMessage}`);
            if([200, 201, 204].indexOf(response.statusCode) != -1) {
                return response.body;
            }
            else if(response.statusCode === 404) {
                return null;
            }
            else {
                throw response;
            }
        }
        catch(error) {
            throw Error(('FailedToGetFileContent' + physicalPath + fileName + this._getFormattedError(error)));
        }
    }

    public async uploadFile(physicalPath: string, fileName: string, filePath: string): Promise<void> {
        physicalPath = physicalPath.replace(/[\\]/g, "/");
        physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1): physicalPath;
        if(!fs.statSync(filePath)) {
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
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`uploadFile. Data: ${JSON.stringify(response)}`);
            if([200, 201, 204].indexOf(response.statusCode) != -1) {
                return response.body;
            }
            
            throw response;
        }
        catch(error) {
            throw Error(('FailedToUploadFile' + physicalPath + fileName + this._getFormattedError(error)));
        }
    }

    public async createPath(physicalPath: string): Promise<any> {
        physicalPath = physicalPath.replace(/[\\]/g, "/");
        physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1): physicalPath;
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'PUT';
        httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/`);
        httpRequest.headers = {
            'If-Match': '*'
        };

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`createPath. Data: ${JSON.stringify(response)}`);
            if([200, 201, 204].indexOf(response.statusCode) != -1) {
                return response.body;
            }
            
            throw response;
        }
        catch(error) {
            throw Error(('FailedToCreatePath' + physicalPath + this._getFormattedError(error)));
        }
    }

    public async runCommand(physicalPath: string, command: string): Promise<void> {
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
            let webRequestOptions: webClient.WebRequestOptions = {retriableErrorCodes: null, retriableStatusCodes: null, retryCount: 5, retryIntervalInSeconds: 5, retryRequestTimedout: false};
            var response = await this._client.beginRequest(httpRequest, webRequestOptions);
            console.debug(`runCommand. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return ;
            }
            else {
                throw response;
            }
        }
        catch(error) {
            throw Error(error.toString());
        }
    }

    public async extractZIP(webPackage: string, physicalPath: string): Promise<void> {
        physicalPath = physicalPath.replace(/[\\]/g, "/");
        physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1): physicalPath;
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'PUT';
        httpRequest.uri = this._client.getRequestUri(`/api/zip/${physicalPath}/`);
        httpRequest.headers = {
            'Content-Type': 'multipart/form-data ',
            'If-Match': '*'
        };
        httpRequest.body = fs.createReadStream(webPackage);

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`extractZIP. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return ;
            }
            else {
                throw response;
            }
        }
        catch(error) {
            throw Error(('Failedtodeploywebapppackageusingkuduservice' + this._getFormattedError(error)));
        }
    }

    public async zipDeploy(webPackage: string, queryParameters?: Array<string>): Promise<any> {
        let httpRequest = new webClient.WebRequest();
        httpRequest.method = 'POST';
        httpRequest.uri = this._client.getRequestUri(`/api/zipdeploy`, queryParameters);
        httpRequest.body = fs.createReadStream(webPackage);

        try {
            let response = await this._client.beginRequest(httpRequest, null, 'application/octet-stream');
            console.debug(`ZIP Deploy response: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                console.debug('Deployment passed');
                return null;
            }
            else if(response.statusCode == 202) {
                let pollableURL: string = response.headers.location;
                if(!!pollableURL) {
                    console.debug(`Polling for ZIP Deploy URL: ${pollableURL}`);
                    return await this._getDeploymentDetailsFromPollURL(pollableURL);
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
        catch(error) {
            throw new Error(('Zip Deploy failed. ' + this._getFormattedError(error)));
        }
    }

    public async warDeploy(webPackage: string, queryParameters?: Array<string>): Promise<any> {
        let httpRequest = new webClient.WebRequest();
        httpRequest.method = 'POST';
        httpRequest.uri = this._client.getRequestUri(`/api/wardeploy`, queryParameters);
        httpRequest.body = fs.createReadStream(webPackage);

        try {
            let response = await this._client.beginRequest(httpRequest);
            console.debug(`War Deploy response: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                console.debug('Deployment passed');
                return null;
            }
            else if(response.statusCode == 202) {
                let pollableURL: string = response.headers.location;
                if(!!pollableURL) {
                    console.debug(`Polling for War Deploy URL: ${pollableURL}`);
                    return await this._getDeploymentDetailsFromPollURL(pollableURL);
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
        catch(error) {
            throw new Error(('PackageDeploymentFailed' + this._getFormattedError(error)));
        }
    }


    public async getDeploymentDetails(deploymentID: string): Promise<any> {
        try {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = this._client.getRequestUri(`/api/deployments/${deploymentID}`); ;
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getDeploymentDetails. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return response.body;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToGetDeploymentLogs' + this._getFormattedError(error)))
        }
    }

    public async getDeploymentLogs(log_url: string): Promise<any> {
        try {
            var httpRequest = new webClient.WebRequest();
            httpRequest.method = 'GET';
            httpRequest.uri = log_url;
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`getDeploymentLogs. Data: ${JSON.stringify(response)}`);
            if(response.statusCode == 200) {
                return response.body;
            }

            throw response;
        }
        catch(error) {
            throw Error(('FailedToGetDeploymentLogs' + this._getFormattedError(error)))
        }
    }

    public async deleteFile(physicalPath: string, fileName: string): Promise<void> {
        physicalPath = physicalPath.replace(/[\\]/g, "/");
        physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1): physicalPath;
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'DELETE';
        httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}/${fileName}`);
        httpRequest.headers = {
            'If-Match': '*'
        };

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`deleteFile. Data: ${JSON.stringify(response)}`);
            if([200, 201, 204, 404].indexOf(response.statusCode) != -1) {
                return ;
            }
            else {
                throw response;
            }
        }
        catch(error) {
            throw Error(('FailedToDeleteFile' + physicalPath + fileName + this._getFormattedError(error)));
        }
    }

    public async deleteFolder(physicalPath: string): Promise<void> {
        physicalPath = physicalPath.replace(/[\\]/g, "/");
        physicalPath = physicalPath[0] == "/" ? physicalPath.slice(1): physicalPath;
        var httpRequest = new webClient.WebRequest();
        httpRequest.method = 'DELETE';
        httpRequest.uri = this._client.getRequestUri(`/api/vfs/${physicalPath}`);
        httpRequest.headers = {
            'If-Match': '*'
        };

        try {
            var response = await this._client.beginRequest(httpRequest);
            console.debug(`deleteFolder. Data: ${JSON.stringify(response)}`);
            if([200, 201, 204, 404].indexOf(response.statusCode) != -1) {
                return ;
            }
            else {
                throw response;
            }
        }
        catch(error) {
            throw Error(('FailedToDeleteFolder' +  physicalPath + this._getFormattedError(error)));
        }
    }

    private async _getDeploymentDetailsFromPollURL(pollURL: string):Promise<any> {
        let httpRequest = new webClient.WebRequest();
        httpRequest.method = 'GET';
        httpRequest.uri = pollURL;

        while(true) {
            let response = await this._client.beginRequest(httpRequest);
            if(response.statusCode == 200 || response.statusCode == 202) {
                var result = response.body;
                console.debug(`POLL URL RESULT: ${JSON.stringify(result)}`);
                if(result.status == KUDU_DEPLOYMENT_CONSTANTS.SUCCESS || result.status == KUDU_DEPLOYMENT_CONSTANTS.FAILED) {
                    return result;
                }
                else {
                    console.debug(`Deployment status: ${result.status} '${result.status_text}'. retry after 5 seconds`);
                    await webClient.sleepFor(5);
                    continue;
                }
            }
            else {
                throw response;
            }
        }
    }

    private _getFormattedError(error: any) {
        if(error && error.statusCode) {
            return `${error.statusMessage} (CODE: ${error.statusCode})`;
        }
        else if(error && error.message) {
            if(error.statusCode) {
                error.message = `${typeof error.message.valueOf() == 'string' ? error.message : error.message.Code + " - " + error.message.Message } (CODE: ${error.statusCode})`
            }

            return error.message;
        }

        return error;
    }
}
