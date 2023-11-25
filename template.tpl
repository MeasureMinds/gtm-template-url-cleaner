___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Cleaner of PII for Page URL by MeasureMinds",
  "categories": [
    "UTILITY"
  ],
  "description": "Delete PII from the URL and keep only whitelisted parameters. The template also provides utilities to lowercase parts of the URL, delete duplicate parameters, and control the maximum length of the URL.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "fullUrl",
    "displayName": "Full URL",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "alwaysInSummary": true
  },
  {
    "type": "GROUP",
    "name": "grpWhitelist",
    "displayName": "Parameter Whitelist",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "LABEL",
        "name": "infoWhitelist",
        "displayName": "Add whitelist parameters. All other parameters will be removed."
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "whitelistParams",
        "displayName": "Parameter Whitelist Table",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "",
            "name": "paramName",
            "type": "TEXT"
          },
          {
            "defaultValue": "none",
            "displayName": "Value Processing",
            "name": "valueFunction",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "none",
                "displayValue": "none"
              },
              {
                "value": "lower",
                "displayValue": "lower"
              }
            ]
          }
        ],
        "help": ""
      }
    ],
    "enablingConditions": []
  },
  {
    "type": "CHECKBOX",
    "name": "lowercaseHostname",
    "checkboxText": "Hostname To Lowercase",
    "simpleValueType": true,
    "defaultValue": true
  },
  {
    "type": "CHECKBOX",
    "name": "lowercasePathname",
    "checkboxText": "Pathname To Lowercase",
    "simpleValueType": true,
    "defaultValue": true
  },
  {
    "type": "CHECKBOX",
    "name": "lowercaseSearchParamsKeys",
    "checkboxText": "All SearchParams Keys To Lowercase",
    "simpleValueType": true,
    "help": "Check this option to change the result to lowercase characters. Note: modification happens before whitelisting and application of RegEx filters. This means that both functions will be case-insensitive.",
    "defaultValue": true
  },
  {
    "type": "CHECKBOX",
    "name": "lowercaseSearchParamsValues",
    "checkboxText": "All SearchParams Values To Lowercase",
    "simpleValueType": true,
    "help": "Check this option to change the result to lowercase characters. Note: modification happens before whitelisting and application of RegEx filters. This means that both functions will be case-insensitive.",
    "defaultValue": false
  },
  {
    "type": "TEXT",
    "name": "maxLen",
    "displayName": "Maximum URL Length",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      },
      {
        "type": "POSITIVE_NUMBER"
      }
    ],
    "defaultValue": 1000
  },
  {
    "type": "CHECKBOX",
    "name": "httpsConvert",
    "checkboxText": "Convert to HTTPS",
    "simpleValueType": true,
    "defaultValue": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

var Object = require("Object");
var parseUrl = require("parseUrl");
var getType = require("getType");
var log = require("logToConsole");

const cleanerFuncs = {
    none: (val) => val,
    lower: (val) => val.toLowerCase()
};

const compare = (a, b) => {
  if (a.priority < b.priority) {
    return -1;
  }
  if (a.priority > b.priority) {
    return 1;
  }
  return 0;
};

const joinMax = (cleanParams, maxLen) => {
  let result = "";
  const otherPriority = 100;

  const paramsPriority = {
    utm_id: 0,
    gclid: 0,
    gbraid: 0,
    wbraid: 0,
    utm_source: 1,
    utm_medium: 1,
    utm_campaign: 1,
    utm_term: 1,
    utm_content: 1,
    utm_query: 2,
    utm_marketing_tactic: 2,
    utm_creative_format: 2,
    utm_source_platform: 2,
    fbclid: 2,
    twclid: 2,
    ttclid: 2,
    li_fat_id: 2,
    ScClid: 2,
    msclkid: 2,
  };

  let cleanParamsWithPriorities = [];
  for (let index = 0; index < cleanParams.length; index++) {
    const param = cleanParams[index];
    const key = param.split("=")[0];
    const priority =
      Object.keys(paramsPriority).indexOf(key) > -1 ? paramsPriority[key] : otherPriority;
    cleanParamsWithPriorities.push({
      key: key,
      value: param,
      priority: priority,
    });
  }

  cleanParamsWithPriorities = cleanParamsWithPriorities.sort(compare);

  for (let index = 0; index < cleanParamsWithPriorities.length; index++) {
    const param = cleanParamsWithPriorities[index].value;
    const resultLength = result.length;
    const paramLenth = param.length;
    if (maxLen - (resultLength + paramLenth) > 0) {
      result += param + "&";
    } else break;
  }
  return result.slice(0, -1);
};

const lowerCaseByConfig = (value, toLower) => {
    return toLower ? value.toLowerCase() : value;
};

var testParams = data.whitelistParams; 

var inUrl = parseUrl(data.fullUrl);
let sp = inUrl.searchParams;


if  (getType(inUrl.hash)!=="undefined" ) {
    const hashUrl = "https://test.com?" + inUrl.hash.slice(1); // PP said check this line
    const hashUrlParsed = parseUrl(hashUrl);
    if ( getType(hashUrlParsed.searchParams)!=="undefined" ) {
        Object.keys(hashUrlParsed.searchParams).forEach((key) => {
            sp[key] = hashUrlParsed.searchParams[key];
        });
    }
}
if(Object.entries(sp).length === 0 && inUrl.search.length > 1){
  const search = inUrl.search.slice(1);
  const serchArr = search.split("&");

  sp = serchArr.reduce((accumulator, currentValue) => {
    const currentParam = currentValue.split('=');
    if(currentParam.length==2){
        accumulator[currentParam[0]] = currentParam[1];
    }
    return accumulator;
  },
  {});
}


var uniqueParams = {};
for ( var prm of Object.entries(sp) ) {
    var k = prm[0] || "";
    if(Object.entries(uniqueParams).indexOf(k)>-1) continue;
    var vl = (prm.length>1) ? getType(prm[1])==='array'?prm[1][0] : prm[1] : "";
    uniqueParams[k]=vl;
}
sp = uniqueParams;

var cleanParams = [];
for ( var prm of Object.entries(sp) ) {
    var k = prm[0] || "";
    var vl = (prm.length>1) ? prm[1] : "";
    if (vl==="") continue;
    vl = lowerCaseByConfig(vl, data.lowercaseSearchParamsValues);
    k = lowerCaseByConfig(k, data.lowercaseSearchParamsKeys);
    let keepParam = false;
    for (let index = 0; index < testParams.length; index++) {
        const testParam = testParams[index].paramName;
        keepParam = (testParam===k.toLowerCase());
        if (keepParam ) {
            const valueFunctionName = testParams[index].valueFunction;
            const cleanerFunc = cleanerFuncs[valueFunctionName];
            vl = cleanerFunc(vl);
            break;
        }
    }

    if (keepParam===true) {
        cleanParams.push(k +"="+ vl);
    }
}

let maxLen = data.maxLen;
var hst = inUrl.hostname;
var pth = inUrl.pathname;
var protocol = data.httpsConvert ? "https:" : inUrl.protocol;

maxLen = maxLen - pth.length;
maxLen = maxLen - (protocol +"//"+ hst + pth).length; // PP said check ":" returned

// var cleanQuery = cleanParams.join("&");
var cleanQuery = joinMax(cleanParams, maxLen);
if (cleanQuery.length>0) cleanQuery = "?" + cleanQuery;

if (data.lowercaseHostname) hst = hst.toLowerCase();
if (data.lowercasePathname) pth = pth.toLowerCase();
//if (data.lowercaseSearchParams) cleanQuery = cleanQuery.toLowerCase();

return protocol + "//" + hst + pth + cleanQuery; // PP said check ":" returned


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Whitelist, Full URL, lowercase
  code: |-
    mockData.whitelistParams = [{paramName: "utm_source","valueFunction":"none"}, {paramName: "utm_medium","valueFunction":"none"}];

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com/page.html?utm_medium=test&utm_source=check");
- name: Whitelist, Full URL with hash, lowercase
  code: |-
    mockData.fullUrl = "https://WWW.Example.com/Page.html?Gclid=Test&utm_source=check&fbclid=something&foo=bar&RANDOM=email@example.com#hash_key=Hash_Value";

    mockData.whitelistParams = [{paramName: "utm_source","valueFunction":"lower"}, {paramName: "gclid","valueFunction":"none"},{paramName: "hash_key","valueFunction":"lower"}];
    mockData.lowercaseHostname = true;
    mockData.lowercasePathname = true;
    mockData.lowercaseSearchParamsKeys = true;
    mockData.lowercaseSearchParamsValues = false;


    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com/page.html?gclid=Test&utm_source=check&hash_key=hash_value");
- name: Whitelist, Full URL with hash and exclamation mark, lowercase
  code: |-
    mockData.fullUrl = "https://WWW.Example.com/Page.html?Gclid=Test&utm_source=check&fbclid=something&foo=bar&RANDOM=email@example.com#!";

    mockData.whitelistParams = [{paramName: "utm_source","valueFunction":"lower"}, {paramName: "gclid","valueFunction":"none"},{paramName: "hash_key","valueFunction":"lower"}];
    mockData.lowercaseHostname = true;
    mockData.lowercasePathname = true;
    mockData.lowercaseSearchParamsKeys = true;
    mockData.lowercaseSearchParamsValues = false;


    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com/page.html?gclid=Test&utm_source=check");
- name: Whitelist lowercase pathname
  code: |-
    mockData.fullUrl = "https://online.test.co.uk/Originations/EIDConfirmationSuccess.aspx";

    mockData.whitelistParams = [{paramName: "utm_source","valueFunction":"lower"}, {paramName: "gclid","valueFunction":"none"},{paramName: "hash_key","valueFunction":"lower"}];
    mockData.lowercaseHostname = true;
    mockData.lowercasePathname = true;
    mockData.lowercaseSearchParamsKeys = true;
    mockData.lowercaseSearchParamsValues = false;


    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://online.test.co.uk/originations/eidconfirmationsuccess.aspx");
- name: Length lower max length
  code: |-
    mockData.fullUrl = "https://d123456789.com/?utm_source=u1";

    mockData.whitelistParams = [{"paramName":"utm_source","valueFunction":"none"}];
    mockData.listMethod = "whitelist";


    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://d123456789.com/?utm_source=u1");
- name: Length more than max length
  code: |-
    mockData.fullUrl = "https://d123456789.com/?utm_source=u1";

    mockData.whitelistParams = [{"paramName":"utm_source","valueFunction":"none"}];
    mockData.listMethod = "whitelist";
    mockData.maxLen = "30";

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://d123456789.com/");
- name: Length more than max length, only 1 param
  code: |-
    mockData.fullUrl = "https://d123456789.com/?utm_source=s1&utm_medium=m1";

    mockData.whitelistParams = [{"paramName":"utm_source","valueFunction":"none"},{"paramName":"utm_medium","valueFunction":"none"}];
    mockData.listMethod = "whitelist";
    mockData.maxLen = "41";

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://d123456789.com/?utm_source=s1");
- name: Convert to HTTPS
  code: |-
    mockData.fullUrl = "http://d123456789.com/?utm_source=u1";

    mockData.whitelistParams = [{"paramName":"utm_source","valueFunction":"none"}];
    mockData.listMethod = "whitelist";
    mockData.httpsConvert = true;

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://d123456789.com/?utm_source=u1");
- name: Change params order based on priority
  code: |-
    mockData.fullUrl = "https://d123456789.com/?test=1&utm_source=u1&gclid=g1";

    mockData.whitelistParams = [{"paramName":"utm_source","valueFunction":"none"},{"paramName":"gclid","valueFunction":"none"},{"paramName":"test","valueFunction":"none"},];
    mockData.listMethod = "whitelist";


    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://d123456789.com/?gclid=g1&utm_source=u1&test=1");
- name: Delete params based on priority
  code: |-
    mockData.fullUrl = "https://d123456789.com/?test=1&utm_source=u1&gclid=g1";

    mockData.whitelistParams = [{"paramName":"utm_source","valueFunction":"none"},{"paramName":"gclid","valueFunction":"none"},{"paramName":"test","valueFunction":"none"},];
    mockData.listMethod = "whitelist";
    mockData.maxLen = "35";

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://d123456789.com/?gclid=g1");
- name: WhiteList double params
  code: |-
    mockData.fullUrl = "https://www.example.com/page.html?utm_medium=test&utm_source=check1&utm_source=check2";

    mockData.whitelistParams = [{paramName: "utm_source","valueFunction":"none"}, {paramName: "utm_medium","valueFunction":"none"}];

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("https://www.example.com/page.html?utm_medium=test&utm_source=check1");
setup: |-
  let mockData = {
    fullUrl: "https://WWW.example.com/page.html?utm_medium=test&utm_source=check&fbclid=something&foo=bar&RANDOM=email@example.com",
    maxLen: "500"

  };


___NOTES___

Created on 4.5.2022, 21:23:46


