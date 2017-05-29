cordova.define("ios-barcode-plugin.BarcodeScanner", function(require, exports, module) {
var exec = cordova.require("cordova/exec"),
    scanInProgress = false;

function BarcodeScanner() {
    this.Encode = {
        TEXT_TYPE: "TEXT_TYPE",
        EMAIL_TYPE: "EMAIL_TYPE",
        PHONE_TYPE: "PHONE_TYPE",
        SMS_TYPE: "SMS_TYPE"
    };
    this.format = {
        "all_1D": 61918,
        "aztec": 1,
        "codabar": 2,
        "code_128": 16,
        "code_39": 4,
        "code_93": 8,
        "data_MATRIX": 32,
        "ean_13": 128,
        "ean_8": 64,
        "itf": 256,
        "maxicode": 512,
        "msi": 131072,
        "pdf_417": 1024,
        "plessey": 262144,
        "qr_CODE": 2048,
        "rss_14": 4096,
        "rss_EXPANDED": 8192,
        "upc_A": 16384,
        "upc_E": 32768,
        "upc_EAN_EXTENSION": 65536
    };
}
BarcodeScanner.prototype.scan = function (successCallback, errorCallback, config) {
    if (config instanceof Array) {

    } else {
        if (typeof(config) === 'object') {
            config = [config];
        } else {
            config = [];
        }
    }
    if (errorCallback == null) {
        errorCallback = function () {
        };
    }
    if (typeof errorCallback != "function") {
        console.log("BarcodeScanner.scan failure: failure parameter not a function");
        return;
    }
    if (typeof successCallback != "function") {
        console.log("BarcodeScanner.scan failure: success callback parameter must be a function");
        return;
    }

    if (scanInProgress) {
        errorCallback('Scan is already in progress');
        return;
    }
    scanInProgress = true;
    exec(
        function (result) {
            scanInProgress = false;
            successCallback(result);
        },
        function (error) {
            scanInProgress = false;
            errorCallback(error);
        },
        'BarcodeScanner',
        'scan',
        config
    );
};

var barcodeScanner = new BarcodeScanner();
module.exports = barcodeScanner;
});
